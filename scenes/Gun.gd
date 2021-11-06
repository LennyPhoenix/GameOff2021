class_name Gun
extends Node2D

export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
export var hip_spread := 40.0
export var aiming_spread := 8.0
export var automatic := true
export var rounds_per_second := 8.0

onready var muzzle: Position2D = $Muzzle

var aiming := false

var _cooldown := 0.0


func _process(delta: float) -> void:
	var shooting: bool = (
		Input.is_action_pressed("shoot") and automatic
		or Input.is_action_just_pressed("shoot")
	)

	_cooldown -= delta

	if shooting and _cooldown <= 0:
		var bullet: Bullet = bullet_scene.instance()
		add_child(bullet)
		bullet.fire(delta, muzzle.global_transform)

		var spread: float = aiming_spread if aiming else hip_spread

		var random_rot: float = rand_range(-spread / 2, spread / 2)
		bullet.global_rotation_degrees += random_rot

		_cooldown = 1 / rounds_per_second
