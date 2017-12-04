#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTileInfo;
varying vec2 vUv;
uniform vec4 uResolution;
uniform float uTime;
uniform sampler2D uNoiseTexture;
uniform sampler2D uDataTexture;
varying float vBrightness;
varying float vZoffset;

vec3 shape(vec3 v, vec3 drive){
	vec3 k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

void main(void){
    vec2 uv = fract(vec2(0.5, 0.5) + vec2(cos(uTime*0.2), sin(uTime*0.2)) * vec2(0.5,0.5));
    vec4 outCol = vec4(1) - texture2D(uNoiseTexture, (vUv + uv) * 4) * 0.5 + texture2D(uDataTexture, vUv) * abs(vZoffset);

    if(vTileInfo.y > 0.5){
        outCol.r = 1.0;
        outCol.gb *= 0.5;
    }

    gl_FragColor = vec4(outCol.rgb, 0.5 + abs(vZoffset) * 0.5);


}