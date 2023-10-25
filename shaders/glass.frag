#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;

const int SAMPLE_COUNT = 10;
const float blurSize = 4.0;  // You can vary this to increase or decrease the blurriness.

out vec4 FragColor;

vec4 blur(vec2 uv) {
    vec4 accumulatedColor = vec4(0.0);
    for (int i = 0; i < SAMPLE_COUNT; i++) {
        float angle = 2.0 * 3.14159265359 * float(i) / float(SAMPLE_COUNT);
        vec2 offset = vec2(cos(angle), sin(angle)) * blurSize / uViewSize;
        accumulatedColor += texture(uTexture, uv + offset);
    }
    return accumulatedColor / float(SAMPLE_COUNT);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;
    FragColor = blur(uv);
}
