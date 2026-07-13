extends Control

# ── État du mode suppression ──────────────────────────────────────────────────
var _delete_mode: bool = false
var _slots_to_delete: Array[bool] = [false, false, false]

# Couleurs du thème hub
const COLOR_GOLD        := Color(0.82, 0.65, 0.38, 1.0)
const COLOR_GOLD_BRIGHT := Color(1.6,  1.2,  0.5,  1.0)
const COLOR_GOLD_DIM    := Color(0.85, 0.72, 0.45, 1.0)
const COLOR_RED_SELECT  := Color(1.0,  0.35, 0.15, 1.0)

func _ready() -> void:
	_refresh_slots()
	_update_delete_button()
	_entrance_animation()


# ── Animation d'entrée ───────────────────────────────────────────────────────
# Pourquoi on n'utilise PAS position.x ici :
#   Les boutons de slot sont dans un HBoxContainer. Un Container gère lui-même
#   la position de ses enfants sur son axe principal (X pour HBox, Y pour VBox).
#   Si on écrit child.position.x = -30 avant que le layout soit calculé, le
#   Container remet tous les enfants à leur position calculée → ils se retrouvent
#   tous superposés à x=0.
#
#   Pour les boutons du bas (dans un VBoxContainer), c'est l'axe Y qui est
#   contrôlé, donc position.x fonctionnerait — mais on reste cohérent.
#
# Solution propre : animer scale:x (0→1) avec pivot_offset au bord gauche.
#   Le nœud "se déplie" de gauche à droite sans jamais quitter sa case dans
#   le layout. On combine avec modulate:a pour le fondu.
func _entrance_animation() -> void:
	var all_nodes: Array = []
	var slots_box: HBoxContainer = get_node("VBoxContainer/SlotsBox")
	for child in slots_box.get_children():
		if child is Button:
			all_nodes.append(child)
	for btn_name in ["Back", "delete"]:
		var btn = get_node_or_null("VBoxContainer/" + btn_name)
		if btn:
			all_nodes.append(btn)

	for idx in all_nodes.size():
		var node: Control = all_nodes[idx]
		# Démarre invisible et "écrasé" à gauche
		node.modulate.a = 0.0
		node.scale.x    = 0.0
		# pivot_offset place l'origine de la transformation au bord gauche
		# du nœud → il se déplie vers la droite
		node.pivot_offset = Vector2(0.0, node.size.y * 0.5)

		var t := create_tween()
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_BACK)
		t.tween_interval(idx * 0.08)                                # décalage en cascade
		t.tween_property(node, "scale:x",    1.0,  0.30)           # dépliage
		t.parallel().tween_property(node, "modulate:a", 1.0, 0.25) # fondu


# ── Hover / exit des boutons (comme le hub) ───────────────────────────────────
func _connect_hover(btn: Button) -> void:
	btn.mouse_entered.connect(_on_btn_hover.bind(btn))
	btn.mouse_exited.connect(_on_btn_exit.bind(btn))

func _on_btn_hover(btn: Button) -> void:
	var sfx: AudioStreamPlayer = get_node_or_null("SFX_Hover")
	if sfx:
		sfx.play()
	var t := create_tween()
	t.tween_property(btn, "self_modulate", COLOR_GOLD_BRIGHT, 0.08)

func _on_btn_exit(btn: Button) -> void:
	var t := create_tween()
	t.tween_property(btn, "self_modulate", COLOR_GOLD_DIM, 0.20)


# ── Rafraîchit le texte de chaque bouton de slot ─────────────────────────────
func _refresh_slots() -> void:
	for i in 3:
		var btn: Button = get_node("VBoxContainer/SlotsBox/Slot%d" % i)
		var info: Dictionary = Global.get_slot_info(i)
		if info.is_empty():
			btn.text = "— Slot %d —\n[Vide]" % (i + 1)
		else:
			btn.text = "— Slot %d —\nNiv.%d   %s" % [i + 1, info["level"], info["date"].left(10)]
		# Reconnecte les signaux
		if btn.pressed.is_connected(_on_slot.bind(i)):
			btn.pressed.disconnect(_on_slot.bind(i))
		if btn.pressed.is_connected(_on_slot_delete.bind(i)):
			btn.pressed.disconnect(_on_slot_delete.bind(i))
		btn.pressed.connect(_on_slot.bind(i))
		_connect_hover(btn)


# ── Clic normal sur un slot ───────────────────────────────────────────────────
func _on_slot(i: int) -> void:
	if _delete_mode:
		return
	var sfx: AudioStreamPlayer = get_node_or_null("SFX_Click")
	if sfx:
		sfx.play()
	var loaded: bool = Global.load_game(i)
	Global.current_slot = i
	if not loaded:
		Global.total_xp        = 0
		Global.player_levels   = [1, 1, 1, 1]
		Global.aptitude_points = [0, 0, 0, 0]
		Global.player_upgrades = [
			{"hp": 0, "atk": 0, "def": 0, "crit": 0},
			{"hp": 0, "atk": 0, "def": 0, "crit": 0},
			{"hp": 0, "atk": 0, "def": 0, "crit": 0},
			{"hp": 0, "atk": 0, "def": 0, "crit": 0},
		]
	if Global.cinematic_debut_viewed:
		get_tree().change_scene_to_file("res://map.tscn")
	else:
		get_tree().change_scene_to_file("res://cinematique_debut.tscn")


# ── Clic sur un slot EN MODE SUPPRESSION ─────────────────────────────────────
func _on_slot_delete(i: int) -> void:
	if Global.get_slot_info(i).is_empty():
		return
	_slots_to_delete[i] = not _slots_to_delete[i]
	var btn: Button = get_node("VBoxContainer/SlotsBox/Slot%d" % i)
	if _slots_to_delete[i]:
		btn.self_modulate = COLOR_RED_SELECT
	else:
		btn.self_modulate = COLOR_GOLD_DIM
	_update_delete_button()


# ── Met à jour le libellé / état du bouton Delete ────────────────────────────
func _update_delete_button() -> void:
	var delete_btn: Button = get_node("VBoxContainer/delete")
	if _delete_mode:
		var count: int = _slots_to_delete.count(true)
		if count > 0:
			delete_btn.text = "Supprimer (%d sélectionné%s)" % [count, "s" if count > 1 else ""]
		else:
			delete_btn.text = "Annuler"
	else:
		delete_btn.text = "Supprimer une save"


# ── Bouton Delete ─────────────────────────────────────────────────────────────
func _on_delete_pressed() -> void:
	var sfx: AudioStreamPlayer = get_node_or_null("SFX_Click")
	if sfx:
		sfx.play()
	if not _delete_mode:
		_enter_delete_mode()
	else:
		var count: int = _slots_to_delete.count(true)
		if count == 0:
			_exit_delete_mode()
		else:
			_confirm_delete()


# ── Active le mode suppression ────────────────────────────────────────────────
func _enter_delete_mode() -> void:
	_delete_mode = true
	_slots_to_delete = [false, false, false]
	for i in 3:
		var btn: Button = get_node("VBoxContainer/SlotsBox/Slot%d" % i)
		btn.self_modulate = COLOR_GOLD_DIM
		if btn.pressed.is_connected(_on_slot.bind(i)):
			btn.pressed.disconnect(_on_slot.bind(i))
		if not btn.pressed.is_connected(_on_slot_delete.bind(i)):
			btn.pressed.connect(_on_slot_delete.bind(i))
		btn.disabled = Global.get_slot_info(i).is_empty()
	_set_label("Sélectionne les saves à supprimer")
	_update_delete_button()


# ── Désactive le mode suppression ─────────────────────────────────────────────
func _exit_delete_mode() -> void:
	_delete_mode = false
	_slots_to_delete = [false, false, false]
	for i in 3:
		var btn: Button = get_node("VBoxContainer/SlotsBox/Slot%d" % i)
		btn.self_modulate = COLOR_GOLD_DIM
		btn.disabled = false
		if btn.pressed.is_connected(_on_slot_delete.bind(i)):
			btn.pressed.disconnect(_on_slot_delete.bind(i))
		if not btn.pressed.is_connected(_on_slot.bind(i)):
			btn.pressed.connect(_on_slot.bind(i))
	_set_label("— Choisir une sauvegarde —")
	_update_delete_button()


# ── Supprime les fichiers sélectionnés ────────────────────────────────────────
func _confirm_delete() -> void:
	for i in 3:
		if _slots_to_delete[i]:
			var path: String = "user://saves/slot_%d.json" % i
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(path)
	_refresh_slots()
	_exit_delete_mode()


# ── Utilitaire : change le texte du Label titre ───────────────────────────────
func _set_label(txt: String) -> void:
	var lbl: Label = get_node_or_null("VBoxContainer/TitleLabel")
	if lbl:
		lbl.text = txt


# ── Bouton Retour ─────────────────────────────────────────────────────────────
func _on_back_pressed() -> void:
	var sfx: AudioStreamPlayer = get_node_or_null("SFX_Click")
	if sfx:
		sfx.play()
	queue_free()
