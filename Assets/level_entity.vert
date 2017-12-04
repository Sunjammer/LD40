#version 120

#ifdef GL_ES
    precision mediump float;
#endif


attribute vec4 aVertex;
varying vec2 vTileInfo;
uniform vec4 uResolution;
uniform mat4 uMatrix;
uniform mat4 uView;
uniform float uTime;
varying vec2 vUv;
varying float vBrightness;
varying float vZoffset;
uniform sampler2D uNoiseTexture;
uniform vec4 uLight0;

float shape(float v, float drive){
	float k = 2.0 * drive / (1.0 - drive);
	return (1.0 + k) * v / (1.0 + k * abs(v));
}

void main(void){
    vTileInfo = aVertex.zw;

    gl_PointSize = aVertex.z + aVertex.z;

    vec2 local = aVertex.xy / uResolution.zw;
    vec2 diff = local-uLight0.xy;

    vUv = local;
    local = local * 2 - 1;
    vec2 r = (uResolution.zw*aVertex.z)/uResolution.xy;
    local = local * r;

    vBrightness = 1.0 - distance(aVertex.xy, uLight0.xy) / uResolution.x;
    float vZoffset = shape(sin(uTime*0.2+local.x) * cos(uTime*0.5+local.y), -0.9);
    float z = vZoffset * 0.1;

    gl_Position = uView * uMatrix * (vec4(local, z, 1.0) * vec4(1,-1, -1, 1));



}