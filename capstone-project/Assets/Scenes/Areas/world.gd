extends Node2D

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	TeleportManager.place_player.call_deferred(player)
