extends CanvasLayer

# Durée avant retour automatique à la map (en secondes)
const DELAY_BEFORE_MAP: float = 3.0

@onready var overlay        : ColorRect  = $Overlay
@onready var title_label    : Label      = $CenterContainer/VBox/TitleLabel
@onready var sub_label      : Label      = $CenterContainer/VBox/SubLabel
@onready var particles_node : Node2D     = $Particles

var _tween: Tween


func show_game_over() -> void:
	# Couleurs sombres + texte rouge sang
	overlay.color            = Color(0.0, 0.0, 0.0, 0.0)
	title_label.text         = "GAME OVER"
	title_label.add_theme_color_override("font_color", Color(0.85, 0.05, 0.05))
	sub_label.text           = "Vous avez été vaincu..."
	sub_label.add_theme_color_override("font_color", Color(0.75, 0.25, 0.25))
	_play_animation(false)


func show_victory() -> void:
	# Couleurs dorées festives
	overlay.color            = Color(0.0, 0.0, 0.0, 0.0)
	title_label.text         = "VICTOIRE !"
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
	sub_label.text           = "Vous avez triomphé !"
	sub_label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3))
	_play_animation(true)


func _play_animation(is_victory: bool) -> void:
	visible = true

	# Réinitialise état visuel
	title_label.modulate.a = 0.0
	sub_label.modulate.a   = 0.0
	title_label.scale      = Vector2(2.0, 2.0)
	sub_label.position.y   = 30.0

	_tween = create_tween().set_parallel(false)

	# 1) Fondu du fond
	_tween.tween_property(overlay, "color:a", 0.75, 0.6)

	# 2) Le titre tombe + apparaît (en parallèle)
	_tween.set_parallel(true)
	_tween.tween_property(title_label, "modulate:a", 1.0, 0.55)
	_tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.55) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.set_parallel(false)

	# 3) Sous-titre glisse vers le haut + apparaît
	_tween.tween_interval(0.15)
	_tween.set_parallel(true)
	_tween.tween_property(sub_label, "modulate:a", 1.0, 0.5)
	_tween.tween_property(sub_label, "position:y", 0.0, 0.5) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.set_parallel(false)

	# 4) Effet spécial selon le résultat
	if is_victory:
		_tween.tween_interval(0.1)
		_tween.tween_callback(_start_confetti)
	else:
		_tween.tween_interval(0.1)
		_tween.tween_callback(_start_shake)

	# 5) Pause puis retour map
	_tween.tween_interval(DELAY_BEFORE_MAP)
	_tween.tween_callback(_return_to_map)


# Légère secousse du titre pour le game over
func _start_shake() -> void:
	var shake_tween = create_tween().set_loops(4)
	shake_tween.tween_property(title_label, "position:x", 10.0, 0.05)
	shake_tween.tween_property(title_label, "position:x", -10.0, 0.05)
	shake_tween.tween_property(title_label, "position:x", 0.0, 0.05)


# Petites étoiles animées pour la victoire (instanciées via code)
func _start_confetti() -> void:
	for i in range(18):
		var star := Label.new()
		star.text = ["★", "✦", "✧", "◆"][randi() % 4]
		star.add_theme_font_size_override("font_size", randi_range(20, 40))
		var col := Color(randf(), randf() * 0.5 + 0.5, randf() * 0.3)
		star.add_theme_color_override("font_color", col)
		star.position = Vector2(
			randf_range(80.0, 1000.0),
			randf_range(-40.0, 640.0)
		)
		add_child(star)

		var t = create_tween()
		t.set_parallel(true)
		t.tween_property(star, "position:y", star.position.y - randf_range(80, 200), 1.8) \
			.set_trans(Tween.TRANS_SINE)
		t.tween_property(star, "modulate:a", 0.0, 1.8)
		t.tween_property(star, "scale",
			Vector2(randf_range(0.5, 1.5), randf_range(0.5, 1.5)), 1.8)


func _return_to_map() -> void:
	var mob_pos = Global.battle_mob_position
	Global.player_spawn_position = mob_pos + Vector2(-80, 0)
	get_tree().change_scene_to_file("res://map.tscn")
