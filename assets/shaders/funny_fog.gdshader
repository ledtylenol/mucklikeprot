
// NOTE: Shader automatically converted from Godot Engine 4.2.2.stable's FogMaterial.

shader_type fog;

uniform float density : hint_range(0, 1, 0.0001) = 1.0;
uniform vec4 albedo : source_color = vec4(1.0);
uniform vec4 emission : source_color = vec4(0, 0, 0, 1);
uniform float height_falloff = 0.0;
uniform float edge_fade = 0.1;
uniform float period = 1.0;
uniform sampler3D density_texture: hint_default_white;
uniform float time = 0.0;
float triangle_wave(float t, float T) {
    float phase = mod(t, T) / T; // Normalized phase within the period [0, 1)
    if (phase < 0.5) {
        return 4.0 * phase - 1.0; // Rising edge
    } else {
        return 3.0 - 4.0 * phase; // Falling edge
    }
}
void fog() {
	vec4 alb = albedo;
    DENSITY = density * clamp(exp2(-height_falloff * (WORLD_POSITION.y - OBJECT_POSITION.y)), 0.0, 1.0);
    DENSITY *= texture(density_texture, UVW).r;
    DENSITY *= pow(clamp(-2.0 * SDF / min(min(SIZE.x, SIZE.y), SIZE.z), 0.0, 1.0), edge_fade);
	vec3 local_pos = WORLD_POSITION - OBJECT_POSITION;
	alb.r = triangle_wave(1.1*TIME + 0.3, period) * (local_pos.y * local_pos.y);
	alb.g = triangle_wave(1.3*TIME + 0.7, period) * local_pos.x * local_pos.x;
	alb.b = triangle_wave(1.8*TIME + 1.2, period) * (local_pos.x *0.5 + local_pos.y * 0.5);
	alb.a = length(local_pos);
	ALBEDO = alb.rgb;
    EMISSION = alb.gbr;
	DENSITY *= pow(2.0, (0.3 * alb.r + 0.6 * alb.g + 0.1 * alb.b * SDF));
	DENSITY *= sin(time*2.);
}
