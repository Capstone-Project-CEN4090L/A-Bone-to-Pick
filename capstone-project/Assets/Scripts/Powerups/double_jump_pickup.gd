extends Area2D

func _ready() -> void:
	if SaveManager.get_player_value("has_double_jump"):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		SaveManager.set_player_value("has_double_jump", true)
		SaveManager.save_at_position(body.global_position)
		queue_free()
