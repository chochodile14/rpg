extends Node
#---------items ----------------------------------------------------------------
var items = {
	# =========================
	# ARMES
	# =========================

	"dagger": {
		"name": "Dague",
		"price": 10,
		"attack": 1,
		"description": "Une petite lame facile à dissimuler."
	},

	"hunting_knife": {
		"name": "Couteau de chasse",
		"price": 8,
		"attack": 1,
		"description": "Utilisé pour la chasse et le dépeçage."
	},

	"short_sword": {
		"name": "Épée courte",
		"price": 25,
		"attack": 2,
		"description": "Une épée légère adaptée aux aventuriers."
	},

	"long_sword": {
		"name": "Épée longue",
		"price": 50,
		"attack": 4,
		"description": "Une arme fiable utilisée par les soldats."
	},

	"sword": {
		"name": "Épée rafiner",
		"price": 90,
		"attack": 6,
		"description": "Peut être maniée à une ou deux mains.",
		"icon": preload("res://art/icon/sword icon.png"),
	},

	"greatsword": {
		"name": "Espadon",
		"price": 120,
		"attack": 8,
		"description": "Une immense lame infligeant de lourds dégâts."
	},

	"war_axe": {
		"name": "Hache de guerre",
		"price": 60,
		"attack": 5,
		"description": "Une arme redoutable contre les armures."
	},

	"spear": {
		"name": "Lance",
		"price": 30,
		"attack": 3,
		"description": "Permet d'attaquer à distance."
	},

	"halberd": {
		"name": "Hallebarde",
		"price": 100,
		"attack": 7,
		"description": "Combinaison d'une hache et d'une lance."
	},

	"short_bow": {
		"name": "Arc court",
		"price": 35,
		"attack": 3,
		"description": "Arc léger pour les tireurs mobiles."
	},

	"long_bow": {
		"name": "Arc long",
		"price": 75,
		"attack": 5,
		"description": "Arc puissant nécessitant de la force."
	},

	"crossbow": {
		"name": "Arbalète",
		"price": 90,
		"attack": 6,
		"description": "Inflige de lourds dégâts à distance."
	},

	"magic_wand": {
		"name": "Baguette magique",
		"price": 100,
		"magic": 2,
		"description": "Canalise l'énergie magique."
	},

	# =========================
	# ARMURES
	# =========================

	"cloth_armor": {
		"name": "Tunique rembourrée",
		"price": 10,
		"defense": 1,
		"description": "Protection basique en tissu."
	},

	"leather_armor": {
		"name": "Armure de cuir",
		"price": 30,
		"defense": 2,
		"description": "Protection légère et flexible."
	},

	"reinforced_leather": {
		"name": "Cuir renforcé",
		"price": 60,
		"defense": 4,
		"description": "Du cuir renforcé par des plaques."
	},

	"chainmail": {
		"name": "Cotte de mailles",
		"price": 120,
		"defense": 6,
		"description": "Protection classique des chevaliers."
	},

	"scale_armor": {
		"name": "Armure d'écailles",
		"price": 180,
		"defense": 8,
		"description": "Fabriquée à partir d'écailles métalliques."
	},

	"plate_armor": {
		"name": "Armure de plates",
		"price": 350,
		"defense": 12,
		"description": "L'une des meilleures protections non magiques."
	},

	"mage_robe": {
		"name": "Robe de mage",
		"price": 50,
		"magic": 3,
		"description": "Augmente la puissance magique."
	},

	"enchanted_robe": {
		"name": "Robe enchantée",
		"price": 200,
		"magic": 5,
		"description": "Robe imprégnée d'énergie mystique."
	},

	# =========================
	# BOUCLIERS
	# =========================

	"small_shield": {
		"name": "Petit bouclier",
		"price": 20,
		"defense": 2,
		"description": "Petit mais efficace."
	},

	"round_shield": {
		"name": "Bouclier rond",
		"price": 40,
		"defense": 4,
		"description": "Utilisé par les guerriers itinérants."
	},

	"shield": {
		"name": "Bouclier de chevalier",
		"price": 90,
		"defense": 6,
		"description": "Bouclier robuste en acier.",
		"icon":preload("res://art/icon/shiel icon.png")
	},

	# =========================
	# CONSOMMABLES
	# =========================

	"apple": {
		"name": "Pomme",
		"price": 1,
		"heal": 5,
		"description": "Restaure 5 PV."
	},

	"bread": {
		"name": "Pain",
		"price": 2,
		"heal": 10,
		"description": "Restaure 10 PV."
	},

	"dried_meat": {
		"name": "Viande séchée",
		"price": 5,
		"heal": 20,
		"description": "Restaure 20 PV."
	},

	"small_potion": {
		"name": "Potion mineure",
		"price": 15,
		"heal": 50,
		"description": "Restaure 50 PV."
	},

	"potion": {
		"name": "Potion",
		"price": 50,
		"heal": 150,
		"description": "Restaure 150 PV.",
		"icon":preload("res://art/icon/potion icon.png")
	},

	"large_potion": {
		"name": "Grande potion",
		"price": 150,
		"heal": 400,
		"description": "Restaure 400 PV."
	},

	"mana_potion": {
		"name": "Potion de mana",
		"price": 50,
		"mana": 50,
		"description": "Restaure 50 PM."
	},

	"greater_mana_potion": {
		"name": "Grande potion de mana",
		"price": 150,
		"mana": 200,
		"description": "Restaure 200 PM."
	},

	"antidote": {
		"name": "Antidote",
		"price": 20,
		"cure": "poison",
		"description": "Guérit le poison."
	},

	# =========================
	# ACCESSOIRES
	# =========================

	"ring_strength": {
		"name": "Anneau de force",
		"price": 150,
		"attack": 3,
		"description": "Augmente la force physique."
	},

	"ring_protection": {
		"name": "Anneau de protection",
		"price": 200,
		"defense": 3,
		"description": "Renforce la résistance aux dégâts."
	},

	"mage_necklace": {
		"name": "Collier du mage",
		"price": 250,
		"magic": 5,
		"description": "Augmente la puissance magique."
	},

	"lucky_talisman": {
		"name": "Talisman de chance",
		"price": 400,
		"luck": 5,
		"description": "Favorise les découvertes rares."
	},

	# =========================
	# OBJETS MAGIQUES
	# =========================

	"fire_scroll": {
		"name": "Parchemin de feu",
		"price": 50,
		"spell": "fireball",
		"description": "Lance une boule de feu."
	},

	"ice_scroll": {
		"name": "Parchemin de glace",
		"price": 50,
		"spell": "ice_shard",
		"description": "Lance un éclat de glace."
	},

	"lightning_scroll": {
		"name": "Parchemin de foudre",
		"price": 75,
		"spell": "lightning",
		"description": "Invoque un éclair."
	},

	"teleport_stone": {
		"name": "Pierre de téléportation",
		"price": 500,
		"description": "Téléporte instantanément en ville."
	},

	# =========================
	# OUTILS
	# =========================

	"torch": {
		"name": "Torche",
		"price": 2,
		"description": "Éclaire les zones sombres."
	},

	"rope": {
		"name": "Corde",
		"price": 5,
		"description": "Permet l'escalade."
	},

	"pickaxe": {
		"name": "Pioche",
		"price": 10,
		"description": "Utilisée pour miner."
	},

	"shovel": {
		"name": "Pelle",
		"price": 8,
		"description": "Permet de creuser."
	},

	"tent": {
		"name": "Tente",
		"price": 25,
		"description": "Permet de se reposer en extérieur."
	},

	"backpack": {
		"name": "Sac à dos",
		"price": 15,
		"inventory_slots": 20,
		"description": "Ajoute 20 emplacements d'inventaire."
	},

	# =========================
	# RESSOURCES
	# =========================

	"wolf_pelt": {
		"name": "Peau de loup",
		"price": 8,
		"description": "Matériau de fabrication."
	},

	"wolf_fang": {
		"name": "Croc de loup",
		"price": 4,
		"description": "Matériau alchimique."
	},

	"goblin_claw": {
		"name": "Griffe de gobelin",
		"price": 3,
		"description": "Trophée de monstre."
	},

	"dragon_scale": {
		"name": "Écaille de dragon",
		"price": 500,
		"description": "Matériau extrêmement rare."
	},

	"iron_ingot": {
		"name": "Lingot de fer",
		"price": 20,
		"description": "Utilisé par les forgerons."
	},

	"steel_ingot": {
		"name": "Lingot d'acier",
		"price": 50,
		"description": "Métal raffiné de qualité."
	},

	"mithril_ore": {
		"name": "Mithril brut",
		"price": 300,
		"description": "Métal légendaire très recherché."
	},

	# =========================
	# TRÉSORS
	# =========================

	"gold_ring": {
		"name": "Bague en or",
		"price": 100,
		"description": "Objet de valeur pouvant être revendu."
	},

	"ruby": {
		"name": "Rubis",
		"price": 400,
		"description": "Pierre précieuse rouge."
	},

	"emerald": {
		"name": "Émeraude",
		"price": 450,
		"description": "Pierre précieuse verte."
	},

	"diamond": {
		"name": "Diamant",
		"price": 1000,
		"description": "L'une des pierres les plus précieuses."
	}
}
#---------inventaire -----------------------------------------------------------
var inventory = {
	"potion": 0,
	"sword" : 0,
	"shield" : 0,
}
#---------Monnaie du jeu a deffinir plus tard ----------------------------------
var gold = 250

# ── Progression cinématique ───────────────────────────────────────────────────
var cinematic_debut_viewed: bool = false   # ← NOUVEAU : a-t-il vu l'intro ?

# ──   sauvegarde de slot  ─────────────────────────────────────────────────────
var current_slot: int = 0

# ── Position combat / map ─────────────────────────────────────────────────────
var battle_mob_position: Vector2 = Vector2.ZERO
var player_spawn_position: Vector2 = Vector2.ZERO
var player: Node = null
var is_tutorial: bool = false

# ── Système d'expérience et de stats ─────────────────────────────────────────
var total_xp: int = 0
var player_levels: Array[int] = [1, 1, 1, 1]
var aptitude_points: Array[int] = [0, 0, 0, 0]
var player_upgrades: Array[Dictionary] = [
	{ "hp": 0, "atk": 0, "def": 0, "crit": 0 },
	{ "hp": 0, "atk": 0, "def": 0, "crit": 0 },
	{ "hp": 0, "atk": 0, "def": 0, "crit": 0 },
	{ "hp": 0, "atk": 0, "def": 0, "crit": 0 },
]
@export var player_classes: Array[CharacterClass] = []

const XP_PER_LEVEL: int     = 100
const XP_PER_COMBAT: int    = 40
const AP_PER_LEVEL: int     = 2
const MAX_UPGRADE: int      = 10

const BASE_HP: float        = 20.0
const BASE_ATK_BONUS: float = 0.0
const BASE_DEF: float       = 0.0
const BASE_CRIT_CHANCE: float = 0.0

const HP_PER_UPGRADE: float   = 5.0
const ATK_PER_UPGRADE: float  = 2.0
const DEF_PER_UPGRADE: float  = 4.0
const CRIT_PER_UPGRADE: float = 0.05

func _ready() -> void:
	player_classes = [
		load("res://data/voyageur.tres"),
		load("res://data/chevalier.tres"),
		load("res://data/archer.tres"),
		load("res://data/dragonier.tres"),
	]


# ── Accesseurs calculés ───────────────────────────────────────────────────────

func get_max_hp(player_idx: int) -> float:
	var rank = player_upgrades[player_idx]["hp"]
	var base = player_classes[player_idx].base_hp
	return base + rank * HP_PER_UPGRADE

func get_atk_bonus(player_idx: int) -> float:
	var rank = player_upgrades[player_idx]["atk"]
	var base = player_classes[player_idx].base_atk
	return base + rank * ATK_PER_UPGRADE

func get_def_reduction(player_idx: int) -> float:
	var rank = player_upgrades[player_idx]["def"]
	var base = player_classes[player_idx].base_def
	return (base + rank * DEF_PER_UPGRADE) / 100.0

func get_crit_chance(player_idx: int) -> float:
	var rank = player_upgrades[player_idx]["crit"]
	var base = player_classes[player_idx].base_crit
	return base + rank * CRIT_PER_UPGRADE
	
func get_attack_multiplier(player_idx: int, attack_type: String) -> float:
	var char_class = player_classes[player_idx]
	if char_class == null:
		return 1.0
	match attack_type:
		"light":
			return char_class.light_dmg_mult
		"heavy":
			return char_class.heavy_dmg_mult
		"ultimate":
			return char_class.ultimate_dmg_mult
	return 1.0
	
func get_player_stats_dict(player_idx: int) -> Dictionary:
	return {
		"level":         player_levels[player_idx],
		"max_hp":        get_max_hp(player_idx),
		"atk_bonus":     get_atk_bonus(player_idx),
		"def_reduction": get_def_reduction(player_idx) * 100.0,  # en %
		"crit_chance":   get_crit_chance(player_idx) * 100.0,    # en %
		"aptitude_pts":  aptitude_points[player_idx],
	}
# ── Gestion XP / niveaux ─────────────────────────────────────────────────────

func add_xp(amount: int) -> Array[int]:
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

func save_game(slot: int) -> void:
	var data := {
		"player_gold":           gold,
		"player_inventory":      inventory,
		"total_xp":              total_xp,
		"player_levels":         player_levels,
		"aptitude_points":       aptitude_points,
		"player_upgrades":       player_upgrades,
		"spawn_position":        [player_spawn_position.x, player_spawn_position.y],
		"cinematic_debut_viewed": cinematic_debut_viewed,  # ← NOUVEAU
		"save_date":             Time.get_datetime_string_from_system(),
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
	gold              = data["player_gold"]
	inventory         = data["player_inventory"]
	total_xp          = data["total_xp"]
	player_levels.assign(data["player_levels"])
	aptitude_points.assign(data["aptitude_points"])
	player_upgrades.assign(data["player_upgrades"])
	var sp            = data["spawn_position"]
	player_spawn_position = Vector2(sp[0], sp[1])
	# ← NOUVEAU : compatibilité avec les anciennes saves (clé absente = false)
	cinematic_debut_viewed = data.get("cinematic_debut_viewed", false)
	return true

func get_slot_info(slot: int) -> Dictionary:
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
