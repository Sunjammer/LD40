attribute vec4 aPosition;
attribute vec4 aNormal;

uniform mat3 uNormal;
uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

varying vec3 vNormal; 
varying vec3 vNormalScreenSpace; 

void main(){
    vNormalScreenSpace = normalize(uNormal * aNormal.xyz);
    vNormal = aNormal.xyz;
    gl_Position = uProjection * uView * uModel * aPosition;
}