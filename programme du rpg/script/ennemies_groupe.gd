extends Node2D

var ennemies: Array = []
var action_queue: Array = []   # stocke {ennemi_index, degats}
var is_battling: bool = false
var enemy_attacking: bool = false
var index: int = 0
 
# Choix d'attaque en cours
var waiting_for_attack_choice: bool = false
var pending_target: int = -1
 
# Ultimate : se charge avec les coups
var ultimate_charge: int = 0
const ULTIMATE_CHARGE_MAX: int = 4
 
signal next_player
signal enemy_turn_done
signal request_attack_choice(can_ultimate: bool)  # demande au UI de s'afficher
 
func _ready() -> void:
	ennemies = get_children()
	for i in ennemies.size():
		ennemies[i].position = Vector2(0, i * 150)
	ennemies[0].focus()
	# Demande le premier choix d'attaque dès le départ
	# call_deferred garantit que battle.gd a eu le temps de connecter le signal
	waiting_for_attack_choice = true
	call_deferred("emit_signal", "request_attack_choice", ultimate_charge >= ULTIMATE_CHARGE_MAX)
 
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
		# Le joueur confirme sa cible → on enregistre et passe au suivant
		action_queue.push_back({ "target": index, "damage": pending_target })
		pending_target = -1
		emit_signal("next_player")
		# Prochain joueur doit aussi choisir son attaque
		waiting_for_attack_choice = true
		emit_signal("request_attack_choice", ultimate_charge >= ULTIMATE_CHARGE_MAX)
 
	if action_queue.size() == ennemies.size() and not is_battling:
		is_battling = true
		_action(action_queue)
 
func choose_attack(damage: float) -> void:
	# Appelé depuis le UI quand le joueur clique sur une attaque
	pending_target = damage
	if damage >= 6:
		ultimate_charge = 0   # reset l'ultime après utilisation
	else:
		ultimate_charge += 1  # charge l'ultime à chaque coup normal
	waiting_for_attack_choice = false
 
func _action(stack: Array):
	for entry in stack:
		var target_idx = entry["target"]
		var dmg = entry["damage"]
		if target_idx < ennemies.size() and is_instance_valid(ennemies[target_idx]):
			ennemies[target_idx].take_damage(dmg)
		await get_tree().create_timer(0.8).timeout
		# Si l'ennemi ciblé est mort, recaler le focus sur un vivant
		if not is_instance_valid(ennemies[index]):
			_move_index_to_alive(index)
	action_queue.clear()
	is_battling = false
	emit_signal("enemy_turn_done")
 
func switch_focus(x, y):
	# Retire le focus de l'ancien ennemi s'il est encore valide
	if y >= 0 and y < ennemies.size() and is_instance_valid(ennemies[y]):
		ennemies[y].unfocus()
	# Cherche un ennemi vivant à partir de x
	_move_index_to_alive(x)
 
func _move_index_to_alive(start: int) -> void:
	# Cherche le prochain ennemi vivant en partant de start (ou wrappe)
	var size = ennemies.size()
	for i in size:
		var candidate = (start + i) % size
		if is_instance_valid(ennemies[candidate]):
			index = candidate
			ennemies[index].focus()
			return
