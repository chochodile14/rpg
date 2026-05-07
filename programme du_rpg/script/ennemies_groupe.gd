extends Node2D

var ennemies: Array = []
var action_queue: Array = []   # stocke {ennemi_index, degats, attack_type, player_node}
var is_battling: bool = false
var enemy_attacking: bool = false
var index: int = 0

# Choix d'attaque en cours
var waiting_for_attack_choice: bool = false
var pending_target: int = -1
var pending_attack_type: String = ""

# Référence au joueur actif qui est en train de choisir
var current_attacker: Node = null

# Ultimate : se charge avec les coups
var ultimate_charge: int = 0
const ULTIMATE_CHARGE_MAX: int = 10

# Attaque lourde : cooldown en tours
var heavy_cooldown: int = 0
const HEAVY_COOLDOWN_MAX: int = 3

signal next_player
signal enemy_turn_done
signal request_attack_choice(can_ultimate: bool, can_heavy: bool)
signal battle_won
signal battle_lost

func _ready() -> void:
	ennemies = get_children()
	for i in ennemies.size():
		ennemies[i].position = Vector2(0, i * 150)
	ennemies[0].focus()
	waiting_for_attack_choice = true
	call_deferred("emit_signal", "request_attack_choice", ultimate_charge >= ULTIMATE_CHARGE_MAX, heavy_cooldown == 0)

func _process(_delta):
	if is_battling or enemy_attacking or waiting_for_attack_choice:
		return

	if Input.is_action_just_pressed("ui_up"):
		var prev = index
		var i = index - 1
		while i >= 0:
			if is_instance_valid(ennemies[i]):
				switch_focus(i, prev)
				break
			i -= 1
	if Input.is_action_just_pressed("ui_down"):
		var prev = index
		var i = index + 1
		while i < ennemies.size():
			if is_instance_valid(ennemies[i]):
				switch_focus(i, prev)
				break
			i += 1

	if Input.is_action_just_pressed("ui_accept"):
		# Enregistre l'action avec le joueur qui attaque
		action_queue.push_back({
			"target": index,
			"damage": pending_target,
			"attack_type": pending_attack_type,
			"attacker": current_attacker
		})
		pending_target = -1
		pending_attack_type = ""
		current_attacker = null
		emit_signal("next_player")
		waiting_for_attack_choice = true
		emit_signal("request_attack_choice", ultimate_charge >= ULTIMATE_CHARGE_MAX, heavy_cooldown == 0)

	# Lance le combat quand tous les joueurs vivants ont choisi
	var player_group = get_parent().get_node("player group")
	var alive_count = player_group.get_alive_count()
	if action_queue.size() >= alive_count and alive_count > 0 and not is_battling:
		is_battling = true
		_action(action_queue)

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

func _action(stack: Array):
	for entry in stack:
		var target_idx = entry["target"]
		var dmg = entry["damage"]
		var atk_type = entry.get("attack_type", "light")
		var attacker = entry.get("attacker", null)

		# Animation d'attaque du BON joueur
		if is_instance_valid(attacker) and not attacker.is_dead:
			await attacker.play_attack_animation(atk_type)
		else:
			await get_tree().create_timer(0.5).timeout

		# Applique les dégâts sur la cible
		if target_idx < ennemies.size() and is_instance_valid(ennemies[target_idx]):
			ennemies[target_idx].take_damage(dmg)

		await get_tree().create_timer(0.3).timeout

		# Recale le focus si l'ennemi est mort
		if not is_instance_valid(ennemies[index]):
			_move_index_to_alive(index)

		# Vérifie victoire après chaque frappe
		var alive_ennemies = ennemies.filter(func(e): return is_instance_valid(e))
		if alive_ennemies.size() == 0:
			action_queue.clear()
			is_battling = false
			emit_signal("battle_won")
			return

	action_queue.clear()
	is_battling = false
	emit_signal("enemy_turn_done")

func switch_focus(x, y):
	if y >= 0 and y < ennemies.size() and is_instance_valid(ennemies[y]):
		ennemies[y].unfocus()
	_move_index_to_alive(x)

func _move_index_to_alive(start: int) -> void:
	var size = ennemies.size()
	for i in size:
		var candidate = (start + i) % size
		if is_instance_valid(ennemies[candidate]):
			index = candidate
			ennemies[index].focus()
			return
