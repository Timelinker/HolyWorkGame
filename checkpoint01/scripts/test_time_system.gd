# 测试时间系统脚本
extends Control

var elapsed_seconds = 0.0
var day = 1
var seconds_per_day = 10

func _ready():
	if $TimeText:
		$TimeText.text = "测试：第%d天" % day

func _process(delta):
	elapsed_seconds += delta
	
	if elapsed_seconds >= seconds_per_day:
		elapsed_seconds -= seconds_per_day
		day += 1
		if $TimeText:
			$TimeText.text = "测试：第%d天" % day
