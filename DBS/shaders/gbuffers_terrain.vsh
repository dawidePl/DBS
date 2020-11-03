#version 120

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 glColor;

uniform mat4 gbufferModelViewInverse;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    lmcoord = clamp((lmcoord - 0.03125) * 1.06667, 0.0, 1.0);
    normal = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * gl_Normal);
    glColor = gl_Color;

    gl_Position = ftransform();
}