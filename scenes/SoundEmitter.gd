extends Node2D

onready var particles: CPUParticles2D = $Particles


func emit_sound(blocking: bool = false, blocking_length: float = 0.4) -> void:
	for detector in get_tree().get_nodes_in_group("SoundDetector"):
		if global_position.distance_to(detector.global_position) < detector.radius:
			if blocking:
				detector.blocking_timer = blocking_length
			else:
				particles.restart()
