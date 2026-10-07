extends Node

var hour := 8.0                  # 0.0 à 24.0
var day_length := 600.0          # secondes réelles pour un jour complet
var running := true

func _process(delta: float) -> void:
	if running:
		hour = fposmod(hour + delta * 24.0 / day_length, 24.0)

# 0.0 en plein jour, 1.0 en pleine nuit, avec une transition douce à l'aube et au crépuscule
func night_factor() -> float:
	var dusk := smoothstep(17.5, 20.0, hour)
	var dawn := 1.0 - smoothstep(5.0, 7.5, hour)
	return maxf(dusk, dawn)

# Pour tester : F6 avance de 2 heures (build debug uniquement)
func _unhandled_key_input(e: InputEvent) -> void:
	if OS.is_debug_build() and e is InputEventKey and e.pressed and e.keycode == KEY_T:
		hour = fposmod(hour + 2.0, 24.0)
		print("[GameClock] touche reçue, heure = ", hour)
