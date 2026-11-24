extends Node


var pending_spawn_id: String = ""


func go_to(path, spawn_id: String = ""):
	pending_spawn_id = spawn_id
	print(spawn_id)
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
