attribute vec2 aPosition;
attribute vec2 aInfo;

uniform vec2 uScreenSize;
varying float vOpacity;

void main(){
    vec2 pos = ((aPosition/uScreenSize) * 2.0 - 1.0) * vec2(1, -1);
    vOpacity = aInfo.y;
    gl_PointSize = aInfo.x;
    gl_Position = vec4(pos, 0.0, 1.0);
}