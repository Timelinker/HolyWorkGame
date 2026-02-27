# 通知弹窗脚本
# 实现淡入淡出和上下移动的动画效果

extends Control

# 引用
var label = null

# 动画变量
var tween = null

func _ready():
	# 获取标签节点
	label = $Label
	
	# 初始化时隐藏
	visible = false
	modulate = Color(1, 1, 1, 0)

# 显示通知
func show_notification(message: String):
	# 设置通知内容
	label.text = message
	
	# 重置位置到屏幕底部外
	position.y = get_viewport().size.y + 100
	
	# 重置透明度
	modulate = Color(1, 1, 1, 0)
	
	# 显示弹窗
	visible = true
	
	# 创建Tween动画
	tween = create_tween()
	
	# 从屏幕底部移动到屏幕正中间
	tween.tween_property(self, "position:y", get_viewport().size.y * 0.5, 0.5).set_ease(Tween.EASE_OUT_QUAD)
	
	# 同时淡入
	tween.parallel().tween_property(self, "modulate:a", 1, 0.5).set_ease(Tween.EASE_OUT_QUAD)
	
	# 停留一段时间
	tween.tween_interval(1.0)
	
	# 淡出
	tween.tween_property(self, "modulate:a", 0, 0.5).set_ease(Tween.EASE_IN_QUAD)
	
	# 同时移动到屏幕底部外
	tween.parallel().tween_property(self, "position:y", get_viewport().size.y + 100, 0.5).set_ease(Tween.EASE_IN_QUAD)
	
	# 动画结束后隐藏
	tween.finished.connect(func():
		visible = false
	)

# 显示金钱和体力变化通知
func show_stat_change(money_change: int, stamina_change: int):
	var message = ""
	
	# 添加金钱变化
	if money_change > 0:
		message += "金钱 +%d" % money_change
	elif money_change < 0:
		message += "金钱 %d" % money_change
	
	# 添加体力变化
	if stamina_change != 0:
		if message != "":
			message += ", "
		if stamina_change > 0:
			message += "体力 +%d" % stamina_change
		elif stamina_change < 0:
			message += "体力 %d" % stamina_change
	
	# 显示通知
	if message != "":
		show_notification(message)
