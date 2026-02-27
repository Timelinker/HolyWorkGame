---
name: 休闲游戏移动端UI适配师（godot-mcp专属）
description: "通过godot-mcp工具完成休闲游戏demo UI的移动端适配，自动检测多分辨率下UI错位/误触问题，调用MCP修改节点属性，适配异形屏安全区，验证适配效果\"
author: \"Godot休闲游戏UI AI\""
---

version: "1.0.0"
tags: ["Godot", "休闲游戏", "移动端适配", "godot-mcp", "异形屏", "demo阶段"]
trigger: "当用户需要优化休闲游戏demo UI的移动端适配效果、解决UI错位/误触问题时触发，自动调用godot-mcp完成适配检测/修改/验证"
---

## 核心流程（深度绑定godot-mcp工具）
1. **适配需求解析**：确定目标设备（手机）、分辨率范围（720x1280/1080x1920/1440x2560）、安全区要求（刘海屏/挖孔屏）
2. **MCP工具调用链**：
   - 调用 `run_project`：分别以不同分辨率启动demo
   - 调用 `capture_screenshot`：捕获各分辨率下UI截图，保存到本地调试目录
   - 分析截图：识别UI错位（锚点错误）、误触（按钮尺寸过小）、安全区越界问题
   - 调用 `add_node`：给根节点添加SafeArea2D，调整所有UI节点至安全区内
   - 调用 `add_node`：修改核心按钮的`custom_minimum_size`（≥60x60px）、锚点（屏幕下半区）
   - 再次调用 `run_project` + `capture_screenshot`：验证适配效果
3. **错误处理**：若MCP返回「截图失败」，自动等待demo加载完成后重试；若「分辨率不支持」，降级为基础分辨率适配

## 输出内容（godot-mcp兼容）
- 适配后的UI场景文件（.tscn）
- 多分辨率适配对比报告（含截图+修改点）
- MCP适配操作清单（节点属性修改记录）

## 核心GDScript示例（MCP自动注入适配逻辑）
```gdscript
# 由MCP自动生成的移动端适配脚本
extends Control
func _ready():
    # MCP自动添加SafeArea2D适配异形屏
    var safe_area = SafeArea2D.new()
    safe_area.name = "SafeArea"
    add_child(safe_area)
    # 将所有UI节点移至安全区内
    for node in get_children():
        if node != safe_area:
            node.reparent(safe_area)
    # MCP自动设置按钮最小尺寸
    $StartBtn.custom_minimum_size = Vector2(60, 60)
    $PauseBtn.custom_minimum_size = Vector2(50, 50)
    # 适配不同分辨率
    adapt_to_screen()

func adapt_to_screen():
    var screen_size = OS.get_window_size()
    var scale = min(screen_size.x/1080, screen_size.y/1920)
    $PropBar.scale = Vector2(scale, scale)
godot-mcp 工具调用参数示例（AI 自动执行）
json
{
  "tool": "capture_screenshot",
  "params": {
    "projectPath": "/Users/xxx/godot-projects/casual-demo",
    "resolution": "1440x2560",
    "savePath": "/Users/xxx/debug/ui_1440.png",
    "waitTime": 2000 # 等待demo加载完成（ms）
  }
}
plaintext

## 3. 休闲游戏UI轻量交互动画师（godot-mcp专属）
```yaml
---
name: "休闲游戏UI轻量交互动画师（godot-mcp专属）"
description: "为休闲游戏demo UI添加低耗交互动画（按钮反馈/弹窗淡入/奖励提示），通过godot-mcp工具添加Tween动画、验证动画性能，确保demo帧率稳定60帧，无卡顿"
author: "Godot休闲游戏UI AI"
version: "1.0.0"
tags: ["Godot", "休闲游戏", "UI动画", "godot-mcp", "轻量动画", "demo阶段"]
trigger: "当用户需要为休闲游戏demo UI添加交互动画、优化动画性能时触发，自动调用godot-mcp完成动画添加/性能验证"
---

## 核心流程（深度绑定godot-mcp工具）
1. **动画需求解析**：识别UI元素（按钮/弹窗/奖励提示）、动画类型（缩放/透明度/位置）、休闲游戏节奏（动画时长≤0.2s）
2. **MCP工具调用链**：
   - 调用 `add_node`：给目标UI节点添加Tween节点，禁用复杂缓动（仅用EASE_OUT_QUAD）
   - 注入动画脚本：按钮点击缩放、弹窗淡入、奖励飘移（动画结束自动销毁节点）
   - 调用 `run_project`：运行demo，开启性能调试模式
   - 调用 `get_debug_output`：获取帧率日志，检查动画期间帧率是否≥60帧
   - 优化：若帧率低于60，简化动画（移除颜色渐变/缩短时长）
3. **错误处理**：若MCP返回「脚本注入失败」，简化动画逻辑为基础Tween调用；若「帧率过低」，自动禁用非核心动画

## 输出内容（godot-mcp兼容）
- 带动画逻辑的UI场景文件（.tscn）
- 动画性能报告（MCP获取的帧率数据+优化建议）
- 轻量动画脚本片段（可复用）

## 核心GDScript示例（MCP自动注入动画逻辑）
```gdscript
# 由MCP自动生成的按钮动画脚本
extends Button
func _ready():
    # MCP自动绑定输入信号
    connect("gui_input", self, "_on_gui_input")

func _on_gui_input(event: InputEvent):
    # 轻量点击反馈（休闲游戏专属）
    if event is InputEventMouseButton and event.pressed:
        var tween = create_tween()
        tween.set_ease(Tween.EASE_OUT_QUAD)
        tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
        tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
    # 悬停变色（仅移动端触摸友好）
    elif event is InputEventMouseMotion:
        self.modulate = Color(1.1, 1.1, 1.1)
    else:
        self.modulate = Color(1, 1, 1)

# 由MCP自动生成的奖励提示动画
func show_reward(text: String, pos: Vector2):
    var reward_label = Label.new()
    reward_label.text = text
    reward_label.rect_position = pos
    add_child(reward_label)
    # 飘移+渐隐（轻量无卡顿）
    var tween = create_tween()
    tween.tween_property(reward_label, "rect_position", pos + Vector2(0, -50), 0.3)
    tween.parallel().tween_property(reward_label, "modulate:a", 0, 0.3)
    tween.finished.connect(reward_label.queue_free) # 自动销毁，轻量化
godot-mcp 工具调用参数示例（AI 自动执行）
json
{
  "tool": "get_debug_output",
  "params": {
    "projectPath": "/Users/xxx/godot-projects/casual-demo",
    "filter": "fps", # 仅过滤帧率相关日志
    "maxLines": 100
  }
}
plaintext

## 4. 休闲游戏核心UI组件开发师（godot-mcp专属）
```yaml
---
name: "休闲游戏核心UI组件开发师（godot-mcp专属）"
description: "为休闲游戏demo开发高留存核心UI组件（7天签到/每日任务/体力条），通过godot-mcp工具创建组件场景、绑定轻量化数据逻辑、验证功能完整性，适配demo阶段本地缓存需求"
author: "Godot休闲游戏UI AI"
version: "1.0.0"
tags: ["Godot", "休闲游戏", "核心组件", "godot-mcp", "签到/任务", "demo阶段"]
trigger: "当用户需要为休闲游戏demo开发签到/任务/体力条等核心UI组件时触发，自动调用godot-mcp完成组件创建/功能验证"
---

## 核心流程（深度绑定godot-mcp工具）
1. **组件需求解析**：确定组件类型（7天签到/每日任务）、奖励类型（金币/道具）、数据缓存方式（本地ConfigFile）
2. **MCP工具调用链**：
   - 调用 `create_scene`：创建组件场景（SignPanel.tscn/TaskPanel.tscn），根节点为Control
   - 调用 `add_node`：添加核心节点（按钮格子/进度条/领取按钮），极简布局（节点数≤8）
   - 注入数据逻辑：本地缓存签到状态/任务进度，一键签到/领奖功能
   - 调用 `run_project`：运行demo，测试组件交互逻辑
   - 调用 `get_debug_output`：检查脚本错误，确保数据缓存生效
3. **错误处理**：若MCP返回「缓存写入失败」，降级为内存缓存（demo阶段临时方案）；若「按钮绑定失败」，简化信号逻辑

## 输出内容（godot-mcp兼容）
- 核心组件场景文件（.tscn）+ 脚本（.gd）
- 组件功能测试报告（MCP验证的功能点）
- 数据缓存逻辑说明（demo阶段本地存储方案）

## 核心GDScript示例（MCP自动生成签到组件）
```gdscript
# 由MCP自动生成的7天签到组件脚本
extends Control
var signed_days: Array[int] = []
var current_day: int = 0
var config: ConfigFile = ConfigFile.new()

func _ready():
    # MCP自动加载本地缓存
    load_sign_data()
    # MCP自动生成7天签到格子
    generate_sign_grid()
    # 绑定一键签到按钮
    $SignBtn.pressed.connect(_on_sign_click)

func generate_sign_grid():
    for i in range(7):
        var btn = Button.new()
        btn.name = "SignBtn_" + str(i)
        btn.text = str(i+1) + "天"
        # MCP自动设置签到状态样式
        if i in signed_days:
            btn.modulate = Color(0.8, 0.8, 0.8)
            btn.disabled = true
            btn.text += "\n已签到"
        elif i == current_day:
            btn.modulate = Color(1, 0.8, 0)
            btn.text += "\n今日可签"
        $SignGrid.add_child(btn)

func _on_sign_click():
    # 一键签到（demo轻量化逻辑）
    if current_day not in signed_days:
        signed_days.append(current_day)
        save_sign_data()
        # 发放奖励（demo默认金币）
        $RewardTip.show_reward("获得100金币", get_global_mouse_position())
        # 刷新UI
        generate_sign_grid()

func load_sign_data():
    # MCP自动配置本地缓存路径
    var err = config.load("user://sign_data.cfg")
    if err == OK:
        signed_days = config.get_value("sign", "signed_days", [])
        current_day = config.get_value("sign", "current_day", 0)

func save_sign_data():
    config.set_value("sign", "signed_days", signed_days)
    config.set_value("sign", "current_day", current_day + 1)
    config.save("user://sign_data.cfg")