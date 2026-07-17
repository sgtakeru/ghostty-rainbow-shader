// Animated rainbow shader for Ghostty.
//
// Adjust these values to change the effect.
const float SPEED = 0.20;
const float FREQUENCY = 1.40;
const float SATURATION = 0.90;
const float STRENGTH = 1.00;

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
    return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 source = texture(iChannel0, uv);

    // Move diagonally so adjacent rows do not share exactly the same hue.
    float hue = fract(
        uv.x * FREQUENCY
        + uv.y * FREQUENCY * 0.35
        - iTime * SPEED
    );
    vec3 rainbow = hsv2rgb(vec3(hue, SATURATION, 1.0));

    // Preserve the source luminance and alpha. Dark backgrounds remain dark,
    // while bright glyphs receive the strongest rainbow color.
    float luminance = dot(source.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 tinted = rainbow * luminance;
    vec3 color = mix(source.rgb, tinted, STRENGTH);

    fragColor = vec4(color, source.a);
}
