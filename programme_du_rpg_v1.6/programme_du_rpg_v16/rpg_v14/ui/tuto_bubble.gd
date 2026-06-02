# ui/tuto_bubble.gd
# Bulle de tutoriel générique : affiche une série d'étapes
# et émet "all_done" quand la dernière est validée.
extends CanvasLayer

signal all_done

@export var steps: Array[Dictionary] = []
# Chaque dict : { "title": String, "text": String, "arrow": String ("", "top","bottom","left","right"), "wait_input": bool }

var _step: int = 0

@onready var panel       : PanelContainer = $Panel
@onready var lbl_title   : Label          = $Panel/VBox/Title
@onready var lbl_text    : Label          = $Panel/VBox/Text
@onready var lbl_arrow   : Label          = $Panel/VBox/ArrowHint
@onready var btn_ok      : Button         = $Panel/VBox/BtnOK
@onready var anim        : AnimationPlayer = $Panel/Anim

func _ready() -> void:
	visible = false

func start() -> void:
	_step = 0
	visible = true
	_show_step()

func _show_step() -> void:
	if _step >= steps.size():
		_finish()
		return
	var s: Dictionary = steps[_step]
	lbl_title.text = s.get("title", "")
	lbl_text.text  = s.get("text",  "")
	var arrow = s.get("arrow", "")
	match arrow:
		"top":    lbl_arrow.text = "▲"
		"bottom": lbl_arrow.text = "▼"
		"left":   lbl_arrow.text = "◀"
		"right":  lbl_arrow.text = "▶"
		_:        lbl_arrow.text = ""
	btn_ok.text    = "Suivant ▶" if _step < steps.size() - 1 else "C'est parti !"
	# pop-in
	panel.scale    = Vector2(0.85, 0.85)
	panel.modulate.a = 0.0
	var t = create_tween().set_parallel(true)
	t.tween_property(panel, "scale",       Vector2(1,1), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "modulate:a",  1.0,          0.18)

func _on_btn_ok_pressed() -> void:
	_step += 1
	_show_step()

func _finish() -> void:
	var t = create_tween()
	t.tween_property(panel, "modulate:a", 0.0, 0.2)
	await t.finished
	visible = false
	emit_signal("all_done")
