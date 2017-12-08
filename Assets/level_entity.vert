#version 420

#ifdef GL_ES
    precision mediump float;
#endif


attribute vec4 aPosition;
attribute vec4 aNormal;

varying float vTileInfo;
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
    vTileInfo = aPosition.w;
	vBrightness = 1.0;
	
	mat4 normalMatrix = transpose(inverse(uModelView));
	vec3 transformedNormal = normalize(normalMatrix * normalize(aNormal)).xyz;
	vBrightness = max(dot(transformedNormal, normalize(vec3(0,1,0))), 0.1);
	
    gl_Position = uMvp * vec4(aPosition.xyz, 1.0);



}