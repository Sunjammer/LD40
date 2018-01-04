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

varying vec4 vVertex;
varying vec3 vNormal;

uniform vec4 uResolution;
uniform mat4 uMvp;
uniform mat4 uView;
uniform mat4 uModelView;
uniform mat3 uNormal;
uniform float uTime;
uniform mat4 uModel;

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

void main(void){
	vNormal = aNormal.xyz;
	vOffset = aOffset;

	vec3 transformedNormal = normalize(uNormal * vNormal);

	vec3 tempPos = aPosition.xyz;
	if(tempPos.z < 0.0) tempPos.z = -100;

	vec3 pos = tempPos + aOffset.xyz;
	pos.z += aOffset.w;
	vQuantizedUv = aOffset.xy / uResolution.zw;
	vUv = pos.xy / uResolution.zw;

	// pulse
	vec2 pulsePos = vec2(0.5);
	float t = length(vQuantizedUv - pulsePos)*3.14;
	vZoffset = pow(cos(-1.0 * uTime * 0.2 + t) * 0.5 + 0.5, 200);
	pos.z = pos.z - vZoffset;

	vBrightness = aOffset.w; 

	vVertex = vec4(pos, 1.0);

    gl_Position = uMvp * vec4(pos, 1.0);



}