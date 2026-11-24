extends Node

var next_spawn_id: String = ""


func place_player(player: CharacterBody2D) -> void:
	if next_spawn_id == "":
		return

	for spawn in get_tree().get_nodes_in_group("teleport_spawns"):
		if spawn.spawn_id == next_spawn_id:
			player.global_position = spawn.global_position
			player.velocity = Vector2.ZERO
			player.reset_physics_interpolation()
			next_spawn_id = ""
			return

	push_warning("Could not find teleport spawn: " + next_spawn_id)
