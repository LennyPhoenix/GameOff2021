extends Node2D

export var radius := 140.0 setget set_radius

var blocking_timer := 0.0


func _process(delta: float) -> void:
	blocking_timer -= delta
	material.set_shader_param("disruption_time", blocking_timer)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1, 1, 1, 1 - blocking_timer))


func set_radius(new_radius: float) -> void:
	radius = new_radius
	update()
