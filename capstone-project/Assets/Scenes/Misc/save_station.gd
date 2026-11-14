extends Area2D


#Unique ID per station, set it in the inspector
@export var checkpoint_id: String = ""

var player_in_range: bool = false
var player: Node2D = null
var resting: bool = false

@onready var prompt: Label = $Prompt

func _enter_tree() -> void:
	add_to_group("spawn_points")

func _ready() -> void:
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if checkpoint_id == "":
		push_warning("SaveStation at %s has no checkpoint_id set" % global_position)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player = body
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player = null
		prompt.visible = false

func get_spawn_id() -> String:
	return checkpoint_id


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		rest()


func rest() -> void:
	if resting or player.dead:
		return
	resting = true


	player.set_health(player.max_health)
	
	var scene_path := get_tree().current_scene.scene_file_path
	SaveManager.set_checkpoint(checkpoint_id, scene_path)
	SaveManager.save_game()


	var original_text := prompt.text
	prompt.text = "Game Saved"
	await get_tree().create_timer(1.5).timeout
	prompt.text = original_text

	resting = false
