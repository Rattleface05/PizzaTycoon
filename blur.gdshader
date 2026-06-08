shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float spread : hint_range(0.0, 10.0) = 5.0;
uniform vec4 dim_color : source_color = vec4(0.0, 0.0, 0.0, 0.75);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 col = vec4(0.0);
	float lod = 5.0; // Base massive blur from mipmaps
	
	// Sample in a wide circle/grid
	float s = spread * 0.01;
	
	col += textureLod(screen_texture, uv + vec2(-s, -s), lod);
	col += textureLod(screen_texture, uv + vec2(0.0, -s), lod);
	col += textureLod(screen_texture, uv + vec2(s, -s), lod);
	
	col += textureLod(screen_texture, uv + vec2(-s, 0.0), lod);
	col += textureLod(screen_texture, uv, lod);
	col += textureLod(screen_texture, uv + vec2(s, 0.0), lod);
	
	col += textureLod(screen_texture, uv + vec2(-s, s), lod);
	col += textureLod(screen_texture, uv + vec2(0.0, s), lod);
	col += textureLod(screen_texture, uv + vec2(s, s), lod);
	
	col /= 9.0;
	
	COLOR = mix(col, dim_color, dim_color.a);
}
