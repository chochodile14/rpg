extends Node2D
@onready var annimation = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	annimation.play("fire_on")
