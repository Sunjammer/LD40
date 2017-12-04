#version 120
#extension GL_EXT_gpu_shader4 : require

varying vec2 vTexCoord;
void main()
{
	vec4 quadVertices[4];
	quadVertices[0] = vec4( -1.0, -1.0, 0.0, 0.0);
	quadVertices[1] = vec4(1.0, -1.0, 1.0, 0.0);
	quadVertices[2] = vec4( -1.0, 1.0, 0.0, 1.0);
	quadVertices[3] = vec4(1.0, 1.0, 1.0, 1.0);

	vTexCoord = quadVertices[gl_VertexID].zw;
	gl_Position = vec4(quadVertices[gl_VertexID].xy, 0.0, 1.0);
}