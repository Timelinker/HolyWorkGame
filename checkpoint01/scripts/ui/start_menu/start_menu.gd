# 开始菜单脚本
# 处理开始游戏和结束游戏的逻辑
extends Control

@onready var start_button = $StartButton
@onready var exit_button = $ExitButton

func _ready():
	# 绑定按钮点击事件
	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

# 开始游戏按钮点击事件
func _on_start_button_pressed():
	print("开始游戏按钮被点击")
	# 切换到游戏主场景
	get_tree().change_scene_to_file("res://scenes/mainScene/main_scene.tscn")

# 结束游戏按钮点击事件
func _on_exit_button_pressed():
	print("结束游戏按钮被点击")
	# 退出游戏
	get_tree().quit()