shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_size = 1.5;

uniform bool enable_glow = true;
uniform vec4 glow_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform float glow_strength = 0.7;
uniform float glow_pulse_speed = 2.0;

uniform float alpha_threshold = 0.05;

void fragment() {
    vec4 base_tex = texture(TEXTURE, UV);

    bool draw_outline = false;
    bool draw_glow = false;

    // ---------- OUTLINE ----------
    if (base_tex.a <= alpha_threshold) {
        for (int dx = -1; dx <= 1; dx++) {
            for (int dy = -1; dy <= 1; dy++) {
                vec2 offset_uv = vec2(float(dx), float(dy)) * outline_size * TEXTURE_PIXEL_SIZE;
                vec4 sample = texture(TEXTURE, UV + offset_uv);
                if (sample.a > alpha_threshold) {
                    draw_outline = true;
                }
            }
        }
    }

    // ---------- GLOW + PULSE ----------
    if (enable_glow) {
        float pulse = 0.5 + 0.5 * sin(TIME * glow_pulse_speed);
        float glow = pulse * glow_strength;

        if (base_tex.a > alpha_threshold) {
            draw_glow = true;
            base_tex.rgb = mix(base_tex.rgb, glow_color.rgb, glow);
        }
    }

    // ---------- FINAL ----------
    if (draw_outline) {
        COLOR = outline_color;
    }
    else if (draw_glow) {
        COLOR = base_tex;
    }
    else {
        COLOR = base_tex;
    }
}
