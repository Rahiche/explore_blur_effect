#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;
const float uRadius = 0.2; // Radius of the circle
const float uBlurAmount = 0.007; // Amount of blur (typically a small value like 0.005)

out vec4 FragColor;

vec4 blur(sampler2D image, vec2 uv, float amount) {
    vec4 color = vec4(0.0);
    for (float x = -1.0; x <= 1.0; x += 1.0) {
        for (float y = -1.0; y <= 1.0; y += 1.0) {
            vec2 step = vec2(x, y) * amount;
            color += texture(image, uv + step);
        }
    }
    return color / 9.0; // Since there are 9 samples in this box blur
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    float dist = length(uv - vec2(0.5, 0.5)); // Distance from the center
    if (dist < uRadius) {
        FragColor = blur(uTexture, uv, uBlurAmount);
    } else {
        FragColor = texture(uTexture, uv);
    }
}
