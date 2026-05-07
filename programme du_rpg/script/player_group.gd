extends Node2D

var player: Array = []
var index: int = 0
var battle_ending: bool = false

func _ready() -> void:
	player = get_children()
	for i in player.size():
		player[i].position = Vector2(0, i * 150)
	player[0].focus()
	# Connecter le signal de victoire
	var ennemies_node = get_parent().get_node("ennemies_groupe")
	ennemies_node.battle_won.connect(_on_battle_won)
	# Informe ennemies_groupe du joueur actif initial
	ennemies_node.set_current_attacker(player[0])

# Retourne le nombre de joueurs encore vivants
func get_alive_count() -> int:
	return player.filter(func(p): return is_instance_valid(p) and not p.is_dead).size()

func _on_ennemies_groupe_next_player():
	if battle_ending:
		return
	# Avance au joueur suivant vivant
	var start = index
	var found = false
	var tries = 0
	while tries < player.size():
		tries += 1
		if index < player.size() - 1:
			index += 1
		else:
			index = 0
		if is_instance_valid(player[index]) and not player[index].is_dead:
			found = true
			break
		if index == start:
			break

	if found:
		var prev = (index - 1) if index > 0 else player.size() - 1
		switch_focus(index, prev)
		# Informe ennemies_groupe du nouveau joueur actif
		var ennemies_node = get_parent().get_node("ennemies_groupe")
		ennemies_node.set_current_attacker(player[index])

func _on_ennemies_groupe_enemy_turn_done():
	if battle_ending:
		return
	var enemies_node = get_parent().get_node("ennemies_groupe")
	enemies_node.enemy_attacking = true

	# Copie les listes au moment de l'attaque
	var alive_enemies = enemies_node.ennemies.filter(func(e): return is_instance_valid(e))
	var alive_players = player.filter(func(p): return is_instance_valid(p) and not p.is_dead)

	for enemy in alive_enemies:
		# Recalcule les joueurs vivants à chaque attaque (un joueur peut mourir entre deux)
		alive_players = player.filter(func(p): return is_instance_valid(p) and not p.is_dead)
		if alive_players.size() > 0:
			var target = alive_players[randi() % alive_players.size()]
			await enemy.attack_animation(target)
			await get_tree().create_timer(0.4).timeout

	enemies_node.enemy_attacking = false

	# Vérifie défaite
	var still_alive = player.filter(func(p): return is_instance_valid(p) and not p.is_dead)
	if still_alive.size() == 0:
		_on_battle_lost()
		return

	# Repositionne l'index sur le premier joueur vivant
	_reset_index_to_alive()

	# Recharge le menu d'attaque pour le prochain tour
	enemies_node.waiting_for_attack_choice = true
	enemies_node.set_current_attacker(player[index])
	enemies_node.emit_signal("request_attack_choice",
		enemies_node.ultimate_charge >= enemies_node.ULTIMATE_CHARGE_MAX,
		enemies_node.heavy_cooldown == 0)

func _reset_index_to_alive() -> void:
	# Repart de l'index 0 pour le nouveau tour
	for i in player.size():
		if is_instance_valid(player[i]) and not player[i].is_dead:
			var old = index
			index = i
			switch_focus(index, old)
			return

func _on_battle_won():
	if battle_ending:
		return
	battle_ending = true
	var alive_players = player.filter(func(p): return is_instance_valid(p) and not p.is_dead)
	for p in alive_players:
		p.play_win_animation()
	await get_tree().create_timer(1.8).timeout
	_return_to_map()

func _on_battle_lost():
	if battle_ending:
		return
	battle_ending = true
	await get_tree().create_timer(1.5).timeout
	_return_to_map()

func _return_to_map():
	var mob_pos = Global.battle_mob_position
	var spawn_pos = mob_pos + Vector2(-80, 0)
	Global.player_spawn_position = spawn_pos
	get_tree().change_scene_to_file("res://map.tscn")

func switch_focus(x, y):
	if x >= 0 and x < player.size() and is_instance_valid(player[x]) and not player[x].is_dead:
		player[x].focus()
	if y >= 0 and y < player.size() and is_instance_valid(player[y]):
		player[y].unfocus()
