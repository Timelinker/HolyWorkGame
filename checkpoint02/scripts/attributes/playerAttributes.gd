# 玩家属性管理单例
extends Node

# 导入属性类型定义
const AT = preload("res://scripts/attributes/attributeTypes.gd")

# 信号定义
# 只保留最核心的信号
signal money_changed(new_value: int)
signal stamina_changed(new_value: int)
signal job_level_changed(new_value: int)

# 属性数据结构 - 简化版本
var _stamina: int = 100
var _max_stamina: int = 100
var _money: int = 0
var _age: int = 20
var _exp: int = 0
var _exp_max: int = 100
var _salary: int = 10
var _job_level: int = 1  # 职级，从1开始

func _ready():
	print("PlayerAttributes initialized")

# 获取体力
func get_stamina() -> int:
	return _stamina

# 设置体力
func set_stamina(value: int) -> void:
	_stamina = clamp(value, 0, _max_stamina)
	stamina_changed.emit(_stamina)

# 增加体力
func add_stamina(amount: int) -> void:
	set_stamina(_stamina + amount)

# 获取体力上限
func get_max_stamina() -> int:
	return _max_stamina

# 增加体力上限
func add_max_stamina(amount: int) -> void:
	_max_stamina += amount
	# 如果当前体力低于新的上限，保持不变；如果高于，设置为新的上限
	set_stamina(_stamina)

# 获取金钱
func get_money() -> int:
	return _money

# 设置金钱
func set_money(value: int) -> void:
	_money = max(0, value)
	money_changed.emit(_money)

# 增加金钱
func add_money(amount: int) -> void:
	set_money(_money + amount)

# 获取年龄
func get_age() -> int:
	return _age

# 增加年龄
func increase_year():
	_age += 1
	print("年龄增加: ", _age)

# 处理天数变化
func process_day_passed():
	# 这里可以添加每天的固定收支逻辑
	print("新的一天")

# 获取职业称号
func get_job_title() -> String:
	# 根据职级返回职业称号
	var titles = {
		1: "初级产品经理",
		2: "中级产品经理",
		3: "高级产品经理",
		4: "产品总监",
		5: "产品副总裁",
		6: "产品总裁"
	}
	return titles.get(_job_level, "高级产品总裁")

# 获取经验值
func get_exp() -> int:
	return _exp

# 获取经验值上限
func get_exp_max() -> int:
	return _exp_max

# 获取工资
func get_salary() -> int:
	return _salary

# 获取职级
func get_job_level() -> int:
	return _job_level

# 工作逻辑
func work() -> bool:
	# 检查体力是否足够
	if _stamina < 5:
		return false
	
	# 消耗体力
	_stamina -= 5
	stamina_changed.emit(_stamina)
	
	# 获得金钱
	_money += _salary
	money_changed.emit(_money)
	
	# 获得经验值
	_exp += 10
	
	# 经验值满时提升职级
	if _exp >= _exp_max:
		_exp = _exp - _exp_max  # 保留剩余经验值
		_exp_max = int(_exp_max * 1.5)
		_salary = int(_salary * 1.2)
		
		# 提升职级
		_job_level += 1
		job_level_changed.emit(_job_level)
	
	return true
