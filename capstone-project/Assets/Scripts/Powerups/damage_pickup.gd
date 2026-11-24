extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		var current_damage = SaveManager.get_player_value("damage")
		SaveManager.set_player_value("damage", current_damage + 10)
		queue_free()
