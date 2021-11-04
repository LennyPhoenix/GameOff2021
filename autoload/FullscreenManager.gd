extends Node


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		toggle_fullscreen()

func toggle_fullscreen() -> void:
	OS.window_fullscreen = not OS.window_fullscreen
