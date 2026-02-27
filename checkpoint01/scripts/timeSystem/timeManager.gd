# 时间系统管理器 - 实现Year/Month/Day层级，10秒=1天
class_name TimeManager
extends Node

# 时间常量
var seconds_per_day = 2.0  # 现实10秒 = 游戏1天

# 游戏时间变量
var year = 2020
var month = 1
var day = 1
var elapsed_seconds = 0.0

# 信号
signal time_changed(year, month, day)
signal day_passed(year, month, day)

func _ready():
	# 启动时间更新
	pass

func _process(delta):
	# 更新流逝的秒数
	elapsed_seconds += delta
	
	# 检查是否过了一天
	if elapsed_seconds >= seconds_per_day:
		elapsed_seconds -= seconds_per_day
		on_day_passed()

# 处理一天过去的逻辑
func on_day_passed():
	# 更新日期
	day += 1
	
	# 检查月份进位
	if day > 30:  # 假设每月30天
		day = 1
		month += 1
		
		# 检查年份进位
		if month > 12:
			month = 1
		year += 1
	
	# 发出信号
	time_changed.emit(year, month, day)
	day_passed.emit(year, month, day)

# 获取当前时间字符串
func get_time_string():
	return "%d年%d月%d日" % [year, month, day]

# 设置时间（用于调试或存档）
func set_time(new_year, new_month, new_day):
	year = new_year
	month = new_month
	day = new_day
	time_changed.emit(year, month, day)
