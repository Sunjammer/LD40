#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;
uniform sampler2D uImage1;  
uniform sampler2D uImage2;
uniform sampler2D uImage3;
uniform sampler2D uImage4;
uniform float uTime;

const float BARREL_DISTORTION = 0.1;
const float rescale = 1.0 - (0.25 * BARREL_DISTORTION);

vec4 shape(vec4 v, vec4 drive){
	vec4 k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

vec3 shape(vec3 v, vec3 drive){
	vec3 k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

vec4 chroma(sampler2D src, float offset, float amount, vec2 texelSize, vec2 uv, vec2 power){
    float y = uv.y;
    float x = uv.x;
    float value = 0.0;
   
    float mid = 1.0 - offset;
    if(uv.y>=mid)
    	value = 1.0 - log(cos((y - mid + 0.5 - 1.0) * 3.14) * x * power.x); //top
    else if(uv.y<mid)
    	value = 1.0 - log(cos((y - mid + 0.5) * 3.14) * x * power.y); //bot
        
    float intensity = max(0.0, value) * amount;
    vec2 dispUv = vec2(intensity*0.005, 0.0);

    float rValue = texture2D(src, uv + dispUv + texelSize * vec2(intensity, 0)).r;
    float gValue = texture2D(src, uv + dispUv + texelSize * vec2(-intensity, intensity)).g;
    float bValue = texture2D(src, uv + dispUv + texelSize * vec2(0,   -intensity)).b; 
   
    return vec4(rValue, gValue, bValue, 1.0);
}

float unipolarSin(float t){
    return (sin(t)+1.0)*0.5;
}

float vignette(vec2 uv){
    uv *=  1.0 - uv.yx;
    float vig = uv.x*uv.y * 15.0;
    return pow(vig, 0.2);
}

void main() {
	//Barrel distortion
    vec2 uv = vTexCoord - .5;
    float rsq = dot(uv,uv);
    uv += (uv * (BARREL_DISTORTION * rsq));
    uv *= rescale;

    if (abs(uv.x) > 0.5 || abs(uv.y) > 0.5)
        discard;
	
    vec2 correctedUv = uv+0.5;

    vec4 color = chroma(uImage0, 0, 2.0, 1.0/uResolution.xy, correctedUv, vec2(20, 500.0));

    float strength = 30.0;
    float foo = (uv.x + 4.0 ) * (uv.y + 4.0 ) * (uTime * 10.0);
    vec4 grain = vec4(mod((mod(foo, 13.0) + 1.0) * (mod(foo, 123.0) + 1.0), 0.01)-0.005) * strength;
    grain = 1.0 - grain;
	color = 1.4 * grain * texture2D(uImage1, correctedUv / 4.) * color; //noise * color
    color = color * vignette(correctedUv);
    //color.rgb = color.r * vec3(1.0, 253.0/255.0, 84.0/255.0);
    color = color + texture2D(uImage2, correctedUv) * 0.01; //dirt
    
	gl_FragColor = vec4(color.rgb, 1.0);
}