// Credit kusma

uniform vec2 uResolution;
varying vec2 vTexCoord;
uniform float uTime;
uniform sampler2D uImage0;
uniform sampler2D uImage1;
uniform vec2 uAmount;

void main()
{
	if(length(uAmount)==0.0){
		gl_FragColor = texture2D(uImage0, vTexCoord);
		return;
	}

	vec4 fragColor;
	vec2 uv = gl_FragCoord.xy / uResolution.xy;
	vec2 block = floor(gl_FragCoord.xy / vec2(16));
	vec2 uv_noise = block / vec2(64);
	uv_noise += floor(vec2(uTime) * vec2(1234.0, 3543.0)) / vec2(64);
	
	float block_thresh = uAmount.x * pow(fract(uTime * 1236.0453), 2.0) * 0.2;
	float line_thresh = uAmount.y * pow(fract(uTime * 2236.0453), 3.0) * 0.7;
	
	vec2 uv_r = uv, uv_g = uv, uv_b = uv;

	// glitch some blocks and lines
	if (texture2D(uImage1, uv_noise).r < block_thresh ||
		texture2D(uImage1, vec2(uv_noise.y, 0.0)).g < line_thresh) {

		vec2 dist = (fract(uv_noise) - 0.5) * 0.3;
		uv_r += dist * 0.1;
		uv_g += dist * 0.2;
		uv_b += dist * 0.125;
	}

	fragColor.r = texture2D(uImage0, uv_r).r;
	fragColor.g = texture2D(uImage0, uv_g).g;
	fragColor.b = texture2D(uImage0, uv_b).b;

	// loose luma for some blocks
	if (texture2D(uImage1, uv_noise).g < block_thresh)
		fragColor.rgb = fragColor.ggg;

	// discolor block lines
	if (texture2D(uImage1, vec2(uv_noise.y, 0.0)).b * 3.5 < line_thresh)
		fragColor.rgb = vec3(0.0, dot(fragColor.rgb, vec3(1.0)), 0.0);

	// interleave lines in some blocks
	if (texture2D(uImage1, uv_noise).g * 1.5 < block_thresh ||
		texture2D(uImage1, vec2(uv_noise.y, 0.0)).g * 2.5 < line_thresh) {
		float line = fract(gl_FragCoord.y / 3.0);
		vec3 mask = vec3(3.0, 0.0, 0.0);
		if (line > 0.333)
			mask = vec3(0.0, 3.0, 0.0);
		if (line > 0.666)
			mask = vec3(0.0, 0.0, 3.0);
		
		fragColor.xyz *= mask;
	}

	gl_FragColor = fragColor;
}