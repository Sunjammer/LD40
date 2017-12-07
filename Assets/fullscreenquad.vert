#version 120

attribute vec4 aVertex;
varying vec2 vTexCoord;
void main()
{
    vTexCoord = aVertex.zw;
	gl_Position = vec4(aVertex.xy, 0.0, 1.0);
}