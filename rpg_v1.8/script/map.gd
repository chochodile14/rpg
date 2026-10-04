# script/map.gd
# ─────────────────────────────────────────────────────────────────────────────
# Gère la scène map :
#   - Repositionne le joueur au retour d'un combat
#   - Ouvre/ferme le menu pause avec Échap
#   - Ouvre le menu aptitude avec Tab
# ─────────────────────────────────────────────────────────────────────────────
extends Node2D

const AptitudeMenuScene = preload("res://ui/aptitude_menu.tscn")

@onready var pause_menu = $character_beta/PauseMenu
@onready var inventory = $character_beta/inventory
var paused         : bool = false
var _aptitude_menu        = null

func _ready() -> void:
	print("Nombre d'AudioStreamPlayer actifs dans l'arbre : ", get_tree().get_nodes_in_group("_debug_audio").size())
	for node in get_tree().root.get_children():
		print("Enfant racine : ", node.name)
	AudioManager.play_menu_music(preload("res://audio/musique varier/music-medieval-chocho.ogg"))
	# Repositionne le joueur si on revient d'un combat
	if Global.player_spawn_position != Vector2.ZERO:
		var player_node = get_node_or_null("character_beta")
		if player_node:
			player_node.global_position = Global.player_spawn_position
		Global.player_spawn_position = Vector2.ZERO

	# Cache le menu pause au départ
	pause_menu.hide()
	inventory.hide()
	# Instancie le menu aptitude
	_aptitude_menu = AptitudeMenuScene.instantiate()
	add_child(_aptitude_menu)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		PauseMenu()
		
	if Input.is_action_just_pressed("Inventory"):
		Inventory()

# Bascule le menu inventaire
func Inventory() -> void:
	if paused:
		inventory.get_node("CanvasLayer").visible = false
		Engine.time_scale = 1
		get_tree().paused = false   # ← AJOUTE ÇA
		paused = false
	else:
		inventory.ShowInventory()
		Engine.time_scale = 0
		get_tree().paused = true    # ← AJOUTE ÇA
		paused = true

# Bascule le menu pause
func PauseMenu() -> void:
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		get_tree().paused = false   # ← AJOUTE ÇA
		paused = false
	else:
		pause_menu.show()
		Engine.time_scale = 0
		get_tree().paused = true    # ← AJOUTE ÇA
		paused = true

# Tab → menu aptitude
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			if _aptitude_menu != null:
				if _aptitude_menu.visible:
					_aptitude_menu._on_close()
				else:
					_aptitude_menu.open_from_map()
			get_viewport().set_input_as_handled()
