# 保存管理器
extends RefCounted

class_name SaveManager

# 保存数据到JSON文件
func save_data(data: Dictionary, file_path: String) -> bool:
	# 创建File对象
	var file = FileAccess.new()
	
	# 尝试打开文件，写入模式
	var error = file.open(file_path, FileAccess.WRITE)
	
	if error != Error.OK:
		print("保存文件失败: %s" % error)
		return false
	
	# 转换为JSON字符串
	var json_string = JSON.stringify(data, "  ")  # 缩进2个空格
	
	# 写入文件
	file.store_string(json_string)
	
	# 关闭文件
	file.close()
	
	return true

# 从JSON文件加载数据
func load_data(file_path: String) -> Dictionary:
	# 创建File对象
	var file = FileAccess.new()
	
	# 尝试打开文件，读取模式
	var error = file.open(file_path, FileAccess.READ)
	
	if error != Error.OK:
		print("加载文件失败: %s" % error)
		return {}
	
	# 读取文件内容
	var json_string = file.get_as_text()
	
	# 关闭文件
	file.close()
	
	# 解析JSON字符串
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != Error.OK:
		print("解析JSON失败: %s" % json.get_error_message())
		return {}
	
	# 返回解析后的数据
	return json.data

# 检查文件是否存在
func file_exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)

# 删除文件
func delete_file(file_path: String) -> bool:
	if not file_exists(file_path):
		return true  # 文件不存在，视为删除成功
	
	var error = FileAccess.remove(file_path)
	
	if error != Error.OK:
		print("删除文件失败: %s" % error)
		return false
	
	return true

# 备份文件
func backup_file(file_path: String) -> bool:
	if not file_exists(file_path):
		return false  # 源文件不存在，无法备份
	
	var backup_path = file_path + ".bak"
	
	# 删除旧备份
	delete_file(backup_path)
	
	# 创建File对象
	var src_file = FileAccess.new()
	var dst_file = FileAccess.new()
	
	# 打开源文件
	var error = src_file.open(file_path, FileAccess.READ)
	if error != Error.OK:
		print("打开源文件失败: %s" % error)
		return false
	
	# 打开目标文件
	error = dst_file.open(backup_path, FileAccess.WRITE)
	if error != Error.OK:
		print("打开目标文件失败: %s" % error)
		src_file.close()
		return false
	
	# 复制文件内容
	dst_file.store_string(src_file.get_as_text())
	
	# 关闭文件
	src_file.close()
	dst_file.close()
	
	return true
