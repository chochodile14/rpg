extends Node2D

class_name BattlePlayer

@onready var _focus = $turn
@onready var progress_bar = $pv
@onready var hurt = $hurt

@export var max_health: float = 7

var health: float = 7:
	set(value):
		health = value
		_update_progress_bar()
		_play_annimation()
		
func _update_progress_bar():
	progress_bar.value = (health/max_health)* 100

func _play_annimation():
	hurt.play("hurt")

func focus():
	_focus.show()
	
func unfocus():
	_focus.hide()
	
func take_damage(value):
	health -= value
