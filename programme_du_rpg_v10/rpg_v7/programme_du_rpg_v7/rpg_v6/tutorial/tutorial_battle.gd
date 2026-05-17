# tutorial/tutorial_battle.gd
extends Node2D

@onready var btn_light    : Button      = $CanvasLayer/choice/light
@onready var btn_heavy    : Button      = $CanvasLayer/choice/heavy
@onready var btn_ultimate : Button      = $CanvasLayer/choice/ultimate
@onready var btn_exit     : Button      = $CanvasLayer/choice/exit
@onready var ennemies     : Node2D      = $ennemies_groupe
@onready var bubble       : CanvasLayer = $TutoBubble
@onready var highlight    : ColorRect   = $CanvasLayer/Highlight

@onready var hint_light   : Label = $CanvasLayer/choice/light/Hint
@onready var hint_heavy   : Label = $CanvasLayer/choice/heavy/Hint
@onready var hint_ult     : Label = $CanvasLayer/choice/ultimate/Hint

var _tuto_phase: int = 0

const INTRO_STEPS: Array[Dictionary] = [
	# ── Combat de base ────────────────────────────────────────────────────────
	{
		"title": "⚔️ Le Combat au Tour par Tour",
		"text":  "Chaque round, tu choisis une attaque\npuis les ennemis ripostent.\nReste attentif à ta barre de vie !",
	},
	{
		"title": "🎯 Choisir une cible",
		"text":  "Appuie sur  ↑  et  ↓ après avoir sélectionné ton attaque\npour changer d'ennemi ciblé.\nL'indicateur (main) montre ta cible.",
	},
	{
		"title": "🎯 Comment attaquer",
		"text":  "En bas à droite : des boutons avec différentes attaques.\nClique sur l'une d'elles,\npuis appuie sur Entrée pour confirmer.",
	},
	{
		"title": "👊 Attaque Légère  [light]",
		"text":  "Rapide et toujours disponible.\nInflige peu de dégâts mais\ncharge la jauge Ultimate (+1).",
	},
	{
		"title": "🪓 Attaque Lourde  [heavy]",
		"text":  "Plus puissante, mais a un cooldown\n(3 tours de recharge).\nCharge l'Ultimate encore plus (+2).",
	},
	{
		"title": "🌟 Attaque Ultimate  [ultimate]",
		"text":  "Disponible après 10 charges.\nC'est le coup le plus dévastateur !\nLa jauge se remet à zéro ensuite.",
	},
	# ── Système d'expérience ─────────────────────────────────────────────────
	{
		"title": "⭐ Système d'Expérience (XP)",
		"text":  "Chaque combat gagné te rapporte de l'XP.\nAccumule suffisamment d'XP pour\nmonter de niveau !",
	},
	{
		"title": "📊 Monter de niveau",
		"text":  "Il faut 100 XP pour passer au niveau suivant.\nChaque niveau rapporte 2 points d'aptitude\npar joueur — à dépenser dans le menu.",
	},
	{
		"title": "🎛️ Menu d'Aptitude",
		"text":  "Après chaque victoire, un menu s'ouvre.\nTu peux améliorer 4 statistiques\npour chacun de tes 4 personnages.",
	},
	{
		"title": "❤️  PV  —  Points de Vie",
		"text":  "Chaque rang augmente les PV maximum de +5.\nPlus de PV = tu encaisses plus de coups\navant d'être éliminé.",
	},
	{
		"title": "⚔️  Attaque",
		"text":  "Chaque rang ajoute +2 dégâts à toutes\ntes attaques (légère, lourde, ultime).\nDeviens plus menaçant au fil du temps !",
	},
	{
		"title": "🛡️  Défense",
		"text":  "Chaque rang réduit les dégâts reçus de 4%.\nAvec 10 rangs : tu encaisses\n40% de moins. Sois solide !",
	},
	{
		"title": "💥  Coup Critique",
		"text":  "Chaque rang donne +5% de chance de\ndoubler tes dégâts sur une attaque.\nAvec 10 rangs : 50% de chance de crit !",
	},
	{
		"title": "🎛️ Ouvrir le menu depuis la map",
		"text":  "Depuis la map (ou n'importe où),\nappuie sur  Tab  pour ouvrir ou fermer\nle menu d'aptitude à tout moment.",
	},
	{
		"title": "🔑 Code de Test",
		"text":  "Dans le menu d'aptitude, appuie sur\n  Ctrl + Shift + X\npour gagner instantanément 9999 XP !",
	},
	{
		"title": "✅ À toi de jouer !",
		"text":  "Les boutons sont maintenant actifs.\nChoisis ton attaque et bats le monstre !\nBonne chance !",
	},
]

func _ready() -> void:
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
	$CanvasLayer/choice.show()
	_on_request_choice(false, false)

func _on_request_choice(can_ult: bool, can_heavy: bool) -> void:
	btn_light.disabled    = false
	btn_heavy.disabled    = not can_heavy
	btn_ultimate.disabled = not can_ult
	btn_light.visible    = true
	btn_heavy.visible    = true
	btn_ultimate.visible = true
	btn_exit.visible     = true

func _hide_buttons() -> void:
	btn_light.visible    = false
	btn_heavy.visible    = false
	btn_ultimate.visible = false
	btn_exit.visible     = false

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
	# Donne aussi l'XP dans le tutoriel pour tester le système
	var leveled_up = Global.add_xp(Global.XP_PER_COMBAT)
	var result_ui = get_node_or_null("CanvasLayer/GameResult")
	if result_ui:
		result_ui.show_victory(Global.XP_PER_COMBAT, leveled_up)
	else:
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file("res://hub.tscn")

func _on_exit_pressed() -> void:
	Global.is_tutorial = false
	get_tree().change_scene_to_file("res://hub.tscn")
