extends Area2D

@export var area: String = ""

func _ready() -> void:
	if area == "green" and SaveManager.get_flag("green_hp_powerup_used"):
		queue_free()
	if area == "blue" and SaveManager.get_flag("blue_hp_powerup_used"):
		queue_free()
	if area == "pink" and SaveManager.get_flag("pink_hp_powerup_used"):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("increase_max_health"):
		if area == "green":
			SaveManager.set_flag("green_hp_powerup_used", true)
		elif area == "blue":
			SaveManager.set_flag("blue_hp_powerup_used", true)
		elif area == "pink":
			SaveManager.set_flag("pink_hp_powerup_used", true)
		body.increase_max_health(2)
		queue_free()
