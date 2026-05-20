shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float dithering = 0.05;
uniform bool color_lcd = false;
uniform vec4 monochrome_light : source_color = vec4(0.537, 0.627, 0.347, 1.0);
uniform vec4 monochrome_dark : source_color = vec4(0.196, 0.227, 0.145, 1.0);
uniform int steps : hint_range(2, 255) = 4;

float random(vec2 seed) {
    return fract(543.2543 * sin(dot(seed, vec2(3525.46, -54.3415))));
}

void fragment() {
    vec4 pixel_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    float rand = random(SCREEN_UV);
    float steps_floated = float(steps);

    float dither_rand = rand * dithering - (dithering * 0.5);
    pixel_color = clamp(pixel_color + vec4(dither_rand, dither_rand, dither_rand, 0.0), vec4(0.0), vec4(1.0));

    float monochrome = pixel_color.r * 0.2126 + pixel_color.g * 0.7152 + pixel_color.b * 0.0722;
    pixel_color = mix(
        mix(monochrome_dark, monochrome_light, floor(monochrome * steps_floated) / steps_floated),
        floor(pixel_color * steps_floated) / steps_floated,
        float(color_lcd)
    );

    COLOR = pixel_color;
}