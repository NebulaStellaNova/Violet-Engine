package violet.states;

import violet.backend.utils.NovaUtils;
import violet.backend.StateBackend;
import violet.backend.filesystem.Paths;
import violet.backend.objects.NovaSprite;

class TitleState extends StateBackend {

	public var bootAnimation:NovaSprite;

	override public function create() {
		super.create();

		bootAnimation = new NovaSprite(Paths.image("menus/titlescreen/bootAnimation"));
		bootAnimation.addAnim("boot", "animation", 40);
		bootAnimation.playAnim("boot", true);
		bootAnimation.scale.set(0.7, 0.7);
		add(bootAnimation);

		NovaUtils.playMusic("freakyMenu", 0);
		FlxG.sound.music.fadeIn(1, 0, 1);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		bootAnimation.updateHitbox();
		bootAnimation.screenCenter();
	}
}