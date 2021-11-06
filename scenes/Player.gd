extends KinematicBody2D

export var move_speed := 80.0
export var acceleration := 1500.0
export var drag := 1000.0
export var sneaking_speed_multiplier := 0.4

var sneaking := false
var input_vector := Vector2.ZERO
var velocity := Vector2.ZERO

onready var rotate_group: Node2D = $Rotate
onready var gun: Gun = $Rotate/Gun


func _process(_delta: float) -> void:
	# Get Movement Input
	input_vector = Vector2.ZERO
	input_vector.x += Input.get_action_strength("right")
	input_vector.x -= Input.get_action_strength("left")
	input_vector.y -= Input.get_action_strength("up")
	input_vector.y += Input.get_action_strength("down")
	input_vector = input_vector.normalized()

	# Set Rotation to Mouse
	rotate_group.global_rotation = get_global_mouse_position().angle_to_point(global_position)

	# Check for Aiming Input
	sneaking = Input.is_action_pressed("sneak")
	gun.aiming = sneaking


func _physics_process(delta: float) -> void:
	# Get Acceleration and Target Speed
	var acc: float = (acceleration if input_vector else drag) * delta
	var target_speed: float = move_speed

	if sneaking:
		target_speed *= sneaking_speed_multiplier

	# Apply Acceleration
	velocity = velocity.move_toward(input_vector * target_speed, acc)

	# Move the Body
	velocity = move_and_slide(velocity)
