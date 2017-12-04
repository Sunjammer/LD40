#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTileInfo;
varying vec2 vUv;
uniform vec4 uResolution;
uniform float uTime;
uniform sampler2D uNoiseTexture;
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
    vec4 outCol = vec4(1.0);
    float visibility = vBrightness;

    if(vTileInfo.y==1.0)
        outCol = texture2D(uNoiseTexture, vUv + gl_PointCoord);

    gl_FragColor = vec4(outCol.rgb, 1.0);


}