extends Area2D

@export var duration: float = 10.0

@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D

func _on_body_entered(body):
	if body.is_in_group("player") and !body.low_gravity_active:
		if body.has_method("activate_low_gravity"):
			body.activate_low_gravity(duration)
			sprite.hide()
			collision.set_deferred("disabled", true)
			await get_tree().create_timer(duration).timeout
			sprite.show()
			collision.set_deferred("disabled", false)
			
