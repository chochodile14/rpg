extends Node2D

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
	# Bloque TOUT si le combat tourne, les ennemis attaquent, ou on attend un choix
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
			# Tous les joueurs ont choisi — on verrouille et on lance
			is_battling = true
			waiting_for_attack_choice = true  # bloque _process pendant le combat
			var stack = action_queue.duplicate()
			action_queue.clear()
			_action(stack)
		else:
			# Il reste des joueurs à faire choisir
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
			ultimate_charge += 2
		"light":
			ultimate_charge += 1
			if heavy_cooldown > 0:
				heavy_cooldown -= 1
	waiting_for_attack_choice = false

func _action(stack: Array) -> void:
	for entry in stack:
		var target_idx = entry["target"]
		var dmg    = entry["damage"]
		var atk_type = entry.get("attack_type", "light")
		var attacker = entry.get("attacker", null)

		# Animation du joueur attaquant
		if is_instance_valid(attacker) and not attacker.is_dead:
			await attacker.play_attack_animation(atk_type)
		else:
			await get_tree().create_timer(0.5).timeout

		# Dégâts sur l'ennemi ciblé
		if target_idx < ennemies.size() \
				and is_instance_valid(ennemies[target_idx]) \
				and not ennemies[target_idx].is_dying:
			ennemies[target_idx].take_damage(dmg)

		await get_tree().create_timer(0.3).timeout

		# Recale le focus si l'ennemi ciblé vient de mourir
		if index >= ennemies.size() \
				or not is_instance_valid(ennemies[index]) \
				or ennemies[index].is_dying:
			_move_index_to_alive()

		# Victoire ?
		if _get_alive_ennemies().size() == 0:
			is_battling = false
			waiting_for_attack_choice = false
			emit_signal("battle_won")
			return

	is_battling = false
	waiting_for_attack_choice = false
	emit_signal("enemy_turn_done")

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
