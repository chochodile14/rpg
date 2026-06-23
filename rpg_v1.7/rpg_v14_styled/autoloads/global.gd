extends Node
#---------inventaire -----------------------------------------------------------
var inventory = {
	"potion": 0,
	"sword" : 0,
	"shield" : 0,
}
#---------Monnaie du jeu a deffinir plus tard ----------------------------------
var gold = 250
# ──   sauvegarde de slot  ─────────────────────────────────────────────────────
var current_slot: int = 0

# ── Position combat / map ─────────────────────────────────────────────────────
var battle_mob_position: Vector2 = Vector2.ZERO
var player_spawn_position: Vector2 = Vector2.ZERO
var player: Node = null
var is_tutorial: bool = false

# ── Système d'expérience et de stats ─────────────────────────────────────────
# Chaque joueur (index 0-3) a ses propres stats.
# On stocke tout ici pour que ça persiste entre les scènes.

# XP totale accumulée (commune à tous les joueurs pour simplifier)
var total_xp: int = 0

# Niveau de chaque joueur (commence à 1)
var player_levels: Array[int] = [1, 1, 1, 1]

# Points d'aptitude disponibles à dépenser pour chaque joueur
var aptitude_points: Array[int] = [0, 0, 0, 0]

# Statistiques : valeur de base + bonus achetés
# Format : { "hp": N, "atk": N, "def": N, "crit": N }
# Ces valeurs sont des NIVEAUX d'amélioration (0 à MAX_UPGRADE)
var player_upgrades: Array[Dictionary] = [
	{ "hp": 0, "atk": 0, "def": 0, "crit": 0 },
	{ "hp": 0, "atk": 0, "def": 0, "crit": 0 },
	{ "hp": 0, "atk": 0, "def": 0, "crit": 0 },
	{ "hp": 0, "atk": 0, "def": 0, "crit": 0 },
]

# Constantes de progression
const XP_PER_LEVEL: int     = 100   # XP nécessaire pour passer au niveau suivant
const XP_PER_COMBAT: int    = 40    # XP gagnée par victoire
const AP_PER_LEVEL: int     = 2     # Points d'aptitude par niveau
const MAX_UPGRADE: int      = 10    # Niveau max d'amélioration par stat

# Valeurs de base en combat
const BASE_HP: float        = 20.0
const BASE_ATK_BONUS: float = 0.0   # bonus s'ajoute aux dégâts de l'attaque
const BASE_DEF: float       = 0.0   # réduction des dégâts reçus (plafonnée à 80%)
const BASE_CRIT_CHANCE: float = 0.0 # % de chance (0.0 à 1.0)

# Bonus par niveau d'amélioration
const HP_PER_UPGRADE: float   = 5.0   # +5 PV par rang
const ATK_PER_UPGRADE: float  = 2.0   # +2 dégâts par rang
const DEF_PER_UPGRADE: float  = 4.0   # 4% de réduction par rang (max 10 * 4 = 40%)
const CRIT_PER_UPGRADE: float = 0.05  # +5% de chance critique par rang

# ── Accesseurs calculés ───────────────────────────────────────────────────────

func get_max_hp(player_idx: int) -> float:
	var rank = player_upgrades[player_idx]["hp"]
	return BASE_HP + rank * HP_PER_UPGRADE

func get_atk_bonus(player_idx: int) -> float:
	var rank = player_upgrades[player_idx]["atk"]
	return BASE_ATK_BONUS + rank * ATK_PER_UPGRADE

func get_def_reduction(player_idx: int) -> float:
	# Retourne un multiplicateur : ex. 0.2 = 20% de réduction
	var rank = player_upgrades[player_idx]["def"]
	return rank * DEF_PER_UPGRADE / 100.0

func get_crit_chance(player_idx: int) -> float:
	var rank = player_upgrades[player_idx]["crit"]
	return BASE_CRIT_CHANCE + rank * CRIT_PER_UPGRADE

# ── Gestion XP / niveaux ─────────────────────────────────────────────────────

func add_xp(amount: int) -> Array[int]:
	# Retourne la liste des joueurs qui ont monté de niveau
	var leveled_up: Array[int] = []
	total_xp += amount
	for i in player_levels.size():
		var new_level = 1 + int(total_xp / XP_PER_LEVEL)
		new_level = min(new_level, 99)
		if new_level > player_levels[i]:
			var gained = new_level - player_levels[i]
			player_levels[i] = new_level
			aptitude_points[i] += gained * AP_PER_LEVEL
			leveled_up.append(i)
	return leveled_up

func xp_to_next_level() -> int:
	# Retourne l'XP manquante pour le prochain niveau (basé sur le joueur 0)
	var current_level = player_levels[0]
	return (current_level * XP_PER_LEVEL) - total_xp

func can_upgrade(player_idx: int, stat: String) -> bool:
	return aptitude_points[player_idx] > 0 and \
		   player_upgrades[player_idx][stat] < MAX_UPGRADE

func spend_aptitude(player_idx: int, stat: String) -> bool:
	if not can_upgrade(player_idx, stat):
		return false
	aptitude_points[player_idx] -= 1
	player_upgrades[player_idx][stat] += 1
	return true



# ── Système de sauvegarde ─────────────────────────────────────────────────────
# Les saves sont dans user://saves/slot_N.json  (N = 0, 1, 2)

func save_game(slot: int) -> void:
	var data := {
		"gold": total_gold,
		"player_inventory": inventory,
		"total_xp":          total_xp,
		"player_levels":      player_levels,
		"aptitude_points":    aptitude_points,
		"player_upgrades":    player_upgrades,
		"spawn_position":     [player_spawn_position.x,
								 player_spawn_position.y],
		"save_date":          Time.get_datetime_string_from_system(),
	}
	DirAccess.make_dir_absolute("user://saves")
	var path := "user://saves/slot_%d.json" % slot
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()

func load_game(slot: int) -> bool:
	var path := "user://saves/slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if data == null: return false
	gold.string("player_gold")
	inventory.string("player_inventory")
	total_xp          = data["total_xp"]
	player_levels.assign(data["player_levels"])
	aptitude_points.assign(data["aptitude_points"])
	player_upgrades.assign(data["player_upgrades"]) 
	var sp            = data["spawn_position"]
	player_spawn_position = Vector2(sp[0], sp[1])
	return true

func get_slot_info(slot: int) -> Dictionary:
	## Retourne {} si le slot est vide, sinon les métadonnées.
	var path := "user://saves/slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if data == null: return {}
	return {
		"level":  data["player_levels"][0],
		"date":   data["save_date"],
		"xp":     data["total_xp"],
	}
