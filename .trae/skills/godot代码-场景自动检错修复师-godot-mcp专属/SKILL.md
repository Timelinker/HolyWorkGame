---
name: Godot代码/场景自动检错修复师（godot-mcp专属）
description: 针对休闲游戏demo，在每次UI优化Skill改动代码/场景后，自动调用godot-mcp工具检测语法错误、运行时BUG、场景配置问题，精准定位错误位置，生成修复方案并支持自动修复，无需手动逐个排查
---

version: "1.0.0"
tags: ["Godot", "休闲游戏", "代码检错", "BUG修复", "godot-mcp", "UI优化后检错"]
trigger: "当用户通过其他Skill（如UI优化/适配）改动Godot代码/场景后，触发自动检错；或用户主动要求检测代码错误时触发，自动调用godot-mcp完成全流程检错修复"
---

## 核心流程（深度绑定godot-mcp工具）
1. **检错前置准备**：
   - 识别本次代码/场景改动范围（UI 相关的 .gd 脚本、.tscn 场景文件）
   - 调用 godot-mcp 的 `list_projects` 工具，定位改动文件的绝对路径
2. **多维度自动检错（godot-mcp 工具调用链）**：
   - 🔹 **语法静态检测**：调用 `run_project` 以 `--headless --check-only` 模式启动项目，检测脚本语法错误、场景节点配置错误（无需运行游戏）
   - 🔹 **运行时动态检测**：调用 `run_project` 正常启动 demo，触发 UI 相关逻辑（如点击按钮、加载UI场景）
   - 🔹 **错误日志采集**：调用 `get_debug_output` 工具，过滤并提取所有错误日志（语法错误/运行时异常/节点不存在/信号绑定失败等）
   - 🔹 **错误分类解析**：将错误分为「致命错误（无法运行）」「普通错误（功能异常）」「警告（不影响运行）」三类
3. **错误定位与修复方案生成**：
   - 解析错误日志中的「文件路径、行号、错误类型」，精准定位到改动的代码/场景节点
   - 针对不同错误类型生成分级修复方案：
     ✅ 简单错误（如语法拼写错误、节点名写错）：自动生成修复代码/配置
     ✅ 复杂错误（如信号绑定失败、锚点配置错误）：给出分步修复指导
     ✅ 潜在BUG（如内存泄漏、频繁重绘）：给出优化建议
4. **自动修复与验证**：
   - 对简单错误：调用 `add_node`/`modify_node` 工具自动修改代码/场景属性
   - 对复杂错误：输出详细修复步骤，等待用户确认后辅助执行
   - 修复后再次调用 `run_project` + `get_debug_output` 验证错误是否解决
5. **错误处理**：
   - 若 godot-mcp 返回「项目启动失败」：先检测 `project.godot` 配置错误，优先修复基础配置
   - 若「错误日志为空」：验证项目是否正常运行，触发 UI 交互后重新采集日志
   - 若「修复后仍报错」：对比改动前后代码，定位修复遗漏点

## 输出内容（godot-mcp兼容）
- 🔍 错误检测报告（含错误类型、文件路径、行号、错误描述）
- 🛠️ 分级修复方案（自动修复/手动修复步骤）
- ✅ 修复验证结果（修复后是否仍有错误）
- 📝 错误日志原始文件（便于二次排查）

## 核心GDScript示例（MCP自动注入的错误检测逻辑）
```gdscript
# 由MCP自动生成的错误检测与修复辅助脚本
extends Node
var mcp_error_log: Array = [] # 存储godot-mcp获取的错误日志
var fix_records: Array = [] # 修复记录

func _ready():
    # 调用godot-mcp启动检错流程
    call_mcp_tool("start_error_check", {"project_path": "/Users/xxx/godot-projects/casual-demo"})

# 接收godot-mcp返回的错误日志并解析
func _on_mcp_error_log_loaded(logs: Array):
    mcp_error_log = logs
    # 分类解析错误
    var syntax_errors = [] # 语法错误
    var runtime_errors = [] # 运行时错误
    var scene_errors = [] # 场景配置错误
    
    for log in logs:
        if "Parse Error" in log or "SyntaxError" in log:
            syntax_errors.append(parse_error(log))
        elif "Invalid get index" in log or "Node not found" in log:
            runtime_errors.append(parse_error(log))
        elif "Scene configuration error" in log or "Anchor preset invalid" in log:
            scene_errors.append(parse_error(log))
    
    # 输出错误报告
    print("=== Godot 错误检测报告 ===")
    print(f"语法错误: {len(syntax_errors)} 个")
    print(f"运行时错误: {len(runtime_errors)} 个")
    print(f"场景配置错误: {len(scene_errors)} 个")
    
    # 自动修复简单错误
    fix_simple_errors(syntax_errors + scene_errors)
    # 输出复杂错误修复步骤
    print_complex_fix_guide(runtime_errors)
    
    # 验证修复结果
    call_mcp_tool("verify_fix", {"project_path": "/Users/xxx/godot-projects/casual-demo"})

# 解析错误日志，提取关键信息（路径、行号、原因）
func parse_error(log: String) -> Dictionary:
    var error_info = {
        "file": "",
        "line": 0,
        "reason": "",
        "type": ""
    }
    # 匹配Godot错误日志格式：res://scripts/ui/main_ui.gd:15 - Parse Error: Unexpected token
    var regex = RegEx.new()
    regex.compile(r"res://(.*):(\d+) - (.*)")
    var match = regex.search(log)
    if match:
        error_info["file"] = "res://" + match.get_string(1)
        error_info["line"] = int(match.get_string(2))
        error_info["reason"] = match.get_string(3)
        # 识别错误类型
        if "Parse Error" in error_info["reason"]:
            error_info["type"] = "syntax"
        elif "Node not found" in error_info["reason"]:
            error_info["type"] = "node"
        elif "Anchor" in error_info["reason"]:
            error_info["type"] = "scene"
    return error_info

# 自动修复简单错误（godot-mcp执行）
func fix_simple_errors(errors: Array[Dictionary]):
    for err in errors:
        var fix_result = false
        # 修复1：语法错误 - 缺少分号
        if "Unexpected token" in err.reason and "syntax" == err.type:
            fix_result = call_mcp_tool("modify_script", {
                "file_path": err.file,
                "line": err.line,
                "replace": "添加分号结尾"
            })
        # 修复2：节点名错误（如StartBtn写成StartBt）
        elif "Node not found: StartBt" in err.reason:
            fix_result = call_mcp_tool("modify_node", {
                "scene_path": err.file.replace(".gd", ".tscn"),
                "node_path": "/Control/StartBt",
                "new_name": "StartBtn"
            })
        # 修复3：锚点预设值错误（休闲游戏移动端适配常见）
        elif "Anchor preset invalid" in err.reason:
            fix_result = call_mcp_tool("modify_node", {
                "scene_path": err.file,
                "node_path": err.reason.split(":")[1].strip(),
                "properties": {"anchors_preset": 8} # 设为下方居中
            })
        # 记录修复结果
        fix_records.append({
            "error": err,
            "fixed": fix_result,
            "fix_type": "auto"
        })

# 输出复杂错误修复指导
func print_complex_fix_guide(errors: Array[Dictionary]):
    print("\n=== 需手动修复的错误 ===")
    for i, err in enumerate(errors):
        print(f"{i+1}. 文件: {err.file} 行号: {err.line}")
        print(f"   错误原因: {err.reason}")
        # 针对UI优化常见错误给出修复建议
        if "signal 'pressed' is not connected" in err.reason:
            print(f"   修复步骤: 1. 打开{err.file}场景 → 2. 选中目标按钮 → 3. 在信号面板绑定pressed信号到对应函数")
        elif "modulate:a" in err.reason: # 透明度赋值错误
            print(f"   修复步骤: 将代码中'modulate:a'改为'modulate/alpha'，或使用Color(1,1,1,0)设置透明度")
        elif "Draw call exceeds limit" in err.reason: # UI性能错误
            print(f"   修复步骤: 合并静态UI节点 → 压缩纹理尺寸 → 减少频繁queue_redraw调用")
        print("---")