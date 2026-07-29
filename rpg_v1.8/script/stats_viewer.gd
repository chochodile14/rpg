extends Control

@onready var grid: GridContainer = $GridContainer

func _ready() -> void:
	_build_table()

func _build_table() -> void:
	for child in grid.get_children():
		child.queue_free()

	grid.columns = 7
	_add_header_row()

	for i in Global.player_levels.size():
		_add_player_row(i)

func _add_header_row() -> void:
	_add_label("Perso", true)
	_add_label("Classe", true)
	_add_label("Niveau", true)
	_add_label("PV Max", true)
	_add_label("ATK Bonus", true)
	_add_label("DEF (%)", true)
	_add_label("Crit (%)", true)

func _add_player_row(player_idx: int) -> void:
	var stats = Global.get_player_stats_dict(player_idx)
	var class_name_text = "???"
	if player_idx < Global.player_classes.size() and Global.player_classes[player_idx] != null:
		class_name_text = Global.player_classes[player_idx].class_name_display

	_add_label("Perso %d" % (player_idx + 1))
	_add_label(class_name_text)
	_add_label(str(stats["level"]))
	_add_label("%.0f" % stats["max_hp"])
	_add_label("%.1f" % stats["atk_bonus"])
	_add_label("%.1f%%" % stats["def_reduction"])
	_add_label("%.1f%%" % stats["crit_chance"])

func _add_label(text: String, is_header: bool = false) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	grid.add_child(lbl)
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		visible = not visible
