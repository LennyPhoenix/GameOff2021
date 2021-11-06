class_name Gun
extends Node2D

signal fired()
signal reloaded()

# Bullet
export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
export var rounds_per_second := 8.0
export var automatic := true
# Timing
export var aim_in_time := 0.3
export var aim_out_time := 0.1
export var reload_time := 1.2
# Spread
export var hip_spread := 40.0
export var aiming_spread := 8.0
# Guides
export var hip_guide_colour := Color(1.0, 1.0, 1.0, 0.1)
export var aiming_guide_colour := Color(1.0, 1.0, 1.0, 0.4)
# Magazine
export var reload_per_round := false
export var mag_size := 24
export var reload_speed_modifier := 0.3
export var reload_fade_time := 0.05

onready var muzzle: Position2D = $Muzzle
onready var top_guide: Node2D = $Muzzle/TopGuide
onready var bottom_guide: Node2D = $Muzzle/BottomGuide

var aiming_weight := 0.0
var reloading_fade := 0.0
var reloading := false
onready var rounds: int = mag_size

var _cooldown := 0.0


func _process(delta: float) -> void:
	var spread: float = lerp(hip_spread, aiming_spread, aiming_weight)
	var guide_colour: Color = lerp(hip_guide_colour, aiming_guide_colour, aiming_weight)

	var has_rounds: bool = (
		not reloading
		and (mag_size == 0 or rounds > 0)
	)
	var shooting: bool = (
		Input.is_action_pressed("shoot")
		or Input.is_action_just_pressed("shoot")
	)

	if reloading:
		reloading_fade += delta / reload_fade_time
	else:
		reloading_fade -= delta / reload_fade_time
	reloading_fade = clamp(reloading_fade, 0, 1)
	guide_colour = lerp(guide_colour, Color(1.0, 1.0, 1.0, 0.0), reloading_fade)

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
			emit_signal("fired")
		else:
			reload()


func reload() -> void:
	if not reloading and mag_size > 0 and rounds < mag_size:
		reloading = true
		yield(get_tree().create_timer(reload_time), "timeout")
		rounds = mag_size
		reloading = false
		emit_signal("reloaded")
