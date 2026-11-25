extends Area2D

func _ready() -> void:
	if SaveManager.get_player_value("has_dash"):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		SaveManager.set_player_value("has_dash", true)
		SaveManager.save_at_position(body.global_position)
		queue_free()



#func _on_body_entered(body: Node2D) -> void:
	#if body.has_method("get_pickup"):
		#SaveManager.set_player_value("has_dash", true)
		#queue_free()
