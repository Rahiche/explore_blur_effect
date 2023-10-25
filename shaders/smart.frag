#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;

out vec4 FragColor;

const int BLUR_SIZE = 4;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    vec4 color = texture(uTexture, uv);
    for (int i = -BLUR_SIZE; i <= BLUR_SIZE; i++) {
        for (int j = -BLUR_SIZE; j <= BLUR_SIZE; j++) {
            vec2 offset = vec2(i, j) / uViewSize;
            color += texture(uTexture, uv + offset);
        }
    }
    color /= (2.0 * BLUR_SIZE + 1.0) * (2.0 * BLUR_SIZE + 1.0);

    FragColor = color;
}
