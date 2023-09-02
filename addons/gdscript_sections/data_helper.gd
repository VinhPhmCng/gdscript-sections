@tool
#class_name
extends Resource

## A script that helps seperate data manipulation from the main UI


const DATA_FOLDER := "res://addons/gdscript_sections/data/"
const DATA_PATH := "res://addons/gdscript_sections/data/data.json"

const IDHelper := preload("res://addons/gdscript_sections/id_helper.gd")


var id_helper: IDHelper = IDHelper.new()


var _data: Dictionary


## Returns a new unique ID
func get_new_id() -> int:
	return id_helper.get_new_id()


## Returns True if the path exists as a key, False otherwise
func is_script_enabled(path: String) -> bool:
	return _data.has(path)


## Adds a new path as a key
func enable_script(path: String) -> void:
	_data[path] = []
	return


## Removes a path from existing keys
func disable_script(path: String) -> void:
	for section in get_sections_paths(path):
		Section.remove_from_disk(section)
	
	_data.erase(path)
	return


## Cuts value from old key to new key
func update_script(old_path: String, new_path) -> void:
	var value := _data.get(old_path, [])
	_data[new_path] = value
	_data.erase(old_path)
	return


## Returns the value (an array of paths of Sections) of an enabled script's path (key)
func get_sections_paths(script_path: String) -> Array:
	return _data.get(script_path, [])


func get_sections(script_path: String, do_sort_by_location: bool) -> Array[Section]:
	var sections: Array[Section] = []
	for path in get_sections_paths(script_path):
		sections.append(Section.get_from_disk(path))
	
	if not do_sort_by_location:
		return sections
	
	# Does sort
	sections.sort_custom(func(a: Section, b: Section):
		if a.location < b.location:
			return true
		return false
	)
	return sections


## Adds a Section's path (value) to an enabled script's path (key)
func add_section_path(script_path: String, section_path: String) -> void:
	var sections: Array = _data.get(script_path, [])
	sections.append(section_path)
	_data[script_path] = sections
	return


## Deletes a Section's path (value) from an enabled script's path (key)
func delete_section_path(script_path: String, section_path: String) -> void:
	var sections: Array = _data[script_path]
	sections.erase(section_path)
	_data[script_path] = sections
	return


## Reads from disk - data.json - to _data
func read() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	var content := file.get_as_text()
	var data := JSON.parse_string(content)
	
	if typeof(data) == TYPE_DICTIONARY:
		_data = data
	else:
		print("Loading data.json failed")
	return


## Write _data to disk - data.json
func write() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.WRITE)
	
	var content := JSON.stringify(_data, "\t")
	file.store_string(content)
	return
