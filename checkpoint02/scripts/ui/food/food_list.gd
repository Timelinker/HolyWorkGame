# 食物列表脚本
# 处理食物购买逻辑
extends Panel

# 信号定义
signal close_pressed

# 属性系统单例（通过AutoLoad自动加载）
var player_attributes = null

# 通知弹窗引用
var notification_popup = null

var buy_button1 = null
var buy_button2 = null
var buy_button3 = null

# 食物数据
var food_items = [
	{"name": "浏阳蒸菜", "stamina": 25, "price": 15},
	{"name": "789外卖", "stamina": 50, "price": 30},
	{"name": "日料", "stamina": 100, "price": 50}
]

func _ready():
	# 获取属性系统单例
	player_attributes = get_node("/root/player_attributes")
	
	# 获取通知弹窗节点（通过父节点）
	var parent = get_parent()
	if parent and parent.has_node("NotificationPopup"):
		notification_popup = parent.get_node("NotificationPopup")
	
	# 获取按钮节点
	buy_button1 = get_node_or_null("VBoxContainer/FoodItems/FoodItem1/BuyButton1")
	buy_button2 = get_node_or_null("VBoxContainer/FoodItems/FoodItem2/BuyButton2")
	buy_button3 = get_node_or_null("VBoxContainer/FoodItems/FoodItem3/BuyButton3")
	
	# 绑定按钮点击事件
	if buy_button1:
		buy_button1.pressed.connect(func(): _on_buy_button_pressed(0))
	if buy_button2:
		buy_button2.pressed.connect(func(): _on_buy_button_pressed(1))
	if buy_button3:
		buy_button3.pressed.connect(func(): _on_buy_button_pressed(2))

# 购买按钮点击事件
func _on_buy_button_pressed(food_index: int):
	print("购买食物：", food_items[food_index]["name"])
	
	# 检查player_attributes是否存在
	if not player_attributes:
		print("错误：player_attributes不存在")
		return
	
	# 获取食物信息
	var food = food_items[food_index]
	var price = food["price"]
	var stamina = food["stamina"]
	
	# 检查金钱是否足够
	var current_money = player_attributes.get_money()
	if current_money < price:
		print("金钱不足，无法购买")
		return
	
	# 记录购买前的状态
	var before_money = player_attributes.get_money()
	var before_stamina = player_attributes.get_stamina()
	
	# 扣除金钱
	player_attributes.set_money(current_money - price)
	
	# 增加体力
	player_attributes.add_stamina(stamina)
	
	# 计算变化量
	var money_change = player_attributes.get_money() - before_money
	var stamina_change = player_attributes.get_stamina() - before_stamina
	
	# 显示通知
	if notification_popup and notification_popup.has_method("show_stat_change"):
		notification_popup.show_stat_change(money_change, stamina_change)
	
	print("购买成功！扣除 %d 金钱，增加 %d 体力" % [price, stamina])
