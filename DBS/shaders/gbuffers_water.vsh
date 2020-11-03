#version 120

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 glColor;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    lmcoord = clamp((lmcoord - 0.03125) * 1.06667, 0.0, 1.0);
    normal = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * gl_Normal);
    glColor = gl_Color;

    vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
    vec3 worldPos = playerPos.xyz + cameraPosition;

    // TODO: waves

    playerPos = worldPos - cameraPosition;
    viewPos = mat3(gbufferModelView) * playerPos;

    vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos, 1.0);
    vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;

    gl_Position = clipPos;
}