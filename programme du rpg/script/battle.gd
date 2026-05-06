extends Node2D


@onready var btn_light = $CanvasLayer/choice/light
@onready var btn_heavy = $CanvasLayer/choice/heavy
@onready var btn_ultimate = $CanvasLayer/choice/ultimate
@onready var ennemies_groupe = $ennemies_groupe

func _ready():
	print("battle lancé")
	$CanvasLayer/choice.show()
	var c = $CanvasLayer/choice
	c.show()
	btn_light.pressed.connect(_on_light)
	btn_heavy.pressed.connect(_on_heavy)
	btn_ultimate.pressed.connect(_on_ultimate)
	ennemies_groupe.request_attack_choice.connect(_on_request_choice)
	_hide_buttons()

func _on_request_choice(can_ultimate: bool):
	btn_light.disabled = false
	btn_heavy.disabled = false
	btn_ultimate.disabled = not can_ultimate
	btn_light.visible = true
	btn_heavy.visible = true
	btn_ultimate.visible = true

func _hide_buttons():
	btn_light.visible = false
	btn_heavy.visible = false
	btn_ultimate.visible = false

func _on_light():
	_hide_buttons()
	ennemies_groupe.choose_attack(1.0)   # Attaque légère : 1 dégât

func _on_heavy():
	_hide_buttons()
	ennemies_groupe.choose_attack(3.0)   # Attaque lourde : 3 dégâts

func _on_ultimate():
	_hide_buttons()
	ennemies_groupe.choose_attack(6.0)   # Ultimate : 6 dégâts
