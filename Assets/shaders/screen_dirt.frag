#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uImage0;
uniform sampler2D uImage1;

void main()
{
       gl_FragColor = texture2D(uImage1, vTexCoord);
}