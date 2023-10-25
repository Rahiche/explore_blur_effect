#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;

out vec4 FragColor;

void main() {
    float Pi = 6.28318530718; // Pi*2

    // GAUSSIAN BLUR SETTINGS
    float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
    float Quality = 20.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
    float Size = 8.0; // BLUR SIZE (Radius)

    vec2 Radius = Size/uViewSize;

    // Get the fragCoord from Flutter function
    vec2 fragCoord = FlutterFragCoord().xy;

    // Normalized pixel coordinates
    vec2 uv = fragCoord / uViewSize;

    // Pixel colour
    vec4 Color = texture(uTexture, uv);

    // Blur calculations
    for(float d = 0.0; d < Pi; d += Pi/Directions) {
        for(float i = 1.0/Quality; i <= 1.0; i += 1.0/Quality) {
            Color += texture(uTexture, uv + vec2(cos(d), sin(d)) * Radius * i);
        }
    }

    // Finalize the color
    Color /= Quality * Directions - 15.0;

    FragColor =  Color;
}
