uniform	mat4 transform;
uniform mat4 cameraInverse;
uniform mat4 cameraProjection;

attribute vec3 vertices;
attribute vec3 normals;
attribute vec2 uvs;

uniform float nTiles1d;
uniform float tileWidth;
uniform float x;
uniform float y;
uniform float unit;
uniform float displayHeightScale;

uniform sampler2D texture;

varying vec2 uv;
varying float light;

void main(void) {
    uv = vec2(
        (uvs.x + x) / nTiles1d,
        1.0 - (uvs.y + y) / nTiles1d
    );
    //light = dot(normalize(mat3(transform[0].xyz, transform[1].xyz, transform[2].xyz) * normals), vec3(0.0, 0.0, 1.0));
    vec4 data = texture2D(texture, uv);

    float height = data.z > 0.0 ? data.z + data.w : 0.0;

    gl_Position = cameraProjection * cameraInverse * transform * vec4(
        vertices.x + tileWidth * x,
        vertices.y + tileWidth * y,
        height * displayHeightScale,
        1.0
    );
}