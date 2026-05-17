extends Node

# Position du monstre sur la map au moment du déclenchement du combat
var battle_mob_position: Vector2 = Vector2.ZERO

# Position de spawn du joueur après le combat
var player_spawn_position: Vector2 = Vector2.ZERO

var player: Node = null

# true quand on est dans le tutoriel
var is_tutorial: bool = false
