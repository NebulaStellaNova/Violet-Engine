#pragma header

uniform vec3 targetColor;
uniform float threshold;
uniform float softness;

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    float dist = distance(color.rgb, targetColor);

    float alphaMask = smoothstep(threshold, threshold + softness, dist);

    color.a *= alphaMask;
    color.rgb *= alphaMask;

    gl_FragColor = color;
}