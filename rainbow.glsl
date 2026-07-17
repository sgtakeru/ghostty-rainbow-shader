// Animated rainbow shader for Ghostty.
//
// Detect glyphs from local contrast so flat backgrounds keep their colors.
const float SPEED = 0.3;
const float SPATIAL_SCALE = 360.0;
const float COLOR_STRENGTH = 0.72;
const float SAMPLE_RADIUS = 1.5;
const float CONTRAST_LOW = 0.035;
const float CONTRAST_HIGH = 0.14;

float luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

vec3 rainbowColor(float hue) {
    return 0.5 + 0.5 * cos(
        6.2831853 * (hue + vec3(0.0, 0.667, 0.333))
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 offset = SAMPLE_RADIUS / iResolution.xy;
    vec4 source = texture(iChannel0, uv);

    // Flat backgrounds have little local contrast. Glyphs and their
    // antialiased edges have enough contrast to pass this mask.
    float contrast = 0.0;
    contrast = max(contrast, length(source.rgb - texture(iChannel0, uv + vec2( offset.x, 0.0)).rgb));
    contrast = max(contrast, length(source.rgb - texture(iChannel0, uv + vec2(-offset.x, 0.0)).rgb));
    contrast = max(contrast, length(source.rgb - texture(iChannel0, uv + vec2(0.0,  offset.y)).rgb));
    contrast = max(contrast, length(source.rgb - texture(iChannel0, uv + vec2(0.0, -offset.y)).rgb));
    contrast = max(contrast, length(source.rgb - texture(iChannel0, uv + offset).rgb));
    contrast = max(contrast, length(source.rgb - texture(iChannel0, uv - offset).rgb));

    float mask = smoothstep(CONTRAST_LOW, CONTRAST_HIGH, contrast);
    float hue = fract(
        (fragCoord.x + fragCoord.y * 0.55) / SPATIAL_SCALE
        + iTime * SPEED
    );
    vec3 rainbow = rainbowColor(hue);

    // Preserve source luminance to avoid bright halos around antialiased text.
    float sourceLuminance = luminance(source.rgb);
    float rainbowLuminance = luminance(rainbow);
    vec3 colored = vec3(sourceLuminance)
        + COLOR_STRENGTH * (rainbow - vec3(rainbowLuminance));

    fragColor = vec4(
        mix(source.rgb, clamp(colored, 0.0, 1.0), mask),
        source.a
    );
}
