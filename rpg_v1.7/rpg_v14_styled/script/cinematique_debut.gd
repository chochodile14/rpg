extends Node2D

# ── Références aux nœuds ─────────────────────────────────────────────────────
@onready var anim        : AnimationPlayer  = $AnimationPlayer
@onready var color_rect  : ColorRect        = $ColorRect
@onready var castle_ex   : TextureRect      = $castleEX
@onready var chasseur    : Sprite2D         = $chasseur
@onready var empreur     : Sprite2D         = $empreur
@onready var angel_sfx               = $angel

# ── Nœuds VFX créés dynamiquement ────────────────────────────────────────────
var snow_particles  : GPUParticles2D
var lightning_timer : Timer
var vfx_timer       : Timer

# ── Dialogue du Chasseur (affiché lettre par lettre) ─────────────────────────
var dialogue_label  : Label
var dialogue_box    : PanelContainer
const CHASSEUR_TEXTE := [
	"...",
	"Il est là.",
	"La cible n'a jamais su que j'existais...",
	"Et pourtant, j'ai toujours su où il allait.",
	"Mon employeur veut qu'il vive encore un peu.",
	"Pour l'instant."
]
const VITESSE_LETTRE  := 0.045

# ── Dialogue de l'Empereur ────────────────────────────────────────────────────
const EMPREUR_TEXTE := [
	"Mon enfant...",
	"Le monde porte encore les cicatrices des Cendres.",
	"Des forces que je ne peux nommer cherchent à tout effacer.",
	"Toi seul peux marcher là où mes armées ne le peuvent pas.",
	"Retrouve ce qui a été perdu.\nAvant que l'obscurité ne le trouve à ta place."
]

# ── État interne ──────────────────────────────────────────────────────────────
var _typing       := false
var _current_text := ""
var _char_index   := 0
var _type_timer   : Timer
var _vfx_t        := 0.0


# ═════════════════════════════════════════════════════════════════════════════
#  SÉQUENCE PRINCIPALE
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_creer_ui_dialogue()
	_creer_neige_et_eclairs()

	$AudioStreamPlayer.play()
	await get_tree().create_timer(4).timeout
	snow_particles.emitting = true
	lightning_timer.start()
	anim.play("start")
	await get_tree().create_timer(1.5).timeout

	anim.play("castle_entry")
	await get_tree().create_timer(2.5).timeout
	anim.play("revers_start")
	await get_tree().create_timer(2.7).timeout

	# ── Arrêt météo, transition vers intérieur ────────────────────────────────
	snow_particles.emitting = false
	lightning_timer.stop()
	$AudioStreamPlayer.stop()

	color_rect.visible   = false
	$castleINf.visible   = true
	$castleINf2.visible  = true
	$castleINf3.visible  = true
	$castleINf4.visible  = true
	$castleINf5.visible  = true
	chasseur.visible     = true

	anim.play("apparetion")
	await get_tree().create_timer(1.5).timeout

	# ── Dialogues du Chasseur ─────────────────────────────────────────────────
	await _afficher_dialogues(CHASSEUR_TEXTE)

	await get_tree().create_timer(1.0).timeout
	$"evil laugh".play()
	await get_tree().create_timer(2.7).timeout

	_cacher_dialogue()
	color_rect.visible = true
	anim.play("revers_start")
	await get_tree().create_timer(3).timeout

	# ── Scène Empereur ────────────────────────────────────────────────────────
	$castleEX.visible    = false
	color_rect.visible   = false
	$castleINf.visible   = true
	$castleINf2.visible  = false
	$castleINf3.visible  = false
	$castleINf4.visible  = false
	$castleINf5.visible  = false
	chasseur.visible     = false
	empreur.visible      = true

	angel_sfx.play()
	await _flash_divin()
	_demarrer_vfx_divin()

	await get_tree().create_timer(1.8).timeout

	# ── Dialogues de l'Empereur ───────────────────────────────────────────────
	await _afficher_dialogues(EMPREUR_TEXTE)
	await get_tree().create_timer(1.2).timeout
	_cacher_dialogue()

	# ── Cinématique terminée : on sauvegarde et on passe à la map ────────────
	Global.cinematic_debut_viewed = true
	Global.save_game(Global.current_slot)
	get_tree().change_scene_to_file("res://map.tscn")


# ═════════════════════════════════════════════════════════════════════════════
#  UI DIALOGUE
# ═════════════════════════════════════════════════════════════════════════════

func _creer_ui_dialogue() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	dialogue_box = PanelContainer.new()
	dialogue_box.name = "DialogueBox"
	var style := StyleBoxFlat.new()
	style.bg_color                = Color(0.04, 0.03, 0.02, 0.88)
	style.border_width_top        = 2
	style.border_color            = Color(0.78, 0.59, 0.2, 0.7)
	style.corner_radius_top_left  = 6
	style.corner_radius_top_right = 6
	style.content_margin_left     = 24.0
	style.content_margin_right    = 24.0
	style.content_margin_top      = 14.0
	style.content_margin_bottom   = 14.0
	dialogue_box.add_theme_stylebox_override("panel", style)
	dialogue_box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dialogue_box.offset_top    = -160.0
	dialogue_box.offset_bottom = -20.0
	dialogue_box.offset_left   = 60.0
	dialogue_box.offset_right  = -60.0
	dialogue_box.visible       = false
	canvas.add_child(dialogue_box)

	dialogue_label = Label.new()
	dialogue_label.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	dialogue_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	dialogue_label.add_theme_color_override("font_color", Color(0.92, 0.87, 0.75))
	dialogue_label.add_theme_font_size_override("font_size", 22)
	dialogue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_label.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	dialogue_box.add_child(dialogue_label)

	_type_timer = Timer.new()
	_type_timer.one_shot  = false
	_type_timer.wait_time = VITESSE_LETTRE
	_type_timer.timeout.connect(_on_type_tick)
	add_child(_type_timer)


# ═════════════════════════════════════════════════════════════════════════════
#  VFX NEIGE ET ÉCLAIRS
# ═════════════════════════════════════════════════════════════════════════════

func _creer_neige_et_eclairs() -> void:
	snow_particles = GPUParticles2D.new()
	snow_particles.name     = "Snow"
	snow_particles.emitting = false
	snow_particles.amount   = 220
	snow_particles.lifetime = 4.5
	snow_particles.position = Vector2(576, -10)
	snow_particles.z_index  = 10

	var pm := ParticleProcessMaterial.new()
	pm.direction            = Vector3(1, 0, 0)
	pm.spread               = 80.0
	pm.gravity              = Vector3(18, 60, 0)
	pm.initial_velocity_min = 20.0
	pm.initial_velocity_max = 60.0
	pm.scale_min            = 1.5
	pm.scale_max            = 4.0
	pm.color                = Color(0.88, 0.93, 1.0, 0.75)
	pm.emission_shape       = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(600, 1, 1)
	snow_particles.process_material = pm
	add_child(snow_particles)

	lightning_timer = Timer.new()
	lightning_timer.one_shot  = false
	lightning_timer.wait_time = randf_range(1.5, 3.5)
	lightning_timer.timeout.connect(_on_lightning)
	add_child(lightning_timer)


func _on_lightning() -> void:
	lightning_timer.wait_time = randf_range(1.5, 4.0)
	var flash := ColorRect.new()
	flash.color   = Color(0.9, 0.95, 1.0, 0.55)
	flash.z_index = 20
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	await get_tree().create_timer(0.08).timeout
	flash.color.a = 0.15
	await get_tree().create_timer(0.06).timeout
	flash.queue_free()


# ═════════════════════════════════════════════════════════════════════════════
#  VFX DIVINS
# ═════════════════════════════════════════════════════════════════════════════

func _flash_divin() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 8
	add_child(canvas)

	var flash := ColorRect.new()
	flash.color = Color(1.0, 0.95, 0.6, 0.0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(flash)

	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.6, 0.4)
	tween.tween_property(flash, "color:a", 0.0, 1.2)
	await tween.finished
	canvas.queue_free()


func _demarrer_vfx_divin() -> void:
	var canvas := CanvasLayer.new()
	canvas.name  = "CanvasVFX"
	canvas.layer = 7
	add_child(canvas)

	var lueur := ColorRect.new()
	lueur.name  = "LueurDivine"
	lueur.color = Color(1.0, 0.88, 0.3, 0.09)
	lueur.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(lueur)

	vfx_timer = Timer.new()
	vfx_timer.one_shot  = false
	vfx_timer.wait_time = 0.016
	vfx_timer.timeout.connect(_on_vfx_frame)
	add_child(vfx_timer)
	vfx_timer.start()

	var light_particles := GPUParticles2D.new()
	light_particles.name     = "DivinParticles"
	light_particles.amount   = 60
	light_particles.lifetime = 3.0
	light_particles.position = Vector2(576, 648)
	light_particles.z_index  = 6

	var lpm := ParticleProcessMaterial.new()
	lpm.direction            = Vector3(0, -1, 0)
	lpm.spread               = 35.0
	lpm.gravity              = Vector3(0, -5, 0)
	lpm.initial_velocity_min = 30.0
	lpm.initial_velocity_max = 80.0
	lpm.scale_min            = 2.0
	lpm.scale_max            = 5.0
	lpm.color                = Color(1.0, 0.92, 0.45, 0.7)
	lpm.emission_shape       = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	lpm.emission_box_extents = Vector3(300, 1, 1)
	light_particles.process_material = lpm
	light_particles.emitting = true
	add_child(light_particles)


func _on_vfx_frame() -> void:
	_vfx_t += 0.016
	var canvas_vfx = get_node_or_null("CanvasVFX")
	if canvas_vfx:
		var lueur = canvas_vfx.get_node_or_null("LueurDivine")
		if lueur:
			lueur.color.a = 0.07 + 0.04 * sin(_vfx_t * 1.8)


# ═════════════════════════════════════════════════════════════════════════════
#  SYSTÈME DE DIALOGUE
# ═════════════════════════════════════════════════════════════════════════════

func _afficher_dialogues(lignes: Array) -> void:
	for ligne in lignes:
		await _taper_texte(ligne)
		await get_tree().create_timer(2.0).timeout

func _taper_texte(texte: String) -> void:
	dialogue_box.visible = true
	_current_text        = texte
	_char_index          = 0
	dialogue_label.text  = ""
	_typing              = true
	_type_timer.start()
	while _typing:
		await get_tree().process_frame

func _on_type_tick() -> void:
	if _char_index < _current_text.length():
		_char_index        += 1
		dialogue_label.text = _current_text.substr(0, _char_index)
	else:
		_typing = false
		_type_timer.stop()

func _cacher_dialogue() -> void:
	dialogue_box.visible = false
	dialogue_label.text  = ""


func _process(_delta: float) -> void:
	pass
