#pragma header

uniform float cutOffLimit;

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec4 color = flixel_texture2D(bitmap, uv);
    float brightness = color.r + color.g + color.b;
    float visibility = 1.0 - smoothstep(0.0, cutOffLimit, brightness);
    gl_FragColor = vec4(0.0, 0.0, 0.0, color.a * visibility);
}