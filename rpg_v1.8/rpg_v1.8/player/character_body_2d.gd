extends CharacterBody2D
class_name Player

@export var speed        = 400
@export var run_speed    = 700
@export var target_scale = 1

# ── Bob de marche ──────────────────────────────────────────────────────────────
@export var bob_amplitude : float = 2.5   # hauteur en pixels
@export var bob_frequency : float = 8.0   # cycles/seconde (run va plus vite automatiquement)

var _bob_timer  : float = 0.0
var _base_y     : float = 0.0
var _was_moving : bool  = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	Global.player = self
	add_to_group("Player")
	print(Global.player_spawn_position)
	if Global.player_spawn_position != Vector2.ZERO:
		global_position = Global.player_spawn_position
	_base_y = animated_sprite_2d.position.y

func _physics_process(delta: float) -> void:
	var is_running  = Input.is_action_pressed("ui_shift") or Input.is_action_pressed("run")
	var current_speed = run_speed if is_running else speed
	var input_dir   = Input.get_vector(
		"mouvement_gauche", "mouvement_droit",
		"mouvement_haut",   "mouvement_bas"
	).normalized() * current_speed

	# ── Animations ────────────────────────────────────────────────────────────
	if input_dir:
		if is_running:
			animated_sprite_2d.animation = "run"
		else:
			animated_sprite_2d.animation = "walk"
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.animation = "idle"
		animated_sprite_2d.play()

	# Flip horizontal selon la direction X
	if input_dir.x != 0:
		animated_sprite_2d.flip_h = input_dir.x < 0

	velocity = input_dir
	move_and_slide()

	# ── Bob vertical (walk + run uniquement) ──────────────────────────────────
	var moving_now = velocity.length() > 1.0
	if moving_now:
		# Le run accélère aussi le bob visuellement
		var freq = bob_frequency * (1.5 if is_running else 1.0)
		_bob_timer += delta * freq * TAU
		animated_sprite_2d.position.y = _base_y + sin(_bob_timer) * bob_amplitude
		_was_moving = true
	else:
		if _was_moving:
			_bob_timer = 0.0
			_was_moving = false
		# Retour doux à la position neutre
		animated_sprite_2d.position.y = lerp(
			animated_sprite_2d.position.y, _base_y, delta * 15.0
		)

func start_turn():
	target_scale = 1.1

func end_turn():
	target_scale = 0.9
