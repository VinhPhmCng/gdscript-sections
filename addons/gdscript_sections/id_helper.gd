@tool
#class_name
extends Resource

const PATH := "res://addons/gdscript_sections/data/id.dat"


var _id: int = -1:
	get = get_new_id


func get_new_id() -> int:
	_id += 1
	return _id

#________________ PRIVATE METHODS ______________#

func read() -> void:
	var file := FileAccess.open(PATH, FileAccess.READ)
	if not file:
		printerr("Cannot read: ", PATH)
		return
	
	_id = file.get_32()
	file.close()
	return
	
	
func write() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if _id != -1:
		file.store_32(_id)
	file.close()
	return
