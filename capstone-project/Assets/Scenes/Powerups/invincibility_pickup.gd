extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		var current_invincibility = SaveManager.get_player_value("invincibility")
		SaveManager.set_player_value("invincibility", current_invincibility * 2)
		queue_free()
