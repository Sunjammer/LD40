#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying float vZoffset;
varying float vTileInfo;
varying vec4 vOffset;
varying vec2 vUv;
varying vec2 vQuantizedUv;
varying vec3 vNormal;
varying vec4 vVertex;
varying float vBrightness;

uniform float uTime;
uniform vec4 uResolution;
uniform mat3 uNormal;
uniform mat4 uModel;

uniform sampler2D uColorTex;
uniform sampler2D uFowTex;

vec3 shape(vec3 v, vec3 drive){
	vec3 k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

void main(void){
	vec3 texColor = texture2D(uColorTex, vQuantizedUv).rgb;
	vec4 fowColor = texture2D(uFowTex, vQuantizedUv);
	vec3 color = texColor * vBrightness;// * (fowColor.r*0.8+0.2);
    gl_FragColor = vec4(color, 1.0);

}