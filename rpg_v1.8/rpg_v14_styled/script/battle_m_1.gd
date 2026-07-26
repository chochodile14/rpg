extends Node2D
class_name BattleEnnemy

# ── Barre de vie (asset pixel-art à 6 paliers : 100/80/60/40/20/0%) ──────────
const HP_BAR_SHEET := preload("res://art/ui/enemy_hp_sheet.png")
const HP_BAR_FRAME_RECTS := [
	Rect2(163, 287, 152, 61),
	Rect2(163, 356, 152, 61),
	Rect2(163, 425, 152, 61),
	Rect2(163, 494, 152, 61),
	Rect2(163, 563, 152, 61),
	Rect2(163, 632, 152, 61),
]
var _hp_frames: Array = []

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

func _ready() -> void:
	for r in HP_BAR_FRAME_RECTS:
		var tex := AtlasTexture.new()
		tex.atlas = HP_BAR_SHEET
		tex.region = r
		_hp_frames.append(tex)
	_update_progress_bar()

func _update_progress_bar():
	if _hp_frames.is_empty():
		return
	var pct = health / max_health
	var idx = clampi(int(round((1.0 - pct) * 5.0)), 0, 5)
	progress_bar.texture = _hp_frames[idx]

func _play_annimation():
	hurt.play("hurt")
	sfx_monster_hurt.play()
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
	
