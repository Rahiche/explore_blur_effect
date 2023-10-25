#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;

const vec2 uMouse = vec2(0.5, 0.5);  // Assuming you still need the mouse coordinates

const int nsamples = 10;

out vec4 FragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    vec2 center = uMouse / uViewSize;
    float blurStart = 1.0;
    float blurWidth = 0.1;

    uv -= center;
    float precompute = blurWidth * (1.0 / float(nsamples - 1));

    vec4 color = vec4(0.0);
    for(int i = 0; i < nsamples; i++) {
        float scale = blurStart + (float(i) * precompute);
        color += texture(uTexture, uv * scale + center);
    }

    color /= float(nsamples);

    FragColor = color;
}
