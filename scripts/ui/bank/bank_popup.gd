# 银行弹窗脚本
# 处理贷款和还款逻辑
extends Panel

# 信号定义
signal close_pressed

# 属性系统单例（通过AutoLoad自动加载）
var player_attributes = null

# 贷款档位数据
var loan_options = [
	{"amount": 500000, "term": 365, "rate": 0.048, "daily_interest": 0},
	{"amount": 1000000, "term": 1095, "rate": 0.042, "daily_interest": 0},
	{"amount": 3000000, "term": 1825, "rate": 0.035, "daily_interest": 0}
]

# 重写_ready方法，确保它被调用
func _ready():
	print("银行弹窗 _ready 方法被调用")
	
	# 尝试获取属性系统单例
	player_attributes = get_node_or_null("/root/player_attributes")
	print("获取player_attributes：", player_attributes)
	
	# 如果获取失败，尝试其他方式
	if not player_attributes:
		print("尝试通过场景树获取player_attributes")
		player_attributes = get_tree().root.get_node_or_null("player_attributes")
		print("通过场景树获取player_attributes：", player_attributes)
	
	# 计算每日利息
	for option in loan_options:
		option["daily_interest"] = option["amount"] * option["rate"] / 365
		print("贷款档位每日利息：", option["daily_interest"])
	
	# 绑定按钮点击事件 - 使用直接路径
	print("开始绑定按钮点击事件")
	
	# 绑定贷款1按钮
	var loan1_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption1/Loan1Button
	if loan1_button:
		loan1_button.pressed.connect(func(): _on_loan_button_pressed(0))
		print("绑定Loan1Button点击事件成功")
	else:
		print("无法找到Loan1Button")
	
	# 绑定贷款2按钮
	var loan2_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption2/Loan2Button
	if loan2_button:
		loan2_button.pressed.connect(func(): _on_loan_button_pressed(1))
		print("绑定Loan2Button点击事件成功")
	else:
		print("无法找到Loan2Button")
	
	# 绑定贷款3按钮
	var loan3_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption3/Loan3Button
	if loan3_button:
		loan3_button.pressed.connect(func(): _on_loan_button_pressed(2))
		print("绑定Loan3Button点击事件成功")
	else:
		print("无法找到Loan3Button")
	
	# 绑定关闭按钮
	var close_button = $VBoxContainer/Footer/CloseButton
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
		print("绑定CloseButton点击事件成功")
	else:
		print("无法找到CloseButton")
	
	print("银行弹窗初始化完成")
	
	# 测试按钮绑定
	_test_button_binding()



# 显示弹窗
func show_popup():
	visible = true

# 隐藏弹窗
func hide_popup():
	visible = false
	
	# 发出关闭信号
	close_pressed.emit()

# 贷款按钮点击事件
func _on_loan_button_pressed(option_index: int):
	print("选择贷款档位：", option_index)
	
	# 检查option_index是否有效
	if option_index < 0 or option_index >= loan_options.size():
		print("错误：无效的贷款档位索引：", option_index)
		return
	
	# 尝试获取属性系统单例
	if not player_attributes:
		print("错误：player_attributes不存在")
		# 尝试重新获取
		player_attributes = get_node_or_null("/root/player_attributes")
		if not player_attributes:
			print("尝试通过场景树获取player_attributes")
			player_attributes = get_tree().root.get_node_or_null("player_attributes")
			if not player_attributes:
				print("错误：无法获取player_attributes")
				# 直接关闭弹窗
				print("尝试直接关闭弹窗")
				visible = false
				# 发出关闭信号
				close_pressed.emit()
				print("弹窗已关闭")
				return
	
	# 获取贷款选项
	var loan_option = loan_options[option_index]
	var loan_amount = loan_option["amount"]
	var daily_interest = loan_option["daily_interest"]
	
	print("贷款金额：", loan_amount)
	print("每日利息：", daily_interest)
	
	# 记录贷款前的金钱
	var before_money = player_attributes.get_money()
	print("贷款前金钱：", before_money)
	
	# 尝试增加金钱总数
	print("尝试增加金钱总数")
	player_attributes.add_money(loan_amount)
	
	# 再次获取金钱，确认是否增加成功
	var after_money = player_attributes.get_money()
	print("贷款后金钱：", after_money)
	
	# 检查金钱是否增加成功
	if after_money != before_money + loan_amount:
		print("警告：金钱增加失败，预期：", before_money + loan_amount, "，实际：", after_money)
		# 尝试直接设置金钱
		print("尝试直接设置金钱")
		player_attributes.set_money(before_money + loan_amount)
		after_money = player_attributes.get_money()
		print("再次尝试后金钱：", after_money)
	
	# 尝试更新贷款总金额
	if player_attributes.has_method("set_loan_amount"):
		print("尝试更新贷款总金额")
		var before_loan = player_attributes.get_loan_amount()
		player_attributes.set_loan_amount(before_loan + loan_amount)
		var after_loan = player_attributes.get_loan_amount()
		print("贷款前总金额：", before_loan, "，贷款后总金额：", after_loan)
	else:
		print("错误：player_attributes没有set_loan_amount方法")
	
	# 尝试将每日利息加到每日消耗上
	if player_attributes.has_method("add_loan_interest"):
		print("尝试添加贷款利息到每日消耗")
		player_attributes.add_loan_interest(daily_interest)
		print("成功添加贷款利息到每日消耗")
	else:
		print("错误：player_attributes没有add_loan_interest方法")
	
	# 尝试通过场景树获取主界面并更新UI
	var root = get_tree().root
	if root:
		var main_interface = root.get_node_or_null("mainScene")
		if main_interface and main_interface.has_method("update_ui"):
			print("尝试通过场景树获取主界面并更新UI")
			main_interface.update_ui()
			print("通过场景树获取主界面并更新UI成功")
	
	# 尝试关闭弹窗
	print("尝试关闭弹窗")
	# 直接设置visible = false
	visible = false
	# 发出close_pressed信号
	close_pressed.emit()
	print("弹窗已关闭")

# 关闭按钮点击事件
func _on_close_button_pressed():
	print("点击关闭按钮")
	# 直接关闭弹窗
	print("准备关闭弹窗")
	
	# 尝试直接设置visible = false
	visible = false
	print("设置visible = false成功")
	
	# 尝试发出close_pressed信号
	close_pressed.emit()
	print("发出close_pressed信号成功")
	
	print("弹窗已关闭")
	
	# 尝试通过场景树获取主界面并更新UI
	var root = get_tree().root
	if root:
		var main_interface = root.get_node_or_null("mainScene")
		if main_interface and main_interface.has_method("update_ui"):
			print("尝试通过场景树获取主界面并更新UI")
			main_interface.update_ui()
			print("通过场景树获取主界面并更新UI成功")

# 当弹窗可见性变化时
func _on_visibility_changed():
	if visible:
		print("银行弹窗显示")
	else:
		print("银行弹窗隐藏")

# 测试按钮绑定
func _test_button_binding():
	print("开始测试按钮绑定")
	
	# 测试贷款1按钮
	var loan1_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption1/Loan1Button
	if loan1_button:
		print("Loan1Button 存在: ", loan1_button)
		print("Loan1Button 类型: ", loan1_button.get_class())
	else:
		print("Loan1Button 不存在")
	
	# 测试贷款2按钮
	var loan2_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption2/Loan2Button
	if loan2_button:
		print("Loan2Button 存在: ", loan2_button)
		print("Loan2Button 类型: ", loan2_button.get_class())
	else:
		print("Loan2Button 不存在")
	
	# 测试贷款3按钮
	var loan3_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption3/Loan3Button
	if loan3_button:
		print("Loan3Button 存在: ", loan3_button)
		print("Loan3Button 类型: ", loan3_button.get_class())
	else:
		print("Loan3Button 不存在")
	
	# 测试关闭按钮
	var close_button = $VBoxContainer/Footer/CloseButton
	if close_button:
		print("CloseButton 存在: ", close_button)
		print("CloseButton 类型: ", close_button.get_class())
	else:
		print("CloseButton 不存在")
	
	print("按钮绑定测试完成")
