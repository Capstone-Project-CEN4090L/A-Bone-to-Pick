extends Area2D

enum TeleportType {
	SAME_WORLD,
	DIFFERENT_SCENE
}

@export var teleport_type: TeleportType = TeleportType.SAME_WORLD
@export var destination_spawn_id: String = ""

@export_file("*.tscn") var destination_scene: String = ""

var player_in_range: bool = false
var player: CharacterBody2D = null
var teleporting: bool = false

@onready var prompt: Label = $Prompt


func _ready() -> void:
	prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player = body
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_range = false
		player = null
		prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		teleport()


func teleport() -> void:
	if teleporting or not is_instance_valid(player):
		return

	if player.dead:
		return

	teleporting = true

	if teleport_type == TeleportType.SAME_WORLD:
		teleport_in_world()
		teleporting = false
	else:
		teleport_to_scene()


func teleport_in_world() -> void:
	for spawn in get_tree().get_nodes_in_group("teleport_spawns"):
		if spawn.spawn_id == destination_spawn_id:
			player.global_position = spawn.global_position
			player.velocity = Vector2.ZERO
			player.reset_physics_interpolation()
			return

	push_warning("Teleport spawn not found: " + destination_spawn_id)


func teleport_to_scene() -> void:
	if destination_scene == "":
		push_warning("Teleport has no destination scene")
		teleporting = false
		return

	TeleportManager.next_spawn_id = destination_spawn_id
	get_tree().change_scene_to_file.call_deferred(destination_scene)
