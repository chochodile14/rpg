# script/settings.gd
# ─────────────────────────────────────────────────────────────────────────────
# Ce script gère le panneau Settings.
# Il peut être ouvert depuis deux endroits :
#   - Le hub (menu principal) → _on_exit_pressed() change de scène vers hub
#   - Le menu pause en jeu  → _on_exit_pressed() cache juste le panneau
#
# La variable `from_pause` (true/false) détermine le comportement du Exit.
# ─────────────────────────────────────────────────────────────────────────────
extends Control

var from_pause: bool = false

func _on_exit_pressed() -> void:
	if from_pause:
		# ← Au lieu de juste hide(), on appelle show_main_buttons() sur PauseMenu
		get_parent().show_main_buttons()
	else:
		get_tree().change_scene_to_file("res://hub.tscn")
