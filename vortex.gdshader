shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength = 0.0;
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius = 1.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 dir = uv - center;
    float dist = length(dir);
    
    // Smooth falloff based on radius
    float effect = smoothstep(radius, 0.0, dist);
    float angle = strength * effect;
    
    float c = cos(angle);
    float s = sin(angle);
    mat2 rot = mat2(vec2(c, -s), vec2(s, c));
    
    vec2 new_uv = center + rot * dir;
    
    // Add a black hole effect (darken center based on strength)
    float darken = 1.0 - (effect * clamp(strength * 0.1, 0.0, 1.0));
    
    COLOR = texture(screen_texture, new_uv) * vec4(darken, darken, darken, 1.0);
}
