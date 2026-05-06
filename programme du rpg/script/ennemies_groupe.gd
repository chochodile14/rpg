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
	waiting_for_attack_choice = true
	emit_signal("request_attack_choice", ultimate_charge >= ULTIMATE_CHARGE_MAX)

func _process(_delta):
	if is_battling or enemy_attacking or waiting_for_attack_choice:
		return

	if Input.is_action_just_pressed("ui_up"):
		if index > 0:
			index -= 1
			switch_focus(index, index + 1)
	if Input.is_action_just_pressed("ui_down"):
		if index < ennemies.size() - 1:
			index += 1
			switch_focus(index, index - 1)

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
	action_queue.clear()
	is_battling = false
	emit_signal("enemy_turn_done")

func switch_focus(x, y):
	if x < ennemies.size():
		ennemies[x].focus()
	if y < ennemies.size():
		ennemies[y].unfocus()
