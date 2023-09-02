@tool
extends Window


signal section_added(text: String)


@onready var main: VBoxContainer = $Background/MarginContainer/Main
@onready var enable_prompt: CenterContainer = $Background/MarginContainer/EnablePrompt
@onready var disable_prompt: CenterContainer = $Background/MarginContainer/DisablePrompt

@onready var add_section: LineEdit = %AddSection
@onready var enable_prompt_label: Label = %EnablePromptLabel


# EnableCancel is handled by section_button in gdscript_sections.gd
# For visibility, only need to handle Enable and Disable

## From EnablePrompt to Main
func show_main() -> void:
	enable_prompt.hide()
	main.show()
	return


## From DisablePrompt (Accept) to EnablePromp[br]
## Or when encounter a disabled script 
func prompt_enable_script(path: String) -> void:
	enable_prompt_label.text = "Enable the plugin for the script \"%s\"?" % path
	
	disable_prompt.hide()
	main.hide()
	enable_prompt.show()
	return


## From EnablePrompt to Main
func _on_Enable_pressed() -> void:
	enable_prompt.hide()
	main.show()
	return


## From Main to DisablePrompt
func _on_Disable_pressed() -> void:
	disable_prompt.show()
	main.hide()
	return


## From DisablePrompt to Main
func _on_DisableCancel_pressed() -> void:
	disable_prompt.hide()
	main.show()
	return


## From DisablePrompt (Accept) to EnablePrompt
func _on_DisableAccept_pressed() -> void:
	disable_prompt.hide()
	main.hide()
	enable_prompt.show()
	return


## Handles adding a new section by "Enter"
func _on_AddSection_text_submitted(new_text: String) -> void:
	section_added.emit(new_text)
	add_section.clear()
	return


## Handles adding a new section by button
func _on_AddButton_pressed() -> void:
	if add_section.text.length() > 0:
		section_added.emit(add_section.text)
		add_section.clear()
	return
