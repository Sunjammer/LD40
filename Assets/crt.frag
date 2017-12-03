#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;
uniform sampler2D uImage1;
uniform float uTime;

const float BARREL_DISTORTION = 0.1;
const float rescale = 1.0 - (0.25 * BARREL_DISTORTION);

void main() {
    vec2 uv = vTexCoord - .5;
    float rsq = dot(uv,uv);
    uv += (uv * (BARREL_DISTORTION * rsq));
    uv *= rescale;

    if (abs(uv.x) > 0.5 || abs(uv.y) > 0.5) {
        //gl_FragColor = vec4(0,0,0,1);
        discard;
    }

    vec4 color = texture2D(uImage0, vTexCoord);
    float intensity = 1.0;
    uv += .5;
    if(color.rgb != vec3(1.0, 0.0, 0.0)){
        vec2 stepSize = 1.0 / uResolution;
        float x = stepSize.x;
        float y = stepSize.y;
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
        vec3 edge = smoothstep(vec3(0.), vec3(1), sqrt((horizEdge.rgb * horizEdge.rgb) + (vertEdge.rgb * vertEdge.rgb)));
        edge += texture2D(uImage0,uv).rgb*.5;
        intensity = 0.2126 * edge.r + 0.7152 * edge.g + 0.0722 * edge.b;
    }

    float strength = 30.0;
    float foo = (uv.x + 4.0 ) * (uv.y + 4.0 ) * (uTime * 10.0);
    vec4 grain = vec4(mod((mod(foo, 13.0) + 1.0) * (mod(foo, 123.0) + 1.0), 0.01)-0.005) * strength;
    grain = 1.0 - grain;
    color = 1.4 * grain * texture2D(uImage1, vTexCoord / 4.) * intensity * vec4(0.31,.83,1,1);

    gl_FragColor = vec4(color.rgb,1.0);
}