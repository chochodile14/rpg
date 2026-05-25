extends Node2D
class_name BattlePlayer

@onready var _focus    = $turn
@onready var progress_bar = $pv
@onready var hurt_anim = $hurt
@onready var atk_anim  = $atk

# Index du joueur dans Global (0-3), réglé par player_group au démarrage
var player_index: int = 0

@export var max_health: float = 20

var health: float = 20:
	set(value):
		health = clamp(value, 0, max_health)
		_update_progress_bar()
		_play_hurt_animation()
		if health <= 0:
			die()

var is_dead: bool = false

func _ready() -> void:
	# Applique les HP depuis Global selon l'index du joueur
	max_health = Global.get_max_hp(player_index)
	health = max_health

func _update_progress_bar():
	progress_bar.value = (health / max_health) * 100

func _play_hurt_animation():
	if not is_dead:
		hurt_anim.play("hurt")

func focus():
	if not is_dead:
		_focus.show()

func unfocus():
	_focus.hide()

func take_damage(raw_damage: float) -> void:
	if is_dead:
		return
	# Applique la réduction de défense
	var reduction = Global.get_def_reduction(player_index)
	var final_dmg = raw_damage * (1.0 - reduction)
	health -= final_dmg

func play_attack_animation(type: String) -> void:
	match type:
		"light":   atk_anim.play("atk_light")
		"heavy":   atk_anim.play("atk_heavy")
		"ultimate":atk_anim.play("atk_ultimate")
	await atk_anim.animation_finished

func play_win_animation() -> void:
	hurt_anim.play("win")
	await hurt_anim.animation_finished

func play_lose_animation() -> void:
	hurt_anim.play("lose")
	await hurt_anim.animation_finished

func die():
	is_dead = true
	_focus.hide()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): queue_free())
