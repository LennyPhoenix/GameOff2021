extends KinematicBody2D

enum State {
	IDLE,
	WALKING,
	SNEAKING,
	SPRINTING,
	IN_ACTION,
}

export var move_speed := 80.0
export var acceleration := 1500.0
export var drag := 1000.0
export var sneaking_speed_multiplier := 0.4
export var sprinting_speed_multiplier := 1.8

var state: int = State.IDLE
var input_vector := Vector2.ZERO
var velocity := Vector2.ZERO
var stow_weight := 0.0

onready var rotate_group: Node2D = $Rotate
onready var gun: Gun = $Rotate/Gun
onready var fov_light: Light2D = $Lights/Vision/FOV


func _process(_delta: float) -> void:
	# Get Movement Input
	input_vector = Input.get_vector("left", "right", "up", "down")

	# Set Rotation to Mouse
	rotate_group.global_rotation = get_global_mouse_position().angle_to_point(global_position)

	# Check for Reload
	if Input.is_action_just_pressed("reload"):
		gun.reload()

	# Input
	if gun.get_current_state() == Gun.State.RELOADING:
		state = State.IN_ACTION
	elif Input.is_action_pressed("sneak"):
		state = State.SNEAKING
	elif input_vector == Vector2.ZERO:
		state = State.IDLE
	elif Input.is_action_pressed("sprint"):
		state = State.SPRINTING
	else:
		state = State.WALKING

	if state == State.SNEAKING and gun.get_current_state() == Gun.State.READY:
		gun.target_state = Gun.State.AIMING
	elif state != State.SNEAKING and gun.get_current_state() == Gun.State.AIMING:
		gun.target_state = Gun.State.READY

	# Lighting
	fov_light.texture_scale = lerp(1, 0.15, gun.reloading_weight)


func _physics_process(delta: float) -> void:
	# Get Acceleration and Target Speed
	var acc: float = (acceleration if input_vector else drag) * delta
	var target_speed: float = move_speed

	# Reloading
	if gun.get_current_state() == Gun.State.RELOADING:
		target_speed *= gun.reload_speed_modifier

	# Update Sneaking/Aiming
	elif state == State.SNEAKING:
		target_speed *= sneaking_speed_multiplier

	# Apply Acceleration
	velocity = velocity.move_toward(input_vector * target_speed, acc)

	# Move the Body
	velocity = move_and_slide(velocity)
