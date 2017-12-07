#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;
uniform sampler2D uImage1;
uniform sampler2D uImage2;
uniform float uTime;

const float BARREL_DISTORTION = 0.1;
const float rescale = 1.0 - (0.25 * BARREL_DISTORTION);

vec3 shape(vec3 v, vec3 drive){
	vec3 k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

void main() {
	//Barrel distortion
    vec2 uv = vTexCoord - .5;
    float rsq = dot(uv,uv);
    uv += (uv * (BARREL_DISTORTION * rsq));
    uv *= rescale;
	//End barrel nonsense

    if (abs(uv.x) > 0.5 || abs(uv.y) > 0.5) {
        //gl_FragColor = vec4(0,0,0,1);
        discard;
    }
	
    vec4 color = texture2D(uImage0, uv+0.5);

	float intensity = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;

    float strength = 30.0;
    float foo = (uv.x + 4.0 ) * (uv.y + 4.0 ) * (uTime * 10.0);
    vec4 grain = vec4(mod((mod(foo, 13.0) + 1.0) * (mod(foo, 123.0) + 1.0), 0.01)-0.005) * strength;
    grain = 1.0 - grain;
	
	color = 1.4 * grain * texture2D(uImage1, vTexCoord / 4.) * intensity + texture2D(uImage2, uv) * 0.2;
    
	gl_FragColor = vec4(color.rgb, 1.0);
}