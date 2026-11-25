extends Area2D

@export var area: String = ""

func _ready() -> void:
	if SaveManager.get_flag("green_invin_powerup_used"):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		var current_invincibility = SaveManager.get_player_value("invincibility")
		SaveManager.set_player_value("invincibility", current_invincibility * 1.5)
		if area == "green":
			SaveManager.set_flag("green_invin_powerup_used", true)
		queue_free()
