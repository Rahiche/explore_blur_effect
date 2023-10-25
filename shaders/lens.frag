#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform sampler2D uTexture;
const float uBlurAmount = 0.6;

out vec4 FragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    // Calculate an offset based on the blur amount. This can be adjusted to get the desired blur strength.
    float maxOffset = uBlurAmount * 5.0;

    vec4 finalColor = vec4(0.0);
    float totalWeight = 0.0;

    // Sample around the current pixel in a circular pattern
    for(float angle = 0.0; angle < 360.0; angle += 45.0) {
        float xOffset = cos(radians(angle)) * maxOffset;
        float yOffset = sin(radians(angle)) * maxOffset;
        vec4 sampleColor = texture(uTexture, uv + vec2(xOffset, yOffset) / uViewSize);

        // The weight decreases the further the sample is from the center
        float weight = 1.0 - distance(uv, uv + vec2(xOffset, yOffset) / uViewSize);

        finalColor += sampleColor * weight;
        totalWeight += weight;
    }

    FragColor = finalColor / totalWeight;
}
