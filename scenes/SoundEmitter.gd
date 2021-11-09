extends Node2D

onready var particles: CPUParticles2D = $Particles


func emit_sound() -> void:
	for detector in get_tree().get_nodes_in_group("SoundDetector"):
		if global_position.distance_to(detector.global_position) < detector.radius:
			particles.restart()
