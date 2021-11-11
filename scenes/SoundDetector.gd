tool
extends Sprite

var blocking_timer := 0.0


func _process(delta: float) -> void:
	blocking_timer -= delta
	if Engine.editor_hint:
		blocking_timer = 1
	modulate = Color(1, 1, 1, clamp(blocking_timer, 0, 1))


func get_radius() -> float:
	return texture.get_width() * scale.x / 2.0
