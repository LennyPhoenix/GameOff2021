tool
extends Node2D

export var length := 100.0 setget set_length
export var dash_length := 5.0 setget set_dash_length
export var colour := Color.white setget set_colour

var points: PoolVector2Array


func _ready() -> void:
	update_points()


func _draw() -> void:
	draw_multiline(points, colour)


func update_points() -> void:
	points = []
	var x = 0
	while x < length:
		points.append(Vector2(x, 0))
		x += dash_length
	points.append(Vector2(length, 0))
	update()


func set_length(new_length: float) -> void:
	length = new_length
	update_points()


func set_dash_length(new_dash_length: float) -> void:
	dash_length = new_dash_length
	update_points()

func set_colour(new_colour: Color) -> void:
	colour = new_colour
	update()
