@tool
#class_name
extends Control

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
	pass



#_______________ VIRTUAL METHODS _______________#



#________________ PUBLIC METHODS _______________#

func update(new_parent: CodeEdit, sections: Array[Section]) -> void:
	if get_parent():
		get_parent().remove_child(self)
		
	$ColorRect.color = Color(randf(), randf(), randf())
		
	new_parent.add_child(self)
	return

#________________ PRIVATE METHODS ______________#



#_______________ SIGNAL CALLBACKS ______________#

#--------------- Internal ---------------#



#--------------- External ---------------#



