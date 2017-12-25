varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;
uniform sampler2D uBloomTexture;
void main(){
    vec3 color = texture2D(uImage0, vTexCoord).rgb + texture2D(uBloomTexture, vTexCoord).rgb;
    gl_FragColor = vec4(color, 1.0);
}