package violet.states.menus;

import violet.backend.utils.NovaUtils;
import flixel.text.FlxText;
import violet.backend.utils.StringUtil;
import lemonui.utils.MathUtil;
import flixel.FlxCamera;
import violet.backend.scripting.events.EventBase;
import violet.backend.EditorListBackend;
import violet.backend.audio.Conductor;

class PauseMenu extends EditorListBackend {

	public var pauseMusic:String = 'game/pause/breakfast';

	public var pauseMusicSound:FlxSound;

	public var optionBg:NovaSprite;

	public var pauseInfo:Array<String> = [ // Variable named by @ShamrockDeveloper
		PlayState.SONG.meta.displayName,
		PlayState.songData._data?.composer != null ? 'Composer: ${PlayState.songData._data?.composer}' : null,
		PlayState.songData._data?.charter != null ? 'Charter: ${PlayState.songData._data?.charter}' : null,
		'Difficulty: ${StringUtil.capitalizeFirst(PlayState.difficulty.toLowerCase())}',
		'0 Blue Balls'
	];

	public var pauseMenuOptions:Array<EditorListOption>;

	override public function new()
	{
		pauseInfo = pauseInfo.filter((v)->{ return v != null; });

		pauseMenuOptions = [
			{ title: 'RESUME', disabled: false, onClick: ()->{
				var event:EventBase = PlayState.instance.songScripts.event('onResume', new EventBase());
				// event = subStateScripts.event('resume', event);
				if (!event.cancelled) close();
			}},
			{ title: 'RESTART SONG', disabled: false, onClick: ()->{
				var event:EventBase = PlayState.instance.songScripts.event('onRestartSong', new EventBase());
				// event = subStateScripts.event('restartSong', event);
				if (event.cancelled) return;
				Conductor.stop();
				Conductor.offset = 0;
				Conductor.instrumental.time = 0;
				FlxG.resetState();
			}},
			{ title: 'CHANGE DIFFICULTY', disabled: true, onClick: ()->{

			}},
			{ title: 'ENABLE PRACTICE MODE', disabled: true, onClick: ()->{

			}},
			{ title: 'OPTIONS', disabled: false, onClick: ()->{
				var event:EventBase = PlayState.instance.songScripts.event('onOpenOptions', new EventBase());
				// event = subStateScripts.event('openOptions', event);
				if (!event.cancelled) {
					FlxTween.tween(optionBg, { alpha: 0.7 }, 0.5, { ease: FlxEase.expoOut });
					openSubState(new OptionsMenu());
				}
			}},
			{ title: 'EXIT TO MENU', disabled: false, onClick: ()->{
				var event:EventBase = PlayState.instance.songScripts.event('onExitToMenu', new EventBase());
				// event = subStateScripts.event('exitToMenu', event);
				if (!event.cancelled) subCamera.fade(0.25, () -> {
					PlayState.instance.exitToMenu();
				});
			}}
		];

		if (PlayState.instance.inCutscene) {
			pauseMenuOptions[1].title = pauseMenuOptions[1].title.replace('SONG', 'CUTSCENE');
			pauseMenuOptions.insert(1, { title: 'SKIP CUTSCENE', disabled: false, onClick: ()->PlayState.instance.callSongScripts('onSkipCutscene')});
		}

		super(pauseMenuOptions);
	}

	override function create() {
		options = pauseMenuOptions;
		showLocks = false;
		super.create();

		pauseMusicSound = FlxG.sound.play(Cache.sound(pauseMusic), 0);
		pauseMusicSound.fadeIn(1, 0, 0.5);

		FlxTween.num(0, 0.6, 0.5, { ease: FlxEase.sineOut }, (v)->{ subCamera.bgColor.alphaFloat = v; });

		FlxG.state.persistentUpdate = false;
		FlxG.state.persistentDraw = true;

		Conductor.pause();

		for (i=>item in items) {
			item.y = (160 * i) + 30;
		}
		scroll(0);

		for (i=>info in pauseInfo) {
			var infoText = new FlxText(0, (i * 30) - 20, info, 33);
			infoText.font = Paths.font('vcr.ttf');
			infoText.updateHitbox();
			infoText.scrollFactor.set();
			infoText.x = FlxG.width - infoText.width - 20;
			infoText.alpha = 0;
			infoText.camera = subCamera;
			add(infoText);

			FlxTween.tween(infoText, { alpha: 1, y: (i * 35) + 20 }, 1, { ease: FlxEase.expoOut, startDelay: i * 0.1 });
		}

		optionBg = new NovaSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		optionBg.alpha = 0;
		optionBg.scrollFactor.set();
		optionBg.camera = subCamera;
		add(optionBg);
	}

	override function pickOption(option:{title:String, onClick:() -> Void}) {
		if (!FlxG.mouse.justPressed) super.pickOption(option);
	}

	override function close() {
		super.close();
		if (PlayState.instance.songStarted) Conductor.play();
		FlxG.state.persistentUpdate = true;
		FlxTween.globalManager.forEach((tween:FlxTween)->{
			tween.active = true;
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		for (i=>item in items) {
			item.y = (160 * i) + 30;
			item.x = MathUtil.lerp(item.x, 90 + ((i-debugCurSelected)*20), 0.2);
		}
	}

	override function scroll(amt:Int) {
		super.scroll(amt);

		for (i=>item in items) {
			if (amt == 0) item.x = 80 + ((i-debugCurSelected)*20);
		}
	}

	override public function closeSubState() {
		FlxTween.tween(optionBg, { alpha: 0 }, 0.5, { ease: FlxEase.expoOut });
		super.closeSubState();
	}

	override function destroy() {
		super.destroy();
		pauseMusicSound.stop();
	}

}