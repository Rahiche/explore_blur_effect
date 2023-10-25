#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;

out vec4 FragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    float focusZone = 0.5; // Width of the in-focus zone in the center
    float blurStrength = 7.0; // Increase for more blur

    float blurAmount = abs(uv.y - 0.5) - focusZone / 2.0;
    blurAmount = clamp(blurAmount, 0.0, 1.0) * blurStrength;

    vec4 color = vec4(0.0);
    for (int i = -4; i <= 4; ++i) {
        for (int j = -4; j <= 4; ++j) {
            vec2 offset = vec2(float(i), float(j)) / uViewSize * blurAmount;
            color += texture(uTexture, uv + offset);
        }
    }
    color /= 81.0;// Normalize by the number of samples (9x9 grid)
    FragColor = color;
}
