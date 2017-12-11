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
varying vec4 vVertex;
varying float vBrightness;
uniform vec4 uResolution;
uniform float uTime;
uniform mat3 uNormal;
uniform mat4 uModel;

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
	vec3 color = vec3(vBrightness);

	vec3 N = normalize(uNormal * vNormal);

	vec3 lightPos = (uModel * vec4(24, 24, 5.0, 1.0)).xyz;
	vec3 fragPos = (uModel * vVertex).xyz;
	vec3 lightDir = normalize(lightPos-fragPos);
	float radius = 48;
	float dist = distance(lightPos, fragPos);
	
	float NdotL = clamp(dot(N, lightDir), 0, 1);
	NdotL *= clamp(1.0-dist/radius, 0, 1);


    gl_FragColor = vec4(vec3(NdotL), 1.0);

}