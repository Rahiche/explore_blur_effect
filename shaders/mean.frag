#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;

out vec4 FragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    vec2 pixelSize = 6.0 / uViewSize;

    // Start with the color of the current pixel.
    vec4 sumColor = texture(uTexture, uv);

    // Add the color of the neighboring pixels.
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (x != 0 || y != 0) {
                sumColor += texture(uTexture, uv + vec2(x, y) * pixelSize);
            }
        }
    }

    // Take the average color by dividing by the number of pixels.
    FragColor = sumColor / 9.0;
}
