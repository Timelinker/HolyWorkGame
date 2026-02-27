# 商品数据管理
extends RefCounted

class_name ShopData

# 商品效果类型枚举
enum EffectType {
	STAMINA,        # 增加体力值
	MAX_STAMINA     # 增加体力值最大上限
}

# 商品数据列表
const SHOP_ITEMS = [
	{
		"id": "liuyang_zhengcai",
		"name": "浏阳蒸菜",
		"price": 15,
		"effect_type": EffectType.STAMINA,
		"effect_value": 25,
		"description": "增加25点体力"
	},
	{
		"id": "protein_shake",
		"name": "蛋白质奶昔",
		"price": 30,
		"effect_type": EffectType.MAX_STAMINA,
		"effect_value": 10,
		"description": "增加10点体力上限"
	},
	{
		"id": "energy_bar",
		"name": "能量棒",
		"price": 8,
		"effect_type": EffectType.STAMINA,
		"effect_value": 15,
		"description": "增加15点体力"
	},
	{
		"id": "vitamin_pill",
		"name": "维生素片",
		"price": 5,
		"effect_type": EffectType.STAMINA,
		"effect_value": 10,
		"description": "增加10点体力"
	},
	{
		"id": "sports_drink",
		"name": "运动饮料",
		"price": 12,
		"effect_type": EffectType.STAMINA,
		"effect_value": 20,
		"description": "增加20点体力"
	},
	{
		"id": "fitness_plan",
		"name": "健身计划",
		"price": 100,
		"effect_type": EffectType.MAX_STAMINA,
		"effect_value": 25,
		"description": "增加25点体力上限"
	}
]

# 根据ID获取商品数据
func get_item_by_id(item_id: String) -> Dictionary:
	for item in SHOP_ITEMS:
		if item["id"] == item_id:
			return item
	return {}

# 获取所有商品数据
func get_all_items() -> Array:
	print("ShopData.get_all_items() 调用，原始商品数量：", len(SHOP_ITEMS))
	var items = SHOP_ITEMS.duplicate(true)  # 使用深度复制
	print("ShopData.get_all_items() 返回商品数量：", len(items))
	return items
