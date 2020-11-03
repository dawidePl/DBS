#include "densityAtPoint.glsl"

// robobo1221s bayer functions from shader toy for test

float bayer2(vec2 a){
    a = floor(a);
    return fract(dot(a, vec2(0.5, a.y * 0.75)));
}

#define bayer4(a)   (bayer2(0.5 * (a)) * 0.25 + bayer2(a))
#define bayer8(a)   (bayer4(0.5* (a)) * 0.25 + bayer2(a))
#define bayer16(a)  (bayer8(0.5 * (a)) * 0.25 + bayer2(a))
#define bayer32(a)  (bayer16(0.5 * (a)) * 0.25 + bayer2(a))
#define bayer64(a)  (bayer32(0.5 * (a)) * 0.25 + bayer2(a))
#define bayer128(a) (bayer64(0.5 * (a)) * 0.25 + bayer2(a))

vec3 getFog(in vec3 color, in vec3 start, in vec3 end, in float densityMultiplier, in bool castShadow) {
    const int steps = 64;
    float dither = bayer128(gl_FragCoord.xy);
    
    mat2x3 scatteringCoeff = mat2x3(vec3(5.8e-6, 13.3e-6, 33.1e-6), vec3(21e-6));
    mat3x3 extinctionCoeff = mat3x3(vec3(5.8e-6, 13.3e-6, 33.1e-6), vec3(21e-6), vec3(3.26033e-21f, 3.21736e-21, 2.97488e-22) * 4e14);

    vec3 endScene = mat3(gbufferModelViewInverse) * end + gbufferModelViewInverse[3].xyz;
    vec3 startScene = mat3(gbufferModelViewInverse) * start + gbufferModelViewInverse[3].xyz;
    vec3 increment = (endScene - startScene) / steps;
    vec3 scenePosition = startScene + increment * dither;

    float stepSize = length(increment);

    vec3 shadowIncrement = mat3(shadowModelView) * increment;
         shadowIncrement *= vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z);
    vec3 shadowPosition = mat3(shadowModelView) * startScene + shadowModelView[3].xyz;
         shadowPosition = mat3(shadowProjection) * shadowPosition + shadowProjection[3].xyz;
         shadowPosition += shadowIncrement * dither;
    
    vec2 phase = phaseCombined(dot(normalize(endScene), mat3(gbufferModelViewInverse) * normalize(shadowLightPosition)), 0.75);
         phase += vec2(0.0, 0.25);

    vec3 scattering = vec3(0.0);
    vec3 transmittance = vec3(1.0);
    vec3 opticalDepth = vec3(0.0);

    for(int i = 0; i < steps; i++, scenePosition += increment, shadowPosition += shadowIncrement) {
        vec3 shadows = getHardShadow(shadowPosition);
        vec3 density = vec3(exp(-densityAtPos(scenePosition - 62.0))) * densityMultiplier;

        vec3 airmass = density * stepSize;

        vec3 stepOpticalDepth = extinctionCoeff * airmass;

        vec3 stepTransmittance = clamp(exp(-stepOpticalDepth), 0.0, 1.0);
        vec3 stepTransmittanceFraction = clamp((stepTransmittance - 1.0) / -stepOpticalDepth, 0.0, 1.0);
        vec3 visibleScattering = transmittance * stepTransmittanceFraction;

        if(castShadow) {
            scattering += ((scatteringCoeff * (airmass.xy * phase)) * visibleScattering) * shadows;
        }else {
            scattering += ((scatteringCoeff * (airmass.xy * phase)) * visibleScattering);
        }

        transmittance *= stepTransmittance;
        opticalDepth += stepOpticalDepth;
    }

    scattering *= fogColor;

    return color * transmittance + scattering * (1.1 - rainStrength);
}