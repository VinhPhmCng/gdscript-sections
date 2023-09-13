@tool
extends Window

## The addon's main User Interface

signal section_added(text: String)
signal section_filter(text: String)

@onready var main: VBoxContainer = $Background/MarginContainer/Main
@onready var enable_prompt: CenterContainer = $Background/MarginContainer/EnablePrompt
@onready var disable_prompt: CenterContainer = $Background/MarginContainer/DisablePrompt
@onready var filter_section: LineEdit = %FilterSection
@onready var add_section: LineEdit = %AddSection
@onready var enable_prompt_label: Label = %EnablePromptLabel
@onready var disable_prompt_label: Label = %DisablePromptLabel

## From EnablePrompt to Main
func show_main() -> void:
	enable_prompt.hide()
	disable_prompt.hide()
	main.show()
	return


## From DisablePrompt (Accept) to EnablePromp[br]
## Or when encounter a disabled script 
func prompt_enable_script(path: String) -> void:
	enable_prompt_label.text = "ENABLE the plugin for the script?\n\"%s\"" % path
	
	disable_prompt.hide()
	main.hide()
	enable_prompt.show()
	return


## From Main to DisablePrompt
func prompt_disable_script(path: String) -> void:
	disable_prompt_label.text = "DISABLE the plugin for the script?\n\"%s\"\n(Will permanently delete all sections)" % path
	
	enable_prompt.hide()
	main.hide()
	disable_prompt.show()
	return


## Updates prompts' font sizes
func set_font_size(to: int) -> void:
	enable_prompt_label.add_theme_font_size_override("font_size", to)
	disable_prompt_label.add_theme_font_size_override("font_size", to)
	return

func _handle_close_event() -> void:
	filter_section.clear()
	return

# Handles buttons' signals - concerning visibility only

## From EnablePrompt to Main
func _on_Enable_pressed() -> void:
	enable_prompt.hide()
	disable_prompt.hide()
	main.show()
	return


## From Main to DisablePrompt
func _on_Disable_pressed() -> void:
	enable_prompt.hide()
	main.hide()
	disable_prompt.show()
	return


## From DisablePrompt to Main
func _on_DisableCancel_pressed() -> void:
	enable_prompt.hide()
	disable_prompt.hide()
	main.show()
	return


## From DisablePrompt (Accept) to EnablePrompt
func _on_DisableAccept_pressed() -> void:
	disable_prompt.hide()
	main.hide()
	enable_prompt.show()
	return


## Handles adding a new section by button
func _on_AddButton_pressed() -> void:
	if add_section.text.length() > 0:
		section_added.emit(add_section.text)
		add_section.clear()
	return


func _on_filter_text_changed(new_text: String) -> void:
	section_filter.emit(new_text)
	return


func _on_visibility_changed() -> void:
	if not self.visible:
		_handle_close_event()
	return
