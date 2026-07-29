extends Node2D
class_name BattlePlayer

# ── Barre de vie (asset pixel-art à 6 paliers : 100/80/60/40/20/0%) ──────────
const HP_SHEET := preload("res://art/ui/player_hp_sheet.png")

const HP_BAR_REGIONS := [
	Rect2(0, 14, 483, 146),    # 100%
	Rect2(0, 175, 483, 147),   # ~83%
	Rect2(0, 336, 483, 147),   # ~66%
	Rect2(0, 498, 483, 146),   # ~50%
	Rect2(0, 659, 483, 146),   # ~33%
	Rect2(0, 820, 483, 147),   # ~16% / vide
]
var _hp_frames: Array = []
@onready var _focus      = $turn
@onready var progress_bar = $pv
@onready var hurt_anim   = $hurt
@onready var atk_anim    = $atk
@onready var _base_sprite: Sprite2D = $base
@onready var _base_default_position: Vector2 = _base_sprite.position

# ── Sons de combat ────────────────────────────────────────────────────────────
@onready var sfx_player_hurt = $SFX_PlayerHurt
@onready var sfx_player_die  = $SFX_PlayerDie
@onready var sfx_punch       = $SFX_Punch
@onready var sfx_heavy       = $SFX_Heavy
@onready var sfx_ultimate    = $SFX_Ultimate

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
	_apply_class_sprite()

func _apply_class_sprite() -> void:
	if player_index < Global.player_classes.size():
		var char_class = Global.player_classes[player_index]
		if char_class != null and char_class.battle_texture != null:
			_base_sprite.texture = char_class.battle_texture
			_base_sprite.rotation_degrees = char_class.battle_rotation_degrees
			_base_sprite.flip_h = char_class.flip_h
			_base_sprite.flip_v = char_class.flip_v

			var tex_height = char_class.battle_texture.get_height()
			if tex_height > 0:
				var uniform_scale = (char_class.battle_target_height / tex_height) * char_class.battle_visual_scale_correction
				_base_sprite.scale = Vector2(uniform_scale, uniform_scale)

			_base_sprite.position = _base_default_position + char_class.battle_offset
func _update_progress_bar():
	var pct = health / max_health
	var stage_index = int(clamp((1.0 - pct) * HP_BAR_REGIONS.size(), 0, HP_BAR_REGIONS.size() - 1))

	var atlas := AtlasTexture.new()
	atlas.atlas = HP_SHEET
	atlas.region = HP_BAR_REGIONS[stage_index]
	progress_bar.texture = atlas

func _play_hurt_animation():
	if not is_dead:
		hurt_anim.play("hurt")
		if sfx_player_hurt: sfx_player_hurt.play()
		_shake_bar()

func _shake_bar() -> void:
	var base_pos = progress_bar.position
	var tween = create_tween()
	tween.tween_property(progress_bar, "position", base_pos + Vector2(4, 0), 0.03)
	tween.tween_property(progress_bar, "position", base_pos + Vector2(-4, 0), 0.03)
	tween.tween_property(progress_bar, "position", base_pos + Vector2(3, 0), 0.03)
	tween.tween_property(progress_bar, "position", base_pos + Vector2(-3, 0), 0.03)
	tween.tween_property(progress_bar, "position", base_pos, 0.03)

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
