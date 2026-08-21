extends CharacterBody2D

var sprint_toggle = false
var state = "IDLE"
@export var walk_speed = 400
@export var run_speed = 600
@export var acceleration = 2000.0   # vitesse à laquelle on atteint la vitesse cible
@export var friction = 1800.0       # vitesse à laquelle on s'arrête
@onready var footstep_dust: CPUParticles2D = $FootstepDust
@onready var footstep_timer: Timer = $FootstepTimer
@onready var sprite_base_y: float = $AnimatedSprite2D.position.y  # position d'origine du sprite

var bob_time = 0.0
const BOB_FREQUENCY_WALK = 9.0
const BOB_FREQUENCY_RUN = 12.0
const BOB_AMPLITUDE = 3.0
func _ready():
	add_to_group("Player")
	if Global.player_spawn_position != Vector2.ZERO:
		global_position = Global.player_spawn_position
		Global.player_spawn_position = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("mouvement_gauche", "mouvement_droit", "mouvement_haut", "mouvement_bas")
	if Input.is_action_just_pressed("sprint toggle"):
		sprint_toggle = !sprint_toggle

	if input_dir == Vector2.ZERO:
		sprint_toggle = false
		state = "IDLE"
	else:
		state = "RUN" if sprint_toggle else "WALK"

	var target_speed = run_speed if state == "RUN" else walk_speed
	var target_velocity = input_dir * target_speed

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	if state in ["WALK", "RUN"] and footstep_timer.is_stopped():
		footstep_timer.wait_time = 0.27 if state == "RUN" else 0.35
		footstep_timer.start()
		footstep_dust.restart()
		footstep_dust.emitting = true

	if state in ["WALK", "RUN"]:
		var freq = BOB_FREQUENCY_RUN if state == "RUN" else BOB_FREQUENCY_WALK
		bob_time += delta * freq
		$AnimatedSprite2D.position.y = sprite_base_y + sin(bob_time) * BOB_AMPLITUDE
	else:
		bob_time = 0.0
		$AnimatedSprite2D.position.y = lerp($AnimatedSprite2D.position.y, sprite_base_y, delta * 10.0)
		
	match state:
		"IDLE":
			$AnimatedSprite2D.play("idle")
			footstep_dust.emitting = false   
			footstep_timer.stop()
		"WALK":
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = input_dir.x < 0
		"RUN":
			$AnimatedSprite2D.play("run")
			$AnimatedSprite2D.flip_h = input_dir.x < 0

	move_and_slide()
