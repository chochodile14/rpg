# tutorial/tutorial_map.gd
# Scène map du tutoriel : le joueur doit marcher jusqu'au monstre
# guidé par les bulles. Quand il touche le monstre -> tutorial_battle
extends Node2D

# Flag Global pour que tutorial_battle sache qu'on vient du tuto
const IS_TUTORIAL: bool = true

@onready var player  : CharacterBody2D = $character_beta
@onready var mob     : Node2D          = $mob_tuto
@onready var bubble  : CanvasLayer     = $TutoBubble
@onready var arrow   : Label           = $CanvasLayer/ArrowIndicator

# Étapes de la bulle de mouvement
const MAP_STEPS: Array[Dictionary] = [
	{
		"title": "🗺️ Bienvenue dans le tutoriel !",
		"text":  "Tu es le personnage rouge.\nApprends à te déplacer d'abord !",
	},
	{
		"title": "🕹️ Se déplacer",
		"text":  "Utilise  Z / Q / S / D\n\npour bouger ton personnage.",
	},
	{
		"title": "👾 Objectif",
		"text":  "Marche jusqu'au monstre\nau loin pour déclencher un combat\net passer à la suite !",
		"arrow": "right",
	},
]

func _ready() -> void:
	Global.is_tutorial = true
	Global.player_spawn_position = Vector2.ZERO
	bubble.steps = MAP_STEPS
	bubble.all_done.connect(_on_bubble_done)
	# Démarre la bulle après 0.4 s pour laisser la scène s'afficher
	await get_tree().create_timer(0.4).timeout
	bubble.start()

func _on_bubble_done() -> void:
	# La bulle est fermée : le joueur peut bouger librement
	# L'indicateur de flèche pointe vers le monstre
	_pulse_arrow()

func _pulse_arrow() -> void:
	if not is_instance_valid(arrow):
		return
	arrow.visible = true
	var t = create_tween().set_loops()
	t.tween_property(arrow, "modulate:a", 0.2, 0.5)
	t.tween_property(arrow, "modulate:a", 1.0, 0.5)

func _process(_delta: float) -> void:
	# Fait pointer la flèche UI vers le monstre en permanence
	if not is_instance_valid(arrow) or not arrow.visible:
		return
	if not is_instance_valid(mob) or not is_instance_valid(player):
		return
	var dir = (mob.global_position - player.global_position).normalized()
	arrow.text = _dir_to_emoji(dir)

func _dir_to_emoji(dir: Vector2) -> String:
	var angle = rad_to_deg(dir.angle())
	if angle >= -45 and angle < 45:   return "➡️"
	elif angle >= 45 and angle < 135: return "⬇️"
	elif angle < -45 and angle >= -135: return "⬆️​"
	else: return "⬅️​"
