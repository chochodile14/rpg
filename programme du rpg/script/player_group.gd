extends Node2D

var player : Array[BattlePlayer] = []
var index : int = 0


func _ready() -> void:
	for child in get_children():
		if child is BattlePlayer:
			player.append(child)
	
	
	
	for i in player.size():
		player[i].position = Vector2(0 , i* 150)


func _on_ennemies_groupe_next_player() :
	if index < player.size() - 1:
		index += 1
		switch_focus(index , index -1)
	else:
		index = 0
		switch_focus(index , player.size() - 1 )

func switch_focus(x,y):
	print(player[x])
	player[x].focus()
	player[y].unfocus()
	
