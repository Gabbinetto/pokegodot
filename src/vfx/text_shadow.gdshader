shader_type canvas_item;
render_mode unshaded;

group_uniforms outline_look;
// Default HGSS text shadow color
uniform vec4 outline_color: source_color = vec4(0.635, 0.635, 0.667, 1.0);
uniform int outline_width = 2;
uniform mat3 directions = mat3(vec3(0.0), vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 1.0));
group_uniforms;

varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR; // Accounts for modulate, LabelSettings color and such
}

void fragment() {
	float alpha = 0.0;

	if (COLOR.a > 0.0) {
		COLOR = vertex_color;
	} else {
		for (float x = -1.0; x < 2.0; x++) {
			for (float y = -1.0; y < 2.0; y++) {
				if (directions[int(x + 1.0)][int(y + 1.0)] <= 0.0) {
					continue;
				}
				vec2 opposite_pixel_position = UV + (TEXTURE_PIXEL_SIZE * vec2(-x * float(outline_width), -y * float(outline_width)));
				alpha += texture(TEXTURE, opposite_pixel_position).a;
			}
		}

		if (alpha > 0.0) {
			COLOR = outline_color;
		}
	}

}