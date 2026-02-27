# 结局场景基础脚本
extends Control

func _ready():
	# 连接重新开始按钮的点击事件
	if $VBoxContainer/RestartButton:
		$VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)

# 重新开始游戏
func _on_restart_button_pressed():
	# 重新加载主场景
	get_tree().reload_current_scene()
