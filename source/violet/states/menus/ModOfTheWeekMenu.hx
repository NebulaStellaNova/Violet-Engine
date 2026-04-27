package violet.states.menus;

import violet.backend.utils.FileUtil;
import violet.backend.scripting.GlobalPack;
import sys.FileSystem;
import violet.backend.shaders.RoundCornerShader;
import haxe.Json;
import violet.backend.utils.NovaUtils;
import sys.io.File;
import openfl.net.URLRequest;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLLoader;
import violet.backend.shaders.GaussianBlurShader;
import flixel.FlxCamera;
import violet.backend.SubStateBackend;

typedef ModOfTheWeekData = {
	var title:String;
	var description:String;
	var modID:String;
	var downloadURL:String;
	var thumbnailURL:String;
}

enum IconMode {
	DOWNLOAD;
	LOADING;
	DELETE;
}

class DownloadIcon extends FlxTypedSpriteGroup<NovaSprite> {

	public var download:NovaSprite;
	public var loading:NovaSprite;
	public var delete:NovaSprite;

	public var downloadO:NovaSprite;
	public var deleteO:NovaSprite;

	public var mode(default, set):IconMode;
	public function set_mode(value:IconMode) {
		download.visible = value == DOWNLOAD;
		loading.visible = value == LOADING;
		delete.visible = value == DELETE;
		return mode = value;
	}

	override public function new() {
		super();
		download = new NovaSprite(Paths.image('menus/motwmenu/download'));
		download.updateHitbox();
		download.x -= download.width/2;
		download.y -= download.height/2;
		add(download);

		delete = new NovaSprite(Paths.image('menus/motwmenu/delete'));
		delete.updateHitbox();
		delete.x -= delete.width/2;
		delete.y -= delete.height/2;
		add(delete);

		downloadO = new NovaSprite(Paths.image('menus/motwmenu/download'));
		downloadO.updateHitbox();
		downloadO.x -= downloadO.width/2;
		downloadO.y -= downloadO.height/2;
		downloadO.blend = ADD;
		add(downloadO);

		deleteO = new NovaSprite(Paths.image('menus/motwmenu/delete'));
		deleteO.updateHitbox();
		deleteO.x -= deleteO.width/2;
		deleteO.y -= deleteO.height/2;
		deleteO.blend = ADD;
		add(deleteO);

		loading = new NovaSprite(Paths.image('menus/motwmenu/loading'));
		loading.addAnim('idle', 'loading', 40, true);
		loading.playAnim('idle');
		loading.updateHitbox();
		loading.x -= loading.width/2;
		loading.y -= loading.height/2;
		add(loading);

		mode = DOWNLOAD;
	}

	public dynamic function onClick() {}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.mouse.overlaps(this, ModOfTheWeekMenu.instance.camera)) {
			downloadO.visible = mode == DOWNLOAD;
			deleteO.visible = mode == DELETE;
			if (mode != LOADING && FlxG.mouse.justPressed) onClick();
		} else {
			downloadO.visible = false;
			deleteO.visible = false;
		}
	}
}

class ModOfTheWeekMenu extends SubStateBackend {

	public var bloom = new GaussianBlurShader(0.0);

	public var motw:ModOfTheWeekData;
	public var gradient:NovaSprite;
	public var motwLogo:NovaSprite;
	public var roundCorner:RoundCornerShader = new RoundCornerShader();

	public var modTitle:NovaText;
	public var modDesc:NovaText;

	public var thumbnail:NovaSprite;

	public var downloadIcon:DownloadIcon = new DownloadIcon();

	public var loadingIcon:NovaSprite;

	public var somethingChanged:Bool = false;

	public static var instance:ModOfTheWeekMenu;

	override public function new() {
		super();
		instance = this;
	}

	override function create() {
		super.create();

		FlxG.camera.addShader(bloom);

		camera = new FlxCamera();
		camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera, false);

		FlxTween.tween(bloom, { intensity: 20.0 }, 1, { ease: FlxEase.expoOut });

		gradient = new NovaSprite(Paths.image('menus/motwmenu/gradient'));
		gradient.shader = roundCorner;

		motwLogo = new NovaSprite(0, 70, Paths.image('menus/motwmenu/motw'));
		motwLogo.screenCenter(X);
		motwLogo.alpha = 0;
		add(motwLogo);
		FlxTween.tween(motwLogo, { alpha: 1 }, 0.5, { ease: FlxEase.expoOut });

		NovaUtils.loadURL('https://nebulastellanova.github.io/Violet-Engine-MoTW/', data->{
			motw = Json.parse(data);
			thumbnail = new NovaSprite(motw.thumbnailURL);
			thumbnail.shader = roundCorner;
			add(thumbnail);
			thumbnail.onLoaded = ()->{
				thumbnail.setGraphicSize(gradient.width, gradient.height);
				thumbnail.updateHitbox();
				thumbnail.screenCenter();
				add(gradient);
				loadingIcon.visible = false;
				downloadIcon.visible = true;
				downloadIcon.mode = DOWNLOAD;

				modTitle.text = motw.title;
				modDesc.text = motw.description;
				modTitle.updateHitbox();
				modDesc.updateHitbox();
				add(modTitle);
				add(modDesc);
				add(downloadIcon);

				for (i in ModdingAPI.availableMods) {
					if (i.id == motw.modID) downloadIcon.mode = DELETE;
				}

				thumbnail.x += FlxG.width;
				FlxTween.tween(thumbnail, { x: thumbnail.x - FlxG.width }, 0.5, { ease: FlxEase.expoOut });
			}
		});

		loadingIcon = new NovaSprite(Paths.image('menus/motwmenu/loading'));
		loadingIcon.addAnim('idle', 'loading', 40, true);
		loadingIcon.playAnim('idle');
		add(loadingIcon);

		modTitle = new NovaText(0, 0, 0, '', Paths.font('Tardling v1.1'));
		modDesc = new NovaText(0, 0, 0, '', Paths.font('PhantomMuff/empty letters'));

		downloadIcon.visible = false;
		downloadIcon.onClick = ()->{
			if (downloadIcon.mode == DELETE) {
				downloadIcon.mode = DOWNLOAD;
				if (Paths.fileExists('${ModdingAPI.MOD_FOLDER}/${motw.modID}.vmod', true)) FileSystem.deleteFile('${ModdingAPI.MOD_FOLDER}/${motw.modID}.vmod');
				for (i in ModdingAPI.availableMods) {
					if (i.id == motw.modID)
						FileUtil.deleteDirectory('${ModdingAPI.MOD_FOLDER}/${i.folder}');
				}
				somethingChanged = true;
			} else if (downloadIcon.mode == DOWNLOAD) {
				downloadMoTW();
				downloadIcon.mode = LOADING;
				somethingChanged = true;
			}
		}
	}

	function downloadMoTW() {
		NovaUtils.loadURL(motw.downloadURL, data->{
			File.saveBytes('${ModdingAPI.MOD_FOLDER}/${motw.modID}.vmod', data);
			downloadIcon.mode = DELETE;
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (Controls.back) close();
		gradient.screenCenter(Y);
		if (thumbnail != null) {
			gradient.x = thumbnail.x;
		}
		loadingIcon.screenCenter();

		modTitle.size = 75;
		modTitle.letterSpacing = -2;
		modTitle.x = gradient.x + 30;
		modTitle.y = gradient.y + gradient.height - 90;

		modDesc.size = 40;
		modDesc.letterSpacing = -3;
		modDesc.x = gradient.x + 30;
		modDesc.y = gradient.y + gradient.height - 50;

		downloadIcon.x = gradient.x + gradient.width - 55;
		downloadIcon.y = gradient.y + gradient.height - 55;
	}

	var closing:Bool = false;
	override function close() {
		FlxTween.cancelTweensOf(bloom);
		if (closing) super.close();
		closing = true;

		MainMenu.instance.canSelect = true;
		FlxTween.tween(motwLogo, { alpha: 0 }, 0.5, { ease: FlxEase.expoOut });
		FlxTween.tween(thumbnail, { x: thumbnail.x - FlxG.width }, 0.5, { ease: FlxEase.expoIn });
		FlxTween.tween(bloom, { intensity: 0.0 }, 0.5, { onComplete: _->{
			if (somethingChanged) {
				MainMenu.instance.reloadMods();
			} else {
				var mm = new MainMenu();
				mm.fadeIn = false;
				FlxG.switchState(mm);
				close();
			}
		}});
	}
}