# tutorial/tutorial_battle.gd
# Battle tutoriel : hérite de la logique de battle.gd mais pilote
# les bulles d'explication étape par étape avant de laisser jouer.
extends Node2D

@onready var btn_light    : Button      = $CanvasLayer/choice/light
@onready var btn_heavy    : Button      = $CanvasLayer/choice/heavy
@onready var btn_ultimate : Button      = $CanvasLayer/choice/ultimate
@onready var btn_exit     : Button      = $CanvasLayer/choice/exit
@onready var ennemies     : Node2D      = $ennemies_groupe
@onready var bubble       : CanvasLayer = $TutoBubble
@onready var highlight    : ColorRect   = $CanvasLayer/Highlight

# Indicateurs flottants sur les boutons
@onready var hint_light   : Label = $CanvasLayer/choice/light/Hint
@onready var hint_heavy   : Label = $CanvasLayer/choice/heavy/Hint
@onready var hint_ult     : Label = $CanvasLayer/choice/ultimate/Hint

var _tuto_phase: int = 0  # 0=intro, 1=cible, 2=light, 3=heavy, 4=ult, 5=libre

const INTRO_STEPS: Array[Dictionary] = [
	{
		"title": "⚔️ Le Combat au Tour par Tour",
		"text":  "Chaque round, tu choisis une attaque\npuis les ennemis ripostent.\nReste attentif à ta barre de vie !",
	},
	{
		"title": "🎯 Choisir une cible",
		"text":  "Appuie sur  ↑  et  ↓ après avoir sèlectionner ton attaque\npour changer d'ennemi ciblé.\nL'indicateur (main) montre ta cible.",
	},
	{
		"title": "👊 Attaque Légère  [light]",
		"text":  "Rapide et toujours disponible.\nInflige peu de dégâts mais\ncharge la jauge Ultimate (+1).",
	},
	{
		"title": "🪓 Attaque Lourde  [heavy]",
		"text":  "Plus puissante mais a un cooldown\n(3 tours de recharge).\nCharge l'Ultimate encore plus (+2).",
	},
	{
		"title": "🌟 Attaque Ultimate  [ultimate]",
		"text":  "Disponible après 10 charges.\nC'est le coup le plus dévastateur !\nLa jauge se remet à zéro ensuite.",
	},
	{
		"title": "✅ À toi de jouer !",
		"text":  "Les boutons sont maintenant actifs.\nChoisis ton attaque et bats le monstre !",
	},
]

func _ready() -> void:
	# Cache tous les boutons jusqu'à la fin du tuto
	$CanvasLayer/choice.hide()
	highlight.visible = false

	btn_light.pressed.connect(_on_light)
	btn_heavy.pressed.connect(_on_heavy)
	btn_ultimate.pressed.connect(_on_ultimate)
	ennemies.request_attack_choice.connect(_on_request_choice)
	ennemies.battle_won.connect(_on_battle_won_tuto)

	bubble.steps = INTRO_STEPS
	bubble.all_done.connect(_on_intro_done)
	await get_tree().create_timer(0.5).timeout
	bubble.start()

func _on_intro_done() -> void:
	# Déverrouille le combat
	$CanvasLayer/choice.show()
	_on_request_choice(false, false)

func _on_request_choice(can_ult: bool, can_heavy: bool) -> void:
	btn_light.disabled    = false
	btn_heavy.disabled    = not can_heavy
	btn_ultimate.disabled = not can_ult
	btn_light.visible    = true
	btn_heavy.visible    = true
	btn_ultimate.visible = true
	btn_exit.visible = true

func _hide_buttons() -> void:
	btn_light.visible    = false
	btn_heavy.visible    = false
	btn_ultimate.visible = false
	btn_exit.visible = false

func _on_light() -> void:
	_hide_buttons()
	ennemies.choose_attack(5.0, "light")

func _on_heavy() -> void:
	_hide_buttons()
	ennemies.choose_attack(10.0, "heavy")

func _on_ultimate() -> void:
	_hide_buttons()
	ennemies.choose_attack(50.0, "ultimate")

func _on_battle_won_tuto() -> void:
	Global.is_tutorial = false
	# Retour au hub après victoire tuto
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://hub.tscn")

func _on_exit_pressed() -> void:
	Global.is_tutorial = false
	get_tree().change_scene_to_file("res://hub.tscn")
