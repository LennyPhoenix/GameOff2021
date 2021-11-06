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
onready var mag_size: Label = $MagSize


func _ready() -> void:
	update_mag_size()


func _on_Gun_fired() -> void:
	update_mag_size()


func _on_Gun_reloaded() -> void:
	update_mag_size()


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

	# Check for Reload
	if Input.is_action_just_pressed("reload"):
		gun.reload()


func _physics_process(delta: float) -> void:
	# Get Acceleration and Target Speed
	var acc: float = (acceleration if input_vector else drag) * delta
	var target_speed: float = move_speed

	if gun.reloading:
		target_speed *= gun.reload_speed_modifier
	# Update Sneaking/Aiming
	elif sneaking:
		target_speed *= sneaking_speed_multiplier
		gun.aiming_weight += delta / gun.aim_in_time
	else:
		gun.aiming_weight -= delta / gun.aim_out_time
	gun.aiming_weight = clamp(gun.aiming_weight, 0, 1)

	# Apply Acceleration
	velocity = velocity.move_toward(input_vector * target_speed, acc)

	# Move the Body
	velocity = move_and_slide(velocity)


func update_mag_size() -> void:
	mag_size.text = "%d / %d" % [gun.rounds, gun.mag_size]
