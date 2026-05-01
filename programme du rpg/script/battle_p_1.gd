extends Node2D

@onready var focus = $turn
@onready var pv = $pv
@onready var hurt = $hurt

@export var max_health: float = 100

var health: float = 100:
	set(value):
		health = value
		_update_pv()
