extends Control

@onready var hero_list: HBoxContainer    = $HeroList
@onready var detail_panel: VBoxContainer = $DetailPanel
@onready var back_button: Button         = $DetailPanel/BackButton
@onready var portrait: TextureRect       = $DetailPanel/Portrait
@onready var name_label: Label           = $DetailPanel/NameLabel
@onready var grid: GridContainer         = $DetailPanel/GridContainer

var selected_index: int = -1

func _ready() -> void:
	back_button.text = "← Retour"
	back_button.custom_minimum_size = Vector2(120, 40)
	back_button.pressed.connect(_show_list)
	_build_hero_list()
	_show_list()
	hero_list.alignment = BoxContainer.ALIGNMENT_CENTER
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_class_menu"):
		visible = not visible
		if visible:
			_show_list()

func _process(_delta: float) -> void:
	if visible and selected_index != -1:
		_build_table()

# -- Liste des héros, côte à côte, taille uniforme -----------------------------
func _build_hero_list() -> void:
	for child in hero_list.get_children():
		child.queue_free()

	for i in Global.player_classes.size():
		var char_class = Global.player_classes[i]
		if char_class == null:
			continue

		var btn := Button.new()
		btn.text = char_class.class_name_display
		btn.custom_minimum_size = Vector2(160, 220)
		btn.expand_icon = true
		btn.add_theme_constant_override("icon_max_width", 140)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		if char_class.battle_texture != null:
			btn.icon = char_class.battle_texture
		btn.pressed.connect(_select_hero.bind(i))
		hero_list.add_child(btn)

# -- Sélection d'un héros : cache la liste, montre le détail -------------------
func _select_hero(idx: int) -> void:
	selected_index = idx
	var char_class = Global.player_classes[idx]
	if char_class == null:
		return

	name_label.text = char_class.class_name_display
	if char_class.battle_texture != null:
		portrait.texture = char_class.battle_texture
	portrait.scale = Vector2(char_class.portrait_scale_correction, char_class.portrait_scale_correction)

	hero_list.visible = false
	detail_panel.visible = true
	_build_table()

#-- Bouton Retour : recache le détail, remontre la liste -----------------------
func _show_list() -> void:
	selected_index = -1
	hero_list.visible = true
	detail_panel.visible = false

#--Tableau de stats ----------------------------------------------------------
func _build_table() -> void:
	for child in grid.get_children():
		child.queue_free()

	grid.columns = 2
	_add_header_row()
	_add_player_row(selected_index)

func _add_header_row() -> void:
	_add_label("Stat", true)
	_add_label("Valeur", true)

func _add_player_row(player_idx: int) -> void:
	var stats = Global.get_player_stats_dict(player_idx)
	_add_stat_line("Niveau", str(stats["level"]))
	_add_stat_line("PV Max", "%.0f" % stats["max_hp"])
	_add_stat_line("ATK Bonus", "%.1f" % stats["atk_bonus"])
	_add_stat_line("DEF", "%.1f%%" % stats["def_reduction"])
	_add_stat_line("Crit", "%.1f%%" % stats["crit_chance"])

func _add_stat_line(label_text: String, value_text: String) -> void:
	_add_label(label_text)
	_add_label(value_text)

func _add_label(text: String, is_header: bool = false) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	grid.add_child(lbl)
