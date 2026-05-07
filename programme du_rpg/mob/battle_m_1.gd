extends Node2D

class_name BattleEnnemy

@onready var _focus = $turn
@onready var progress_bar = $pv
@onready var hurt = $hurt

@export var max_health: float = 100
@export var attack_damage: float = 2.0

var health: float = 100:
	set(value):
		health = clamp(value, 0, max_health)
		_update_progress_bar()
		_play_annimation()
		if health <= 0:
			die()

func _update_progress_bar():
	progress_bar.value = (health / max_health) * 100

func _play_annimation():
	hurt.play("hurt")

func focus():
	_focus.show()

func unfocus():
	_focus.hide()

func take_damage(value):
	health -= value

func die():
	_focus.hide()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): queue_free())

func attack_animation(target_node: Node2D) -> void:
	var start_pos = position
	var target_pos = target_node.global_position + Vector2(-200, 0)
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.18)
	tween.tween_callback(func():
		target_node.take_damage(attack_damage)
	)
	tween.tween_interval(0.1)
	tween.tween_property(self, "position", start_pos, 0.18)
	await tween.finished
