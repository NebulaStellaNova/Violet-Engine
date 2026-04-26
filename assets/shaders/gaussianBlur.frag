#pragma header

uniform float intensity;

uniform float quality;
float directions = 16.0;

void main()
{
    vec2 uv = openfl_TextureCoordv;

    if (intensity < 0.001) {
        gl_FragColor = flixel_texture2D(bitmap, uv);
        return;
    }

    vec2 radius = vec2(intensity) / openfl_TextureSize;

    vec4 color = flixel_texture2D(bitmap, uv);
    float count = 1.0;

    float q = max(1.0, quality);
    float d = max(1.0, directions);
    float pi2 = 6.28318530718;

    for(float angle = 0.0; angle < pi2; angle += pi2 / d)
    {
        for(float i = 1.0 / q; i <= 1.0; i += 1.0 / q)
        {
            color += flixel_texture2D(bitmap, uv + vec2(cos(angle), sin(angle)) * radius * i);
            count++;
        }
    }

    gl_FragColor = color / count;
}