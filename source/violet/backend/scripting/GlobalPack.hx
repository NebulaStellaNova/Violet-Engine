package violet.backend.scripting;

class GlobalPack #if SCRIPT_SUPPORT extends ScriptPack #end {

	public static var instance:GlobalPack;

	override public function new() {
		super();
		instance = this;
	}

	public static function init() {
		#if SCRIPT_SUPPORT
		if (instance != null) {
			instance.clear();
		}
		var pack = new GlobalPack();
		ModdingAPI.checkForScripts('data/scripts/global', pack);
		ModdingAPI.checkForScripts('data', 'global', pack);
		pack.execute();

		pack.call('create');
		pack.call('postCreate');

		FlxG.signals.preUpdate.add(()->{
			pack.parent = FlxG.state;
			pack.call('update', [FlxG.elapsed]);
			pack.call('onUpdate', [FlxG.elapsed]);
		});

		FlxG.signals.postUpdate.add(()->pack.call('postUpdate', [FlxG.elapsed]));
		FlxG.signals.postUpdate.add(()->pack.call('onUpdatePost', [FlxG.elapsed]));

		FlxG.signals.focusGained.add(()->pack.call('focusGained'));
		FlxG.signals.focusGained.add(()->pack.call('onFocusGained'));

		FlxG.signals.focusLost.add(()->pack.call('focusLost'));
		FlxG.signals.focusLost.add(()->pack.call('onFocusLost'));

		FlxG.signals.gameResized.add((int, int)->pack.call('gameResized', [int, int]));
		FlxG.signals.gameResized.add((int, int)->pack.call('onGameResized', [int, int]));

		FlxG.signals.preDraw.add(()->pack.call('preDraw'));
		FlxG.signals.preDraw.add(()->pack.call('onDrawPre'));

		FlxG.signals.postDraw.add(()->pack.call('postDraw'));
		FlxG.signals.postDraw.add(()->pack.call('onDrawPost'));

		FlxG.signals.preStateSwitch.add(()->pack.call('preStateSwitch'));
		FlxG.signals.preStateSwitch.add(()->pack.call('onPreStateSwitch'));

		FlxG.signals.postStateSwitch.add(()->pack.call('postStateSwitch'));
		FlxG.signals.postStateSwitch.add(()->pack.call('onPostStateSwitch'));

		FlxG.signals.preStateCreate.add((state)->pack.call('preStateCreate', [state]));
		FlxG.signals.preStateCreate.add((state)->pack.call('onPreStateCreate', [state]));
		#end
	}

	#if SCRIPT_SUPPORT
	override public function addScript(script) {
		super.addScript(script);
		script.set('global', true);
	}
	#end

}