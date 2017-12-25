varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uImage0;


vec3 map(vec3 inColor, float exposure){
    const float gamma = 2.2;
    vec3 mapped = vec3(1.0) - exp(-inColor * exposure);
    mapped = pow(mapped, vec3(1.0/gamma));
    return mapped;
}

void main(){
    vec4 c = texture2D(uImage0, vTexCoord);
    gl_FragColor = vec4(map(c.xyz, 1.1), c.a);
}