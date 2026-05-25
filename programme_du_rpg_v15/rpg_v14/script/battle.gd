extends Node2D

@onready var btn_light      : Button      = $CanvasLayer/choice/light
@onready var btn_heavy      : Button      = $CanvasLayer/choice/heavy
@onready var btn_ultimate   : Button      = $CanvasLayer/choice/ultimate
@onready var btn_exit       : Button      = $CanvasLayer/choice/exit
@onready var ennemies_groupe: Node        = $ennemies_groupe
@onready var ult_bar        : ProgressBar = $CanvasLayer/UltBar/BarBg/Bar
@onready var ult_label      : Label       = $CanvasLayer/UltBar/Label
@onready var ult_flash      : ColorRect   = $CanvasLayer/UltBar/Flash

func _ready():
	print("battle lancé")
	$CanvasLayer/choice.show()
	btn_light.pressed.connect(_on_light)
	btn_heavy.pressed.connect(_on_heavy)
	btn_ultimate.pressed.connect(_on_ultimate)
	ennemies_groupe.request_attack_choice.connect(_on_request_choice)
	ennemies_groupe.ultimate_charge_changed.connect(_on_charge_changed)
	_hide_buttons()
	# Initialise la barre à 0
	_on_charge_changed(0, ennemies_groupe.ULTIMATE_CHARGE_MAX)

func _on_request_choice(can_ultimate: bool, can_heavy: bool):
	btn_light.disabled    = false
	btn_heavy.disabled    = not can_heavy
	btn_ultimate.disabled = not can_ultimate
	btn_light.visible    = true
	btn_heavy.visible    = true
	btn_ultimate.visible = true
	btn_exit.visible     = true

func _hide_buttons():
	btn_light.visible    = false
	btn_heavy.visible    = false
	btn_ultimate.visible = false
	btn_exit.visible     = false

func _on_light():
	_hide_buttons()
	ennemies_groupe.choose_attack(5.0, "light")

func _on_heavy():
	_hide_buttons()
	ennemies_groupe.choose_attack(10.0, "heavy")

func _on_ultimate():
	_hide_buttons()
	ennemies_groupe.choose_attack(50.0, "ultimate")

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://map.tscn")

# ── Barre de charge de l'Ultimate ────────────────────────────────────────────
func _on_charge_changed(current: int, maximum: int) -> void:
	var pct = float(current) / float(maximum)
	ult_bar.value = pct * 100.0

	# Couleur qui passe du bleu → violet → or selon la charge
	var col: Color
	if pct < 0.5:
		col = Color(0.2, 0.5, 1.0).lerp(Color(0.7, 0.2, 1.0), pct * 2.0)
	else:
		col = Color(0.7, 0.2, 1.0).lerp(Color(1.0, 0.85, 0.0), (pct - 0.5) * 2.0)

	# Applique la couleur à la barre via StyleBoxFlat
	var style = ult_bar.get_theme_stylebox("fill").duplicate()
	if style is StyleBoxFlat:
		style.bg_color = col
		ult_bar.add_theme_stylebox_override("fill", style)

	# Texte
	if current >= maximum:
		ult_label.text       = "🌟 ULTIMATE PRÊT !"
		ult_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1))
		# Flash doré quand c'est plein
		_flash_bar()
	else:
		ult_label.text = "⚡ Ultimate  %d / %d" % [current, maximum]
		ult_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))

func _flash_bar() -> void:
	ult_flash.visible = true
	ult_flash.modulate.a = 0.7
	var t = create_tween()
	t.tween_property(ult_flash, "modulate:a", 0.0, 0.6)
	t.tween_callback(func(): ult_flash.visible = false)
