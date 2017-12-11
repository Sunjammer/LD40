#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying float vZoffset;
varying vec4 vOffset;
varying float vTileInfo;
varying vec2 vUv;
varying vec2 vQuantizedUv;
varying vec3 vNormal;
varying float vBrightness;
uniform vec4 uResolution;
uniform float uTime;
uniform mat3 uNormal;

uniform sampler2D uColorTex;

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
	vec3 color = vBrightness * smoothstep(vec3(1.0), texColor, vec3(vZoffset));
    gl_FragColor = vec4(color,1);

}