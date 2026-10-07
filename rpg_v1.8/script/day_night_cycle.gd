class_name DayNightCycle
extends Node

@export var ambient: LitCanvasModulate
@export var sun: LitDirectionalLight2D
@export var grade: LitPostColorGrade   
@export var vignette: LitPostVignette  

var ambient_grad := _make([
	[0.00, "#232c4d"], [0.20, "#262f52"], [0.27, "#8a6a6e"], [0.33, "#d9a574"],
	[0.42, "#f0ead8"], [0.58, "#f4f0e4"], [0.70, "#e8c89a"], [0.77, "#e08a52"],
	[0.83, "#5a4262"], [0.90, "#2a3252"], [1.00, "#232c4d"]])
var sun_grad := _make([
	[0.00, "#7f93c9"], [0.25, "#a8a0c0"], [0.28, "#ffb27a"], [0.40, "#fff1d6"],
	[0.55, "#fff6e6"], [0.70, "#ffd9a0"], [0.77, "#ff9050"], [0.80, "#9a7fbf"],
	[0.85, "#7f93c9"], [1.00, "#7f93c9"]])
var tint_grad := _make([
	[0.00, "#c4cdf5"], [0.25, "#ffd9c0"], [0.40, "#ffffff"], [0.60, "#ffffff"],
	[0.75, "#ffd0a0"], [0.85, "#c4cdf5"], [1.00, "#c4cdf5"]])

func _make(stops: Array) -> Gradient:
	var g := Gradient.new()
	var offs := PackedFloat32Array()
	var cols := PackedColorArray()
	for s in stops:
		offs.append(s[0])
		cols.append(Color(s[1]))
	g.offsets = offs
	g.colors = cols
	return g

func _process(_delta: float) -> void:
	var h := GameClock.hour
	var t := h / 24.0
	var night := GameClock.night_factor()

	ambient.color = ambient_grad.sample(t)
	if Engine.get_process_frames() % 60 == 0:
		print("heure=", snapped(h, 0.01), " | couleur=", ambient.color.to_html(false), " | noeud=", ambient.get_path())
	# Soleil de 6 h à 18 h, lune de 18 h à 6 h : même lumière, deux rôles
	var is_day := h >= 6.0 and h < 18.0
	var p := (h - 6.0) / 12.0 if is_day else fposmod(h - 18.0, 24.0) / 12.0
	var elev := sin(p * PI)   # 0 à l'horizon, 1 au zénith
	sun.rotation = lerpf(0.0, PI, p)   # de la gauche (lever) vers la droite (coucher)
	sun.color = sun_grad.sample(t)
	if is_day:
		sun.energy = lerpf(0.1, 0.2, elev)
		sun.shadow_length = lerpf(1.0, 0.2, elev)
		sun.height = lerpf(8.0, 40.0, elev)
	else:
		sun.energy = lerpf(0.1, 0.2, elev)
		sun.shadow_length = lerpf(1.0, 0.5, elev)
		sun.height = lerpf(8.0, 24.0, elev)

	if grade:
		grade.tint = tint_grad.sample(t)
		grade.saturation = lerpf(1.0, 0.75, night)
	if vignette:
		vignette.strength = lerpf(0.3, 0.55, night)
