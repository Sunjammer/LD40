#version 120

#ifdef GL_ES
    precision mediump float;
#endif


attribute vec4 aPosition;
attribute vec4 aNormal;
attribute vec4 aOffset;

varying vec2 vUv;
varying vec2 vQuantizedUv;
varying float vBrightness;
varying float vZoffset;
varying vec4 vOffset;

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
	vNormal = aNormal.xyz;
	vOffset = aOffset;

	vec3 transformedNormal = normalize(uNormal * vNormal);

	vec3 pos = aPosition.xyz + aOffset.xyz;
	pos.z += aOffset.w;
	vQuantizedUv = aOffset.xy / uResolution.zw;
	vUv = pos.xy / uResolution.zw;

	vec2 pulsePos = vec2(0.5);
	float t = length(vQuantizedUv - pulsePos)*3.14;
	vZoffset = pow(cos(-1.0 * uTime+t) * 0.5 + 0.5, 200);
	pos.z = pos.z - vZoffset;

	float t2 = length(vUv - pulsePos)*3.14;
	vBrightness = max(dot(transformedNormal, normalize(vec3(0.5,0.5,0.5))), 0.1);

    gl_Position = uMvp * vec4(pos, 1.0);



}