extends Node2D

var ennemies : Array[BattleEnnemy] = []
var action_queue :Array = []
var is_in_battle: bool = false
var index : int = 0

signal next_player
signal take_damage
@onready var  choice =$"../CanvasLayer/choice"


func _ready() -> void:
	# Init ennemies 
	for child in get_children():
		if child is BattleEnnemy:
			ennemies.append(child)
	
	# Set ennemies position
	for i in ennemies.size():
		ennemies[i].position = Vector2(0 , i* 150)
	
	show_choice()

func _process(_delta) :
	if not choice.visible:
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
	
	if action_queue.size() == ennemies.size() and not is_in_battle:
		is_in_battle = true
		_action(action_queue)
		

func _action(stack):
	for i in stack:
		ennemies[i].take_damage(1)
		await get_tree().create_timer(0.2).timeout
	action_queue.clear()
	is_in_battle = false
	show_choice()

func switch_focus(x,y):
	ennemies[x].focus()
	ennemies[y].unfocus()

func show_choice():
	choice.show()
	choice.find_child("atk").grab_focus()
	

func _reset_focus():
	index=0
	for enemy in ennemies:
		enemy.unfocus() 

func _start_choosing():
	_reset_focus()
	ennemies[0].focus()


func _on_atk_pressed() -> void:
	choice.hide()
	emit_signal("take_damage")
	_start_choosing()


func _on_run_pressed() -> void:
	get_tree().change_scene_to_file("res://map.tscn")
