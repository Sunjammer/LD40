#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying float vTileInfo;
varying vec2 vUv;
varying vec3 vNormal;
varying float vBrightness;
uniform vec4 uResolution;
uniform float uTime;
uniform mat3 uNormal;

vec3 shape(vec3 v, vec3 drive){
	vec3 k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

void main(void){
	
    gl_FragColor = vec4(vBrightness,vBrightness,vBrightness,1);


}