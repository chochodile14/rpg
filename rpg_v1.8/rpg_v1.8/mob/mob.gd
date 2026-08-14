# mob/mob.gd  ─────────────────────────────────────────────────────────────────
#
# MACHINE À ÉTATS DU MONSTRE :
#
#   WANDER  →  le monstre se promène aléatoirement à vitesse lente.
#              Il choisit un point aléatoire, s'y dirige, attend 1-3 s puis
#              recommence. Animation "walk" ralentie (speed_scale 0.5).
#
#   ALERT   →  il vient de repérer le joueur. Il s'arrête, "!" apparaît,
#              il attend 0.5 s pour laisser le temps de fuir puis…
#
#   CHASE   →  il court vers le joueur. Le sprite se retourne SEULEMENT si le
#              déplacement est principalement horizontal (|dx| > |dy|).
#              Si le joueur est surtout en haut/bas, pas de flip.
#              Animation "walk" à pleine vitesse (speed_scale 1.0).
#
#   DEAD    →  après un combat ou un respawn en cours. Tout désactivé.
#
# DÉCLENCHEMENT DU COMBAT :
#   La petite Area2D de contact (rayon ~40px) déclenche le combat quand
#   elle touche le joueur. Le monstre disparaît immédiatement et réapparaît
#   après `respawn_delay` secondes à sa position initiale.
#
# ─────────────────────────────────────────────────────────────────────────────

extends RigidBody2D

# ── Paramètres inspecteur ─────────────────────────────────────────────────────
@export var speed_wander : float = 40.0    # vitesse de balade (lente)
@export var speed_chase  : float = 130.0   # vitesse de poursuite
@export var detect_range : float = 220.0   # rayon de détection (px)
@export var lose_range   : float = 360.0   # distance d'abandon de poursuite
@export var respawn_delay: float = 20.0    # secondes avant réapparition
@export var wander_radius: float = 180.0   # amplitude max de la balade

# ── Références nœuds ──────────────────────────────────────────────────────────
@onready var sprite       : AnimatedSprite2D  = $AnimatedSprite2D
@onready var nav_agent    : NavigationAgent2D = $NavigationAgent2D
@onready var nav_timer    : Timer             = $NavTimer
@onready var alert_label  : Label             = $AlertLabel
@onready var detect_shape : CollisionShape2D  = $DetectionZone/DetectionShape
@onready var detect_zone  : Area2D            = $DetectionZone
@onready var contact_area : Area2D            = $Area2D

# ── État interne ──────────────────────────────────────────────────────────────
enum State { WANDER, ALERT, CHASE, DEAD }
var state          : State   = State.WANDER
var player_ref     : Node2D  = null
var _spawn_pos     : Vector2 = Vector2.ZERO
var _triggered     : bool    = false


# ═════════════════════════════════════════════════════════════════════════════
func _ready() -> void:
	_spawn_pos = global_position
	lock_rotation = true

	# Ajuste le rayon de la zone de détection
	if detect_shape.shape is CircleShape2D:
		(detect_shape.shape as CircleShape2D).radius = detect_range

	alert_label.visible = false

	# Timer navigation : recalcule le chemin toutes les 0.3 s
	nav_timer.wait_time = 0.3
	nav_timer.timeout.connect(_on_nav_tick)
	nav_timer.start()

	# Attend 2 frames avant d'activer les collisions
	# → empêche le déclenchement immédiat au chargement
	freeze = true
	await get_tree().process_frame
	await get_tree().process_frame
	freeze = false

	_set_state(State.WANDER)


# ═════════════════════════════════════════════════════════════════════════════
func _physics_process(_delta: float) -> void:
	match state:
		State.WANDER, State.CHASE:
			if nav_agent.is_navigation_finished():
				linear_velocity = Vector2.ZERO
				return
			var next : Vector2 = nav_agent.get_next_path_position()
			var dir  : Vector2 = (next - global_position).normalized()
			var spd  : float   = speed_wander if state == State.WANDER else speed_chase
			linear_velocity = dir * spd
			_orient_sprite(dir)
		_:
			linear_velocity = Vector2.ZERO


# ── Oriente le sprite selon la direction ──────────────────────────────────────
# Règle : on flip SEULEMENT si le mouvement est majoritairement horizontal.
# Si |dx| <= |dy| (on va surtout vers le haut ou le bas), on ne touche pas.
func _orient_sprite(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		sprite.flip_h = (dir.x < 0)
	# Sinon (haut/bas dominant) : on garde le flip actuel, pas de changement


# ═════════════════════════════════════════════════════════════════════════════
#  TIMER NAVIGATION  (toutes les 0.3 s)
# ═════════════════════════════════════════════════════════════════════════════
func _on_nav_tick() -> void:
	match state:

		State.WANDER:
			# Si on est arrivé au point cible, on en choisit un nouveau
			if nav_agent.is_navigation_finished():
				_pick_wander_target()

		State.CHASE:
			if not is_instance_valid(player_ref):
				_set_state(State.WANDER)
				return
			nav_agent.target_position = player_ref.global_position
			# Abandon si le joueur est trop loin
			if global_position.distance_to(player_ref.global_position) > lose_range:
				_set_state(State.WANDER)


# ── Choisit un point aléatoire autour de la position de spawn ─────────────────
func _pick_wander_target() -> void:
	var angle  : float   = randf() * TAU
	var radius : float   = randf_range(40.0, wander_radius)
	var target : Vector2 = _spawn_pos + Vector2(cos(angle), sin(angle)) * radius
	nav_agent.target_position = target
	# Petite pause aléatoire avant de partir (0.8 à 2.5 s)
	await get_tree().create_timer(randf_range(0.8, 2.5)).timeout


# ═════════════════════════════════════════════════════════════════════════════
#  ZONE DE DÉTECTION  (grand cercle)
# ═════════════════════════════════════════════════════════════════════════════
func _on_detection_zone_body_entered(body: Node2D) -> void:
	if state != State.WANDER:
		return
	if not body.is_in_group("Player"):
		return
	player_ref = body
	_set_state(State.ALERT)


# ═════════════════════════════════════════════════════════════════════════════
#  ZONE DE CONTACT  (petit cercle)  → déclenche le combat
# ═════════════════════════════════════════════════════════════════════════════
func _on_area_2d_body_entered(body: Node2D) -> void:
	if _triggered or state == State.DEAD:
		return
	if not body.is_in_group("Player"):
		return
	_triggered = true
	Global.battle_mob_position   = global_position
	Global.player_spawn_position = global_position + Vector2(-130, 0)
	_disappear()
	if Global.is_tutorial:
		get_tree().change_scene_to_file("res://tutorial/tutorial_battle.tscn")
	else:
		get_tree().change_scene_to_file("res://battle.tscn")


# ═════════════════════════════════════════════════════════════════════════════
#  MACHINE À ÉTATS
# ═════════════════════════════════════════════════════════════════════════════
func _set_state(new_state: State) -> void:
	state = new_state
	match new_state:

		State.WANDER:
			player_ref          = null
			alert_label.visible = false
			sprite.play("walk")
			sprite.speed_scale  = 0.5        # lent → donne l'impression de flâner
			_pick_wander_target()

		State.ALERT:
			linear_velocity     = Vector2.ZERO
			sprite.stop()
			alert_label.visible = true
			# Animation pop du "!"
			alert_label.scale      = Vector2(0.4, 0.4)
			alert_label.modulate.a = 0.0
			var t = create_tween().set_parallel(true)
			t.tween_property(alert_label, "scale",      Vector2(1.5, 1.5), 0.12)
			t.tween_property(alert_label, "modulate:a", 1.0,               0.12)
			# Attend 0.5 s (le joueur peut encore fuir !)
			await get_tree().create_timer(0.5).timeout
			if state == State.ALERT:
				_set_state(State.CHASE)

		State.CHASE:
			alert_label.visible = false
			sprite.play("walk")
			sprite.speed_scale  = 1.0        # pleine vitesse
			# Mise à jour immédiate de la cible
			if is_instance_valid(player_ref):
				nav_agent.target_position = player_ref.global_position

		State.DEAD:
			linear_velocity     = Vector2.ZERO
			alert_label.visible = false
			sprite.stop()


# ═════════════════════════════════════════════════════════════════════════════
#  DISPARITION + RÉAPPARITION
# ═════════════════════════════════════════════════════════════════════════════
func _disappear() -> void:
	_set_state(State.DEAD)
	sprite.visible          = false
	freeze                  = true
	process_mode            = Node.PROCESS_MODE_DISABLED
	detect_zone.monitoring  = false
	contact_area.monitoring = false
	# Lance le respawn en tâche de fond
	_respawn_after_delay()


func _respawn_after_delay() -> void:
	# process_mode est désactivé donc on ne peut pas await ici directement.
	# On utilise SceneTree directement depuis le root.
	await get_tree().create_timer(respawn_delay).timeout
	_respawn()


func _respawn() -> void:
	global_position         = _spawn_pos
	_triggered              = false
	freeze                  = false
	process_mode            = Node.PROCESS_MODE_INHERIT
	detect_zone.monitoring  = true
	contact_area.monitoring = true
	sprite.visible          = true
	# Fondu d'apparition
	sprite.modulate.a = 0.0
	sprite.scale      = Vector2(0.6, 0.6)
	var t = create_tween().set_parallel(true)
	t.tween_property(sprite, "modulate:a", 1.0,          0.6)
	t.tween_property(sprite, "scale",      Vector2(1,1), 0.6)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t.finished
	_set_state(State.WANDER)
