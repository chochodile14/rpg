extends Node2D
class_name BattleEnnemy

@onready var _focus       = $turn
@onready var progress_bar = $pv
@onready var hurt         = $hurt

# ── Sons de combat ────────────────────────────────────────────────────────────
# Crée les AudioStreamPlayer enfants suivants dans la scène battle_m_1.tscn :
# SFX_MonsterHurt → alice_soundz-kick_h_08-224057.mp3  (monstre reçoit dégâts)
# SFX_MonsterDie  → data_pion-sfx28-attack-338386.mp3  (mort du monstre)
#SFX_MonsterAtk   → alice_soundz-kick_h_05-224057.mp3  (monstre attaque)
@onready var sfx_monster_hurt = $SFX_MonsterHurt
@onready var sfx_monster_die  = $SFX_MonsterDie
@onready var sfx_monster_atk  = $SFX_MonsterAtk

@export var max_health: float = 100
@export var attack_damage: float = 3.0

var is_dying: bool = false

var health: float = 100:
	set(value):
		health = clamp(value, 0, max_health)
		_update_progress_bar()
		if not is_dying:
			_play_annimation()
		if health <= 0 and not is_dying:
			die()

func _update_progress_bar():
	progress_bar.value = (health / max_health) * 100

func _play_annimation():
	hurt.play("hurt")
	sfx_monster_hurt.play()

func focus():
	if not is_dying:
		_focus.show()

func unfocus():
	_focus.hide()

func take_damage(value):
	if not is_dying:
		health -= value

func die():
	is_dying = true
	_focus.hide()
	sfx_monster_die.play()
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
	sfx_monster_atk.play()
	tween.tween_interval(0.1)
	tween.tween_property(self, "position", start_pos, 0.18)
	await tween.finished
	
