shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_size = 1.5;
uniform bool enable_outline = true;
uniform float alpha_threshold = 0.05;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Se outline desativado, só mostra o sprite
    if (!enable_outline) {
        COLOR = tex;
        // sem return aqui
    } else {
        bool draw_outline = false;

        // Só procurar borda se pixel atual for transparente o suficiente
        if (tex.a <= alpha_threshold) {
            // verificar vizinhos (3x3)
            for (int dx = -1; dx <= 1; dx++) {
                for (int dy = -1; dy <= 1; dy++) {
                    // deslocamento em unidades UV: outline_size pixels
                    vec2 offset_uv = vec2(float(dx), float(dy)) * outline_size * TEXTURE_PIXEL_SIZE;
                    vec4 sample = texture(TEXTURE, UV + offset_uv);
                    if (sample.a > alpha_threshold) {
                        draw_outline = true;
                    }
                }
            }
        }

        // Se precisamos desenhar o contorno, sobrescreve a cor; senão mostra o sprite normal
        if (draw_outline) {
            COLOR = outline_color;
        } else {
            COLOR = tex;
        }
    }
}
