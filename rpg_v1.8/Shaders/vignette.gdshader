shader_type canvas_item;

// Assombrit progressivement les bords de l'écran pour concentrer le regard
// sur le titre et les boutons, comme dans Elden Ring / Cult of the Lamb.

uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float radius : hint_range(0.0, 1.5) = 0.75;
uniform float softness : hint_range(0.05, 1.5) = 0.6;
uniform vec4 vignette_color : source_color = vec4(0.02, 0.015, 0.01, 1.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float darkness = smoothstep(radius - softness, radius, dist) * intensity;
	COLOR = vec4(vignette_color.rgb, clamp(darkness, 0.0, 1.0));
}
