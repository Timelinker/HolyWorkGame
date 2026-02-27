# 简化的玩家属性管理单例
extends Node

# 信号定义
signal money_changed(new_value: int)
signal stamina_changed(new_value: int)
signal job_level_changed(new_value: int)
signal game_ended(ending_type: String)

# 游戏状态
var is_game_ended = false


# 职业等级配置表
var job_level_config = [
	{"level": 0, "exp_required": 0, "exp_reward": 10, "money_reward": 10, "title": "公司新人"},
	{"level": 1, "exp_required": 10, "exp_reward": 12, "money_reward": 15, "title": "初级产品-1"},
	{"level": 2, "exp_required": 50, "exp_reward": 18, "money_reward": 25, "title": "初级产品-2"},
	{"level": 3, "exp_required": 200, "exp_reward": 30, "money_reward": 40, "title": "初级产品-3"},
	{"level": 4, "exp_required": 800, "exp_reward": 50, "money_reward": 70, "title": "中级产品-1"},
	{"level": 5, "exp_required": 2500, "exp_reward": 80, "money_reward": 120, "title": "中级产品-2"},
	{"level": 6, "exp_required": 8000, "exp_reward": 130, "money_reward": 200, "title": "中级产品-3"},
	{"level": 7, "exp_required": 25000, "exp_reward": 200, "money_reward": 320, "title": "高级产品-1"},
	{"level": 8, "exp_required": 80000, "exp_reward": 320, "money_reward": 500, "title": "高级产品-2"},
	{"level": 9, "exp_required": 250000, "exp_reward": 500, "money_reward": 800, "title": "高级产品-3"},
	{"level": 10, "exp_required": 800000, "exp_reward": 800, "money_reward": 1300, "title": "资产产品-1"},
	{"level": 11, "exp_required": 2500000, "exp_reward": 1300, "money_reward": 2000, "title": "资产产品-2"},
	{"level": 12, "exp_required": 8000000, "exp_reward": 2000, "money_reward": 3200, "title": "资产产品-3"},
	{"level": 13, "exp_required": 25000000, "exp_reward": 3200, "money_reward": 5000, "title": "产品专家-1"},
	{"level": 14, "exp_required": 80000000, "exp_reward": 5000, "money_reward": 8000, "title": "产品专家-2"},
	{"level": 15, "exp_required": 250000000, "exp_reward": 8000, "money_reward": 13000, "title": "产品专家-3"},
	{"level": 16, "exp_required": 800000000, "exp_reward": 13000, "money_reward": 20000, "title": "部门总监"},
	{"level": 17, "exp_required": 2500000000, "exp_reward": 20000, "money_reward": 32000, "title": "部门总负责人"},
	{"level": 18, "exp_required": 8000000000, "exp_reward": 32000, "money_reward": 50000, "title": "副总裁"},
	{"level": 19, "exp_required": 25000000000, "exp_reward": 50000, "money_reward": 80000, "title": "总裁"},
	{"level": 20, "exp_required": 80000000000, "exp_reward": 80000, "money_reward": 130000, "title": "董事长"}
]

# 属性数据结构
var _stamina: int = 100
var _max_stamina: int = 100
var _money: int = 500
var _age: int = 20
var _exp: int = 0
var _exp_max: int = 0  # 将根据职业等级配置动态设置
var _job_level: int = 0  # 职级，从0开始（公司新人）
var _total_spent: int = 0  # 总花费金币数
var _game_days: int = 0  # 游戏天数
var _loan_amount: int = 0  # 贷款总金额
var _daily_loan_interest: float = 0  # 每日贷款利息
var _daily_repayment: float = 0  # 每日还款金额
var _rent: int = 50  # 每日房租
var last_day_processed = 0  # 上次处理的天数

func _ready():
	print("SimplePlayerAttributes initialized")
	# 初始化经验值上限
	_update_exp_max()

# 获取当前职业等级配置
func _get_current_job_config():
	if _job_level < 0 or _job_level >= job_level_config.size():
		return job_level_config[-1]  # 返回最高等级配置
	return job_level_config[_job_level]

# 更新经验值上限
func _update_exp_max():
	var config = _get_current_job_config()
	_exp_max = config.exp_required
	print("更新经验值上限：", _exp_max)

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
	set_stamina(_stamina)

# 获取金钱
func get_money() -> int:
	return _money

# 设置金钱
func set_money(value: int) -> void:
	print("set_money called with value:", value, " current _money:", _money)
	# 检查破产条件
	if not is_game_ended and value <= 0:
		print("触发破产结局条件满足")
		# 先更新金钱值
		_money = max(0, value)
		print("更新后 _money:", _money)
		money_changed.emit(_money)
		# 然后触发结局
		trigger_ending("failure_ending2")
		return
	
	# 计算花费的金钱
	if value < _money:
		_total_spent += _money - value
	_money = max(0, value)
	print("更新后 _money:", _money)
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
	
	# 检查结局条件
	check_endings()

# 处理天数变化
func process_day_passed(day: int = 0):
	# 只有当传入的天数与上次处理的天数不同时，才增加_game_days
	if day > last_day_processed:
		_game_days = day
		last_day_processed = day
		print("simple_player_attributes: 新的一天，游戏天数：", _game_days)
	else:
		print("simple_player_attributes: 跳过重复的天数处理，当前游戏天数：", _game_days)

# 获取职业称号
func get_job_title() -> String:
	var config = _get_current_job_config()
	return config.title

# 获取经验值
func get_exp() -> int:
	return _exp

# 获取经验值上限
func get_exp_max() -> int:
	return _exp_max

# 获取工资（返回当前职业等级的金钱奖励）
func get_salary() -> int:
	var config = _get_current_job_config()
	return config.money_reward

# 获取职级
func get_job_level() -> int:
	return _job_level

# 获取每日消耗
func get_daily_consumption() -> int:
	if _game_days <= 0:
		return 0
	return _total_spent / _game_days

# 获取总花费
func get_total_spent() -> int:
	return _total_spent

# 获取游戏天数
func get_game_days() -> int:
	return _game_days

# 工作逻辑
func work() -> bool:
	if _stamina < 5:
		return false
	
	_stamina -= 5
	stamina_changed.emit(_stamina)
	
	# 获取当前职业等级配置
	var config = _get_current_job_config()
	
	# 增加金钱
	_money += config.money_reward
	money_changed.emit(_money)
	
	# 增加经验值
	_exp += config.exp_reward
	
	# 检查升级
	if _exp >= _exp_max:
		# 升级到下一级
		_job_level += 1
		
		# 计算剩余经验值
		_exp = _exp - _exp_max
		
		# 更新经验值上限
		_update_exp_max()
		
		# 发出职级变化信号
		job_level_changed.emit(_job_level)
		print("升级到职级：", _job_level, "，新称号：", get_job_title())
	
	return true

# 增加贷款利息到每日消耗
func add_loan_interest(amount: float) -> void:
	_daily_loan_interest += amount
	print("增加每日贷款利息：", amount, "，当前每日利息：", _daily_loan_interest)

# 增加每日还款金额
func add_daily_repayment(amount: float) -> void:
	_daily_repayment += amount
	print("增加每日还款金额：", amount, "，当前每日还款：", _daily_repayment)

# 获取贷款总金额
func get_loan_amount() -> int:
	return _loan_amount

# 设置贷款总金额
func set_loan_amount(amount: int) -> void:
	_loan_amount = amount
	print("设置贷款总金额：", _loan_amount)

# 获取每日贷款利息
func get_daily_loan_interest() -> float:
	return _daily_loan_interest

# 获取每日还款金额
func get_daily_repayment() -> float:
	return _daily_repayment

# 获取每日房租
func get_rent() -> int:
	return _rent

# 检查结局条件
func check_endings() -> void:
	if is_game_ended:
		return
	
	# 检查年龄是否达到21岁
	if _age >= 21:
		# 检查职位是否达到中级产品-1（等级4）
		if _job_level >= 4:
			# 成功结局
			trigger_ending("success_ending")
		else:
			# 失败结局1：职位不足
			trigger_ending("failure_ending1")

# 触发结局
func trigger_ending(ending_type: String) -> void:
	is_game_ended = true
	print("触发结局: ", ending_type)
	# 发出结局触发信号
	game_ended.emit(ending_type)

# 重置游戏状态（用于重新开始游戏）
func reset_game_state() -> void:
	# 重置游戏状态
	is_game_ended = false
	# 重置属性值
	_stamina = 100
	_max_stamina = 100
	_money = 500
	_age = 20
	_exp = 0
	_job_level = 0
	_total_spent = 0
	_game_days = 0
	_loan_amount = 0
	_daily_loan_interest = 0
	_daily_repayment = 0
	_rent = 50
	last_day_processed = 0
	# 更新经验值上限
	_update_exp_max()
	print("游戏状态已重置")

# 处理每日消耗（包括贷款利息、还款和房租）
func process_daily_consumption() -> void:
	# 如果游戏已经结束，不再处理每日消耗
	if is_game_ended:
		return
	
	# 添加贷款利息到总花费
	_total_spent += int(_daily_loan_interest)
	print("处理每日消耗：", int(_daily_loan_interest), "，总花费：", _total_spent)
	
	# 处理房租
	set_money(_money - _rent)
	print("处理每日房租：", _rent, "，剩余金钱：", _money)
	
	# 如果游戏已经结束（触发了破产结局），不再处理后续内容
	if is_game_ended:
		return
	
	# 处理每日还款
	if _daily_repayment > 0:
		# 从总金钱中扣除每日还款
		var repayment_amount = int(_daily_repayment)
		set_money(_money - repayment_amount)
		print("处理每日还款：", repayment_amount, "，剩余金钱：", _money)
