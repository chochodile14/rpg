shader_type canvas_item;

// Transition "iris" façon jeu souls-like : un cercle noir s'ouvre ou se referme
// à partir d'un point précis de l'écran (le centre, ou le bouton cliqué).

uniform vec2 center = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 2.0) = 1.6;
uniform float softness : hint_range(0.001, 0.3) = 0.05;
uniform float aspect = 1.7778;
uniform vec4 wipe_color : source_color = vec4(0.03, 0.02, 0.012, 1.0);

void fragment() {
	vec2 uv = UV;
	uv.x *= aspect;
	vec2 c = center;
	c.x *= aspect;
	float dist = distance(uv, c);
	float alpha = 1.0 - smoothstep(radius - softness, radius + softness, dist);
	COLOR = vec4(wipe_color.rgb, clamp(alpha, 0.0, 1.0));
}
