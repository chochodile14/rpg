extends Node2D

@onready var label: Label = $Label

func _ready() -> void:
	visible = false

func show_prompt(key_text: String = "F") -> void:
	label.text = key_text
	visible = true
	scale = Vector2(0.6, 0.6)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_prompt() -> void:
	visible = false
