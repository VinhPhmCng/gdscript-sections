@tool
#class_name
extends Control

# docstring


#___________________ SIGNALS ___________________#

signal section_display_relocated(which: Control, event: InputEventMouseMotion)

#____________________ ENUMS ____________________#



#__________________ CONSTANTS __________________#

const SectionDisplay := preload("res://addons/gdscript_sections/section_display.tscn")

#______________ EXPORTED VARIABLES _____________#



#_______________ PUBLIC VARIABLES ______________#



#_______________ PRIVATE VARIABLES _____________#



#______________ ONREADY VARIABLES ______________#



#___________________ _init() ___________________#



#________________ _enter_tree() ________________#



#___________________ _ready() __________________#
func _ready() -> void:
	pass



#_______________ VIRTUAL METHODS _______________#



#________________ PUBLIC METHODS _______________#

func update(new_parent: CodeEdit, sections: Array[Section]) -> void:
	if get_parent():
		get_parent().remove_child(self)
	new_parent.add_child(self)
	
	for child in %SectionsDisplay.get_children():
		%SectionsDisplay.remove_child(child)
		child.queue_free()
	
	for section in sections:
		var display := SectionDisplay.instantiate()
		%SectionsDisplay.add_child(display)
		display.set_deferred("size:y", new_parent.get_line_height())
		display.get_node("%Text").text = "   " + section.text
		display.get_node("%Text").add_theme_font_size_override(
			"font_size",
			new_parent.get_theme_font_size("font_size")
		)
		display.position.y = section.location * new_parent.get_line_height()
		display.get_node("PaddingGutters").custom_minimum_size.x = new_parent.get_total_gutter_width()
		display.get_node("PaddingMinimap").custom_minimum_size.x = new_parent.get_minimap_width()
		display.get_node("PaddingGutters").size.x = new_parent.get_total_gutter_width()
		display.get_node("PaddingMinimap").size.x = new_parent.get_minimap_width()
		display.get_node("Main").gui_input.connect(_on_SectionDisplay_Main_gui_input.bind(display))
		display.set_meta("section_resource", section)
		display.set_meta("total_relative_y", 0.0)
	return

#________________ PRIVATE METHODS ______________#



#_______________ SIGNAL CALLBACKS ______________#

#--------------- Internal ---------------#



#--------------- External ---------------#

func _on_SectionDisplay_Main_gui_input(event: InputEvent, which: Control) -> void:
	if event is InputEventMouseMotion:
		if not event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			return
		
		section_display_relocated.emit(which, event)
		
	return

