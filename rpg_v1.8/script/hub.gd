extends CanvasLayer

# --- Références aux nœuds ---
@onready var sfx_hover_player : AudioStreamPlayer = $SFX_Hover
@onready var sfx_click_player : AudioStreamPlayer = $SFX_Click
@onready var sfx_open_player  : AudioStreamPlayer = $SFX_Open
@onready var vbox             : VBoxContainer      = $VBoxContainer
@onready var particles_far    : CPUParticles2D     = $BgParticlesFar
@onready var particles_bg     : CPUParticles2D     = $BgParticles
@onready var particles_sparks : CPUParticles2D     = $BgSparks
@onready var background       : TextureRect        = $Background
@onready var title_label      : Label              = $TitleLabel
@onready var selector         : Label               = $Selector

const SaveSlotsScene = preload("res://ui/save_slots.tscn")

var _current_button : Button = null

func _ready() -> void:
	sfx_hover_player.bus = "SFX"
	sfx_click_player.bus = "SFX"
	sfx_open_player.bus = "SFX"
	AudioManager.play_menu_music(preload("res://audio/musique varier/menu-sacha-2.2.ogg"))
	_setup_particles()
	_connect_buttons()
	_setup_background_pan()
	_play_opening_reveal()
	_entrance_animation()
	_play_title_shine()
	_start_selector_idle_pulse()
	call_deferred("_align_selector_default")

# =====================================================================
#  FOND & AMBIANCE
# =====================================================================

func _setup_background_pan() -> void:
	# Léger effet "Ken Burns" : le fond respire lentement en boucle,
	# ça évite l'effet "image figée" d'un écran-titre statique.
	background.pivot_offset = background.size / 2.0
	var t := create_tween().set_loops()
	t.tween_property(background, "scale", Vector2(1.07, 1.07), 10.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(background, "scale", Vector2(1.0, 1.0), 10.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _setup_particles() -> void:
	# Courbe utilisée pour faire "respirer" chaque particule : elle grossit,
	# tient un instant, puis se réduit en s'éteignant (flicker de braise).
	var flicker_curve := Curve.new()
	flicker_curve.add_point(Vector2(0.0, 0.0))
	flicker_curve.add_point(Vector2(0.15, 1.0))
	flicker_curve.add_point(Vector2(0.7, 0.85))
	flicker_curve.add_point(Vector2(1.0, 0.0))

	# --- Couche lointaine : grosses braises floues, lentes, en arrière-plan ---
	particles_far.emitting              = true
	particles_far.amount                = 4
	particles_far.lifetime              = 11.0
	particles_far.randomness             = 0.6
	particles_far.lifetime_randomness    = 0.5
	particles_far.gravity                = Vector2(4, -18)
	particles_far.initial_velocity_min   = 6.0
	particles_far.initial_velocity_max   = 16.0
	particles_far.scale_amount_min       = 5.0
	particles_far.scale_amount_max       = 11.0
	particles_far.scale_amount_curve     = flicker_curve
	particles_far.color                  = Color(0.7, 0.4, 0.12, 0.35)
	particles_far.color_ramp             = _fire_gradient()
	particles_far.hue_variation_min      = -0.04
	particles_far.hue_variation_max      = 0.06
	particles_far.emission_shape         = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles_far.emission_rect_extents  = Vector2(760, 12)
	particles_far.position               = Vector2(760, 700)
	particles_far.direction              = Vector2(0, -1)
	particles_far.spread                 = 20.0
	particles_far.orbit_velocity_min     = -0.06
	particles_far.orbit_velocity_max     = 0.06

	# --- Couche proche : petites braises vives, plus rapides, au premier plan ---
	particles_bg.emitting               = true
	particles_bg.amount                 = 10
	particles_bg.lifetime               = 6.5
	particles_bg.randomness              = 0.5
	particles_bg.lifetime_randomness     = 0.4
	particles_bg.gravity                = Vector2(8, -45)
	particles_bg.initial_velocity_min   = 15.0
	particles_bg.initial_velocity_max   = 55.0
	particles_bg.scale_amount_min       = 1.5
	particles_bg.scale_amount_max       = 4.5
	particles_bg.scale_amount_curve     = flicker_curve
	particles_bg.color                  = Color(0.95, 0.6, 0.15, 0.9)
	particles_bg.color_ramp             = _fire_gradient()
	particles_bg.hue_variation_min      = -0.05
	particles_bg.hue_variation_max      = 0.08
	particles_bg.emission_shape         = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles_bg.emission_rect_extents  = Vector2(730, 10)
	particles_bg.position               = Vector2(730, 680)
	particles_bg.direction              = Vector2(0, -1)
	particles_bg.spread                 = 35.0
	particles_bg.angular_velocity_min   = -30.0
	particles_bg.angular_velocity_max   = 30.0
	particles_bg.orbit_velocity_min     = -0.12
	particles_bg.orbit_velocity_max     = 0.12

	# --- Étincelles : quelques éclats dorés qui scintillent, très discrets ---
	particles_sparks.emitting               = true
	particles_sparks.amount                 = 5
	particles_sparks.lifetime               = 3.0
	particles_sparks.randomness              = 0.8
	particles_sparks.lifetime_randomness     = 0.6
	particles_sparks.gravity                = Vector2(0, -6)
	particles_sparks.initial_velocity_min   = 4.0
	particles_sparks.initial_velocity_max   = 20.0
	particles_sparks.scale_amount_min       = 0.5
	particles_sparks.scale_amount_max       = 1.4
	particles_sparks.scale_amount_curve     = flicker_curve
	particles_sparks.color                  = Color(1.0, 0.85, 0.5, 1.0)
	particles_sparks.emission_shape         = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles_sparks.emission_rect_extents  = Vector2(576, 324)
	particles_sparks.position               = Vector2(576, 324)
	particles_sparks.direction              = Vector2(0, -1)
	particles_sparks.spread                 = 180.0
	particles_sparks.angular_velocity_min   = -60.0
	particles_sparks.angular_velocity_max   = 60.0

func _fire_gradient() -> Gradient:
	var g := Gradient.new()
	g.colors = PackedColorArray([
		Color(1.0, 0.85, 0.25, 0.0),
		Color(0.95, 0.60, 0.05, 1.0),
		Color(0.55, 0.20, 0.02, 0.8),
		Color(0.10, 0.06, 0.02, 0.0)
	])
	g.offsets = PackedFloat32Array([0.0, 0.15, 0.55, 1.0])
	return g

# =====================================================================
#  OUVERTURE DU MENU (effet "iris" façon souls-like)
# =====================================================================

func _play_opening_reveal() -> void:
	Transition.snap_cover()
	Transition.reveal(Vector2(-1, -1), 1.1)

func _play_title_shine() -> void:
	var mat := title_label.material as ShaderMaterial
	mat.set_shader_parameter("progress", -0.5)
	var t := create_tween()
	t.tween_interval(0.9)
	t.tween_method(_set_shine_progress, -0.5, 1.4, 0.9)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _set_shine_progress(p: float) -> void:
	(title_label.material as ShaderMaterial).set_shader_parameter("progress", p)

# =====================================================================
#  BOUTONS : hover / focus (clavier + manette) / sélecteur animé
# =====================================================================

func _connect_buttons() -> void:
	for child in vbox.get_children():
		if not child is Button:
			continue
		child.focus_mode = Control.FOCUS_ALL
		child.mouse_entered.connect(_on_btn_selected.bind(child))
		child.focus_entered.connect(_on_btn_selected.bind(child))
		child.mouse_exited.connect(_on_btn_deselected.bind(child))
		child.focus_exited.connect(_on_btn_deselected.bind(child))

	var start_btn    : Button = vbox.get_node_or_null("start")
	var tutorial_btn : Button = vbox.get_node_or_null("tutorial")
	var option_btn   : Button = vbox.get_node_or_null("option")
	var credits_btn  : Button = vbox.get_node_or_null("credits")
	var exit_btn     : Button = vbox.get_node_or_null("exit")

	if start_btn:    start_btn.pressed.connect(_on_start_pressed)
	if tutorial_btn: tutorial_btn.pressed.connect(_on_tutorial_pressed)
	if option_btn:   option_btn.pressed.connect(_on_option_pressed)
	if credits_btn:  credits_btn.pressed.connect(_on_credits_pressed)
	if exit_btn:     exit_btn.pressed.connect(_on_exit_pressed)

func _on_btn_selected(btn: Button) -> void:
	if _current_button == btn:
		return
	_current_button = btn
	sfx_hover_player.play()
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(btn, "self_modulate", Color(1.6, 1.25, 0.55, 1.0), 0.1)
	t.tween_property(btn, "scale", Vector2(1.04, 1.04), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_move_selector_to(btn, false)

func _on_btn_deselected(btn: Button) -> void:
	if _current_button == btn:
		_current_button = null
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(btn, "self_modulate", Color(0.85, 0.72, 0.45, 1.0), 0.2)
	t.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)

func _move_selector_to(btn: Button, instant: bool) -> void:
	btn.pivot_offset = btn.size / 2.0
	var target_y := vbox.position.y + btn.position.y + btn.size.y / 2.0 - selector.size.y / 2.0
	if instant:
		selector.position.y = target_y
		selector.modulate.a = 1.0
		return
	var t := create_tween()
	t.tween_property(selector, "position:y", target_y, 0.18)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(selector, "modulate:a", 1.0, 0.12)

func _align_selector_default() -> void:
	var start_btn : Button = vbox.get_node_or_null("start")
	if start_btn:
		_move_selector_to(start_btn, true)
		start_btn.grab_focus()

func _start_selector_idle_pulse() -> void:
	# Petit scintillement continu du sélecteur, comme une flamme qui vacille.
	var t := create_tween().set_loops()
	t.tween_property(selector, "modulate", Color(1.0, 0.85, 0.4, 1.0), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(selector, "modulate", Color(1.0, 0.65, 0.2, 1.0), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# =====================================================================
#  ENTRÉE EN SCÈNE DES BOUTONS
# =====================================================================

func _entrance_animation() -> void:
	var idx := 0
	for child in vbox.get_children():
		if not child is Button:
			continue
		child.pivot_offset = child.size / 2.0
		child.modulate.a = 0.0
		child.position.x = -40.0
		var t := create_tween()
		t.tween_interval(0.55 + idx * 0.09)
		t.tween_property(child, "modulate:a", 1.0, 0.35)
		t.parallel().tween_property(child, "position:x", 0.0, 0.4)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		idx += 1

# =====================================================================
#  TRANSITIONS VERS LES AUTRES SCÈNES (iris qui se referme)
# =====================================================================

func _go_to_scene(path: String, origin: Control) -> void:
	sfx_click_player.play()
	sfx_open_player.play()
	var origin_pos := Vector2(-1, -1)
	if origin:
		origin_pos = origin.global_position + origin.size / 2.0
	Transition.change_scene(path, origin_pos)

func _on_start_pressed() -> void:
	sfx_click_player.play()
	sfx_open_player.play()
	var panel = SaveSlotsScene.instantiate()
	add_child(panel)         # s'affiche par-dessus le menu

func _on_option_pressed() -> void:
	_go_to_scene("res://settings.tscn", vbox.get_node_or_null("option"))

func _on_tutorial_pressed() -> void:
	_go_to_scene("res://tutorial/tutorial_map.tscn", vbox.get_node_or_null("tutorial"))

func _on_exit_pressed() -> void:
	sfx_click_player.play()
	await Transition.cover()
	get_tree().quit()

func _on_credits_pressed() -> void:
	sfx_click_player.play()
	# TODO Okalips : brancher ici l'ouverture d'un futur écran de crédits.
