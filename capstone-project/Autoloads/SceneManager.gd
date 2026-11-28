extends Node

@onready var black_screen: ColorRect = $FadeLayer/BlackScreen

var pending_spawn_id: String = ""


func go_to(path, spawn_id: String = ""):
	pending_spawn_id = spawn_id
	print(spawn_id)
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	
func die_fade(path: String = "", spawn_id: String = ""):
	black_screen.color = Color(0, 0, 0, 0)

	var tween = create_tween()
	tween.tween_property(black_screen, "color:a", 1.0, 1.0)
	await tween.finished

	await go_to(path, spawn_id)

	tween = create_tween()
	tween.tween_property(black_screen, "color:a", 0.0, 1.0)
	await tween.finished
