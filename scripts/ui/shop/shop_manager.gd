# 商城管理器
# 负责处理商品购买逻辑

extends Node

# 导入商品数据管理
const ShopData = preload("res://scripts/data/shop_data.gd")

# 属性系统单例（通过AutoLoad自动加载）
var player_attributes = null

func _ready():
	# 获取属性系统单例
	player_attributes = get_node("/root/player_attributes")

# 信号定义
signal purchase_success(item_id: String, item_name: String)
signal purchase_failed(item_id: String, reason: String)

# 商品数据实例
var shop_data = ShopData.new()

# 购买商品方法
func purchase_item(item_id: String) -> bool:
	# 检查player_attributes是否存在
	if not player_attributes:
		purchase_failed.emit(item_id, "属性系统未初始化")
		return false
	
	# 获取商品数据
	var item = shop_data.get_item_by_id(item_id)
	
	# 检查商品是否存在
	if len(item) == 0:
		purchase_failed.emit(item_id, "商品不存在")
		return false
	
	# 检查玩家是否有足够的金钱
	var player_money = player_attributes.get_money()
	if player_money < item["price"]:
		purchase_failed.emit(item_id, "金钱不足")
		return false
	
	# 扣除金钱
	player_attributes.set_money(player_money - item["price"])
	
	# 应用商品效果
	match item["effect_type"]:
		ShopData.EffectType.STAMINA:
			# 增加体力值
			player_attributes.add_stamina(item["effect_value"])
			
		ShopData.EffectType.MAX_STAMINA:
			# 增加体力上限
			player_attributes.add_max_stamina(item["effect_value"])
			
		_:
			# 未知效果类型
			print("未知的商品效果类型: ", item["effect_type"])
	
	# 发送购买成功信号
	purchase_success.emit(item_id, item["name"])
	
	return true

# 获取商品列表
func get_all_items() -> Array:
	var items = shop_data.get_all_items()
	print("ShopManager.get_all_items() 调用，返回商品数量：", len(items))
	return items

# 获取单个商品信息
func get_item_info(item_id: String) -> Dictionary:
	return shop_data.get_item_by_id(item_id)
