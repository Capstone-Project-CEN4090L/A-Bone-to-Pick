extends CanvasLayer

const hp_per_heart := 2

@export var full_icon: Texture2D
@export var half_icon: Texture2D
@export var empty_icon: Texture2D

@onready var health_icons: HBoxContainer = $HealthIcons



func update_health(current: int, maximum: int) -> void:
	# Number of heart containers to show, e.g. max 10 -> 5 hearts, max 9 -> 5 hearts
	var heart_count: int = ceili(float(maximum) / hp_per_heart)

	while health_icons.get_child_count() < heart_count:
		health_icons.add_child(health_icons.get_child(0).duplicate())

	for i in health_icons.get_child_count():
		var icon: TextureRect = health_icons.get_child(i)
		icon.visible = i < heart_count

		# How much health is left in this heart (0, 1, or 2)
		var hp_in_heart: int = clampi(current - i * hp_per_heart, 0, hp_per_heart)

		if hp_in_heart >= hp_per_heart:
			icon.texture = full_icon
		elif hp_in_heart > 0:
			icon.texture = half_icon
		else:
			icon.texture = empty_icon
