package violet.states.menus;

import violet.backend.audio.Conductor;
import violet.data.Constants;
import violet.backend.scripting.GlobalPack;
import flixel.addons.display.FlxRuntimeShader;
import lemonui.utils.SpriteUtil;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.SubStateBackend;

class ModTag extends FlxSpriteGroup {
	override public function new(tag:String) {
		super();

		var label:NovaText = new NovaText(7.5, 5, 0, tag);
		label.font = Paths.font('vcr.ttf');
		label.size = 50;
		label.updateHitbox();

		var bg:NovaSprite = new NovaSprite().makeGraphic(label.width + 15, label.height + 10, FlxColor.BLACK);
		bg.alpha = 0.5;
		SpriteUtil.roundSpriteCorners(bg, 10);

		add(bg);
		add(label);
	}
}

class ModMenu extends SubStateBackend {

	public var roundCornerShader:FlxRuntimeShader = new FlxRuntimeShader("
		#pragma header
		// Shader by: @NebulaStellaNova

		uniform float radius;

		void main() {
			vec2 uv = openfl_TextureCoordv;
			vec2 size = openfl_TextureSize;
			float aspect = size.x / size.y;

			vec2 aspectUV = uv * vec2(aspect, 1.0);
			vec2 center = vec2(aspect * 0.5, 0.5);

			float resRadius = clamp(radius, 0.0, 360.0) / 720.0;

			vec2 q = abs(aspectUV - center) - vec2(aspect * 0.5 - resRadius, 0.5 - resRadius);
			float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);

			vec4 color = flixel_texture2D(bitmap, uv);

			float smoothing = fwidth(dist);
			float alpha = 1.0 - smoothstep(resRadius - smoothing, resRadius + smoothing, dist);

			gl_FragColor = color * alpha;
		}
	");

	public var statusText:NovaSprite;
	public var tagImage:NovaSprite;

	public var modIconList:Array<FlxSpriteGroup> = [];
	public var modInfoBox:NovaSprite;

	public var infoSeperator:NovaSprite;

	public static var curSelected:Int = 0;

	public var tagsText:NovaText;
	public var description:NovaText;
	public var modTitleText:NovaText;
	public var creditsTitle:NovaText;
	public var descriptionTitle:NovaText;

	public var creditsStuff:Array<NovaText> = [];

	public var selectedMod:ModMeta;
	public var instant:Bool = true;

	public var tagSprites:Array<ModTag> = [];

	public var bootBools:Array<Bool> = [];

	override public function create() {
		super.create();

		roundCornerShader.setFloat('radius', 35);

		modInfoBox = new NovaSprite(Paths.image("menus/modmenu/modInfoPanel"));
		modInfoBox.updateHitbox();
		modInfoBox.scrollFactor.set();
		modInfoBox.screenCenter();
		// modInfoBox.x = FlxG.width - modInfoBox.width - 20;
		modInfoBox.x = FlxG.width + 200;
		add(modInfoBox);

		infoSeperator = new NovaSprite(Paths.image("menus/modmenu/modInfoSeperator"));
		infoSeperator.updateHitbox();
		infoSeperator.scrollFactor.set();
		infoSeperator.screenCenter();
		add(infoSeperator);

		for (i=>mod in ModdingAPI.availableMods) {
			bootBools.push(ModdingAPI.checkModEnabled(mod.id));
			var icon:FlxSpriteGroup = new FlxSpriteGroup();
			icon.ID = i;

			var iconBox = new NovaSprite(Paths.image("menus/modmenu/iconBox"));
			icon.add(iconBox);

			var modIcon:ModIcon = new ModIcon(mod.folder);
			modIcon.setGraphicSize(iconBox.width - 20, iconBox.height - 20);
			modIcon.x = 10;
			modIcon.y = 10;
			modIcon.updateHitbox();
			modIcon.shader = roundCornerShader;
			icon.add(modIcon);

			icon.scrollFactor.set();
			modIconList.push(icon);
			add(icon);
		}

		FlxTween.tween(modInfoBox, {x: FlxG.width - modInfoBox.width - 35 }, 0.5, { ease: FlxEase.smootherStepOut });

		modTitleText = new NovaText(0, 0, modInfoBox.width/2, "", Paths.font("Tardling v1.1.ttf"));
		modTitleText.size = 125;
		modTitleText.text = 'Yooooooo';
		modTitleText.scrollFactor.set();
		modTitleText.alignment = CENTER;
		add(modTitleText);

		tagsText = new NovaText(0, 0, "", Paths.font("PhantomMuff/empty letters.ttf"));
		tagsText.size = 60;
		tagsText.text = 'Tag:';
		tagsText.scrollFactor.set();
		tagsText.alignment = LEFT;
		add(tagsText);

		tagImage = new NovaSprite(Paths.image("menus/modmenu/tags/example"));
		tagImage.scale.scale(0.66, 0.66);
		tagImage.x = tagsText.x + tagsText.width + 10;
		tagImage.y = tagsText.y;
		tagImage.scrollFactor.set();
		// add(tagImage);

		descriptionTitle = new NovaText(0, 0, modInfoBox.width/4, "", Paths.font("PhantomMuff/empty letters.ttf"));
		descriptionTitle.size = 75;
		descriptionTitle.text = 'Description:';
		descriptionTitle.scrollFactor.set();
		descriptionTitle.alignment = LEFT;
		descriptionTitle.updateHitbox();
		add(descriptionTitle);

		description = new NovaText(0, descriptionTitle.y + descriptionTitle.height, modInfoBox.width/4, "", Paths.font("Tardling v1.1.ttf"));
		description.size = 60;
		description.text = 'Test';
		description.scrollFactor.set();
		description.alignment = LEFT;
		add(description);

		creditsTitle = new NovaText(0, 0, modInfoBox.width/2, "", Paths.font("PhantomMuff/empty letters.ttf"));
		creditsTitle.size = 75;
		creditsTitle.text = 'Credits:';
		creditsTitle.scrollFactor.set();
		creditsTitle.alignment = RIGHT;
		add(creditsTitle);

		statusText = new NovaSprite(Paths.image("menus/modmenu/enabled"));
		statusText.scrollFactor.set();
		add(statusText);

		selectedMod = ModdingAPI.availableMods[curSelected];
		updateCredits();
	}

	override public function update(e) {
		super.update(e);

		if (Controls.back) {
			exit();
		}

		curSelected = FlxMath.wrap(curSelected + (Controls.uiUp ? -1 : (Controls.uiDown ? 1 : 0)), 0, modIconList.length - 1);

		var height:Float = 0;
		for (i in modIconList) {
			i.y = MathUtil.lerp(i.y, ((i.ID - curSelected) * (i.height + 10)) + modInfoBox.y, instant ? 1 : 0.2);
			i.alpha = i.ID == curSelected ? 1 : 0.5;
			i.x = modInfoBox.x - i.width - 20;
		}
		modTitleText.text = selectedMod.title;

		infoSeperator.updateHitbox();
		infoSeperator.x = modInfoBox.x + (modInfoBox.width/2) - (infoSeperator.width/2);
		infoSeperator.y = modInfoBox.y + 100;

		modTitleText.updateHitbox();
		modTitleText.x = modInfoBox.x;
		modTitleText.y = modInfoBox.y + 30;

		tagsText.updateHitbox();
		tagsText.x = infoSeperator.x;
		tagsText.y = infoSeperator.y + 20;

		descriptionTitle.x = infoSeperator.x;
		descriptionTitle.y = infoSeperator.y + 75;

		description.text = selectedMod.description;
		description.updateHitbox();
		description.x = descriptionTitle.x;
		description.y = descriptionTitle.y + descriptionTitle.height + 5;

		creditsTitle.updateHitbox();
		creditsTitle.x = modInfoBox.x - 65;
		creditsTitle.y = infoSeperator.y + 75;

		if (FlxG.keys.justPressed.ENTER) {
			if (ModdingAPI.checkModEnabled(selectedMod.id)) ModdingAPI.disableMod(selectedMod.id);
			else ModdingAPI.enableMod(selectedMod.id);
			statusText.loadSprite(Paths.image("menus/modmenu/" + (ModdingAPI.checkModEnabled(selectedMod.id) ? "enabled" : "disabled")));
		}

		modInfoBox.updateHitbox();
		statusText.updateHitbox();
		statusText.x = modInfoBox.x + (modInfoBox.width/2) - (statusText.width/2);
		statusText.y = (modInfoBox.y + modInfoBox.height) - (statusText.height + 20);


		tagsText.updateHitbox();
		tagImage.updateHitbox();
		tagImage.x = tagsText.x + tagsText.width + 10;
		tagImage.y = tagsText.y;

		var xPos = 0.0;
		for (tag in tagSprites) {
			tag.x = tagsText.x + tagsText.width + 10 + xPos;
			tag.y = tagsText.y;
			xPos += tag.width + 10;
		}

		selectedMod = ModdingAPI.availableMods[curSelected];

		if (Controls.uiUp || Controls.uiDown || instant) {
			updateCredits();
		}

		for (ind=>i in creditsStuff) {
			i.x = creditsTitle.x;
			i.scrollFactor.set();
		}

		if (instant) instant = false;
	}

	function updateCredits() {
		for (i in creditsStuff) {
			remove(i);
		}
		for (i in creditsStuff) {
			creditsStuff.remove(i);
		}

		for (i in tagSprites) {
			remove(i);
			i.destroy();
		}

		tagSprites.resize(0);

		tagsText.text = selectedMod.tags.length > 1 ? "Tags:" : "Tag:";
		tagsText.updateHitbox();

		var xPos = 0.0;
		for (i in selectedMod.tags) {
			var tag = new ModTag(i);
			tag.x = tagsText.x + tagsText.width + 10 + xPos;
			tag.y = tagsText.y;
			tag.scrollFactor.set();
			add(tag);
			tagSprites.push(tag);
			xPos += tag.width + 10;
		}

		statusText.loadSprite(Paths.image("menus/modmenu/" + (ModdingAPI.checkModEnabled(selectedMod.id) ? "enabled" : "disabled")));
		statusText.updateHitbox();
		statusText.x = modInfoBox.x + (modInfoBox.width/2) - (statusText.width/2);
		statusText.y = (modInfoBox.y + modInfoBox.height) - (statusText.height + 20);


		var start = creditsTitle.y + creditsTitle.height + 5;
		for (i in selectedMod.contributors) {
			var name = new NovaText(creditsTitle.x, 0, modInfoBox.width/2, "", Paths.font("Tardling v1.1.ttf"));
			name.size = 125;
			name.text = i.name;
			name.scrollFactor.set();
			name.alignment = RIGHT;
			name.size = 75;
			name.y = start;
			name.updateHitbox();
			add(name);
			creditsStuff.push(name);
			start += name.height;

			var roles = new NovaText(creditsTitle.x, 0, modInfoBox.width/2, "", Paths.font("PhantomMuff/empty letters.ttf"));
			roles.size = 125;
			roles.text = i.role;
			roles.scrollFactor.set();
			roles.alignment = RIGHT;
			roles.size = 55;
			roles.y = start;
			roles.updateHitbox();
			add(roles);
			creditsStuff.push(roles);
			start += roles.height + 15;
		}
	}

	override public function close() {
		super.close();

		var needsReset:Bool = false;

		for (i => mod in ModdingAPI.availableMods) {
			if (bootBools[i] != ModdingAPI.checkModEnabled(mod.id)) needsReset = true;
		}

		FlxG.save.flush();

		if (needsReset) {
			Conductor.stop();
			Constants.MENU_MUSIC = 'mainMenuTheme';
			ModdingAPI.reloadRegistries();
			GlobalPack.init();
			InitialState.refreshRedirects();
			FlxG.switchState(new MainMenu());
		}
		// state.onCloseSubState();
	}

	function exit() {
		NovaUtils.playMenuSFX(CANCEL);

		FlxTween.tween(modInfoBox, {x: FlxG.width + 200 }, 0.5, { ease: FlxEase.smootherStepIn });

		if (Std.isOfType(_parentState, MainMenu)) {
			FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut });
		}

		new FlxTimer().start(0.5, (_)->{
			close();
		});
	}
}