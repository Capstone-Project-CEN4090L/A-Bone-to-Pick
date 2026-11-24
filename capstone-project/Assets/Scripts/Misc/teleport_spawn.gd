extends Marker2D

@export var spawn_id: String = ""
func _enter_tree() -> void:
	add_to_group("teleport_spawns")
