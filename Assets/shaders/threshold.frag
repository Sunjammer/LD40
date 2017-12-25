varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;
void main(){
    vec3 color = texture2D(uImage0, vTexCoord).rgb;
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    if(brightness > 0.95)
        gl_FragColor = vec4(color, 1.0);
    else
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}