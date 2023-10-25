#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform float sigma;
uniform sampler2D uTexture;

out vec4 FragColor;

float normpdf(in float x, in float sigma)
{
    return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;

    vec4 color = vec4(texture(uTexture, uv).rgb, 1.0);

    if(fragCoord.y < uViewSize.y * 0.2) { // Compute the effect for the top 30% of the image.
        // How much the shift is visible.
        const float shiftPower = 4.0;

        //declare stuff
        //The bigger the value the slower the effect
        const int mSize = 35;
        const int kSize = (mSize-1)/2;
        float kernel[mSize];
        vec3 final_colour = vec3(0.0);

        //create the 1-D kernel
        float Z = 0.00;
        for (int j = 0; j <= kSize; ++j)
        kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma );

        //get the normalization factor (as the gaussian has been clamped)
        for (int j = 0; j < mSize; ++j)
        Z += kernel[j];

        //read out the texels
        for (int i=-kSize; i <= kSize; ++i)
        {
            for (int j=-kSize; j <= kSize; ++j)
            final_colour += kernel[kSize+j]*kernel[kSize+i]*texture(uTexture, (fragCoord.xy+vec2(float(i),float(j))) / uViewSize).rgb;
        }

        // Blend factor for the effect
        float val = clamp(shiftPower * abs(uViewSize.y * 0.2 - fragCoord.y) / (uViewSize.y * 0.3), 0.0, 1.0);
        FragColor = vec4(final_colour/(Z*Z), 1.0) * val + color * (1.0 - val);
    } else {
        FragColor = color;
    }
}
