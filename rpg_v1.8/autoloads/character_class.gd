extends Resource
class_name CharacterClass

@export var class_name_display: String = "Guerrier"


@export var base_hp: float = 20.0
@export var base_atk: float = 0.0
@export var base_def: float = 0.0
@export var base_crit: float = 0.0
#-----------------taille des characters-----------------------------------------
@export var battle_target_height: float = 220.0
@export var battle_rotation_degrees: float = 0.0
@export var flip_h: bool = false
@export var flip_v: bool = false
@export var battle_visual_scale_correction: float = 1.0  
@export var battle_offset: Vector2 = Vector2.ZERO         


@export var light_dmg_mult: float = 1.0
@export var heavy_dmg_mult: float = 1.0
@export var ultimate_dmg_mult: float = 1.0


@export var sprite_frames: SpriteFrames
@export var battle_texture: Texture2D
