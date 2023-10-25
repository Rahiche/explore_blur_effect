#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform float uTime;
uniform sampler2D uTexture;

// Added uniforms
const float uDeformStrength = 0.0;
const float uRadiusEffect = 0.0;
const int uIterationCount = 1;

out vec4 FragColor;

vec3 deform( in vec2 p, in float t )
{
    t *= 1.0;

    p += uDeformStrength*sin( t*vec2(1.1,1.3)+vec2(0.0,0.5) );

    float a = atan( p.y, p.x );
    float r = length( p );

    float s = r * (1.0 + uRadiusEffect*cos(t*1.7));

    vec2 uv = 0.1*t + 0.05*p.yx + 0.05*vec2( cos(t+a*2.0),
    sin(t+a*2.0))/s;

    return texture( uTexture, 0.5*uv ).xyz;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;
    vec2 p = -1.0 + 2.0*uv;

    vec3 col = vec3(0.0);
    for( int i=0; i<uIterationCount; i++ )
    {
        float t = uTime + float(i)*0.0035;
        col += deform( p, t );
    }
    col /= float(uIterationCount);

    col = pow( col, vec3(0.6,0.7,0.8) );

    FragColor = vec4( col, 1.0 );
}
