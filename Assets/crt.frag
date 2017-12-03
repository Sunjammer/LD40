#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;

void main() {
    vec2 uv = vTexCoord;

    float x = 1.0 / uResolution.x;
    float y = 1.0 / uResolution.y;
    vec4 horizEdge = vec4( 0.0 );
    horizEdge -= texture2D( uImage0, vec2( uv.x - x, uv.y - y ) ) * 1.0;
    horizEdge -= texture2D( uImage0, vec2( uv.x - x, uv.y     ) ) * 2.0;
    horizEdge -= texture2D( uImage0, vec2( uv.x - x, uv.y + y ) ) * 1.0;
    horizEdge += texture2D( uImage0, vec2( uv.x + x, uv.y - y ) ) * 1.0;
    horizEdge += texture2D( uImage0, vec2( uv.x + x, uv.y     ) ) * 2.0;
    horizEdge += texture2D( uImage0, vec2( uv.x + x, uv.y + y ) ) * 1.0;
    vec4 vertEdge = vec4( 0.0 );
    
    vertEdge -= texture2D( uImage0, vec2( uv.x - x, uv.y - y ) ) * 1.0;
    vertEdge -= texture2D( uImage0, vec2( uv.x    , uv.y - y ) ) * 2.0;
    vertEdge -= texture2D( uImage0, vec2( uv.x + x, uv.y - y ) ) * 1.0;
    vertEdge += texture2D( uImage0, vec2( uv.x - x, uv.y + y ) ) * 1.0;
    vertEdge += texture2D( uImage0, vec2( uv.x    , uv.y + y ) ) * 2.0;
    vertEdge += texture2D( uImage0, vec2( uv.x + x, uv.y + y ) ) * 1.0;
    vec3 edge = smoothstep(vec3(0), vec3(1), sqrt((horizEdge.rgb * horizEdge.rgb) + (vertEdge.rgb * vertEdge.rgb)));


    float intensity = 0.2126 * edge.r + 0.7152 * edge.g + 0.0722 * edge.b;
    // texture2D(iChannel0, uv/5.*sin(iGlobalTime)) * 
    gl_FragColor = intensity * vec4(0.3,1,.2,1);
    gl_FragColor.w = 1.;
}