# 简单测试脚本
extends Control

func _ready():
	print("Simple test scene loaded successfully!")
	if $Label:
		$Label.text = "测试场景加载成功！"
