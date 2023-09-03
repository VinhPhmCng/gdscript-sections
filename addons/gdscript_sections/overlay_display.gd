@tool
#class_name
extends Control

## The "container" for SectionDisplays[br]
## It will be added as a child to the currently active CodeEdit.
## It takes the full size of said CodeEdit, its scroll properties,
## and has the responsibility to syncs its own scrolling to that of the CodeEdit.

signal section_display_relocated(which: Control, event: InputEventMouseMotion)

## The display of a single Section resource
## Not to be confused with OverlayDisplay or SectionsDisplay
const SectionDisplay := preload("res://addons/gdscript_sections/section_display.tscn")


## Relocates itself to a new parent and
## displays the new SectionDisplays
func update(new_parent: CodeEdit, sections: Array[Section]) -> void:
	if get_parent():
		get_parent().remove_child(self)
	new_parent.add_child(self)
	
	# Ensures this parent will remove the OverlayDisplay
	# before being freed
	new_parent.tree_exiting.connect(func():
		new_parent.remove_child(self)
	)
	
	# Removes previous display
	for child in %SectionsDisplay.get_children():
		%SectionsDisplay.remove_child(child)
		child.queue_free()
	
	# Sets up new display
	for section in sections:
		var section_display := SectionDisplay.instantiate()
		%SectionsDisplay.add_child(section_display)
		section_display.set_deferred("size:y", new_parent.get_line_height())
		section_display.get_node("%Text").text = "   " + section.text
		section_display.get_node("%Text").add_theme_font_size_override(
			"font_size",
			new_parent.get_theme_font_size("font_size") + 2
		)
		section_display.position.y = section.location * new_parent.get_line_height()
		section_display.get_node("PaddingGutters").custom_minimum_size.x = new_parent.get_total_gutter_width()
		section_display.get_node("PaddingMinimap").custom_minimum_size.x = new_parent.get_minimap_width()
		section_display.get_node("PaddingGutters").size.x = new_parent.get_total_gutter_width()
		section_display.get_node("PaddingMinimap").size.x = new_parent.get_minimap_width()
		section_display.get_node("Main").gui_input.connect(_on_SectionDisplay_Main_gui_input.bind(section_display))
		section_display.set_meta("section_resource", section)
		section_display.set_meta("total_relative_y", 0.0)
	return


## Handles user's relocation of a SectionDisplay[br]
## Sends signals to EditorPlugin to gets its merits
func _on_SectionDisplay_Main_gui_input(event: InputEvent, which: Control) -> void:
	if event is InputEventMouseMotion:
		if not event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			return
		
		section_display_relocated.emit(which, event)
	return

