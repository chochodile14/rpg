extends Node2D

@onready var btn_light = $CanvasLayer/choice/light
@onready var btn_heavy = $CanvasLayer/choice/heavy
@onready var btn_ultimate = $CanvasLayer/choice/ultimate
@onready var btn_exit = $CanvasLayer/choice/exit
@onready var ennemies_groupe = $ennemies_groupe

func _ready():
	print("battle lancé")
	$CanvasLayer/choice.show()
	btn_light.pressed.connect(_on_light)
	btn_heavy.pressed.connect(_on_heavy)
	btn_ultimate.pressed.connect(_on_ultimate)
	ennemies_groupe.request_attack_choice.connect(_on_request_choice)
	_hide_buttons()

func _on_request_choice(can_ultimate: bool, can_heavy: bool):
	btn_light.disabled = false
	btn_heavy.disabled = not can_heavy
	btn_ultimate.disabled = not can_ultimate
	btn_light.visible = true
	btn_heavy.visible = true
	btn_ultimate.visible = true
	btn_exit.visible= true

func _hide_buttons():
	btn_light.visible = false
	btn_heavy.visible = false
	btn_ultimate.visible = false
	btn_exit.visible= false

func _on_light():
	_hide_buttons()
	ennemies_groupe.choose_attack(5.0, "light")

func _on_heavy():
	_hide_buttons()
	ennemies_groupe.choose_attack(10.0, "heavy")

func _on_ultimate():
	_hide_buttons()
	ennemies_groupe.choose_attack(50.0, "ultimate")


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://map.tscn")
