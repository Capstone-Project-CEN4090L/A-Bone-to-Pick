extends CharacterBody2D

@export var damage: int = 2
@export var fall_speed: int = 500
@export var stop_position: int = 120
@export var pause: float = 0.5

var falling = false
var spawn_position: Vector2

var fallsfx = preload("res://Assets/Sounds/spike_fall.mp3")

@onready var sprite = $Sprite2D
@onready var hitbox = $AttackArea/hitbox

func _ready():
	spawn_position = position
	sprite.hide()

func _physics_process(delta: float) -> void:
	if falling and velocity.y == 0:
		await get_tree().create_timer(pause)
		sprite.hide()
		hitbox.disabled = true
		falling = false
		velocity.y = 0
		position = spawn_position
	move_and_slide()
	
func fall():
	hitbox.disabled = false
	sprite.show()
	falling = true
	$sfx.stream = fallsfx
	$sfx.play()
	velocity.y = fall_speed

func fast_fall():
	hitbox.disabled = false
	sprite.visible = true
	falling = true
	$sfx.stream = fallsfx
	$sfx.play()
	velocity.y = fall_speed * 2
	
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, 0, false)
