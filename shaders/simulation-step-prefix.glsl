#ifdef GL_ES
    precision highp float;
#endif

uniform sampler2D texture;
uniform float unit;
uniform float time;
uniform float dt;
uniform float sourceWaterHeight;
uniform float sourceWaterVelocity;

varying vec2 uv;
varying vec2 uvLeft;
varying vec2 uvRight;
varying vec2 uvTop;
varying vec2 uvBottom;

#define V(D)  D.xy
#define Vx(D) D.x
#define Vy(D) D.y
#define H(D)  D.z
#define T(D)  D.w
#define L(D)  H(D) + T(D)

vec4 simData (vec2 pos) {
    vec4 data = texture2D(texture, pos);
    float minExtent = unit;
    float maxExtent = 1.0 - unit;

    if (pos.x < minExtent) {
        vec4 borderData = texture2D(texture, vec2(minExtent, clamp(pos.y, minExtent, maxExtent)));
        data.x = sourceWaterHeight > borderData.w ? sourceWaterVelocity : 0.0;
        data.z = sourceWaterHeight - borderData.w;
        data.w = borderData.w;
    } else if (pos.x > maxExtent) {
        vec4 borderData = texture2D(texture, vec2(maxExtent, clamp(pos.y, minExtent, maxExtent)));
        data.x = max(borderData.x, 0.0);
        data.z = borderData.z;
        data.w = borderData.w;
    }

    if (pos.y < minExtent) {
        vec4 borderData = texture2D(texture, vec2(clamp(pos.x, minExtent, maxExtent), minExtent));
        data.y = 0.0;
        data.z = borderData.z;
        data.w = borderData.w;
    } else if (pos.y > maxExtent) {
        vec4 borderData = texture2D(texture, vec2(clamp(pos.x, minExtent, maxExtent), maxExtent));
        data.y = 0.0;
        data.z = borderData.z;
        data.w = borderData.w;
    }

    return data;
}

vec4 simulationStep(vec2, vec2, vec2, vec2, vec2);

void main(void) {
    gl_FragColor = simulationStep(uv, uvLeft, uvRight, uvTop, uvBottom);
}