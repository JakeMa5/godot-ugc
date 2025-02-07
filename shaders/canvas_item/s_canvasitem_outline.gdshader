shader_type canvas_item;

uniform vec4 outline_color : source_color;
uniform float outline_min_width = 1.2;
uniform float outline_max_width = 3.0;
uniform float outline_speed = 4.0;

void fragment() {
    float outline_width = mix(outline_min_width, outline_max_width, 0.5 * (sin(TIME * outline_speed) + 1.0));
    
    vec4 col = texture(TEXTURE, UV);
    vec2 ps = TEXTURE_PIXEL_SIZE;
    float a;
    float maxa = col.a;
    float mina = col.a;

    a = texture(TEXTURE, UV + vec2(0.0, -outline_width) * ps).a;
    maxa = max(a, maxa);
    mina = min(a, mina);

    a = texture(TEXTURE, UV + vec2(0.0, outline_width) * ps).a;
    maxa = max(a, maxa);
    mina = min(a, mina);

    a = texture(TEXTURE, UV + vec2(-outline_width, 0.0) * ps).a;
    maxa = max(a, maxa);
    mina = min(a, mina);

    a = texture(TEXTURE, UV + vec2(outline_width, 0.0) * ps).a;
    maxa = max(a, maxa);
    mina = min(a, mina);
	
    COLOR = mix(col, outline_color, maxa - mina);
}