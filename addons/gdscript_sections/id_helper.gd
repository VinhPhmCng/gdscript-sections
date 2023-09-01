@tool
#class_name
extends Resource

## A script that helps seperate unique ID generation from DataHelper

const PATH := "res://addons/gdscript_sections/data/id.dat"


var _id: int = -1:
	get = get_new_id


## Returns a new unique ID
func get_new_id() -> int:
	_id += 1
	return _id


## Reads from disk - id.dat - to _id
func read() -> void:
	var file := FileAccess.open(PATH, FileAccess.READ)
	if not file:
		printerr("Cannot read: ", PATH)
		return
	
	_id = file.get_32()
	file.close()
	return
	

## Writes _id to disk - id.dat
func write() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if _id != -1:
		file.store_32(_id)
	file.close()
	return
