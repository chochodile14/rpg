# ui/damage_number.gd
extends Node2D

func setup(screen_pos: Vector2, amount: float, attack_type: String) -> void:
	var vp = get_viewport().get_visible_rect()
	var px = clamp(screen_pos.x + randf_range(-20, 20), 60, vp.size.x - 60)
	var py = clamp(screen_pos.y, 80, vp.size.y - 80)
	position = Vector2(px, py)

	var lbl := Label.new()
	add_child(lbl)

	match attack_type:
		"crit":
			# ── Coup Critique : texte doré XXL avec icône étoile ─────────────
			lbl.text = "💥 CRITIQUE  -%d !!" % int(amount)
			lbl.add_theme_color_override("font_color",  Color(1.0, 0.95, 0.0))
			lbl.add_theme_color_override("font_outline_color", Color(0.6, 0.0, 0.0))
			lbl.add_theme_font_size_override("font_size", 42)
			lbl.add_theme_constant_override("outline_size", 5)
		"ultimate":
			lbl.text = "⚡ -%d !" % int(amount)
			lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
			lbl.add_theme_font_size_override("font_size", 36)
			lbl.add_theme_constant_override("outline_size", 3)
		"heavy":
			lbl.text = "-%d !" % int(amount)
			lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.1))
			lbl.add_theme_font_size_override("font_size", 30)
			lbl.add_theme_constant_override("outline_size", 3)
		_:
			lbl.text = "-%d" % int(amount)
			lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
			lbl.add_theme_font_size_override("font_size", 24)
			lbl.add_theme_constant_override("outline_size", 2)

	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)

	await get_tree().process_frame
	lbl.position = Vector2(-lbl.size.x / 2.0, -lbl.size.y / 2.0)

	var rise   = 90 if attack_type == "crit" else 70
	var duration = 1.1 if attack_type == "crit" else 0.85

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - rise, duration) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, duration).set_delay(duration * 0.4)

	# Entrée avec zoom pour les types forts
	if attack_type in ["crit", "ultimate"]:
		lbl.scale = Vector2(0.3, 0.3)
		tween.tween_property(lbl, "scale", Vector2(1.0, 1.0), 0.22) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Légère rotation aléatoire sur le critique pour plus de punch
	if attack_type == "crit":
		var rot = randf_range(-0.15, 0.15)
		tween.tween_property(lbl, "rotation", rot, 0.15)

	await tween.finished
	queue_free()
