#version 120

#ifdef GL_ES
    precision mediump float;
#endif


attribute vec4 aVertex;
varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform float uTime;

void main(void){
    vTexCoord = aVertex.zw;
    gl_PointSize = 4.0;
    gl_Position = vec4(aVertex.xy*20, 0.0, 1.0);

}