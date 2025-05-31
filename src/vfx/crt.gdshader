shader_type canvas_item;

uniform vec2 resolution = vec2(512.0, 394.0);
uniform float brightness : hint_range(0.0, 1.0, 0.01) = 0.666;

void fragment() {
	vec2 pixel = UV * (resolution);
	
	int modulus = int(mod(pixel.x * 3.0, 3.0));
	
	if (modulus == 0) {
		COLOR.g = mix(0.0, COLOR.g, brightness);
		COLOR.b = mix(0.0, COLOR.b, brightness);
	} else if (modulus == 1) {
		COLOR.r = mix(0.0, COLOR.r, brightness);
		COLOR.g = mix(0.0, COLOR.g, brightness);
	} else {
		COLOR.r = mix(0.0, COLOR.r, brightness);
		COLOR.b = mix(0.0, COLOR.b, brightness);
	}
}