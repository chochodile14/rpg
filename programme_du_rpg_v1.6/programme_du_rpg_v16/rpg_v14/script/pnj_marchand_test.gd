extends CharacterBody2D

var state = "WALK"
var dialogue_open = false
var player_in_range = false
var shop_open = false
var dialogue_index = 0
var total_price = 0
var shop_item = {
	"sword" : 60,
	"potion": 20,
	"bouclier" : 80,
}
var dialogue = [
	"Bonjour voyageur! Les routes sont longues et les poches bien vide. Mais 
	MOI ALDRIC VENNEBROC A CE QUI VOUS FAUT!!",
	"et a des pris ma fois des plus genereux",
	"Je me nomme Aldric Vennebroc",
	"Ceci n'est que le debut de votre avanture,",
	"dans les vaste terre de l'empire!"
]
@onready var sprite := $AnimatedSprite2D

var waypoints = [
	Vector2(1264.0,-892.0),
	Vector2(936.0, -892.0), 
	Vector2(778.0,-1221.0),
	Vector2(762.0, -1173.0), 
	Vector2(547.0,-1186.0),
	Vector2(454.0, -1085.0), 
	Vector2(178.0,-1085.0),
	Vector2(191.0,-665.0),
	Vector2(500.0,-665.0),
	Vector2(864.0,-995.0),
	Vector2(1264.0,-892.0),
	Vector2(936.0, -892.0), 
]
var target_index := 0
const SPEED := 60.0
var saved_position: Vector2 = Vector2.ZERO
func _ready():
	position = waypoints[0]  # <- on démarre PILE sur le 1er point
	target_index = 1
	$CanvasLayer/DialogueBox/Dialogue.text = dialogue[0]
	$CanvasLayer.visible = false
	$shopbox.visible = false
	$CanvasLayer/DialogueBox/achat.visible = false
	dialogue_index = 0
func next_dialogue():
	dialogue_index += 1

func _physics_process(delta):
	
	
	match state :
		"WALK":
			var target = waypoints[target_index]
			var dir_vec = target - position
			var dist = dir_vec.length()
			if dist < SPEED * delta:
				position = target
				target_index = (target_index + 1) % waypoints.size()
			else:
				velocity = dir_vec.normalized() * SPEED
				_update_animation(dir_vec)
				move_and_slide()
		
		"STUN":
			velocity = Vector2.ZERO
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.play("idle")
			move_and_slide()
			$shopbox.visible = false
			
			if dialogue_index < dialogue.size():
				$CanvasLayer.visible = true
				$CanvasLayer/DialogueBox/Dialogue.text = dialogue[dialogue_index]
			else:
				$CanvasLayer.visible = false
				dialogue_open = false
				dialogue_index = 0
		"SHOP":
			
			$shopbox.visible = true
			$CanvasLayer.visible = false
func _update_animation(dir_vec: Vector2):
	if abs(dir_vec.x) > abs(dir_vec.y):
		sprite.play("walk left")
		sprite.flip_h = dir_vec.x > 0   # true = on regarde à droite
	else:
		sprite.flip_h = false
		sprite.play("walk down" if dir_vec.y > 0 else "walk up")
		

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interaction"):
		if dialogue_open == true:
				next_dialogue()
				if dialogue_index == 2:
					$CanvasLayer/DialogueBox/achat.visible = true
		else:
			$CanvasLayer/DialogueBox/achat.visible = false
			dialogue_open = true
			saved_position = global_position
			talk_to_PNJ()
			state = "STUN"
			
				




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
		state = "WALK"


func _on_suivant_pressed() -> void:
	dialogue_index += 1
	if dialogue_index < dialogue.size():
		$CanvasLayer/DialogueBox/Dialogue.text = dialogue[dialogue_index]
	else:
		$CanvasLayer.visible = false
		state = "WALK"


func _on_achat_pressed() -> void:
	state = "SHOP"


func _on_acheter_pressed() -> void:
	if $shopbox/DialogueBox/sword.button_pressed:
		print("sword")
	if $shopbox/DialogueBox/potion.button_pressed:
		print("potion")
	if $shopbox/DialogueBox/shield.button_pressed:
		print("shield")
	$CanvasLayer/DialogueBox/achat.visible = false
	if Global.gold >= total_price:
		Global.gold -= total_price
		print("achat reussit", "il te reste", Global.gold)
	else:
		print("pas asser d'or")


func _on_parler_pressed() -> void:
	state = "STUN"
