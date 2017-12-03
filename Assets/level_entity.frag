#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform float uTime;

void main(void){
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}