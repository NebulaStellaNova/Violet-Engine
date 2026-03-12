package violet.ui.freeplay;

import violet.data.song.Song;
import violet.backend.shaders.GaussianBlurShader;
import violet.backend.objects.special_thanks.GenzuSprite;
import flixel.group.FlxSpriteGroup;

class Capsule extends FlxSpriteGroup {
	public var icon:GenzuSprite;
	public var capsule:GenzuSprite;
	public var bpmText:GenzuSprite;
	public var difficultyText:GenzuSprite;

	var textGroup:FlxTypedSpriteGroup<NovaText>;
	var iconGroup:FlxTypedSpriteGroup<GenzuSprite>;
	var blur = new GaussianBlurShader(1);

	static final GLOW_COLOR = 0xFF00ccff;

	public function new(song:Song) {
		super();

		capsule = new GenzuSprite(0, 0, Paths.image("menus/freeplay/capsule/freeplayCapsule"));
		capsule.addAnim("idle", "mp3 capsule w backing NOT SELECTED", [], null, 24, true);
		capsule.addAnim("selected", "mp3 capsule w backing0", [], null, 24, true);
		capsule.addAnim("confirm", "mp3 capsule w backing0", [], null, 24, false); // adjust anim name as needed
		capsule.playAnim("idle");
		add(capsule);

		bpmText = new GenzuSprite(116, 95, Paths.image("menus/freeplay/capsule/text/bpmtext"));
		bpmText.updateHitbox();
		bpmText.scale.set(1.2, 1.2);
		add(bpmText);

		difficultyText = new GenzuSprite(450, 95, Paths.image("menus/freeplay/capsule/text/difficultytext"));
		difficultyText.updateHitbox();
		difficultyText.scale.set(1.2, 1.2);
		add(difficultyText);

		textGroup = new FlxTypedSpriteGroup<NovaText>(0, 0);

		var glowText = new NovaText(0, 0, null, song.displayName, 40);
		glowText.setFont(Paths.font("5by7"));
		glowText.updateHitbox();
		glowText.x += 120;
		glowText.y += 42;
		glowText.color = GLOW_COLOR;
		glowText.shader = blur;
		textGroup.add(glowText);

		var mainText = new NovaText(0, 0, null, song.displayName, 40);
		mainText.setFont(Paths.font("5by7"));
		mainText.updateHitbox();
		mainText.x += 120;
		mainText.y += 42;
		textGroup.add(mainText);

		add(textGroup);

		iconGroup = new FlxTypedSpriteGroup<GenzuSprite>(0, 0);

		icon = new GenzuSprite(30, 30, Paths.image('menus/freeplay/icons/${song.icon}'));
		icon.scale.set(2.5, 2.5);
		icon.pixelPerfectRender = true;
		icon.antialiasing = false;
		icon.addAnim("idle", "idle", [], null, 24, true);
		icon.addAnim("confirm", "confirm", [], null, 12, false);
		icon.playAnim("idle");
		iconGroup.add(icon);

		add(iconGroup);
	}

	public function setSelected(selected:Bool) {
		capsule.playAnim(selected ? "selected" : "idle");
		textGroup.alpha = selected ? 1 : 0.6;
	}

	public function playConfirm() {
		capsule.playAnim("confirm", true);
		icon.playAnim("confirm", true);
	}
}