@tool
extends EditorPlugin

# Following Godot's official tutorial - Making plugins:
# https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html

const DATA_FOLDER := "res://addons/gdscript_sections/data/"

const Dialog := preload("res://addons/gdscript_sections/dialog.tscn")
const OverlayDisplay := preload("res://addons/gdscript_sections/overlay_display.tscn")
const DataHelper := preload("res://addons/gdscript_sections/data_helper.gd")

var Godot_base_control: Control
var script_editor: ScriptEditor
var script_subcontainer: Control
var file_system_dock: FileSystemDock

var active_code_edit: CodeEdit

var dialog: Window = Dialog.instantiate()
var display: Control = OverlayDisplay.instantiate()
## The display of sections of the active script
var tree: Tree
var section_button := Button.new()
var data_helper: DataHelper = DataHelper.new()


## Initialization of the plugin goes here.
func _enter_tree() -> void:
	# Reads all enabled scripts and the unique ID
	if data_helper:
		data_helper.read()
		data_helper.id_helper.read()
	
	# Gets editor components
	Godot_base_control = get_editor_interface().get_base_control()
	script_editor = get_editor_interface().get_script_editor()
	script_subcontainer = script_editor.get_child(0)
	file_system_dock = get_editor_interface().get_file_system_dock()
	
	# File-related signals
	file_system_dock.files_moved.connect(_on_FileSystemDock_files_moved)
	file_system_dock.file_removed.connect(_on_FileSystemDock_file_removed)
	
	
	# Sets up dialog
	dialog.title = "GDSCript Sections"
	dialog.gui_embed_subwindows = true
	dialog.hide()
	
	Godot_base_control.add_child(dialog)
	
	dialog.section_added.connect(_on_Dialog_section_added)
	
	dialog.close_requested.connect(_on_Dialog_close_requested)
	dialog.window_input.connect(_on_Dialog_window_input)
	dialog.get_node("%EnableCancel").pressed.connect(_on_Dialog_close_requested)
	dialog.get_node("%DisableAccept").pressed.connect(_on_Dialog_close_requested)
	dialog.get_node("%SyncTheme").pressed.connect(_on_Dialog_close_requested)
	
	# Visibility has been handled in dialog.gd 
	## Handles reading from and writing to file
	dialog.get_node("%Enable").pressed.connect(_on_Dialog_Enable_pressed)
	dialog.get_node("%DisableAccept").pressed.connect(_on_Dialog_DisableAccept_pressed)
	
	## Handles toggling display
	dialog.get_node("%Show").toggled.connect(_on_Dialog_Show_toggled)
	## Handles syncing theme
	dialog.get_node("%SyncTheme").pressed.connect(_on_Dialog_SyncTheme_pressed)
	
	# Dialog's Background
	var background: PanelContainer = dialog.get_node("Background")
	background.add_theme_stylebox_override("panel", _get_editor_style("Content"))
	
	# Adds addon's button to Script tab
	var menu_container := script_subcontainer.get_child(0)
	menu_container.add_child(section_button)
	
	# Configures Tree
	section_button.icon = _get_editor_icon("FileList")
	section_button.text = "Sections"
	section_button.tooltip_text = "Shortcut: Ctrl+U"
	section_button.focus_mode = Control.FOCUS_NONE
	section_button.toggle_mode = true
	section_button.set_pressed(false)
	section_button.toggled.connect(_on_section_button_toggled)
	
	# TreeItems
	tree = background.get_node("%TreeItems")
	tree.set_column_title(0, "Goto")
	tree.set_column_title(1, "Section Name")
	tree.set_column_title(2, "Delete")
	
	# Tree's signals
	tree.button_clicked.connect(_on_TreeItems_button_clicked)
	tree.item_edited.connect(_on_TreeItems_item_edited)
	
	# Script-editing-related signal
	script_editor.editor_script_changed.connect(_on_ScriptEditor_editor_script_changed)
	_on_ScriptEditor_editor_script_changed(script_editor.get_current_script()) # Trigger for first time enabling

	# Syncing theme
	Godot_base_control.theme_changed.connect(func():
		background.add_theme_stylebox_override("panel", _get_editor_style("Content"))
		section_button.icon = _get_editor_icon("FileList")
		dialog.get_node("%Show").set_pressed(false)
	)
	
	# OverlayDisplay's signals
	display.section_display_relocated.connect(_on_SectionDisplay_relocated)
	
	return
	

## Clean-up of the plugin goes here.
func _exit_tree() -> void:
	# Safeguard saving of data
	if data_helper:
		data_helper.write()
		data_helper.id_helper.write()
	
	if display:
		display.queue_free()
	
	if dialog:
		dialog.queue_free()
	
	if section_button:
		section_button.queue_free()
	return


## Saves data when the project is saved or closed
func _save_external_data() -> void:
	if data_helper:
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


func _get_active_code_edit() -> CodeEdit:
	return (
		script_editor
		.get_current_editor()
		.get_base_editor()
	)


func _get_active_code_edit_height() -> float:
	return (
		_get_active_code_edit().get_line_count()
		*
		_get_active_code_edit().get_line_height()
	)


func _disconnect_signals_previous_code_edit() -> void:
	if not active_code_edit:
		return
		
	if active_code_edit.gui_input.is_connected(_on_active_code_edit_gui_input):
		active_code_edit.gui_input.disconnect(_on_active_code_edit_gui_input)
		
	if active_code_edit.text_changed.is_connected(_on_active_code_edit_height_changed):
		active_code_edit.text_changed.disconnect(_on_active_code_edit_height_changed)
		
#	if active_code_edit.get_v_scroll_bar().changed.is_connected(_on_active_code_edit_VScrollBar_changed):
#		active_code_edit.get_v_scroll_bar().changed.disconnect(_on_active_code_edit_VScrollBar_changed)

	if active_code_edit.get_v_scroll_bar().value_changed.is_connected(_on_active_code_edit_VScrollBar_value_changed):
		active_code_edit.get_v_scroll_bar().value_changed.disconnect(_on_active_code_edit_VScrollBar_value_changed)
	return


func _connect_signals_active_code_edit() -> void:
	if not active_code_edit:
		return
	
	active_code_edit.gui_input.connect(_on_active_code_edit_gui_input)
	active_code_edit.text_changed.connect(_on_active_code_edit_height_changed)
#	active_code_edit.get_v_scroll_bar().changed.connect(_on_active_code_edit_VScrollBar_changed)
	active_code_edit.get_v_scroll_bar().value_changed.connect(_on_active_code_edit_VScrollBar_value_changed)
	return


func _update_ui_and_display() -> void:
	var sections: Array[Section] = []
	if dialog.get_node("%Show").button_pressed:
		sections = data_helper.get_sections(script_editor.get_current_script().get_path(), false)
		
	display.update(
		_get_active_code_edit(),
		sections
	)
	_update_TreeItems(tree)
	return


## Updates to display sections of the active script
func _update_TreeItems(tree: Tree) -> void:
	var sections: Array[Section] = data_helper.get_sections(
		script_editor.get_current_script().get_path(),
		true
	)

	tree.clear()
	var root := tree.create_item()

	for section in sections:
		_add_section_to_tree(tree, section)
	return


func _add_section_to_tree(tree: Tree, section: Section) -> void:
	var root := tree.get_root()
	var item := tree.create_item(root)
	if not item:
		return
	
	item.add_button(0, _get_editor_icon("ArrowRight"))
	tree.set_column_expand(0, false)
	tree.set_column_custom_minimum_width(0, 25)
	item.set_selectable(0, false)
	item.set_metadata(0, section.location)

	item.set_text(1, section.text)
	item.set_selectable(1, true)
	item.set_editable(1, true)
	item.set_autowrap_mode(1, TextServer.AUTOWRAP_WORD_SMART)
	tree.set_column_expand(1, true)
	tree.set_column_clip_content(1, true)
	
	item.add_button(2, _get_editor_icon("Remove"))
	tree.set_column_expand(2, false)
	item.set_selectable(2, false)
	item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
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
		else:
			dialog.prompt_enable_script(script_editor.get_current_script().get_path())
			
		dialog.popup()
	else:
		if dialog.visible:
			dialog.hide()
	return


func _on_Dialog_window_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if OS.get_keycode_string(event.get_key_label_with_modifiers()) == "Ctrl+U":
			section_button.set_pressed(false)
	return


## De-toggles UI button when Dialog is closed
func _on_Dialog_close_requested() -> void:
	if section_button:
		section_button.set_pressed(false)
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


func _on_Dialog_Show_toggled(button_pressed: bool) -> void:
	var sections: Array[Section] = []
	
	if button_pressed:
		sections = data_helper.get_sections(script_editor.get_current_script().get_path(), false)
		_on_active_code_edit_height_changed()

	display.update(
		_get_active_code_edit(),
		sections
	)
	return


func _on_Dialog_SyncTheme_pressed() -> void:
	var sections: Array[Section] = []
	if dialog.get_node("%Show").button_pressed:
		sections = data_helper.get_sections(script_editor.get_current_script().get_path(), false)
		_on_active_code_edit_height_changed()
		
	display.update(
		_get_active_code_edit(),
		sections
	)
	return


## Incomplete
## Adds a new section to the enabled active script[br]
## Emitted when AddSection (LineEdit) submits or AddButton is pressed 
func _on_Dialog_section_added(text: String) -> void:
	var section := Section.new()
	
	section.text = text
	section.location = (
		_get_active_code_edit().get_caret_line()
#		*
#		_get_active_code_edit().get_line_height()
	)
	_get_active_code_edit().center_viewport_to_caret()
	
	# IMPORTANT - there can be only one data helper throughout the plugin
	# Otherwise, data manipulation gets weird
	section.data_helper = data_helper
	
	var section_path := section.save_to_disk()
	
	data_helper.add_section_path(
		script_editor.get_current_script().get_path(),
		section_path
	)

	_update_ui_and_display()
	return


## Handles Goto buttons or Delete buttons of sections
func _on_TreeItems_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if not mouse_button_index == MOUSE_BUTTON_LEFT:
		return
	
	match column:
		0: # Goto
			_get_active_code_edit().get_v_scroll_bar().value = (
				item.get_metadata(0)
			)
			
		2: # Deletion
			data_helper.delete_section_path(
				script_editor.get_current_script().get_path(),
				item.get_metadata(2)
			)
			
			Section.remove_from_disk(item.get_metadata(2))
			_update_ui_and_display()
			
		_:
			pass
	return


## Handles renaming of sections
func _on_TreeItems_item_edited() -> void:
	var item := tree.get_edited()
	var path := item.get_metadata(2)
	var section := Section.get_from_disk(path)
	
	# Setting text
	section.text = item.get_text(1)
	
	section.update_to_disk()
	_update_ui_and_display()
	return
	
	
func _on_ScriptEditor_editor_script_changed(script: Script) -> void:
#	printt("OPEN:", script.get_path())
	if not _is_active_script(): # Safeguard (unnecessary?)
		return
		
	_disconnect_signals_previous_code_edit()
	active_code_edit = _get_active_code_edit()
	_connect_signals_active_code_edit()
	
#	printt("TEST", _get_active_code_edit().get_v_scroll_bar().value)
	_on_active_code_edit_height_changed()
#	printt(
#		script_editor.get_current_script().get_path(),
#		data_helper._data,
#		data_helper.get_sections_paths(script_editor.get_current_script().get_path()),
#		data_helper.get_sections(script_editor.get_current_script().get_path(), false),
#	)

	_update_ui_and_display()
	
	# Emulates scroll
	_on_active_code_edit_VScrollBar_value_changed(
		floorf(_get_active_code_edit().get_v_scroll_bar().value)
		*
		_get_active_code_edit().get_line_height()
	)
	return


func _on_active_code_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if OS.get_keycode_string(event.get_key_label_with_modifiers()) == "Ctrl+U":
			section_button.set_pressed(true)
	return


func _on_active_code_edit_height_changed() -> void:
	var scroll: ScrollContainer = display.get_node("ScrollContainer")
	var sections_display: Control = display.get_node("%SectionsDisplay")
	sections_display.set_custom_minimum_size(Vector2(
		sections_display.get_custom_minimum_size().x,
		_get_active_code_edit_height()
	))
	return


#func _on_active_code_edit_VScrollBar_changed() -> void:
#	var scroll: ScrollContainer = display.get_node("ScrollContainer")
#	var sections_display: Control = display.get_node("%SectionsDisplay")
#	return
	

func _on_active_code_edit_VScrollBar_value_changed(value: float) -> void:
	var scroll: ScrollContainer = display.get_node("ScrollContainer")
	var sections_display: Control = display.get_node("%SectionsDisplay")
	
#	printt("BEFORE SCROLL", scroll.get_v_scroll_bar().value)
#	printt(_get_active_code_edit().get_v_scroll_bar().value, value)
	scroll.get_v_scroll_bar().value = (
		floorf(value)
		*
		_get_active_code_edit().get_line_height()
	)
#	printt("SCROLLING", scroll.get_v_scroll_bar().value)


#	printt(
#		"DISPLAY:",
#		sections_display.get_custom_minimum_size(),
#		scroll.get_v_scroll_bar().min_value,
#		scroll.get_v_scroll_bar().max_value,
#		scroll.get_v_scroll_bar().value,
#	)
#	printt(
#		"GODOT:",
#		_get_active_code_edit().get_v_scroll_bar().min_value,
#		_get_active_code_edit().get_v_scroll_bar().max_value,
#		_get_active_code_edit().get_v_scroll_bar().value,
#	)
#	print()
	
#	print(_get_active_code_edit().get_v_scroll())
	
	return


func _on_SectionDisplay_relocated(which: Control, event: InputEventMouseMotion) -> void:
	var total_relative_y := which.get_meta("total_relative_y")
	total_relative_y += event.relative.y
	
	while abs(total_relative_y) >= _get_active_code_edit().get_line_height():
		if total_relative_y > 0:
			which.position.y += _get_active_code_edit().get_line_height()
			total_relative_y -= _get_active_code_edit().get_line_height()
		else:
			which.position.y -= _get_active_code_edit().get_line_height()
			total_relative_y += _get_active_code_edit().get_line_height()
		
	which.set_meta("total_relative_y", total_relative_y)
	
	var section: Section = which.get_meta("section_resource")
#	printt(section, section.get_path())
	section.location = which.position.y / _get_active_code_edit().get_line_height()
	section.update_to_disk()
	return
