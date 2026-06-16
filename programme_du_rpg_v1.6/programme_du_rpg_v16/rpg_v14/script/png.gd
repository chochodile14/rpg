extends CharacterBody2D

var dialogue_open = false
var player_in_range = false
var dialogue_index = 0
var dialogue = [
	"Bonjour voyageur .",
	"Je me nomme (nom)",
	"Ceci n'est que le debut de votre avanture,",
	"dans les vaste terre de l'empire!"
	
]
@onready var sprite := $AnimatedSprite2D

var waypoints = [
	Vector2(-263,-1859),
	Vector2(-257, -1704), 
	Vector2(410,-1755),
	Vector2(128, -1499), 
	Vector2(410,-1755),
	Vector2(-257, -1704), 
	Vector2(-263,-1859),
]
var target_index := 0
const SPEED := 60.0

func _ready():
	position = waypoints[0]  # <- on démarre PILE sur le 1er point
	target_index = 1
	$CanvasLayer/DialogueBox/Dialogue.text = dialogue[0]
	$CanvasLayer.visible = false
	dialogue_index = 0
func next_dialogue():
	dialogue_index += 1

func _physics_process(delta):
	var target = waypoints[target_index]
	var dir_vec = target - position
	var dist = dir_vec.length()

	if dist < SPEED * delta:
		position = target
		target_index = (target_index + 1) % waypoints.size()
	else:
		velocity = dir_vec.normalized() * SPEED
		move_and_slide()

	_update_animation(dir_vec)

func _update_animation(dir_vec: Vector2):
	if abs(dir_vec.x) > abs(dir_vec.y):
		sprite.play("walk_left")
		sprite.flip_h = dir_vec.x > 0   # true = on regarde à droite
	else:
		sprite.flip_h = false
		sprite.play("walk_down" if dir_vec.y > 0 else "walk_up")
		

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interaction"):
		if dialogue_open == true:
			next_dialogue()
			if dialogue_index < dialogue.size():
				$CanvasLayer/DialogueBox/Dialogue.text = dialogue[dialogue_index]
			else:
				$CanvasLayer.visible = false
				dialogue_open = false
				dialogue_index = 0
		else:
			dialogue_open = true
			talk_to_PNJ()



func talk_to_PNJ():
	if dialogue_open :
		$CanvasLayer.visible = true
		$CanvasLayer/DialogueBox/Dialogue.text = dialogue[0]



func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true



func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		$CanvasLayer.visible = false
		dialogue_open = false
		dialogue_index = 0


func _on_suivant_pressed() -> void:
	dialogue_index += 1
	if dialogue_index < dialogue.size():
		$CanvasLayer/DialogueBox/Dialogue.text = dialogue[dialogue_index]
	else:
		$CanvasLayer.visible = false
