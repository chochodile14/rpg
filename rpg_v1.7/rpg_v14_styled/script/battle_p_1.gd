extends Node2D
class_name BattlePlayer

@onready var _focus      = $turn
@onready var progress_bar = $pv
@onready var hurt_anim   = $hurt
@onready var atk_anim    = $atk

# ── Sons de combat ────────────────────────────────────────────────────────────
@onready var sfx_player_hurt = $SFX_PlayerHurt   # kick_m_05 → joueur reçoit dégâts
@onready var sfx_player_die  = $SFX_PlayerDie    # fall1     → joueur meurt
@onready var sfx_punch       = $SFX_Punch        # punch_h_05 → attaque légère
@onready var sfx_heavy       = $SFX_Heavy        # scorpion_claw → attaque lourde
@onready var sfx_ultimate    = $SFX_Ultimate     # bear_attack → ultime

var player_index: int = 0

@export var max_health: float = 20

# CORRECTION : on stocke la valeur séparément pour pouvoir comparer avant d'affecter
var health: float = 20:
	set(value):
		var prev_health = health
		health = clamp(value, 0, max_health)
		_update_progress_bar()
		# On compare la NOUVELLE valeur à l'ancienne pour détecter les dégâts
		if health < prev_health and not is_dead:
			_play_hurt_animation()
		if health <= 0:
			die()

var is_dead: bool = false

func _ready() -> void:
	max_health = Global.get_max_hp(player_index)
	health = max_health

func _update_progress_bar():
	progress_bar.value = (health / max_health) * 100

func _play_hurt_animation():
	if not is_dead:
		hurt_anim.play("hurt")
		if sfx_player_hurt: sfx_player_hurt.play()

func focus():
	if not is_dead:
		_focus.show()

func unfocus():
	_focus.hide()

func take_damage(raw_damage: float) -> void:
	if is_dead:
		return
	var reduction = Global.get_def_reduction(player_index)
	var final_dmg = raw_damage * (1.0 - reduction)
	health -= final_dmg

func play_attack_animation(type: String) -> void:
	match type:
		"light":
			atk_anim.play("atk_light")
			if sfx_punch: sfx_punch.play()
		"heavy":
			atk_anim.play("atk_heavy")
			if sfx_heavy: sfx_heavy.play()
		"ultimate":
			atk_anim.play("atk_ultimate")
			if sfx_ultimate: sfx_ultimate.play()
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
	if sfx_player_die: sfx_player_die.play()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): queue_free())
