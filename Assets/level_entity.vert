#version 120

#ifdef GL_ES
    precision mediump float;
#endif


attribute vec4 aPosition;
attribute vec4 aNormal;
attribute vec4 aOffset;

varying vec2 vUv;
varying float vBrightness;
varying float vZoffset;

varying vec3 vNormal;

uniform vec4 uResolution;
uniform mat4 uMvp;
uniform mat4 uView;
uniform mat4 uModelView;
uniform mat3 uNormal;
uniform float uTime;

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

void main(void){
	vBrightness = 1.0;
	vNormal = aNormal.xyz;
	
	vec3 transformedNormal = normalize(uNormal * aNormal.xyz);
	vBrightness = max(dot(transformedNormal, normalize(vec3(0,0.5,1))), 0.1);
	
	vec3 pos = aPosition.xyz + aOffset.xyz;

    gl_Position = uMvp * vec4(pos, 1.0);



}