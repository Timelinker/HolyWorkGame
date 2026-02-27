# 基本游戏逻辑脚本
extends Control

# 属性系统单例（通过AutoLoad自动加载）
var pa = null

# 时间系统变量
var year = 2020
var month = 1
var day = 1
var elapsed_seconds = 0.0
var seconds_per_day = 1.0  # 现实1秒 = 游戏1天
var is_time_paused = false  # 时间暂停标志

func _ready():
	# 获取属性系统单例
	pa = get_node("/root/player_attributes")
	# 初始化UI显示
	update_ui()
	
	# 绑定工作按钮点击事件
	if $WorkButton:
		$WorkButton.pressed.connect(_on_work_button_clicked)
	
	# 连接属性变化信号
	_connect_attributes_signals()

func _connect_attributes_signals():
	# 只连接实际存在的信号
	if pa:
		pa.money_changed.connect(_on_money_changed)
		pa.stamina_changed.connect(_on_stamina_changed)
		pa.job_level_changed.connect(_on_job_level_changed)

func _process(delta):
	# 只有当时间未暂停时，才更新时间系统
	if not is_time_paused:
		# 更新流逝的秒数
		elapsed_seconds += delta
		
		# 检查是否过了一天
		if elapsed_seconds >= seconds_per_day:
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
	
	# 通知属性系统天数变化
	if pa:
		pa.process_day_passed()
	
	# 更新UI显示
	_update_time_display()

# 更新UI显示
func update_ui():
	# 检查pa是否存在
	if not pa:
		return
	
	# 更新体力显示
	if $VBoxContainer/TopRow/StaminaText:
		$VBoxContainer/TopRow/StaminaText.text = "体力值：%d" % pa.get_stamina()
	
	# 更新金钱显示
	if $MoneyText:
		$MoneyText.text = "金钱数：%d" % pa.get_money()
	
	# 更新年龄显示
	if $VBoxContainer/TopRow/AgeText:
		$VBoxContainer/TopRow/AgeText.text = "年龄：%d岁" % pa.get_age()
	
	# 更新时间显示
	_update_time_display()

# 更新时间显示
func _update_time_display():
	if $VBoxContainer/TopRow/TimeText:
		$VBoxContainer/TopRow/TimeText.text = "时间：%d年%d月%d日" % [year, month, day]

# 点击工作按钮的核心逻辑
func _on_work_button_clicked():
	# 检查pa是否存在
	if not pa:
		return
	
	# 使用属性系统的work方法
	var success = pa.work()
	
	if not success:
		# 体力不足时的提示
		print("体力不足，无法工作！")
	
	# 无论成功与否，都更新UI
	update_ui()

# 属性变化信号处理

# 金钱变化
func _on_money_changed(new_value):
	if $MoneyText:
		$MoneyText.text = "金钱数：%d" % new_value

# 体力变化
func _on_stamina_changed(new_value):
	if $VBoxContainer/TopRow/StaminaText:
		$VBoxContainer/TopRow/StaminaText.text = "体力值：%d" % new_value

# 职级变化
func _on_job_level_changed(new_value):
	# 更新所有相关UI元素
	update_ui()
	print("职级变化：%d" % new_value)
