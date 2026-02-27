# 银行弹窗脚本
extends Panel

signal close_pressed

func _ready():
	print("BankPopup _ready")
	
	# 绑定关闭按钮
	var close_button = $VBoxContainer/Footer/CloseButton
	if close_button:
		close_button.pressed.connect(_on_close)
		print("Bound close button")
	
	# 绑定贷款1按钮
	var loan1_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption1/Loan1Button
	if loan1_button:
		loan1_button.pressed.connect(_on_loan_1)
		print("Bound loan 1 button")
	
	# 绑定贷款2按钮
	var loan2_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption2/Loan2Button
	if loan2_button:
		loan2_button.pressed.connect(_on_loan_2)
		print("Bound loan 2 button")
	
	# 绑定贷款3按钮
	var loan3_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption3/Loan3Button
	if loan3_button:
		loan3_button.pressed.connect(_on_loan_3)
		print("Bound loan 3 button")

func _on_loan_1():
	print("Loan 1 selected")
	
	# 执行50W贷款操作
	var player_attributes = get_node_or_null("/root/player_attributes")
	if player_attributes:
		# 增加金钱
		player_attributes.add_money(500000)
		print("增加金钱500000")
		
		# 计算每日还款金额
		var daily_repayment = 500000.0 * 1.048 / 365.0
		
		# 增加每日消耗
		player_attributes.add_loan_interest(daily_repayment)
		print("增加每日消耗:", daily_repayment)
		
		# 增加每日还款金额
		player_attributes.add_daily_repayment(daily_repayment)
		print("增加每日还款:", daily_repayment)
		
		# 更新贷款金额
		var current_loan = player_attributes.get_loan_amount()
		player_attributes.set_loan_amount(current_loan + 500000)
		print("更新贷款金额:", current_loan + 500000)
	
	# 禁用贷款1按钮，使其不可再次点击
	var loan1_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption1/Loan1Button
	if loan1_button:
		loan1_button.disabled = true
		loan1_button.text = "已选择"
		print("禁用贷款1按钮")
	
	# 关闭弹窗
	visible = false
	close_pressed.emit()

func _on_loan_2():
	print("Loan 2 selected")
	
	# 执行100W贷款操作
	var player_attributes = get_node_or_null("/root/player_attributes")
	if player_attributes:
		# 增加金钱
		player_attributes.add_money(1000000)
		print("增加金钱1000000")
		
		# 计算每日还款金额
		var total_amount = 1000000.0 * pow(1.0 + 0.042, 3)
		var daily_repayment = total_amount / (365.0 * 3)
		
		# 增加每日消耗
		player_attributes.add_loan_interest(daily_repayment)
		print("增加每日消耗:", daily_repayment)
		
		# 增加每日还款金额
		player_attributes.add_daily_repayment(daily_repayment)
		print("增加每日还款:", daily_repayment)
		
		# 更新贷款金额
		var current_loan = player_attributes.get_loan_amount()
		player_attributes.set_loan_amount(current_loan + 1000000)
		print("更新贷款金额:", current_loan + 1000000)
	
	# 禁用贷款2按钮，使其不可再次点击
	var loan2_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption2/Loan2Button
	if loan2_button:
		loan2_button.disabled = true
		loan2_button.text = "已选择"
		print("禁用贷款2按钮")
	
	# 关闭弹窗
	visible = false
	close_pressed.emit()

func _on_loan_3():
	print("Loan 3 selected")
	
	# 执行300W贷款操作
	var player_attributes = get_node_or_null("/root/player_attributes")
	if player_attributes:
		# 增加金钱
		player_attributes.add_money(3000000)
		print("增加金钱3000000")
		
		# 计算每日还款金额
		var total_amount = 3000000.0 * pow(1.035, 5)
		var daily_repayment = total_amount / (365.0 * 5)
		
		# 增加每日消耗
		player_attributes.add_loan_interest(daily_repayment)
		print("增加每日消耗:", daily_repayment)
		
		# 增加每日还款金额
		player_attributes.add_daily_repayment(daily_repayment)
		print("增加每日还款:", daily_repayment)
		
		# 更新贷款金额
		var current_loan = player_attributes.get_loan_amount()
		player_attributes.set_loan_amount(current_loan + 3000000)
		print("更新贷款金额:", current_loan + 3000000)
	
	# 禁用贷款3按钮，使其不可再次点击
	var loan3_button = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption3/Loan3Button
	if loan3_button:
		loan3_button.disabled = true
		loan3_button.text = "已选择"
		print("禁用贷款3按钮")
	
	# 关闭弹窗
	visible = false
	close_pressed.emit()

func _on_close():
	print("Close button pressed")
	
	# 关闭弹窗
	visible = false
	close_pressed.emit()
