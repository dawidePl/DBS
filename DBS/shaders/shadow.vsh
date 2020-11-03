#version 120

#include "src/distort.glsl"

varying float transparent;
varying vec2 texcoord;
varying vec4 glColor;

attribute vec4 mc_Entity;

float transparency(in float matID) {
    if(matID == 160) return 1.0;
    if(matID == 95) return 1.0;
    if(matID == 30) return 1.0;

    return 0.0;
}

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glColor = gl_Color;
    transparent = transparency(mc_Entity.x);

    gl_Position = ftransform();
    gl_Position.xyz = distort(gl_Position.xyz);
}