# ui/aptitude_menu.gd
extends CanvasLayer

signal menu_closed

@onready var title_lbl  : Label         = $Panel/VBox/Title
@onready var xp_lbl     : Label         = $Panel/VBox/XpBar/XpLabel
@onready var xp_bar     : ProgressBar   = $Panel/VBox/XpBar/Bar
@onready var players_box: HBoxContainer = $Panel/VBox/PlayersBox
@onready var close_btn  : Button        = $Panel/VBox/CloseBtn
@onready var hotkey_lbl : Label         = $Panel/VBox/HotkeyLabel

var _player_cards: Array = []
var _opened_from_map: bool = false

func _ready() -> void:
	visible = false
	close_btn.pressed.connect(_on_close)
	_build_cards()

# ── Ouverture après victoire ──────────────────────────────────────────────────
func open_menu(xp_gained: int) -> void:
	_opened_from_map = false
	_refresh_xp_bar()
	_refresh_all_cards()
	title_lbl.text  = "🏆  +%d XP gagnés  —  Dépense tes points d'aptitude !" % xp_gained
	hotkey_lbl.text = "💡 Tab = rouvrir ce menu depuis la map  |  Ctrl+Shift+X = +9999 XP (test)"
	close_btn.text  = "Continuer →"
	visible = true

# ── Ouverture depuis la map (appelé par map.gd) ───────────────────────────────
func open_from_map() -> void:
	_opened_from_map = true
	_refresh_xp_bar()
	_refresh_all_cards()
	title_lbl.text  = "🎛️  Menu d'Aptitude  —  Dépense tes points d'aptitude"
	hotkey_lbl.text = "💡 Tab = fermer  |  Shift+X = +9999 XP (test)"
	close_btn.text  = "Fermer  [Tab]"
	visible = true

# ── Cheat code Ctrl+Shift+X ──────────────────────────────────────────────────
# Utilise _input (et non _unhandled_key_input) pour fonctionner même quand
# le CanvasLayer est enfant d'un autre nœud et que le focus est sur un Button.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_X and event.shift_pressed:
			Global.add_xp(9999)
			_refresh_all_cards()
			_refresh_xp_bar()
			title_lbl.text = "🔥 CHEAT CODE activé : +9999 XP !"
			get_viewport().set_input_as_handled()

func _on_close() -> void:
	visible = false
	if not _opened_from_map:
		emit_signal("menu_closed")

# ── Construction des cartes ───────────────────────────────────────────────────
func _build_cards() -> void:
	for i in 4:
		var card = _make_player_card(i)
		players_box.add_child(card["root"])
		_player_cards.append(card)

func _make_player_card(pidx: int) -> Dictionary:
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(200, 0)
	vbox.add_theme_constant_override("separation", 6)

	var name_lbl = Label.new()
	name_lbl.text = "Joueur %d  (Niv. %d)" % [pidx + 1, Global.player_levels[pidx]]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_lbl)

	var ap_lbl = Label.new()
	ap_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ap_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(ap_lbl)

	vbox.add_child(HSeparator.new())

	var stat_rows = {}
	for stat_key in ["hp", "atk", "def", "crit"]:
		var row = _make_stat_row(pidx, stat_key)
		vbox.add_child(row["root"])
		stat_rows[stat_key] = row

	return { "root": vbox, "name_lbl": name_lbl, "ap_lbl": ap_lbl,
			 "stat_rows": stat_rows, "pidx": pidx }

func _make_stat_row(pidx: int, stat_key: String) -> Dictionary:
	var icons = { "hp": "❤️", "atk": "⚔️", "def": "🛡️", "crit": "💥" }
	var names = { "hp": "PV", "atk": "Attaque", "def": "Défense", "crit": "Critique" }

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)

	var icon_lbl = Label.new()
	icon_lbl.text = icons[stat_key]
	hbox.add_child(icon_lbl)

	var name_lbl = Label.new()
	name_lbl.text = names[stat_key]
	name_lbl.custom_minimum_size = Vector2(65, 0)
	hbox.add_child(name_lbl)

	var rank_lbl = Label.new()
	rank_lbl.custom_minimum_size = Vector2(32, 0)
	rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(rank_lbl)

	var val_lbl = Label.new()
	val_lbl.add_theme_color_override("font_color", Color(0.6, 0.9, 1.0))
	val_lbl.custom_minimum_size = Vector2(70, 0)
	hbox.add_child(val_lbl)

	var btn = Button.new()
	btn.text = "+"
	btn.custom_minimum_size = Vector2(30, 0)
	btn.pressed.connect(func(): _on_upgrade(pidx, stat_key))
	hbox.add_child(btn)

	return { "root": hbox, "rank_lbl": rank_lbl, "val_lbl": val_lbl, "btn": btn }

func _refresh_xp_bar() -> void:
	var lvl = Global.player_levels[0]
	var xp_this_lvl = Global.total_xp - (lvl - 1) * Global.XP_PER_LEVEL
	xp_bar.value = float(xp_this_lvl) / Global.XP_PER_LEVEL * 100.0
	xp_lbl.text  = "XP : %d / %d  (Niveau %d)" % [xp_this_lvl, Global.XP_PER_LEVEL, lvl]

func _refresh_all_cards() -> void:
	for card in _player_cards:
		var pidx: int = card["pidx"]
		card["name_lbl"].text = "Joueur %d  (Niv. %d)" % [pidx + 1, Global.player_levels[pidx]]
		card["ap_lbl"].text   = "Points dispo : %d" % Global.aptitude_points[pidx]
		for stat_key in ["hp", "atk", "def", "crit"]:
			_refresh_row(card, stat_key)

func _refresh_row(card: Dictionary, stat_key: String) -> void:
	var pidx: int = card["pidx"]
	var row  = card["stat_rows"][stat_key]
	var rank = Global.player_upgrades[pidx][stat_key]
	row["rank_lbl"].text = "[%d/%d]" % [rank, Global.MAX_UPGRADE]
	match stat_key:
		"hp":   row["val_lbl"].text = "+%.0f PV" % (rank * Global.HP_PER_UPGRADE)
		"atk":  row["val_lbl"].text = "+%.0f dégâts" % (rank * Global.ATK_PER_UPGRADE)
		"def":  row["val_lbl"].text = "-%d%% dmg" % (rank * int(Global.DEF_PER_UPGRADE))
		"crit": row["val_lbl"].text = "+%d%% crit" % (rank * int(Global.CRIT_PER_UPGRADE * 100))
	row["btn"].disabled = not Global.can_upgrade(pidx, stat_key)

func _on_upgrade(pidx: int, stat_key: String) -> void:
	if Global.spend_aptitude(pidx, stat_key):
		_refresh_all_cards()
		_refresh_xp_bar()
