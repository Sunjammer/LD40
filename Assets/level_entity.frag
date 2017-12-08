#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying float vTileInfo;
varying vec2 vUv;
varying float vBrightness;
uniform vec4 uResolution;
uniform float uTime;

varying vec3 N;
varying vec3 v;

vec3 shape(vec3 v, vec3 drive){
	vec3 k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

void main(void){
    gl_FragColor = vec4(vec3(vBrightness), 1.0);


}