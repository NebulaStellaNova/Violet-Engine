#pragma header

uniform float angle;
uniform float pivotY; // NEW: 0.0 is top, 1.0 is bottom, 0.5 is center

void main() {
    vec2 uv = openfl_TextureCoordv;
    float rad = radians(angle);

    // Swap 0.5 for your new pivotY uniform
    float limitX = (uv.y - pivotY) * tan(rad);

    vec4 color = flixel_texture2D(bitmap, uv);

    if (uv.x < limitX) {
        color = vec4(0.0);
    }

    gl_FragColor = color;
}