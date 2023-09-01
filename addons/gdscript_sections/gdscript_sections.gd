@tool
extends EditorPlugin

# Following Godot's official tutorial - Making plugins:
# https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html

const DATA_FOLDER := "res://addons/gdscript_sections/data/"

const Dialog := preload("res://addons/gdscript_sections/dialog.tscn")
const DataHelper := preload("res://addons/gdscript_sections/data_helper.gd")

var Godot_base_control: Control
var script_editor: ScriptEditor
var script_subcontainer: Control
var file_system_dock: FileSystemDock

var dialog: Window = Dialog.instantiate()
## The display of sections of the active script
var tree: Tree
var section_button := Button.new()
var data_helper: DataHelper = DataHelper.new()


## Initialization of the plugin goes here.
func _enter_tree() -> void:
	# Getting editor components
	Godot_base_control = get_editor_interface().get_base_control()
	script_editor = get_editor_interface().get_script_editor()
	script_subcontainer = script_editor.get_child(0)
	file_system_dock = get_editor_interface().get_file_system_dock()
	
	# File-related signals
	file_system_dock.files_moved.connect(_on_FileSystemDock_files_moved)
	file_system_dock.file_removed.connect(_on_FileSystemDock_file_removed)
	
	
	# Setting up dialog
	dialog.title = "GDSCript Sections"
	dialog.gui_embed_subwindows = true
	dialog.hide()
	
	Godot_base_control.add_child(dialog)
	
	dialog.section_added.connect(_on_Dialog_section_added)
	
	dialog.close_requested.connect(_on_Dialog_close_requested)
	dialog.get_node("%EnableCancel").pressed.connect(_on_Dialog_close_requested)
	dialog.get_node("%DisableAccept").pressed.connect(_on_Dialog_close_requested)
	
	# Visibility has been handled in dialog.gd 
	# Handles reading from and writing to file
	dialog.get_node("%Enable").pressed.connect(_on_Dialog_Enable_pressed)
	dialog.get_node("%DisableAccept").pressed.connect(_on_Dialog_DisableAccept_pressed)
	
	
	# Dialog's Background
	var background: PanelContainer = dialog.get_node("Background")
	background.add_theme_stylebox_override("panel", _get_editor_style("Content"))
	
	# Adding addon's button to Script tab
	var menu_container := script_subcontainer.get_child(0)
	menu_container.add_child(section_button)
	
	section_button.icon = _get_editor_icon("FileList")
	section_button.text = "Sections"
	section_button.tooltip_text = "Shortcut: Ctrl+U"
	section_button.focus_mode = Control.FOCUS_NONE
	section_button.toggle_mode = true
	section_button.button_pressed = false
	section_button.toggled.connect(_on_section_button_toggled)
	
	# TreeItems
	tree = background.get_node("%TreeItems")
	tree.set_column_title(0, "Goto")
	tree.set_column_title(1, "Section Name")
	tree.set_column_title(2, "Delete")
	
	# Tree's signals
	tree.button_clicked.connect(_on_TreeItems_button_clicked)
	tree.item_edited.connect(_on_TreeItems_item_edited)
	
	# Syncing theme
	Godot_base_control.theme_changed.connect(func():
		background.add_theme_stylebox_override("panel", _get_editor_style("Content"))
		section_button.icon = _get_editor_icon("FileList")
	)
	
	# Reading all enabled scripts and the unique ID
	if data_helper:
		data_helper.read()
		data_helper.id_helper.read()
	return
	

## Clean-up of the plugin goes here.
func _exit_tree() -> void:
	# Safeguard saving of data
	if data_helper:
		data_helper.write()
		data_helper.id_helper.write()
	
	if dialog:
		dialog.queue_free()
	
	if section_button:
		section_button.queue_free()
	return


## Saves data when the project is saved or closed
func _save_external_data() -> void:
	if data_helper:
#		printt("save_external", data_helper._data)
#		prints("ID:", data_helper.id_helper.get_new_id())
#		print()
		data_helper.write()
		data_helper.id_helper.write()
	return


# Private functions
func _get_editor_icon(name: StringName) -> Texture2D:
	return (
		get_editor_interface()
		.get_base_control()
		.get_theme_icon(name, "EditorIcons")
	)

func _get_editor_style(name: StringName) -> StyleBox:
	return (
		get_editor_interface()
		.get_base_control()
		.get_theme_stylebox(name, "EditorStyles")
	)


## Returns True if the currently active script is a GDScript (possibly CSharpScript too?)[br]
## Returns False if it is other types (.txt, .json, etc.) or a documentation
func _is_active_script() -> bool:
	if not script_editor.get_current_editor():
		return false

	if script_editor.get_current_script():
		return true
	else:
		return false


## Updates to display sections of the active script
func _update_TreeItems(tree: Tree) -> void:
	var sections: Array[Section] = []
	for path in data_helper.get_sections_paths(script_editor.get_current_script().get_path()):
		var sec := Section.get_from_disk(path)
#		printt("GETFROMDISK", sec.get_path(), sec.text, sec.location)
		sections.append(Section.get_from_disk(path))
	
	tree.clear()
	var root := tree.create_item()
	
	for section in sections:
#		printt(section.get_path(), section.text, section.location)
		_add_section_to_tree(tree, section)
	return


func _add_section_to_tree(tree: Tree, section: Section) -> void:
	var root := tree.get_root()
	var item := tree.create_item(root)
	
	item.add_button(0, _get_editor_icon("ArrowRight"))
	tree.set_column_expand(0, false)
	item.set_selectable(0, false)
	item.set_metadata(0, section.location)
	
	item.set_text(1, section.text)
	item.set_editable(1, true)
	tree.set_column_expand(1, true)
	
	item.add_button(2, _get_editor_icon("Remove"))
	tree.set_column_expand(2, false)
	item.set_selectable(2, false)
	item.set_metadata(2, section.get_path())
	return


# Signal callbacks
## Updates data to in-editor file manipulation
## (Move or Rename)
func _on_FileSystemDock_files_moved(old_file: String, new_file: String) -> void:
	if data_helper.is_script_enabled(old_file):
		data_helper.update_script(old_file, new_file)
	return
	

## Updates data to in-editor file manipulation
## (Remove)
func _on_FileSystemDock_file_removed(file: String) -> void:
	if data_helper.is_script_enabled(file):
		data_helper.disable_script(file)
	return


## Shows or hides the main UI (Dialog)
func _on_section_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		if not _is_active_script():
			section_button.set_pressed_no_signal(false)
			return
		
		if data_helper.is_script_enabled(script_editor.get_current_script().get_path()):
			dialog.show_main()
			_update_TreeItems(tree)
		else:
			dialog.prompt_enable_script(script_editor.get_current_script().get_path())
			
		dialog.popup()
	else:
		if dialog.visible:
			dialog.hide()
	return


## De-toggles UI button when Dialog is closed
func _on_Dialog_close_requested() -> void:
	if section_button:
		section_button.button_pressed = false
	return


## Enables the active script
func _on_Dialog_Enable_pressed() -> void:
	data_helper.enable_script(
		script_editor.get_current_script().get_path()
	)
	_update_TreeItems(tree)
	return


## Disables the active script
func _on_Dialog_DisableAccept_pressed() -> void:
	data_helper.disable_script(
		script_editor.get_current_script().get_path()
	)
	return


## Incomplete
## Adds a new section to the enabled active script[br]
## Emitted when AddSection (LineEdit) submits or AddButton is pressed 
func _on_Dialog_section_added(text: String) -> void:
	var section := Section.new()
	
	section.text = text
	section.location = 5 # Todo
	# IMPORTANT - there can be only one data helper throughout the plugin
	# Otherwise, data manipulation gets weird
	section.data_helper = data_helper
#	printt("ADDED", section.get_path(), section.text, section.location)
	
	var section_path := section.save_to_disk()
	
	data_helper.add_section_path(
		script_editor.get_current_script().get_path(),
		section_path
	)

	_update_TreeItems(tree)
	return


## Handles Goto buttons or Delete buttons of sections
func _on_TreeItems_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if not mouse_button_index == MOUSE_BUTTON_LEFT:
		return
	
	match column:
		0:
			dialog.goto(item.get_metadata(0))
			
		2:
			data_helper.delete_section_path(
				script_editor.get_current_script().get_path(),
				item.get_metadata(2)
			)
			
			Section.remove_from_disk(item.get_metadata(2))
			_update_TreeItems(tree)
			
		_:
			pass
	return


## Handles renaming of sections
func _on_TreeItems_item_edited() -> void:
	var item := tree.get_edited()
	var path := item.get_metadata(2)
	var section := Section.get_from_disk(path)
	
	section.text = item.get_text(1)
	section.update_to_disk()
	return
