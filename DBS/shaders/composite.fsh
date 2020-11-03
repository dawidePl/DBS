#version 120

// Composite - terrain lightning

varying vec2 texcoord;

/*
colortex0 - albedo
colortex1 - lmcoord
colortex2 - normal
*/

const int shadowMapResolution = 2048;
const int noiseTextureResolution = 64;
const float sunPathRotation = -40;

uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;

uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform sampler2D depthtex0;

uniform sampler2D noisetex;
uniform sampler2D shadow;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "src/shadow.glsl"
#include "src/phase.glsl"
#include "src/volumetricFog.glsl"

float lmcurve(in float lmcoord) {
    return 1.0 - abs(lmcoord - 1.5);
}

vec3 calculateColor(in vec4 feetPos, in vec2 coord, in vec3 albedo, in vec3 normal, in vec2 lmcoord) {
    float NdotL = dot(normal, mat3(gbufferModelViewInverse) * normalize(shadowLightPosition));
    vec3 SLV = getShadowColor(coord, feetPos);
    vec3 directSunLight = vec3(1.0, 0.95, 0.95) * fogColor;
    vec3 labertDiffuse = albedo.rgb * max(0.0, NdotL) / 3.141592;
    vec3 torchColor = vec3(1.0);

    vec2 lightmap = clamp(lmcoord, vec2(0.0), vec2(1.0));
         lightmap.x = lmcurve(lightmap.x);
         lightmap.x = clamp(lightmap.x, 0.03, 1.0);

    vec3 color = directSunLight * labertDiffuse * SLV;
         color = skyColor * albedo.rgb * lightmap.y + color * (1.0 - rainStrength);
         color = torchColor * albedo.rgb * lightmap.x + color;

    return color;
}

void main() {
    vec2 lmcoord = texture2D(colortex1, texcoord).xy;
    vec3 normal = texture2D(colortex2, texcoord).xyz;
         normal *= 2.0 + 1.0;
    vec4 albedo = texture2D(colortex0, texcoord);

    vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec3 viewPos = tmp.xyz / tmp.w;
    vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
    vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
    
    if(texture2D(depthtex0, texcoord).x < 1.0) {
        albedo.rgb = calculateColor(vec4(feetPlayerPos, 1.0), texcoord, albedo.rgb, normal, lmcoord);

        albedo.rgb = getFog(albedo.rgb, vec3(0.0), viewPos);
    }

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = albedo;
}