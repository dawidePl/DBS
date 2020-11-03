vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
vec3 clipPos = screenPos * 2.0 - 1.0;
vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
vec3 viewPos = tmp.xyz / tmp.w;
vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;