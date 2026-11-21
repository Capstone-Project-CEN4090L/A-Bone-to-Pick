extends Node

var UI_scene = preload("res://Assets/Scenes/UI/UI_root.tscn")
var pause_scene = preload("res://Assets/Scenes/UI/pause_menu.tscn")

var debug_panel: CanvasLayer
var UI_root: CanvasLayer
var pause_menu: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	UI_root = UI_scene.instantiate()
	pause_menu = pause_scene.instantiate()
	add_child(UI_root)
	add_child(pause_menu)
	pause_menu.visible = false
	if OS.is_debug_build():
		debug_panel = load("res://Assets/Scripts/UI/debug_panel.gd").new()
		add_child(debug_panel)
	
	

func set_gameplay_ui(enabled):
	UI_root.visible = enabled
	pause_menu.can_pause = enabled
