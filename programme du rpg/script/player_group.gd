extends Node2D

var player: Array = []
var index: int = 0

func _ready() -> void:
	player = get_children()
	for i in player.size():
		player[i].position = Vector2(0, i * 150)
	player[0].focus()

func _on_ennemies_groupe_next_player():
	# Avance au joueur suivant vivant
	var start = index
	while true:
		if index < player.size() - 1:
			index += 1
		else:
			index = 0
		if is_instance_valid(player[index]) and not player[index].is_dead:
			break
		if index == start:
			break
	switch_focus(index, index - 1 if index > 0 else player.size() - 1)

func _on_ennemies_groupe_enemy_turn_done():
	var enemies_node = get_parent().get_node("ennemies_groupe")
	enemies_node.enemy_attacking = true
	# Copie la liste pour éviter les erreurs si un ennemi meurt pendant l'attaque
	var alive_enemies = enemies_node.ennemies.filter(func(e): return is_instance_valid(e))
	var alive_players = player.filter(func(p): return is_instance_valid(p) and not p.is_dead)
	for enemy in alive_enemies:
		if alive_players.size() > 0:
			var target = alive_players[randi() % alive_players.size()]
			await enemy.attack_animation(target)
			await get_tree().create_timer(0.4).timeout
	enemies_node.enemy_attacking = false
	# Recharge le menu d'attaque pour le prochain tour
	enemies_node.waiting_for_attack_choice = true
	enemies_node.emit_signal("request_attack_choice", enemies_node.ultimate_charge >= enemies_node.ULTIMATE_CHARGE_MAX)

func switch_focus(x, y):
	if x < player.size() and is_instance_valid(player[x]) and not player[x].is_dead:
		player[x].focus()
	if y >= 0 and y < player.size() and is_instance_valid(player[y]):
		player[y].unfocus()
