extends Node2D

var ennemies : Array = []

func _ready() -> void:
	ennemies = get_children()
	for i in ennemies.size():
		ennemies[i].position = Vector2(0 , i* 150)
