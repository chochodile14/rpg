# pause_menu.gd
# ─────────────────────────────────────────────────────────────────────────────
# Gère le menu pause (Échap).
# Structure de la scène :
#   PauseMenu (Control)
#   ├── MarginContainer / VBoxContainer
#   │   ├── resume   (Button)
#   │   ├── settigs  (Button)  ← ouvre le panneau Settings
#   │   └── quit     (Button)
#   └── settings     (instance de settings.tscn, cachée par défaut)
#
# FONCTIONNEMENT :
#   - _on_resume_pressed()  → appelle PauseMenu() sur la map pour dépausear
#   - _on_settigs_pressed() → affiche le panneau settings (en jeu, pas de
#                             changement de scène, pas de musique de menu)
#   - _on_quit_pressed()    → quitte le jeu
# ─────────────────────────────────────────────────────────────────────────────
extends Control

@onready var settings_panel = $settings
@onready var buttons = $MarginContainer/VBoxContainer  # ← AJOUTE ÇA

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # ← AJOUTE ÇA
	settings_panel.hide()
	settings_panel.from_pause = true

func _on_resume_pressed() -> void:
	var map = get_tree().current_scene
	if map.has_method("PauseMenu"):
		map.PauseMenu()

func _on_settigs_pressed() -> void:
	buttons.hide()          # ← CACHE les boutons
	settings_panel.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

# ← NOUVELLE FONCTION appelée par le panneau Settings quand on clique Back
func show_main_buttons() -> void:
	settings_panel.hide()
	buttons.show()          # ← REAFFICHE les boutons
