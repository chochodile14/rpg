extends Node2D

const AptitudeMenuScene = preload("res://ui/aptitude_menu.tscn")

var _aptitude_menu = null

func _ready() -> void:
	# Repositionne le joueur si on revient d'un combat
	if Global.player_spawn_position != Vector2.ZERO:
		var player_node = get_node_or_null("character_body_2d")
		if player_node:
			player_node.global_position = Global.player_spawn_position
		Global.player_spawn_position = Vector2.ZERO

	# Crée le menu d'aptitude une fois, il reste dans la scène
	_aptitude_menu = AptitudeMenuScene.instantiate()
	add_child(_aptitude_menu)

func new_game():
	$character_body_2d.start($Marker2D.position)
	$character_body_2d.show()
	$start.hide()

func _process(_delta: float) -> void:
	pass

# ── Tab géré ici pour éviter tout conflit avec les autres nœuds ──────────────
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			if _aptitude_menu != null:
				if _aptitude_menu.visible:
					_aptitude_menu._on_close()
				else:
					_aptitude_menu.open_from_map()
			get_viewport().set_input_as_handled()
