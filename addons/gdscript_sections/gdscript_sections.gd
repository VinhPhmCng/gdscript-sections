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
var active_code_edit: CodeEdit # Keeping a reference to deal with signal connections
var dialog: Window = Dialog.instantiate()
var display: Control = OverlayDisplay.instantiate()
var tree: Tree # The UI display of sections of the active script
var addon_button := Button.new()
var data_helper: DataHelper = DataHelper.new()


## Initialization of the plugin goes here.
func _enter_tree() -> void:
	# Reads all enabled scripts and the unique ID
	if data_helper:
		data_helper.read()
		data_helper.id_helper.read()
	
	# Gets Godot editor's components
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
	dialog.set_font_size(14)
	
	dialog.section_added.connect(_on_Dialog_section_added)
	
	dialog.close_requested.connect(_on_Dialog_close_requested)
	dialog.window_input.connect(_on_Dialog_window_input)
	dialog.get_node("%EnableCancel").pressed.connect(_on_Dialog_close_requested)
	dialog.get_node("%DisableAccept").pressed.connect(_on_Dialog_close_requested)
	dialog.get_node("%SyncTheme").pressed.connect(_on_Dialog_close_requested)
	
	# Visibility has been handled in dialog.gd 
	## Handles reading from and writing to file
	dialog.get_node("%Enable").pressed.connect(_on_Dialog_Enable_pressed)
	dialog.get_node("%Disable").pressed.connect(_on_Dialog_Disable_pressed)
	dialog.get_node("%DisableAccept").pressed.connect(_on_Dialog_DisableAccept_pressed)
	## Handles toggling display
	dialog.get_node("%Show").toggled.connect(_on_Dialog_Show_toggled)
	## Handles syncing theme
	dialog.get_node("%SyncTheme").pressed.connect(_on_Dialog_SyncTheme_pressed)
	
	# Dialog's theme
	var background: PanelContainer = dialog.get_node("Background")
	background.add_theme_stylebox_override("panel", _get_editor_style("Content"))
	
	# Adds addon's button to Script tab
	var menu_container := script_subcontainer.get_child(0)
	menu_container.add_child(addon_button)
	
	# Configures addon's button
	addon_button.icon = _get_editor_icon("FileList")
	addon_button.text = "Sections"
	addon_button.tooltip_text = "Shortcut: Ctrl+U"
	addon_button.focus_mode = Control.FOCUS_NONE
	addon_button.toggle_mode = true
	addon_button.set_pressed(false)
	addon_button.toggled.connect(_on_addon_button_toggled)
	
	# Configures TreeItems
	tree = background.get_node("%TreeItems")
	tree.set_column_title(0, "Goto")
	tree.set_column_title(1, "Section Name")
	tree.set_column_title(2, "Delete")
	
	# Tree's signals
	tree.button_clicked.connect(_on_TreeItems_button_clicked)
	tree.item_edited.connect(_on_TreeItems_item_edited)
	
	# Script-editing-related signal
	script_editor.editor_script_changed.connect(_on_ScriptEditor_editor_script_changed)
	# Triggers once in case user enables the addon while opening a script
	_on_ScriptEditor_editor_script_changed(script_editor.get_current_script())

	# Syncs theme
	# Also hides the display - to maintain consistency and reduce workload
	Godot_base_control.theme_changed.connect(func():
		background.add_theme_stylebox_override("panel", _get_editor_style("Content"))
		addon_button.icon = _get_editor_icon("FileList")
		dialog.get_node("%Show").set_pressed(false)
	)
	
	# OverlayDisplay's signals
	display.section_display_relocated.connect(_on_SectionDisplay_relocated)
	return
	

## Clean-up of the plugin goes here.
func _exit_tree() -> void:
	# Ensures saving of data
	if data_helper:
		data_helper.write()
		data_helper.id_helper.write()
	
	if display:
		display.queue_free()
	
	if dialog:
		dialog.queue_free()
	
	if addon_button:
		addon_button.queue_free()
	return


## Saves data when the project is saved or closed
func _save_external_data() -> void:
	if data_helper:
		data_helper.write()
		data_helper.id_helper.write()
	return



## Returns Godot editor's icon
func _get_editor_icon(name: StringName) -> Texture2D:
	return (
		get_editor_interface()
		.get_base_control()
		.get_theme_icon(name, "EditorIcons")
	)


## Returns Godot editor's stylebox
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


## Returns the CodeEdit responsible for editing the currently active script
func _get_active_code_edit() -> CodeEdit:
	return (
		script_editor
		.get_current_editor()
		.get_base_editor()
	)


## Returns the active CodeEdit's total height
func _get_active_code_edit_height() -> float:
	return (
		_get_active_code_edit().get_line_count()
		*
		_get_active_code_edit().get_line_height()
	)


## Disconnects the active CodeEdit's signals[br]
## "previous" is for clarity and readibility
func _disconnect_signals_previous_code_edit() -> void:
	if not active_code_edit:
		return
		
	if active_code_edit.gui_input.is_connected(_on_active_code_edit_gui_input):
		active_code_edit.gui_input.disconnect(_on_active_code_edit_gui_input)
		
	if active_code_edit.text_changed.is_connected(_on_active_code_edit_height_changed):
		active_code_edit.text_changed.disconnect(_on_active_code_edit_height_changed)

	if active_code_edit.get_v_scroll_bar().value_changed.is_connected(_on_active_code_edit_VScrollBar_value_changed):
		active_code_edit.get_v_scroll_bar().value_changed.disconnect(_on_active_code_edit_VScrollBar_value_changed)
	return


## Connects the active CodeEdit's signals
func _connect_signals_active_code_edit() -> void:
	if not active_code_edit:
		return
	
	active_code_edit.gui_input.connect(_on_active_code_edit_gui_input)
	active_code_edit.text_changed.connect(_on_active_code_edit_height_changed)
#	active_code_edit.get_v_scroll_bar().changed.connect(_on_active_code_edit_VScrollBar_changed)
	active_code_edit.get_v_scroll_bar().value_changed.connect(_on_active_code_edit_VScrollBar_value_changed)
	return


## Updates both UI display and OverlayDisplay
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


## Add a TreeItem (row) with Goto button, Name field, and Delete button
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



## Updates data when a in-editor file is manipulated
## (Move or Rename)
func _on_FileSystemDock_files_moved(old_file: String, new_file: String) -> void:
	if data_helper.is_script_enabled(old_file):
		data_helper.update_script(old_file, new_file)
	return
	

## Updates data when a in-editor file is manipulated
## (Remove)
func _on_FileSystemDock_file_removed(file: String) -> void:
	if data_helper.is_script_enabled(file):
		data_helper.disable_script(file)
	return


## Shows or hides the main UI (Dialog)
func _on_addon_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		if not _is_active_script():
			addon_button.set_pressed_no_signal(false)
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


## Handles shortcuts when the main UI (Dialog) is shown
func _on_Dialog_window_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if OS.get_keycode_string(event.get_key_label_with_modifiers()) == "Ctrl+U":
			addon_button.set_pressed(false) # Hides main UI (Dialog)
	return


## De-toggles UI button when Dialog is closed
func _on_Dialog_close_requested() -> void:
	if addon_button:
		addon_button.set_pressed(false)
	return


## Enables the active script
func _on_Dialog_Enable_pressed() -> void:
	data_helper.enable_script(
		script_editor.get_current_script().get_path()
	)
	_update_TreeItems(tree)
	return


## Updates disable prompt
func _on_Dialog_Disable_pressed() -> void:
	dialog.prompt_disable_script(script_editor.get_current_script().get_path())
	return


## Disables the active script
func _on_Dialog_DisableAccept_pressed() -> void:
	data_helper.disable_script(
		script_editor.get_current_script().get_path()
	)
	return


## Updates OverlayDisplay only
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


## Updates OverlayDisplay only
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


## Adds a new section to the enabled active script.
## Its location will be set to the line holding the caret.[br]
## Emitted when AddSection (LineEdit) submits or AddButton is pressed 
func _on_Dialog_section_added(text: String) -> void:
	var section := Section.new()
	section.text = text
	section.location = _get_active_code_edit().get_caret_line()
	_get_active_code_edit().center_viewport_to_caret()
	
	# IMPORTANT - There can be only one instance of DataHelper throughout the addon.
	# Otherwise, data manipulation gets weird.
	section.data_helper = data_helper
	
	var section_path := section.save_to_disk()
	
	data_helper.add_section_path(
		script_editor.get_current_script().get_path(),
		section_path
	)

	_update_ui_and_display()
	return


## Handles button presses of main UI (Tree)
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
	
	section.text = item.get_text(1)
	
	section.update_to_disk()
	_update_ui_and_display()
	return
	

## Updates everthing correspondingly to the newly activated script
func _on_ScriptEditor_editor_script_changed(script: Script) -> void:
	if not _is_active_script(): # Safeguard (unnecessary?)
		return
	
	# Redirects signals
	_disconnect_signals_previous_code_edit()
	active_code_edit = _get_active_code_edit()
	_connect_signals_active_code_edit()

	# Updates 
	_on_active_code_edit_height_changed()
	_update_ui_and_display()

	# Emulates scroll
	_on_active_code_edit_VScrollBar_value_changed(
		floorf(_get_active_code_edit().get_v_scroll_bar().value)
		*
		_get_active_code_edit().get_line_height()
	)
	return


## Handles shortcuts when the main UI (Dialog) is hidden
func _on_active_code_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if OS.get_keycode_string(event.get_key_label_with_modifiers()) == "Ctrl+U":
			addon_button.set_pressed(true)
			
		if OS.get_keycode_string(event.get_key_label_with_modifiers()) == "Ctrl+J":
			dialog.get_node("%Show").set_pressed(
				not dialog.get_node("%Show").button_pressed
			)
	return


## Updates the height of the Control that is responsible for current SectionDisplays
func _on_active_code_edit_height_changed() -> void:
	var scroll: ScrollContainer = display.get_node("ScrollContainer")
	var sections_display: Control = display.get_node("%SectionsDisplay")
	sections_display.set_custom_minimum_size(Vector2(
		sections_display.get_custom_minimum_size().x,
		_get_active_code_edit_height()
	))
	return
	

## Syncs scrolling of active CodeEdit to that of OverlayDisplay
func _on_active_code_edit_VScrollBar_value_changed(value: float) -> void:
	var scroll: ScrollContainer = display.get_node("ScrollContainer")
	var sections_display: Control = display.get_node("%SectionsDisplay")
	
	scroll.get_v_scroll_bar().value = (
		floorf(value)
		*
		_get_active_code_edit().get_line_height()
	)
	return


## Handles user's relocation of a SectionDisplay
func _on_SectionDisplay_relocated(which: Control, event: InputEventMouseMotion) -> void:
	var total_relative_y := which.get_meta("total_relative_y") # Accumulation of previous events
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
	section.location = which.position.y / _get_active_code_edit().get_line_height()
	section.update_to_disk()
	return
