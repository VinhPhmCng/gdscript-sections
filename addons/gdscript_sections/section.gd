@tool
class_name Section
extends Resource

## A custom resource that stores data of a Section

const DataHelper := preload("res://addons/gdscript_sections/data_helper.gd")

@export var text: String = ""
## The approximate line number in a CodeEdit
@export var location: int

var data_helper: DataHelper # There should only be one instance of this


## Updates itself to disk and does nothing else
func update_to_disk() -> void:
	ResourceSaver.save(self, self.get_path())
	return


## Saves newly to disk with a unique path and
## returns the save path 
func save_to_disk() -> String:
	var path := create_save_path()
	ResourceSaver.save(self, path)
#	printt("SAVETODISK", self.get_path(), self.text, self.s)
	return path
	

## Returns a unique save path
func create_save_path() -> String:
	var path := data_helper.DATA_FOLDER
	path = path.path_join("section")
	path += str(data_helper.get_new_id())
	path += ".tres"
	return path
	

## Deletes resource at "path"
static func remove_from_disk(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	return


## Returns Section resource at "path"
static func get_from_disk(path: String) -> Section:
	return ResourceLoader.load(path, "Section")
