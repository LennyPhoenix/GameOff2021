class_name Gun
extends Node2D

# TODO: Use target_state system along with a get_current_state method,
#       for each state, have some kind of requirement or a method to update weights and run through
#       each every _process.

enum State {
	STOWED,
	READY,
	AIMING,
	RELOADING,
	ADJUSTING,
}

# Bullet
export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
export var rounds_per_second := 8.0
export var automatic := true
# Timing
export var aim_in_time := 0.3
export var aim_out_time := 0.1
export var reload_time := 1.2
export var stow_time := 0.2
export var unstown_time := 0.3
# Spread
export var hip_spread := 40.0
export var aiming_spread := 8.0
# Guides
export var hip_guide_colour := Color(1.0, 1.0, 1.0, 0.07)
export var aiming_guide_colour := Color(1.0, 1.0, 1.0, 0.25)
# Magazine
export var reload_per_round := false
export var mag_size := 24
export var reload_speed_modifier := 0.3
export var reload_fade_time := 0.1

onready var muzzle: Position2D = $Muzzle
onready var top_guide: Node2D = $Muzzle/TopGuide
onready var bottom_guide: Node2D = $Muzzle/BottomGuide
onready var ammo_label: Label = $UI/Ammo

var target_state: int = State.READY
var aiming_weight := 0.0
var stowed_weight := 0.0
var reloading_weight := 0.0
onready var rounds: int = mag_size

var _cooldown := 0.0


func _ready() -> void:
	update_ammo_label()


func _process(delta: float) -> void:
	_update_states(delta)
	var current_state = get_current_state()

	var spread: float = lerp(hip_spread, aiming_spread, aiming_weight)
	var guide_colour: Color = lerp(hip_guide_colour, aiming_guide_colour, aiming_weight)

	var has_rounds: bool = current_state != State.RELOADING and (mag_size == 0 or rounds > 0)
	var shooting: bool = current_state in [State.READY, State.AIMING] and (
		(Input.is_action_pressed("shoot") and automatic)
		or Input.is_action_just_pressed("shoot")
	)

	guide_colour = lerp(guide_colour, Color(1.0, 1.0, 1.0, 0.0), reloading_weight)

	_cooldown -= delta

	top_guide.rotation_degrees = -spread / 2
	bottom_guide.rotation_degrees = spread / 2
	top_guide.colour = guide_colour
	bottom_guide.colour = guide_colour

	if shooting and _cooldown <= 0:
		if has_rounds:
			var bullet: Bullet = bullet_scene.instance()
			add_child(bullet)
			bullet.fire(delta, muzzle.global_transform)

			var random_rot: float = rand_range(-spread / 2, spread / 2)
			bullet.global_rotation_degrees += random_rot

			if mag_size > 0:
				rounds -= 1
			_cooldown = 1 / rounds_per_second

			update_ammo_label()
		else:
			reload()


func _update_states(delta: float) -> void:
	if target_state == State.RELOADING:
		reloading_weight += delta / reload_fade_time
	else:
		reloading_weight -= delta / reload_fade_time

		if target_state == State.AIMING:
			aiming_weight += delta / aim_in_time
		else:
			aiming_weight -= delta / aim_out_time

	aiming_weight = clamp(aiming_weight, 0, 1)
	reloading_weight = clamp(reloading_weight, 0, 1)


func get_current_state() -> int:
	if reloading_weight > 0:
		return State.RELOADING
	elif stowed_weight == 1:
		return State.STOWED
	elif aiming_weight == 1:
		return State.AIMING
	elif reloading_weight + stowed_weight + aiming_weight > 0:
		return State.ADJUSTING
	else:
		return State.READY


func reload() -> void:
	var current_state = get_current_state()

	if not current_state in [State.RELOADING, State.STOWED] and mag_size > 0 and rounds < mag_size:
		var prev_state = current_state
		target_state = State.RELOADING
		yield(get_tree().create_timer(reload_time), "timeout")
		rounds = mag_size
		target_state = prev_state

		update_ammo_label()


func update_ammo_label() -> void:
	ammo_label.visible = mag_size > 0
	ammo_label.text = "%d / %d" % [rounds, mag_size]
