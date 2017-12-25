#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uImage0;
uniform int uHorizontal;

uniform float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);
void main(){
    vec2 tex_offset = 1.0 / uResolution; 
    vec3 result = texture2D(uImage0, vTexCoord).rgb * weight[0]; 
    if(uHorizontal==1)
    {
        for(int i = 1; i < 5; ++i)
        {
            result += texture2D(uImage0, vTexCoord + vec2(tex_offset.x * i, 0.0)).rgb * weight[i];
            result += texture2D(uImage0, vTexCoord - vec2(tex_offset.x * i, 0.0)).rgb * weight[i];
        }
    }
    else
    {
        for(int i = 1; i < 5; ++i)
        {
            result += texture2D(uImage0, vTexCoord + vec2(0.0, tex_offset.y * i)).rgb * weight[i];
            result += texture2D(uImage0, vTexCoord - vec2(0.0, tex_offset.y * i)).rgb * weight[i];
        }
    }
    gl_FragColor = vec4(result, 1.0);
}