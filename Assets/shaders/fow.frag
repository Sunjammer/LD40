varying vec2 vTexCoord;
uniform float uTime;
uniform vec2 uResolution;
void main(){
    float p = length(gl_FragCoord.xy/uResolution - vec2(0.5));
    float exposed = smoothstep(0.4, 0.45, p);
    gl_FragColor = vec4(1.0-exposed, 0.0, 0.0, 1.0);
}