extends Node2D
@onready var annimation = $AnimatedSprite2D
@export var always_on := false
@export var light: LitPointLight2D       # NOUVEAU : la lumière à commander
@export var base_energy := 1.3           # NOUVEAU : puissance à pleine nuit

var t := randf() * 100.0                 # NOUVEAU : décale chaque torche

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	annimation.play("fire_on")

func _process(delta: float) -> void:     # NOUVEAU : le calculateur
	if light == null:
		return
	t += delta
	var flicker := 1.0 + sin(t * 9.0) * 0.06 + sin(t * 23.0) * 0.04
	var n := 1.0 if always_on else GameClock.night_factor()
	light.energy = base_energy * flicker * lerpf(0.0, 1.0, n)
