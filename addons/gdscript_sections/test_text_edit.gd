#@tool
#class_name
extends CodeEdit

# docstring


#___________________ SIGNALS ___________________#



#____________________ ENUMS ____________________#



#__________________ CONSTANTS __________________#



#______________ EXPORTED VARIABLES _____________#



#_______________ PUBLIC VARIABLES ______________#



#_______________ PRIVATE VARIABLES _____________#



#______________ ONREADY VARIABLES ______________#



#___________________ _init() ___________________#



#________________ _enter_tree() ________________#



#___________________ _ready() __________________#
func _ready() -> void:
#	print(get_gutter_count())
#	print(get_gutter_count())
	add_gutter(3)
	set_gutter_type(3, TextEdit.GUTTER_TYPE_STRING)
	set_line_gutter_text(0, 3, "HELLO")
	set_line_gutter_item_color(0, 3, Color.RED)
	return



#_______________ VIRTUAL METHODS _______________#



#________________ PUBLIC METHODS _______________#



#________________ PRIVATE METHODS ______________#



#_______________ SIGNAL CALLBACKS ______________#

#--------------- Internal ---------------#



#--------------- External ---------------#
