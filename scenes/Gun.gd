extends Node2D

export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")

onready var muzzle: Position2D = $Muzzle


func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		var bullet: Bullet = bullet_scene.instance()
		add_child(bullet)
		bullet.fire(delta, muzzle.global_transform, 0.0, 500.0)
