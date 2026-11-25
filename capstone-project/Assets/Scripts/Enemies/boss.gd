extends CharacterBody2D

@export var max_health: int = 240
var health: int

@export var move_speed: float = 200.0
@export var patrol_distance: float = 1600.0
@export var contact_damage: int = 2
@export var spike_cooldown: float = 0.2
@export var ceiling_spikes_right: Array[CharacterBody2D] = []
@export var ceiling_spikes_left: Array[CharacterBody2D] = []
@export var invincibility_timer: float = 2.0
@export var start_delay: float = 2.0
@export var death_delay: float = 1.0

var start_position: Vector2 = Vector2(1110.0, 15.0)
var left_point: float = -600.0
var right_point: float = 1110.0
var direction: int
var grounded_dash_speed: float = 1400.0
var roll = -1
var attack_cooldown: float = 2.0
var dashes_remaining: int = 0
var jump_velocity: int = -400
var dash_speed: int = 2000
var dashing = false
var hits: int = 0
var flash_timer: float = 0.05
var invincible: bool = false
var turnaround = false
var hitbox_x: float = 65.0
var hitbox_y: float = 158.0
var dash_hitbox_x: float = 175.0
var dash_hitbox_y: float = 150.0
var dead_collision: Vector2 = Vector2(65.0, 153.0)
var dead: bool = false

var jumpsfx = preload("res://Assets/Sounds/bossjump.mp3")
var dashsfx = preload("res://Assets/Sounds/bossdash.mp3")

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var dash_attack: CollisionShape2D = $AttackArea/dash_attack
@onready var air_dash_attack: CollisionShape2D = $AttackArea/air_dash_attack
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	health = max_health
	start_position = global_position
	sprite.play("boss")
	sprite.flip_h = false


func _physics_process(delta):
	if dead:
		velocity.x = 0.0

		if not is_on_floor():
			velocity += get_gravity() * delta * 0.7

		move_and_slide()
		return

	if roll == -1:
		roll = 0
		await get_tree().create_timer(start_delay).timeout
		
		if dead:
			return

		dash(randi_range(1, 4))
	elif roll == 1:
		print("Dashing!")
		dash(randi_range(1, 4))
		roll = 0
	elif roll == 2:
		print("Jumping!")
		jump()
		roll = 0
	elif roll == 3:
		print("Summoning Spikes!")
		summon_spikes()
		roll = 0

	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta * 0.7
		
	if dashes_remaining > 0:
		velocity.x = direction * grounded_dash_speed
		
	move_and_slide()
	
	if dashes_remaining > 0:
		update_dash_state()


func damage_player(player):
	if dead:
		return
	if sprite.flip_h:
		player.take_damage(contact_damage, 1, true)
	else:
		player.take_damage(contact_damage, -1, true)
	
	print("Boss damaged player")


func take_damage(
	amount: int,
	hit_direction: Vector2 = Vector2.ZERO,
	knockback_amount: float = 0.0
):
	if invincible or dead:
		return
	
	hits = hits + 1
	health -= amount
	sprite.modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)
	
	if health <= 0:
		die()
		return

	print("Boss Health: ", health)
	
	if hits >= 3:
		invincibility()
		hits = 0
		

func invincibility():
	if dead:
		return
	invincible = true
	await flash()
	if dead:
		return
	invincible = false
	
	
func flash() -> void:
	var timer = 0.0
	while timer < invincibility_timer:
		if dead:
			return
		sprite.visible = !sprite.visible
		await get_tree().create_timer(flash_timer).timeout
		timer += flash_timer
	sprite.visible = true

func dash(dashcount: int):
	if dead:
		return

	sprite.play("boss_crouch")
	await get_tree().create_timer(0.5).timeout
	
	if dead:
		return

	sprite.play("boss_dash")
	collision.shape.size = Vector2(dash_hitbox_x, dash_hitbox_y)
	if sprite.flip_h:
		global_position.x = left_point
	else:
		global_position.x = right_point
	var midpoint = (left_point + right_point) / 2.0
	direction = 1 if global_position.x < midpoint else -1
	dash_attack.set_deferred("disabled", false)
	dashes_remaining = dashcount
	sprite.flip_h = direction > 0
	
func update_dash_state() -> void:
	if dead:
		return

	var target_x: float = left_point if direction < 0 else right_point
	
	if (global_position.x - target_x) * direction < 0.0 and !dead:
		return
	
	print("Turning!")
	
	dashes_remaining -= 1
	
	if dashes_remaining == 0:
		collision.shape.size = Vector2(hitbox_x, hitbox_y)
		sprite.play("boss")
		dash_attack.disabled = true
		velocity.x = 0.0
		sprite.flip_h = !sprite.flip_h
		print("Done Dashing")
		await get_tree().create_timer(attack_cooldown).timeout
		if dead:
			return
		if roll != -2:
			roll = randi_range(1, 3)
			while roll == 1:
				roll = randi_range(1, 3)
		return
	
	direction *= -1
	sprite.flip_h = direction > 0

func jump() -> void:
	if dead:
		return

	sprite.play("boss_crouch")
	await get_tree().create_timer(0.5).timeout
	
	if dead:
		return
		
	collision.shape.size = Vector2(dash_hitbox_x, dash_hitbox_y)
	sprite.play("boss_dash")
	set_collision_mask_value(1, false)
	$sfx.stream = jumpsfx
	$sfx.play()
	velocity.y = jump_velocity
	var target_x: float = left_point if direction < 0 else right_point
	var dir = 1 if sprite.flip_h else -1
	await get_tree().create_timer(0.6).timeout
	if dead:
		return
	$sfx.stream = dashsfx
	$sfx.play()
	air_dash_attack.disabled = false
	dashing = true
	velocity.y = 0
	velocity.x = dash_speed * dir
	await get_tree().create_timer(0.85).timeout
	
	if dead:
		return
		
	if sprite.flip_h:
		global_position.x = right_point
	else:
		global_position.x = left_point
	air_dash_attack.disabled = true
	sprite.flip_h = !sprite.flip_h
	velocity.x = 0
	dashing = false
	collision.shape.size = Vector2(hitbox_x, hitbox_y)
	set_collision_mask_value(1, true)
	sprite.play("boss")
	print("Done Air Attacking")
	await get_tree().create_timer(attack_cooldown).timeout
	
	if dead:
		return
		
	if roll != -2:
		roll = randi_range(1, 3)
		while roll == 2:
			roll = randi_range(1, 3)

func summon_spikes() -> void:
	sprite.play("boss_spikes")
	summon_spikes_right()
	summon_spikes_left()
	
func summon_spikes_right() -> void:
	for spike in ceiling_spikes_right:
		if dead:
			return
		if !spike.has_method("fall"):
			continue
		spike.fall()
		await get_tree().create_timer(spike_cooldown).timeout
	if dead:
		return
	await get_tree().create_timer(attack_cooldown).timeout
	if dead:
		return
	if roll != -2:
		roll = randi_range(1, 3)
		while roll == 3:
			roll = randi_range(1, 3)

func summon_spikes_left() -> void:
	for spike in ceiling_spikes_left:
		if dead:
			return
		if !spike.has_method("fall"):
			continue
		spike.fall()
		await get_tree().create_timer(spike_cooldown).timeout
	if dead:
		return

func die() -> void:
	if dead:
		return
	
	Engine.time_scale = 0.25
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), death_delay)
	collision.shape.size = dead_collision
	dead = true
	invincible = true
	dashes_remaining = 0
	roll = -2
	dashing = false
	velocity.x = 0.0
	velocity.y = maxf(velocity.y, 0.0)
	set_collision_mask_value(1, true)
	dash_attack.set_deferred("disabled", true)
	air_dash_attack.set_deferred("disabled", true)
	attack_area.set_deferred("monitoring", false)
	$sfx.stop()
	sprite.visible = true
	sprite.play("boss_death")
	await get_tree().create_timer(death_delay).timeout
	queue_free()
	SceneManager.go_to("res://Assets/Scenes/UI/main_menu.tscn")

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		damage_player(body)
