uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

varying vec3 vNormal; 
varying vec3 vNormalScreenSpace; 

void main(){
    vec4 light = vec4(0.0, 0.0, -1.0, 0.0);
    light = normalize(light);
    float NdotL = max(0.0, dot(vNormalScreenSpace, light.xyz));
    gl_FragColor = vec4(abs(vNormal) * NdotL, 1.0);
}