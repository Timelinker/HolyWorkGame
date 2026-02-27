# 玩家属性类型定义
extends RefCounted

class_name AttributeTypes

# 职业等级对应的称号
const JOB_TITLES = {
	1: "初级产品经理",
	2: "中级产品经理",
	3: "高级产品经理",
	4: "产品总监",
	5: "产品副总裁",
	6: "产品总裁"
}

# 初始属性值
const INITIAL_ATTRIBUTES = {
	"daily_expense": 0,
	"daily_income": 0,
	"money": 0,
	"stamina": 100,
	"age": 20,
	"job_title": "初级产品经理",
	"level": 1,
	"exp": 0,
	"exp_max": 100,
	"salary": 10
}

# 体力恢复速率（每小时恢复量）
const STAMINA_RECOVERY_RATE = 5  # 每小时恢复5点体力

# 工作消耗体力
const WORK_STAMINA_COST = 5  # 每次工作消耗5点体力

# 工作获得经验值
const WORK_EXP_GAIN = 10  # 每次工作获得10点经验

# 经验值上限系数（每级增加的倍数）
const EXP_MAX_MULTIPLIER = 1.5  # 每级经验上限是前一级的1.5倍

# 工资增长系数（每级增加的倍数）
const SALARY_MULTIPLIER = 1.2  # 每级工资是前一级的1.2倍

# 保存文件路径
const SAVE_FILE_PATH = "user://player_attributes.json"
