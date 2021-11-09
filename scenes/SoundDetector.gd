tool
extends Node2D

export var radius := 140.0


func _draw() -> void:
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, radius, Color(1, 1, 1, 0.1))
