#pragma header
// @NebulaStellaNova

// The radius of the corners 0 - 360
uniform float _radius;

void main() {
    vec2 uv = openfl_TextureCoordv;

    vec2 size = openfl_TextureSize;

    float aspect = size.x / size.y;

    vec2 aspectUV = uv;
    aspectUV.x *= aspect;

    float resRadius = clamp(_radius, 0.0, 360.0) * (0.5 / 360.0);
    vec2 limit = vec2(aspect - resRadius, 1.0 - resRadius);

    vec2 d = max(abs(aspectUV - vec2(aspect * 0.5, 0.5)) - vec2(aspect * 0.5 - resRadius, 0.5 - resRadius), 0.0);
    float dist = length(d);

    vec4 color = flixel_texture2D(bitmap, uv);

    float alpha = 1.0 - smoothstep(resRadius - 0.002, resRadius, dist);

    gl_FragColor = color * alpha;
}