extends Node2D

var player: Array = []
var index: int = 0
var battle_ending: bool = false

func _ready() -> void:
	player = get_children()
	for i in player.size():
		player[i].position = Vector2(0, i * 150)
	player[0].focus()
	var ennemies_node = get_parent().get_node("ennemies_groupe")
	ennemies_node.battle_won.connect(_on_battle_won)
	ennemies_node.set_current_attacker(player[0])

func get_alive_count() -> int:
	return player.filter(func(p): return is_instance_valid(p) and not p.is_dead).size()

func _on_ennemies_groupe_next_player():
	if battle_ending:
		return
	var start = index
	var tries = 0
	var found = false
	while tries < player.size():
		tries += 1
		index = (index + 1) % player.size()
		if is_instance_valid(player[index]) and not player[index].is_dead:
			found = true
			break
	if found:
		switch_focus(index, start)
		var ennemies_node = get_parent().get_node("ennemies_groupe")
		ennemies_node.set_current_attacker(player[index])

func _on_ennemies_groupe_enemy_turn_done():
	if battle_ending:
		return
	var enemies_node = get_parent().get_node("ennemies_groupe")
	enemies_node.enemy_attacking = true

	var alive_enemies = enemies_node._get_alive_ennemies()
	for enemy in alive_enemies:
		if battle_ending:
			break
		var alive_players = player.filter(func(p): return is_instance_valid(p) and not p.is_dead)
		if alive_players.size() == 0:
			break
		var target = alive_players[randi() % alive_players.size()]
		await enemy.attack_animation(target)
		await get_tree().create_timer(0.3).timeout

	enemies_node.enemy_attacking = false

	# Vérifie défaite — appel direct sans await pour éviter l'abandon silencieux
	if get_alive_count() == 0:
		_trigger_game_over()
		return

	# Repart du premier joueur vivant pour le prochain tour
	_reset_index_to_alive()
	enemies_node.waiting_for_attack_choice = true
	enemies_node.set_current_attacker(player[index])
	enemies_node.emit_signal("request_attack_choice",
		enemies_node.ultimate_charge >= enemies_node.ULTIMATE_CHARGE_MAX,
		enemies_node.heavy_cooldown == 0)

func _reset_index_to_alive() -> void:
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
	# Attend la fin de l'animation puis retour map
	await get_tree().create_timer(1.8).timeout
	_return_to_map()

# Séparation claire : _trigger_game_over() est synchrone, le await est dedans
func _trigger_game_over() -> void:
	if battle_ending:
		return
	battle_ending = true
	_do_game_over()   # lance la coroutine proprement

func _do_game_over() -> void:
	await get_tree().create_timer(1.5).timeout
	_return_to_map()

func _return_to_map() -> void:
	var mob_pos = Global.battle_mob_position
	Global.player_spawn_position = mob_pos + Vector2(-80, 0)
	get_tree().change_scene_to_file("res://map.tscn")

func switch_focus(x: int, y: int) -> void:
	if x >= 0 and x < player.size() \
			and is_instance_valid(player[x]) and not player[x].is_dead:
		player[x].focus()
	if y >= 0 and y < player.size() and is_instance_valid(player[y]):
		player[y].unfocus()
