@tool
#class_name
extends Resource

# docstring


#___________________ SIGNALS ___________________#



#____________________ ENUMS ____________________#



#__________________ CONSTANTS __________________#

const DATA_FOLDER := "res://addons/gdscript_sections/data/"
const DATA_PATH := "res://addons/gdscript_sections/data/data.json"

const IDHelper := preload("res://addons/gdscript_sections/id_helper.gd")

#______________ EXPORTED VARIABLES _____________#



#_______________ PUBLIC VARIABLES ______________#

var id_helper: IDHelper = IDHelper.new()

#_______________ PRIVATE VARIABLES _____________#

var _data: Dictionary


#______________ ONREADY VARIABLES ______________#



#___________________ _init() ___________________#



#________________ _enter_tree() ________________#



#___________________ _ready() __________________#
func _init() -> void:
	return



#_______________ VIRTUAL METHODS _______________#



#________________ PUBLIC METHODS _______________#

func get_new_id() -> int:
	return id_helper.get_new_id()


func is_script_enabled(path: String) -> bool:
	return _data.has(path)


func enable_script(path: String) -> void:
	_data[path] = []
	return


func disable_script(path: String) -> void:
	_data.erase(path)
	return


func update_script(old_path: String, new_path) -> void:
	var value := _data.get(old_path, [])
	_data[new_path] = value
	_data.erase(old_path)
	return


func get_sections_path(script_path: String) -> Array:
	return _data.get(script_path, [])


func add_section_path(script_path: String, section_path: String) -> void:
	var sections: Array = _data[script_path]
	sections.append(section_path)
	_data[script_path] = sections
	
	return


func delete_section_path(script_path: String, section_path: String) -> void:
	var sections: Array = _data[script_path]
	sections.erase(section_path)
	_data[script_path] = sections
	
	return


func update_section(script_path: String, section_path: String) -> void:
	
	return


#________________ PRIVATE METHODS ______________#

func read() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	var content := file.get_as_text()
	var data := JSON.parse_string(content)
	
	if typeof(data) == TYPE_DICTIONARY:
		_data = data
	else:
		print("Loading data.json failed")
	return


func write() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.WRITE)
	
	var content := JSON.stringify(_data, "\t")
	file.store_string(content)
	return

#_______________ SIGNAL CALLBACKS ______________#

#--------------- Internal ---------------#



#--------------- External ---------------#



