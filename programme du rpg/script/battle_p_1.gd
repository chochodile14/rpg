extends Node2D

class_name BattlePlayer

@onready var _focus = $turn
@onready var progress_bar = $pv
@onready var hurt = $hurt

@export var max_health: float = 7

var health: float = 7:
	set(value):
		health = clamp(value, 0, max_health)
		_update_progress_bar()
		_play_annimation()
		if health <= 0:
			die()

var is_dead: bool = false

func _update_progress_bar():
	progress_bar.value = (health / max_health) * 100

func _play_annimation():
	if not is_dead:
		hurt.play("hurt")

func focus():
	if not is_dead:
		_focus.show()

func unfocus():
	_focus.hide()

func take_damage(value):
	if not is_dead:
		health -= value

func die():
	is_dead = true
	_focus.hide()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): queue_free())
