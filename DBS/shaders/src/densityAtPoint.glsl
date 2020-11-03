// Credit to Chocapic13

float densityAtPos(in vec3 pos)
{
	pos /= 18.;
	pos.xz *= 0.5;
	

	vec3 p = floor(pos);
	vec3 f = fract(pos);
	
	f = (f*f) * (3.-2.*f);

	vec2 uv =  p.xz + f.xz + p.y * vec2(0.0,193.0);

	vec2 coord =  uv / 512.0;

	vec2 xy = texture2D(noisetex, coord).yx;

	return mix(xy.r,xy.g, f.y);
}