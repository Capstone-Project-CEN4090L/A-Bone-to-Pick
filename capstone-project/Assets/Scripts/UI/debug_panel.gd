extends CanvasLayer
## Dev-only debug panel. Toggle with F1 ("toggle_debug_panel").

#Add new unlocks here.
const UNLOCKS := {
	"has_dash": "Dash",
	"has_double_jump": "Double Jump",
	"has_air_attack": "Air Attack",
}

var panel: PanelContainer
var unlock_toggles: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_build_ui()
	panel.visible = false


func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(16, 64)
	add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "DEBUG (F1)"
	vbox.add_child(title)

	for key in UNLOCKS:
		var toggle := CheckButton.new()
		toggle.text = UNLOCKS[key]
		toggle.focus_mode = Control.FOCUS_NONE
		toggle.toggled.connect(func(on: bool): SaveManager.set_player_value(key, on))
		vbox.add_child(toggle)
		unlock_toggles[key] = toggle

	vbox.add_child(HSeparator.new())
	_add_button(vbox, "Full Heal", _full_heal)
	_add_button(vbox, "Save Here", _save_here)
	_add_button(vbox, "Load Save", _load_save)
	_add_button(vbox, "Reload Scene", _reload_scene)
	_add_button(vbox, "Kill Player", _kill_player)


func _add_button(parent: Node, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	parent.add_child(button)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_panel"):
		if panel.visible:
			_close()
		elif _get_player() != null:  # only open during gameplay
			_open()
		get_viewport().set_input_as_handled()


func _open() -> void:
	for key in unlock_toggles:
		unlock_toggles[key].set_pressed_no_signal(bool(SaveManager.get_player_value(key, false)))
	panel.visible = true
	get_tree().paused = true


func _close() -> void:
	panel.visible = false
	if not UILayer.pause_menu.visible:
		get_tree().paused = false


func _get_player() -> Node:
	return get_tree().get_first_node_in_group("player")


func _full_heal() -> void:
	var player = _get_player()
	if player:
		player.set_health(player.max_health)


func _save_here() -> void:
	var player = _get_player()
	if player == null:
		return
	SaveManager.set_debug_checkpoint(get_tree().current_scene.scene_file_path, player.global_position)
	SaveManager.save_game()


func _load_save() -> void:
	if not SaveManager.load_game():
		return
	var scene_path: String = SaveManager.game_state["last_scene"]
	if scene_path == "":
		scene_path = get_tree().current_scene.scene_file_path
	panel.visible = false
	SceneManager.go_to(scene_path, SaveManager.game_state["last_checkpoint"])


func _reload_scene() -> void:
	panel.visible = false
	SceneManager.go_to(get_tree().current_scene.scene_file_path)

func _kill_player() -> void:
	var player = _get_player()
	if player == null or player.dead:
		return
	_close()  # unpause first so the death animation and respawn play normally
	player.die()
