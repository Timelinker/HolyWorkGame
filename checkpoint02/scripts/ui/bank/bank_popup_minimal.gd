# 最小化的银行弹窗脚本
extends Panel

signal close_pressed

func _ready():
	print("BankPopup minimal _ready")
	
	# 绑定关闭按钮
	var close_button = $VBoxContainer/Footer/CloseButton
	if close_button:
		close_button.pressed.connect(_on_close)
		print("Bound close button")
	
	# 绑定贷款按钮
	var loan1 = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption1/Loan1Button
	var loan2 = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption2/Loan2Button
	var loan3 = $VBoxContainer/TabContainer/LoanTab/LoanOptions/LoanOption3/Loan3Button
	
	if loan1:
		loan1.pressed.connect(func(): _on_loan(500000))
		print("Bound loan 1 button")
	
	if loan2:
		loan2.pressed.connect(func(): _on_loan(1000000))
		print("Bound loan 2 button")
	
	if loan3:
		loan3.pressed.connect(func(): _on_loan(3000000))
		print("Bound loan 3 button")

func _on_loan(amount):
	print("Loan selected:", amount)
	
	# 简单的测试输出
	print("Would add money:", amount)
	
	# 关闭弹窗
	visible = false
	close_pressed.emit()

func _on_close():
	print("Close button pressed")
	visible = false
	close_pressed.emit()
