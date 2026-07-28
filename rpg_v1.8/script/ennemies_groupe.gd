extends Node2D

const DamageNumber = preload("res://ui/damage_number.tscn")

var ennemies: Array = []
var action_queue: Array = []
var is_battling: bool = false
var enemy_attacking: bool = false
var index: int = 0

var waiting_for_attack_choice: bool = false
var pending_target: float = 0.0
var pending_attack_type: String = ""
var current_attacker: Node = null

var ultimate_charge: int = 0
const ULTIMATE_CHARGE_MAX: int = 10

var heavy_cooldown: int = 0
const HEAVY_COOLDOWN_MAX: int = 3

signal next_player
signal enemy_turn_done
signal request_attack_choice(can_ultimate: bool, can_heavy: bool)
signal battle_won
signal ultimate_charge_changed(current: int, maximum: int)

func _ready() -> void:
	ennemies = get_children()
	for i in ennemies.size():
		ennemies[i].position = Vector2(0, i * 150)
	ennemies[0].focus()
	waiting_for_attack_choice = true
	call_deferred("emit_signal", "request_attack_choice",
		ultimate_charge >= ULTIMATE_CHARGE_MAX, heavy_cooldown == 0)

func _get_alive_ennemies() -> Array:
	return ennemies.filter(func(e): return is_instance_valid(e) and not e.is_dying)

func _process(_delta):
	if is_battling or enemy_attacking or waiting_for_attack_choice:
		return

	if Input.is_action_just_pressed("ui_up"):
		var prev = index
		var i = index - 1
		while i >= 0:
			if is_instance_valid(ennemies[i]) and not ennemies[i].is_dying:
				switch_focus(i, prev)
				break
			i -= 1

	if Input.is_action_just_pressed("ui_down"):
		var prev = index
		var i = index + 1
		while i < ennemies.size():
			if is_instance_valid(ennemies[i]) and not ennemies[i].is_dying:
				switch_focus(i, prev)
				break
			i += 1

	if Input.is_action_just_pressed("ui_accept"):
		action_queue.push_back({
			"target": index,
			"damage": pending_target,
			"attack_type": pending_attack_type,
			"attacker": current_attacker
		})
		pending_target = 0.0
		pending_attack_type = ""
		current_attacker = null

		var player_group = get_parent().get_node("player group")
		var alive_count = player_group.get_alive_count()

		if action_queue.size() >= alive_count:
			is_battling = true
			waiting_for_attack_choice = true
			var stack = action_queue.duplicate()
			action_queue.clear()
			_action(stack)
		else:
			emit_signal("next_player")
			waiting_for_attack_choice = true
			emit_signal("request_attack_choice",
				ultimate_charge >= ULTIMATE_CHARGE_MAX, heavy_cooldown == 0)

func set_current_attacker(player_node: Node) -> void:
	current_attacker = player_node

func choose_attack(damage: float, attack_type: String) -> void:
	pending_target = damage
	pending_attack_type = attack_type
	match attack_type:
		"ultimate":
			ultimate_charge = 0
		"heavy":
			heavy_cooldown = HEAVY_COOLDOWN_MAX
			ultimate_charge = min(ultimate_charge + 2, ULTIMATE_CHARGE_MAX)
		"light":
			ultimate_charge = min(ultimate_charge + 1, ULTIMATE_CHARGE_MAX)
			if heavy_cooldown > 0:
				heavy_cooldown -= 1
	waiting_for_attack_choice = false
	emit_signal("ultimate_charge_changed", ultimate_charge, ULTIMATE_CHARGE_MAX)

func _action(stack: Array) -> void:
	for entry in stack:
		var target_idx = entry["target"]
		var base_dmg   = entry["damage"]
		var atk_type   = entry.get("attack_type", "light")
		var attacker   = entry.get("attacker", null)

		# ── Calcule les dégâts finaux avec les stats du joueur ──────────────
		var final_dmg = base_dmg
		var is_crit   = false
		if is_instance_valid(attacker) and not attacker.is_dead:
			var pidx = attacker.player_index
			# Bonus d'attaque
			final_dmg += Global.get_atk_bonus(pidx)
			# ── NOUVEAU : multiplicateur selon la classe et le type d'attaque ──
			final_dmg *= Global.get_attack_multiplier(pidx, atk_type)
			# Coup critique ?
			var crit_roll = randf()
			if crit_roll < Global.get_crit_chance(pidx):
				final_dmg *= 2.0
				is_crit = true
			# Animation
			await attacker.play_attack_animation(atk_type)

		# ── Applique les dégâts ──────────────────────────────────────────────
		if target_idx < ennemies.size() \
				and is_instance_valid(ennemies[target_idx]) \
				and not ennemies[target_idx].is_dying:
			var enemy_node = ennemies[target_idx]
			enemy_node.take_damage(final_dmg)
			_spawn_damage_number(enemy_node, final_dmg, atk_type if not is_crit else "crit")

		await get_tree().create_timer(0.3).timeout

		if index >= ennemies.size() \
				or not is_instance_valid(ennemies[index]) \
				or ennemies[index].is_dying:
			_move_index_to_alive()

		if _get_alive_ennemies().size() == 0:
			is_battling = false
			waiting_for_attack_choice = false
			emit_signal("battle_won")
			return

	is_battling = false
	waiting_for_attack_choice = false
	emit_signal("enemy_turn_done")

func _spawn_damage_number(enemy_node: Node2D, dmg: float, atk_type: String) -> void:
	var root = get_tree().current_scene
	var dmg_layer = root.get_node_or_null("DmgLayer")
	if dmg_layer == null:
		dmg_layer = CanvasLayer.new()
		dmg_layer.name = "DmgLayer"
		dmg_layer.layer = 5
		root.add_child(dmg_layer)
	var popup = DamageNumber.instantiate()
	dmg_layer.add_child(popup)
	var screen_pos = get_viewport().get_screen_transform() * enemy_node.global_position
	popup.setup(screen_pos, dmg, atk_type)

func switch_focus(x: int, y: int) -> void:
	if y >= 0 and y < ennemies.size() \
			and is_instance_valid(ennemies[y]) and not ennemies[y].is_dying:
		ennemies[y].unfocus()
	_move_index_to_alive_from(x)

func _move_index_to_alive() -> void:
	_move_index_to_alive_from(index)

func _move_index_to_alive_from(start: int) -> void:
	var size = ennemies.size()
	for i in size:
		var candidate = (start + i) % size
		if is_instance_valid(ennemies[candidate]) and not ennemies[candidate].is_dying:
			index = candidate
			ennemies[index].focus()
			return
