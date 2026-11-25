extends Area2D

@export var area: String = ""

func _ready() -> void:
	if area == "green" and SaveManager.get_flag("green_damage_powerup_used"):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		var current_damage = SaveManager.get_player_value("damage")
		if area == "green":
			SaveManager.set_flag("green_damage_powerup_used", true)
		SaveManager.set_player_value("damage", current_damage + 10)
		queue_free()
