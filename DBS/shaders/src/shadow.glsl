#include "distort.glsl"

vec3 getShadowSpacePos(in vec2 coord, in vec4 feetPos) {
    vec4 positionShadowSpace = shadowModelView * feetPos;
    positionShadowSpace = shadowProjection * positionShadowSpace;
    positionShadowSpace /= positionShadowSpace.w;

    return distort(positionShadowSpace.xyz) * 0.5 + 0.5;
}

mat2 getRotationMatrix(in vec2 coord) {
    float rotationAmmount = texture2D(noisetex, coord * vec2(viewWidth / noiseTextureResolution, viewHeight / noiseTextureResolution)).r;

    return mat2(cos(rotationAmmount), -sin(rotationAmmount), sin(rotationAmmount), cos(rotationAmmount));
}

vec3 getShadowColor(in vec2 coord, in vec4 feetPos) {
    vec3 shadowCoord = getShadowSpacePos(coord, feetPos);

    mat2 rotationMatrix = getRotationMatrix(coord);
    
    vec3 shadowColor = vec3(0.0);
    for(int y = -2; y < 2; y++) {
        for(int x = -2; x < 2; x++) {
            vec2 offset = vec2(x, y) / shadowMapResolution;
            offset = rotationMatrix * offset;

            float shadowDepth = step(shadowCoord.z - (texture2D(shadow, shadowCoord.st + offset).r), 0.0001);
            float shadowTranslucent = step(shadowCoord.z - (texture2D(shadowtex1, shadowCoord.st + offset).r), 0.0001);

            vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb;
            shadowColor += mix(vec3(shadowDepth), colorSample, float(shadowDepth < shadowTranslucent));
        }
    }

    return shadowColor / ((-2 * -2) * (2 * 2));
}

vec3 getHardShadow(in vec3 position) {
    position = distort(position);

    vec3 shadows = vec3(0.0);
    float shadowDepth = texture2D(shadowtex0, position.xy * 0.5 + 0.5).r * 2.0 - 1.0;
    shadowDepth = step(position.z - 0.0001, shadowDepth);
    float shadowTranslucent = texture2D(shadowtex1, position.xy * 0.5 + 0.5).r * 2.0 - 1.0;
    shadowTranslucent = step(position.z - 0.0001, shadowTranslucent);
    vec4 shadowColor = texture2D(shadowcolor0, position.xy * 0.5 + 0.5);

    shadows += mix(vec3(shadowDepth), shadowColor.rgb, float(shadowDepth < shadowTranslucent));

    return shadows;
}