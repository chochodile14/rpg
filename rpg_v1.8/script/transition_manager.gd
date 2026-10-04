extends CanvasLayer



@onready var rect: ColorRect = $TransitionRect

const MAX_RADIUS := 1.6

func _ready() -> void:
	layer = 100  # toujours au-dessus de tout le reste
	_set_radius(0.0)

func _mat() -> ShaderMaterial:
	return rect.material as ShaderMaterial

func _set_radius(r: float) -> void:
	_mat().set_shader_parameter("radius", r)

func _set_center(c: Vector2) -> void:
	_mat().set_shader_parameter("center", c)

func _screen_uv(pos: Vector2) -> Vector2:
	var vp_size := get_viewport().get_visible_rect().size
	return pos / vp_size

# Place l'écran instantanément dans un état (utile avant un premier reveal()).
func snap_cover() -> void:
	_set_center(Vector2(0.5, 0.5))
	_set_radius(MAX_RADIUS)

func snap_clear() -> void:
	_set_radius(0.0)

# Referme l'iris vers le noir, à partir d'un point de l'écran donné
# (en coordonnées globales, ex: bouton.global_position). Vector2(-1,-1) = centre.
func cover(origin_global_pos: Vector2 = Vector2(-1, -1), duration: float = 0.6) -> void:
	var center := Vector2(0.5, 0.5)
	if origin_global_pos.x >= 0.0:
		center = _screen_uv(origin_global_pos)
	_set_center(center)
	var t := create_tween()
	t.tween_method(_set_radius, 0.0, MAX_RADIUS, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await t.finished

# Ouvre l'iris depuis le noir.
func reveal(origin_global_pos: Vector2 = Vector2(-1, -1), duration: float = 0.9) -> void:
	var center := Vector2(0.5, 0.5)
	if origin_global_pos.x >= 0.0:
		center = _screen_uv(origin_global_pos)
	_set_center(center)
	_set_radius(MAX_RADIUS)
	var t := create_tween()
	t.tween_method(_set_radius, MAX_RADIUS, 0.0, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await t.finished

# Tout-en-un : ferme l'écran, change de scène, laisse une frame au moteur
# pour instancier la nouvelle scène, puis rouvre l'écran dessus.
func change_scene(path: String, origin_global_pos: Vector2 = Vector2(-1, -1)) -> void:
	await cover(origin_global_pos)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	reveal()
	$TransitionRect.visible = false
