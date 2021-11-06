class_name Gun
extends Node2D

export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
export var aim_in_time := 0.3
export var aim_out_time := 0.1
export var hip_spread := 40.0
export var aiming_spread := 8.0
export var automatic := true
export var rounds_per_second := 8.0
export var hip_guide_colour := Color(1.0, 1.0, 1.0, 0.1)
export var aiming_guide_colour := Color(1.0, 1.0, 1.0, 0.4)

onready var tween := $Tween
onready var muzzle: Position2D = $Muzzle
onready var top_guide: Node2D = $Muzzle/TopGuide
onready var bottom_guide: Node2D = $Muzzle/BottomGuide

var aiming_weight := 0.0

var _cooldown := 0.0


func _process(delta: float) -> void:
	var spread: float = lerp(hip_spread, aiming_spread, aiming_weight)
	var guide_colour: Color = lerp(hip_guide_colour, aiming_guide_colour, aiming_weight)
	var shooting: bool = (
		Input.is_action_pressed("shoot") and automatic
		or Input.is_action_just_pressed("shoot")
	)

	_cooldown -= delta

	top_guide.rotation_degrees = -spread / 2
	bottom_guide.rotation_degrees = spread / 2
	top_guide.colour = guide_colour
	bottom_guide.colour = guide_colour

	if shooting and _cooldown <= 0:
		var bullet: Bullet = bullet_scene.instance()
		add_child(bullet)
		bullet.fire(delta, muzzle.global_transform)

		var random_rot: float = rand_range(-spread / 2, spread / 2)
		bullet.global_rotation_degrees += random_rot

		_cooldown = 1 / rounds_per_second
