# ui/damage_number.gd
# Chiffre de dégât flottant qui monte et s'estompe au-dessus d'un ennemi.
# Doit être ajouté à un CanvasLayer pour rester dans l'espace écran.
extends Node2D

func setup(screen_pos: Vector2, amount: float, attack_type: String) -> void:
	# Clamp pour ne jamais dépasser les bords de l'écran (1152x648 par défaut)
	var vp  = get_viewport().get_visible_rect()
	var px  = clamp(screen_pos.x + randf_range(-20, 20), 60, vp.size.x - 60)
	var py  = clamp(screen_pos.y,                        80, vp.size.y - 80)
	position = Vector2(px, py)

	var lbl := Label.new()
	add_child(lbl)

	match attack_type:
		"ultimate":
			lbl.text = "⚡ -%d !" % int(amount)
			lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
			lbl.add_theme_font_size_override("font_size", 36)
		"heavy":
			lbl.text = "-%d !" % int(amount)
			lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.1))
			lbl.add_theme_font_size_override("font_size", 30)
		_:
			lbl.text = "-%d" % int(amount)
			lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
			lbl.add_theme_font_size_override("font_size", 24)

	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.add_theme_constant_override("outline_size", 3)

	# Centre le label sur son origine
	await get_tree().process_frame
	lbl.position = Vector2(-lbl.size.x / 2.0, -lbl.size.y / 2.0)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 70, 0.85)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.85).set_delay(0.3)

	if attack_type == "ultimate":
		lbl.scale = Vector2(0.4, 0.4)
		tween.tween_property(lbl, "scale", Vector2(1.0, 1.0), 0.2)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween.finished
	queue_free()
