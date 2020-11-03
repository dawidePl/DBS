#version 120

// composite1 - clouds

varying vec2 texcoord;

/*
colortex0 - albedo
colortex1 - lmcoord
colortex2 - normal
*/

uniform float frameTimeCounter;

uniform vec3 fogColor;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform sampler2D depthtex0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "src/settings.glsl"

#ifdef RENDER_CLOUDS
    //noise function from iq: https://www.shadertoy.com/view/Msf3WH
    vec2 hash(vec2 p)  
    {
        p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
        return -1.0 + 2.0*fract(sin(p)*43758.5453123);
    }

    float noise(in vec2 p)
    {
        const float K1 = 0.366025404; // (sqrt(3)-1)/2;
        const float K2 = 0.211324865; // (3-sqrt(3))/6;

        vec2  i = floor( p + (p.x+p.y)*K1 );
        vec2  a = p - i + (i.x+i.y)*K2;
        float m = step(a.y,a.x); 
        vec2  o = vec2(m,1.0-m);
        vec2  b = a - o + K2;
        vec2  c = a - 1.0 + 2.0*K2;
        vec3  h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
        vec3  n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
        return dot( n, vec3(70.0) );
    }

    const mat2 m2 = mat2(1.6,  1.2, -1.2,  1.6);

    float fbm4(vec2 p) {
        float amp = 0.5;
        float h = 0.0;
        for (int i = 0; i < 4; i++) {
            float n = noise(p);
            h += amp * n;
            amp *= 0.5;
            p = m2 * p ;
        }
        
        return  0.5 + 0.5*h;
    }
#endif

#include "src/getPos.glsl"

void main() {
    float depth = texture2D(depthtex0, texcoord).x;
    vec2 lmcoord = texture2D(colortex1, texcoord).xy;
    vec3 normal = texture2D(colortex2, texcoord).xyz;
         normal *= 2.0 + 1.0;
    vec4 albedo = texture2D(colortex0, texcoord);

    #ifdef RENDER_CLOUDS
        if(depth == 1.0) {
            vec2 pos = eyePlayerPos.xz / eyePlayerPos.y;

            if(pos != vec2(0.0)) {
                vec2 turbulence = 0.008 * vec2(noise(vec2(pos.x * 10.0, pos.y * 10.0)), noise(vec2(pos.x * 10.0, pos.y * 10.0)));
                vec2 scale = pos * 2.0;
                    scale += turbulence;

                float n1 = fbm4(vec2(scale.x - 20.0 * sin(frameTimeCounter * 0.001 * 2.0), scale.y - 50.0 * sin(frameTimeCounter * 0.001)));

                // albedo.rgb = mix(albedo.rgb, vec3(1.0), smoothstep(0.5, 0.8, n1));

                // layer 2
                turbulence = 0.05 * vec2(noise(vec2(pos.x * 2.0, pos.y * 2.1)), noise(vec2(pos.x * 1.5, pos.y * 1.2)));
                scale = pos * 0.5;
                scale += turbulence;

                float n2 = fbm4(scale + 20.0 * sin(frameTimeCounter * 0.001));

                albedo.rgb = mix(albedo.rgb, fogColor, smoothstep(0.2, 0.9, n2));
                albedo.rgb = min(albedo.rgb, vec3(1.0));
            }
        }
    #endif

    /*DRAWBUFFERS:012*/
    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(lmcoord, 0.0, 1.0);
    gl_FragData[2] = vec4(normal * 0.5 + 0.5, 1.0);
}