class_name Bullet
extends Area2D

export var speed := 1200.0
export var max_distance := 3000.0
export var speed_variation := 500.0

onready var raycast := $RayCast2D

var _travelled := 0.0


func _init() -> void:
	set_as_toplevel(true)


func _on_body_entered(_body: Node) -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	var distance = speed * delta
	raycast.cast_to = Vector2(distance, 0)

	if raycast.is_colliding():
		global_position = raycast.get_collision_point()
	else:
		position += transform.x * distance
		_travelled += distance

	if _travelled > max_distance:
		queue_free()


func fire(delta: float, new_transform: Transform2D) -> void:
	transform = new_transform

	speed += rand_range(-speed_variation / 2, speed_variation / 2)

	var distance = speed * delta
	raycast.cast_to = Vector2(distance, 0)
