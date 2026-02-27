# 商城弹窗脚本
extends Panel

# 导入商城数据
const ShopData = preload("res://scripts/data/shop_data.gd")

# 信号定义
signal close_pressed

# 引用
@onready var close_button = $VBoxContainer/TitleBar/CloseButton
@onready var items_container = $VBoxContainer/ItemList/ScrollContainer/ItemsContainer
@onready var money_text = $VBoxContainer/Footer/MoneyText
@onready var total_items_text = $VBoxContainer/Footer/TotalItems

# 属性系统单例（通过AutoLoad自动加载）
@onready var player_attributes = get_node("/root/player_attributes")

# 商城管理器引用（从父节点获取）
var shop_manager = null

func _ready():
	# 绑定信号
	close_button.pressed.connect(_on_close_button_pressed)
	
	# 查找商城管理器（使用find_node方法）
	shop_manager = find_shop_manager()
	
	# 初始化商品列表
	_init_item_list()
	
	# 更新UI
	_update_ui()

# 显示弹窗
func show_popup():
	visible = true
	
	# 初始化商品列表
	_init_item_list()
	
	# 更新UI
	_update_ui()

# 隐藏弹窗
func hide_popup():
	visible = false
	
	# 发出关闭信号
	close_pressed.emit()

# 获取商城管理器的简单方法
func find_shop_manager() -> Node:
	print("🔍 开始获取ShopManager节点")
	
	# 直接通过节点路径获取
	var main_scene = get_node("../..")  # ShopPopup -> SafeArea2D -> mainScene
	if main_scene:
		print("✅ 找到mainScene节点：", main_scene.name)
		
		# 直接查找ShopManager
		if main_scene.has_node("ShopManager"):
			var shop_manager = main_scene.get_node("ShopManager")
			print("✅ 直接找到ShopManager：", shop_manager.name)
			return shop_manager
		else:
			print("❌ mainScene中没有ShopManager节点")
			# 打印mainScene的所有子节点
			print("📋 mainScene的子节点数量：", main_scene.get_child_count())
			for child in main_scene.get_children():
				print("   - ", child.name)
			return null
	else:
		print("❌ 无法找到mainScene节点")
		return null

# 打印场景树结构的辅助函数
func _print_scene_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent, "- ", node.name)
	for child in node.get_children():
		_print_scene_tree(child, depth + 1)

# 外部调用的初始化商品列表方法
func init_shop_items():
	# 初始化商品列表
	_init_item_list()
	# 更新UI
	_update_ui()

# 初始化商品列表
func _init_item_list():
	print("=== 初始化商品列表开始 ===")
	
	# 检查必要节点是否存在
	if not items_container:
		print("❌ items_container不存在")
		return
	else:
		print("✅ items_container存在：", items_container.name)
		print("   items_container可见性：", items_container.visible)
		print("   items_container尺寸：", items_container.size)
	
	if not total_items_text:
		print("❌ total_items_text不存在")
		return
	else:
		print("✅ total_items_text存在：", total_items_text.name)
	
	# 清除现有商品项
	print("📋 清除现有商品项，当前子节点数量：", len(items_container.get_children()))
	for child in items_container.get_children():
		child.queue_free()
	print("📋 清除后子节点数量：", len(items_container.get_children()))
	
	# 检查shop_manager是否存在
	if shop_manager == null:
		print("🔍 shop_manager为null，重新查找")
		shop_manager = find_shop_manager()
	
	if not shop_manager:
		print("❌ shop_manager获取失败")
		return
	else:
		print("✅ shop_manager获取成功：", shop_manager.name)
	
	# 获取所有商品数据
	var items = shop_manager.get_all_items()
	print("📦 获取到商品数量：", len(items))
	if len(items) > 0:
		print("📋 商品列表示例：")
		for i in range(min(3, len(items))):
			print("   ", i+1, ". ", items[i]["name"], " (", items[i]["price"], "金币")
	
	# 动态生成商品项
	var added_count = 0
	for item in items:
		print("➕ 添加商品：", item["name"])
		_add_item_to_list(item)
		added_count += 1
	
	# 更新商品总数
	total_items_text.text = "共 %d 件商品" % len(items)
	print("📊 商品总数已更新为：", total_items_text.text)
	print("✅ 商品列表初始化完成，共添加 %d 件商品" % added_count)
	print("   items_container当前子节点数量：", len(items_container.get_children()))
	print("=== 初始化商品列表结束 ===")

# 已购买商品ID集合
var purchased_items = []

# 添加商品项到列表
func _add_item_to_list(item: Dictionary):
	print("=== 添加商品项开始 ===")
	print("商品ID：", item["id"])
	print("商品名称：", item["name"])
	
	# 创建商品项容器
	var item_container = HBoxContainer.new()
	item_container.name = item["id"]
	item_container.add_theme_constant_override("separation", 10)
	item_container.size_flags_horizontal = 3  # FILL
	item_container.size_flags_vertical = 1  # SHRINK_CENTER
	item_container.visible = true
	print("✅ 创建商品项容器：", item_container.name)
	
	# 创建名称标签
	var name_label = Label.new()
	name_label.text = "  " + item["name"]  # 前面增加2个空格
	name_label.horizontal_alignment = 1  # 1表示水平居中对齐
	name_label.vertical_alignment = 1  # 1表示垂直居中对齐
	name_label.size_flags_horizontal = 1  # EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.visible = true
	item_container.add_child(name_label)
	print("✅ 添加名称标签：", name_label.text)
	
	# 创建价格标签
	var price_label = Label.new()
	price_label.text = "  ¥%d" % item["price"]  # 前面增加2个空格
	price_label.horizontal_alignment = 1  # 1表示水平居中对齐
	price_label.vertical_alignment = 1  # 1表示垂直居中对齐
	price_label.size_flags_horizontal = 1  # EXPAND_FILL
	price_label.add_theme_font_size_override("font_size", 20)
	price_label.visible = true
	item_container.add_child(price_label)
	print("✅ 添加价格标签：", price_label.text)
	
	# 创建效果标签
	var effect_label = Label.new()
	effect_label.text = item["description"]
	effect_label.horizontal_alignment = 1  # 1表示水平居中对齐
	effect_label.vertical_alignment = 1  # 1表示垂直居中对齐
	effect_label.size_flags_horizontal = 1  # EXPAND_FILL
	effect_label.add_theme_font_size_override("font_size", 16)
	effect_label.autowrap_mode = 0  # 0表示不自动换行
	effect_label.visible = true
	effect_label.size_flags_vertical = 1  # SHRINK_CENTER
	item_container.add_child(effect_label)
	print("✅ 添加效果标签：", effect_label.text)
	
	# 添加Spacer节点，填充剩余空间，将购买按钮推到右侧
	var spacer = Control.new()
	spacer.size_flags_horizontal = 3  # FILL
	spacer.visible = true
	item_container.add_child(spacer)
	print("✅ 添加Spacer节点")
	
	# 创建购买按钮
	var buy_button = Button.new()
	buy_button.text = "  购买"  # 前面增加2个空格
	buy_button.custom_minimum_size = Vector2(100, 50)  # 增大按钮尺寸，适合移动端触摸
	buy_button.add_theme_font_size_override("font_size", 20)
	# 确保按钮使用默认的按钮行为，自动恢复状态
	buy_button.toggle_mode = false
	buy_button.button_pressed = false
	
	# 检查商品是否已购买
	if item["id"] in purchased_items:
		buy_button.text = "  已购买"
		buy_button.disabled = true
		buy_button.modulate = Color(0.5, 0.5, 0.5)  # 灰色显示
	else:
		# 绑定购买事件
		buy_button.pressed.connect(func(): _on_buy_button_pressed(item["id"], buy_button))
	
	item_container.add_child(buy_button)
	print("✅ 添加购买按钮：", buy_button.text)
	
	# 在购买按钮右侧添加固定宽度的Control节点，模拟6个空格的宽度
	var right_margin = Control.new()
	right_margin.custom_minimum_size = Vector2(30, 0)  # 使用属性设置最小宽度，大约6个空格的宽度
	right_margin.visible = true
	item_container.add_child(right_margin)
	print("✅ 添加右侧边距")
	
	# 添加到容器
	items_container.add_child(item_container)
	print("✅ 商品项添加到容器")
	print("   商品项子节点数量：", len(item_container.get_children()))
	print("   添加后容器子节点数量：", len(items_container.get_children()))
	print("=== 添加商品项完成 ===")

# 关闭按钮点击事件
func _on_close_button_pressed():
	hide_popup()

# 购买按钮点击事件
func _on_buy_button_pressed(item_id: String, buy_button: Button = null):
	# 调用商城管理器购买商品
	var success = shop_manager.purchase_item(item_id)
	
	# 购买成功后更新按钮状态
	if success and buy_button:
		# 将商品添加到已购买列表
		purchased_items.append(item_id)
		# 更新按钮状态
		buy_button.text = "  已购买"
		buy_button.disabled = true
		buy_button.modulate = Color(0.5, 0.5, 0.5)  # 灰色显示
		print("✅ 商品购买成功，按钮状态已更新：", item_id)
	
	# 无论成功与否，都更新UI
	_update_ui()

# 更新UI
func _update_ui():
	# 检查必要节点是否存在
	if not money_text:
		return
	
	# 检查player_attributes是否存在
	if not player_attributes:
		print("错误：player_attributes不存在")
		return
	
	# 更新金钱显示
	var money = player_attributes.get_money()
	money_text.text = "金钱：%d" % money
	
	# 更新商品列表（如果需要动态刷新）
	# _init_item_list()

# 当弹窗可见性变化时更新UI
func _on_visibility_changed():
	if visible:
		_update_ui()
