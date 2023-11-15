shader_type canvas_item;

uniform float color_level; 

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR = mix(vec4(COLOR.r / 4., COLOR.g / 4., COLOR.b / 3., COLOR.a), COLOR, color_level);
}
