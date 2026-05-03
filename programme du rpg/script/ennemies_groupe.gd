extends Node2D

var ennemies : Array = []
var action_queue :Array = []
var is_battling: bool = false
var index : int = 0

signal next_player

func _ready() -> void:
	ennemies = get_children()
	for i in ennemies.size():
		ennemies[i].position = Vector2(0 , i* 150)
	
	ennemies[0].focus()

func _process(_delta) :
	if Input.is_action_just_pressed("ui_up"):
		if index > 0:
			index -= 1
			switch_focus(index, index+1)
	if Input.is_action_just_pressed("ui_down"):
		if index < ennemies.size() - 1:
			index += 1
			switch_focus(index, index - 1)

	if Input.is_action_just_pressed("ui_accept"):
		action_queue.push_back(index)
		emit_signal("next_player")
	
	if action_queue.size() == ennemies.size() and not is_battling:
		is_battling = true
		_action(action_queue)
		

func _action(stack):
	for i in stack:
		ennemies[i].take_damage(1)
		await get_tree().create_timer(1).timeout
	action_queue.clear()
	is_battling = false

func switch_focus(x,y):
	ennemies[x].focus()
	ennemies[y].unfocus()
