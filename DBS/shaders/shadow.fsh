#version 120

varying float transparent;
varying vec2 texcoord;
varying vec4 glColor;

uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, texcoord) * glColor;

    color.rgb = mix(vec3(0.0), color.rgb, transparent);

    gl_FragData[0] = color;
}