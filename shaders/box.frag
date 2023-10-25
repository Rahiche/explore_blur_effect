#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;

out vec4 FragColor;

const int BLUR_SIZE = 3; // You can adjust this value for a larger or smaller blur

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    vec4 color = vec4(0.0);
    for (int y = -BLUR_SIZE; y <= BLUR_SIZE; y++) {
        for (int x = -BLUR_SIZE; x <= BLUR_SIZE; x++) {
            vec2 offset = vec2(x, y) / uViewSize;
            color += texture(uTexture, uv + offset);
        }
    }

    FragColor = color / pow(float(BLUR_SIZE * 2 + 1), 2.0);  // Dividing by the total number of samples
}
