shader_type canvas_item;

// Bande lumineuse qui traverse le titre une seule fois à l'apparition du menu,
// comme le reflet qu'on voit passer sur les logos de jeux AAA.

uniform float progress : hint_range(-0.5, 1.5) = -0.5;
uniform float band_width : hint_range(0.02, 1.0) = 0.16;
uniform vec4 shine_color : source_color = vec4(1.0, 0.92, 0.65, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float d = abs(UV.x - progress);
	float band = smoothstep(band_width, 0.0, d);
	vec3 shine = mix(tex.rgb, tex.rgb + shine_color.rgb * 0.9, band);
	COLOR = vec4(shine, tex.a);
}
