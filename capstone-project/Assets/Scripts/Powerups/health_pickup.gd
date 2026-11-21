extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("increase_max_health"):
		body.increase_max_health(2)
		queue_free()
