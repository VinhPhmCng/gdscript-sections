@tool
class_name Section
extends Resource

const DataHelper := preload("res://addons/gdscript_sections/data_helper.gd")

@export var text: String = ""
@export var location: int 

var data_helper: DataHelper

#func _init(new_text: String, new_location: int) -> void:
#	text = new_text
#	location = new_location
#	return


func update_to_disk() -> void:
	ResourceSaver.save(self, self.get_path())
	return


func save_to_disk() -> String:
	var path := create_save_path()
	ResourceSaver.save(self, path)
#	printt("SAVETODISK", self.get_path(), self.text, self.location)
	return path
	
	
func create_save_path() -> String:
	var path := data_helper.DATA_FOLDER
	path = path.path_join("section")
	path += str(data_helper.get_new_id())
	path += ".tres"
	return path
	
	
static func remove_from_disk(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	return


static func get_from_disk(path: String) -> Section:
	return ResourceLoader.load(path, "Section")
