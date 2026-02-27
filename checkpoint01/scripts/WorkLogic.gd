# 核心工作逻辑脚本 - 集成属性系统
extends Control

# 属性系统单例（通过AutoLoad自动加载）
var pa = null

# 通知弹窗引用
var notification_popup = null

# 银行弹窗引用
var bank_popup = null

# 时间系统变量 - Year/Month/Day层级
var year = 2020
var month = 1
var day = 1
var elapsed_seconds = 0.0
var seconds_per_day = 1.0  # 现实1秒 = 游戏1天（加快时间流转速度）
var is_time_paused = false  # 时间暂停标志

func _ready():
	print("WorkLogic: 实例化，节点路径：", get_path())
	# 获取属性系统单例
	pa = get_node_or_null("/root/player_attributes")
	if pa:
		print("成功获取属性系统单例")
	else:
		print("无法获取属性系统单例")
	
	# 获取通知弹窗节点
	if has_node("SafeArea2D/NotificationPopup"):
		notification_popup = get_node("SafeArea2D/NotificationPopup")
	
	# 获取银行弹窗节点
	if has_node("SafeArea2D/BankPopup"):
		bank_popup = get_node("SafeArea2D/BankPopup")
	
	# 初始化UI显示
	update_ui()
	
	# 绑定工作按钮点击事件
	if $SafeArea2D/WorkButton:
		$SafeArea2D/WorkButton.pressed.connect(_on_work_button_clicked)
	
	# 绑定商城按钮点击事件
	if $SafeArea2D/ShopButton:
		$SafeArea2D/ShopButton.pressed.connect(_on_shop_button_clicked)
	
	# 绑定银行按钮点击事件
	if $SafeArea2D/BankButton:
		$SafeArea2D/BankButton.pressed.connect(_on_bank_button_clicked)
	
	# 连接属性变化信号
	_connect_attributes_signals()
	
	# 连接商城相关信号
	_connect_shop_signals()
	
	# 连接银行相关信号
	_connect_bank_signals()

func _connect_attributes_signals():
	# 只连接实际存在的信号
	if pa:
		pa.money_changed.connect(_on_money_changed)
		pa.stamina_changed.connect(_on_stamina_changed)
		pa.job_level_changed.connect(_on_job_level_changed)

func _connect_shop_signals():
	# 连接商城管理器的购买信号
	if $ShopManager:
		$ShopManager.purchase_success.connect(_on_purchase_success)
		$ShopManager.purchase_failed.connect(_on_purchase_failed)

	# 连接商城弹窗的关闭信号
	if $SafeArea2D/ShopPopup:
		$SafeArea2D/ShopPopup.close_pressed.connect(_on_shop_close_pressed)

func _connect_bank_signals():
	# 连接银行弹窗的关闭信号
	if $SafeArea2D/BankPopup:
		var bank_popup = $SafeArea2D/BankPopup
		# 检查银行弹窗是否有close_pressed信号
		if bank_popup and bank_popup.has_signal("close_pressed"):
			bank_popup.close_pressed.connect(_on_bank_close_pressed)
			print("成功连接银行弹窗的close_pressed信号")
		else:
			print("警告：银行弹窗没有close_pressed信号")



func _process(delta):
	# 只有当时间未暂停时，才更新时间系统
	if not is_time_paused:
		# 更新流逝的秒数
		elapsed_seconds += delta
		
		# 检查是否过了一天
		while elapsed_seconds >= seconds_per_day:
			elapsed_seconds -= seconds_per_day
			increment_day()

# 增加一天的逻辑
func increment_day():
	# 更新日期
	day += 1
	
	# 检查月份进位（每月30天）
	if day > 30:
		day = 1
		month += 1
		
		# 检查年份进位
		if month > 12:
			month = 1
			year += 1
		# 通知属性系统年份变化
		if pa:
			pa.increase_year()
	
	# 通知属性系统天数变化，传入当前的day值
	if pa:
		print("WorkLogic: 调用process_day_passed()，当前游戏天数：", day)
		pa.process_day_passed(day)
		# 处理每日消耗（包括贷款利息）
		if pa.has_method("process_daily_consumption"):
			pa.process_daily_consumption()
	
	# 更新UI显示
	_update_time_display()
	update_ui()

# 更新UI显示
func update_ui():
	# 检查pa是否存在
	if not pa:
		return
	
	# 更新体力显示
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow1/StaminaText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow1/StaminaText.text = "体力值：%d" % pa.get_stamina()
	
	# 更新金钱显示
	if $SafeArea2D/MoneyText:
		$SafeArea2D/MoneyText.text = "金钱数：%d" % pa.get_money()
	
	# 更新年龄显示
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow1/AgeText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow1/AgeText.text = "年龄：%d岁" % pa.get_age()
	
	# 更新职级显示
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow2/JobLevelText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow2/JobLevelText.text = "职级：%s" % pa.get_job_title()
	
	# 更新薪资显示
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow2/SalaryText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow2/SalaryText.text = "薪资：%d" % pa.get_salary()
	
	# 更新经验值显示
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow2/ExpText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow2/ExpText.text = "经验：%d/%d" % [pa.get_exp(), pa.get_exp_max()]
	
	# 更新每日消耗显示
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow2/DailyConsumptionText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow2/DailyConsumptionText.text = "每日消耗：%d" % pa.get_daily_consumption()
	
	# 更新每日还款显示
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow2/DailyRepaymentText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow2/DailyRepaymentText.text = "每日还款：%d" % int(pa.get_daily_repayment())
	
	# 更新时间显示
	_update_time_display()

# 更新时间显示
func _update_time_display():
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow1/TimeText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow1/TimeText.text = "时间：%d年%d月%d日" % [year, month, day]

# 点击工作按钮的核心逻辑
func _on_work_button_clicked():
	# 检查pa是否存在
	if not pa:
		return
	
	# 记录工作前的状态
	var before_money = pa.get_money()
	var before_stamina = pa.get_stamina()
	
	# 使用属性系统的work方法
	var success = pa.work()
	
	if success:
		# 计算变化量
		var money_change = pa.get_money() - before_money
		var stamina_change = pa.get_stamina() - before_stamina
		
		# 显示通知
		if notification_popup and notification_popup.has_method("show_stat_change"):
			notification_popup.show_stat_change(money_change, stamina_change)
	
	if not success:
		# 体力不足时的提示
		if $SafeArea2D/VBoxContainer/TopInfo/TopRow1/StaminaText:
			$SafeArea2D/VBoxContainer/TopInfo/TopRow1/StaminaText.text = "体力值：%d（体力不足！）" % pa.get_stamina()
	
	# 无论成功与否，都更新UI
	update_ui()

# 属性变化信号处理

# 金钱变化
func _on_money_changed(new_value):
	if $SafeArea2D/MoneyText:
		$SafeArea2D/MoneyText.text = "金钱数：%d" % new_value

# 体力变化
func _on_stamina_changed(new_value):
	if $SafeArea2D/VBoxContainer/TopInfo/TopRow1/StaminaText:
		$SafeArea2D/VBoxContainer/TopInfo/TopRow1/StaminaText.text = "体力值：%d" % new_value

# 职级变化
func _on_job_level_changed(new_value):
	# 更新所有相关UI元素
	update_ui()
	print("职级变化：%d" % new_value)

# 商城按钮点击事件处理
func _on_shop_button_clicked():
	# 显示商城弹窗
	if $SafeArea2D/ShopPopup:
		$SafeArea2D/ShopPopup.visible = true
		# 初始化商城弹窗的商品列表
		if $SafeArea2D/ShopPopup.has_method("init_shop_items"):
			$SafeArea2D/ShopPopup.init_shop_items()
		# 暂停时间系统
		is_time_paused = true

# 商城关闭事件处理
func _on_shop_close_pressed():
	# 隐藏商城弹窗
	if $SafeArea2D/ShopPopup:
		$SafeArea2D/ShopPopup.visible = false
		# 恢复时间系统
		is_time_paused = false

# 银行按钮点击事件处理
func _on_bank_button_clicked():
	# 显示银行弹窗
	if $SafeArea2D/BankPopup:
		$SafeArea2D/BankPopup.visible = true
		# 暂停时间系统
		is_time_paused = true

# 银行关闭事件处理
func _on_bank_close_pressed():
	# 隐藏银行弹窗
	if $SafeArea2D/BankPopup:
		$SafeArea2D/BankPopup.visible = false
		# 恢复时间系统
		is_time_paused = false

# 购买成功事件处理
func _on_purchase_success(item_id: String, item_name: String):
	# 可以在这里添加购买成功的提示
	print("购买成功：%s" % item_name)
	# 更新UI
	update_ui()

# 购买失败事件处理
func _on_purchase_failed(item_id: String, reason: String):
	# 可以在这里添加购买失败的提示
	print("购买失败：%s，原因：%s" % [item_id, reason])

# 显示通知方法
func show_notification(message: String):
	print("显示通知：", message)
	# 在底部面板显示通知
	if $SafeArea2D/MoneyText:
		$SafeArea2D/MoneyText.text = message
		# 3秒后恢复金钱显示
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 3.0
		timer.one_shot = true
		timer.timeout.connect(func():
			if pa:
				$SafeArea2D/MoneyText.text = "金钱数：%d" % pa.get_money()
			timer.queue_free()
		)
		timer.start()
