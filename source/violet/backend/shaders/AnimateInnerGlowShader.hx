package violet.backend.shaders;

import flixel.system.FlxAssets.FlxShader;

class AnimateInnerGlowShader extends FlxShader {
	public var color(default, set):FlxColor;
	function set_color(v:FlxColor) {
        this.glowColor.value = [ v.redFloat, v.greenFloat, v.blueFloat, v.alphaFloat ];
		return color = v;
	}

	public var size(default, set):Float;
	function set_size(v:Float) {
        this.glowSize.value = [v];
		return size = v;
	}

	public var strength(default, set):Float;
	function set_strength(v:Float) {
        this.glowStrength.value = [v];
		return strength = v;
	}

	public var quality(default, set):Float;
	function set_quality(v:Float) {
        this.glowQuality.value = [v];
		return quality = v;
	}



    @:glFragmentSource("
        #pragma header

		uniform vec4 glowColor;
		uniform float glowSize;
		uniform float glowStrength;
		uniform float glowQuality;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec4 baseColor = flixel_texture2D(bitmap, uv);

			if (baseColor.a == 0.0 || glowSize <= 0.0 || glowStrength <= 0.0 || glowQuality <= 0.0) {
				gl_FragColor = baseColor;
				return;
			}

			float missingAlpha = 0.0;
			float totalSamples = 0.0;
			vec2 pixelSize = 1.0 / openfl_TextureSize;

			const int MAX_QUALITY = 15;
			const int MAX_SAMPLES = 64;

			for (int r = 1; r <= MAX_QUALITY; r++) {
				if (float(r) > glowQuality) break;

				float currentSamples = float(r) * 4.0 + 4.0;

				for (int i = 0; i < MAX_SAMPLES; i++) {
					if (float(i) >= currentSamples) break;

					float angle = (float(i) / currentSamples) * 6.28318530718;

					vec2 offset = vec2(cos(angle), sin(angle)) * (glowSize * (float(r) / glowQuality)) * pixelSize;

					float neighborAlpha = flixel_texture2D(bitmap, uv + offset).a;
					missingAlpha += (1.0 - neighborAlpha);
					totalSamples += 1.0;
				}
			}

			float glowIntensity = (missingAlpha / totalSamples) * glowStrength;
			glowIntensity = clamp(glowIntensity, 0.0, 1.0);

			glowIntensity = glowIntensity * baseColor.a * glowColor.a;

			vec3 finalRGB = mix(baseColor.rgb, glowColor.rgb * baseColor.a, glowIntensity);

			gl_FragColor = vec4(finalRGB, baseColor.a);
		}
    ")
    public function new(color:FlxColor = FlxColor.WHITE, size:Float = 8, strength:Float = 2, quality:Float = 6) {
        super();
		this.color = color;
		this.size = size;
		this.strength = strength;
		this.quality = quality;
    }
}