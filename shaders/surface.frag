#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;

// You may want to set these as uniforms for better flexibility
const float radius = 2.0;
const float threshold = 0.4;

out vec4 FragColor;

vec4 getAverageColor(vec2 uv, vec2 offset) {
    vec4 sum = vec4(0.0);
    int count = 0;

    for (float x = -radius; x <= radius; x += 1.0) {
        for (float y = -radius; y <= radius; y += 1.0) {
            vec4 texel = texture(uTexture, uv + vec2(x,y) * offset);
            sum += texel;
            count++;
        }
    }

    return sum / float(count);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    vec4 baseColor = texture(uTexture, uv);
    vec4 averageColor = getAverageColor(uv, 1.0/uViewSize);

    float diff = length(baseColor - averageColor);
    if (diff < threshold) {
        FragColor = averageColor;
    } else {
        FragColor = baseColor;
    }
}
