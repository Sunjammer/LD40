varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uImage0;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 map(vec3 inColor, float exposure){
    const float gamma = 2.2;
    vec3 mapped = vec3(1.0) - exp(-inColor * exposure);
    mapped = pow(mapped, vec3(1.0/gamma));
    return mapped;
}

void main(){
    vec4 c = texture2D(uImage0, vTexCoord);
    vec3 s = map(c.xyz, 3.0);
    gl_FragColor = vec4(s, c.a);
}