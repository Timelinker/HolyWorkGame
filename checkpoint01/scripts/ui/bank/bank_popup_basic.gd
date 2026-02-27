# 银行弹窗脚本
extends Panel

signal close_pressed

func _ready():
	print("BankPopup _ready")
	
	# 绑定关闭按钮
	if has_node("VBoxContainer/Footer/CloseButton"):
		$VBoxContainer/Footer/CloseButton.pressed.connect(_on_close)
		print("Bound close button")
	
	# 绑定贷款1按钮
	if has_node("VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption1/Loan1Button"):
		$VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption1/Loan1Button.pressed.connect(_on_loan_1)
		print("Bound loan 1 button")
	
	# 绑定贷款2按钮
	if has_node("VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption2/Loan2Button"):
		$VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption2/Loan2Button.pressed.connect(_on_loan_2)
		print("Bound loan 2 button")
	
	# 绑定贷款3按钮
	if has_node("VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption3/Loan3Button"):
		$VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption3/Loan3Button.pressed.connect(_on_loan_3)
		print("Bound loan 3 button")

func _on_loan_1():
	print("Loan 1 selected")
	_process_loan(500000)

func _on_loan_2():
	print("Loan 2 selected")
	_process_loan(1000000)

func _on_loan_3():
	print("Loan 3 selected")
	_process_loan(3000000)

func _process_loan(amount):
	# 获取属性系统
	var player_attributes = get_node_or_null("/root/player_attributes")
	if player_attributes:
		# 增加金钱
		player_attributes.add_money(amount)
		print("Money added:", amount)
	
	# 关闭弹窗
	visible = false
	close_pressed.emit()

func _on_close():
	print("Close button pressed")
	visible = false
	close_pressed.emit()
