package violet.states.editors;

import violet.backend.utils.NovaUtils;
import lemonui.elements.MenuBar;
import violet.states.editors.sub.*;
import violet.backend.utils.JsonUtil;
import violet.states.menus.MainMenu;
import violet.data.character.CharacterData;
import yaml.Yaml;
import sys.FileSystem;
import violet.backend.utils.FileUtil;
import openfl.events.Event;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.net.FileReference;
import openfl.net.FileFilter;
import flixel.FlxSprite;

import violet.data.animation.AnimationData;
import lemonui.elements.NumericStepper;
import lemonui.elements.TextInput;
import lemonui.elements.Tickbox;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import lemonui.elements.TabPanel;
import violet.data.character.Character;
import violet.data.character.CharacterRegistry;
import lemonui.elements.Dropdown;
import lemonui.elements.MenuItem;
import violet.states.debug.EditorPickerMenu;
import violet.backend.utils.ParseUtil;
import lemonui.utils.ElementUtil;
import violet.backend.StateBackend;

using violet.backend.utils.MathUtil;
using violet.backend.utils.AnimationUtil;

typedef CameraTarget = {
	var x:Float;
	var y:Float;
	var zoom:Float;
}

class CharacterEditorState extends StateBackend {

	public static var instance:CharacterEditorState;
	public static var newList:Array<String> = [];

	public var characterList(get, never):Array<String>;
	function get_characterList() {
		var out = [for (i in CharacterRegistry.characterDatas.keys()) i];
		out.sort(NovaUtils.sortAlphabetically);
		return out;
	}

	public var animationList:Array<AnimationData> = [];
	public var selectedAnimation(get, never):AnimationData;
	function get_selectedAnimation() {
		for (i in animationList) {
			if (i.name == animationDropdown.selectedText.text) return i;
		}
		return animationList[0];// Null safety
	}

	public var bgCamera:FlxCamera;
	public var charCamera:FlxCamera;
	public var lemonCamera:FlxCamera;

	public var character:Character;
	public var ghost:Character;

	public var characterAnim(get, never):String;
	function get_characterAnim():String {
		return character.animation.name != null ? character.animation.name : character.anim.name;
	}

	public var ghostAnim(get, never):String;
	function get_ghostAnim():String {
		return ghost.animation.name != null ? ghost.animation.name : ghost.anim.name;
	}

	public var cameraTarget:CameraTarget = { x: 0, y: 0, zoom: 1 }
	public var copiedOffset:Array<Float> = [0, 0];
	
	public var lastMouseX:Float = 0;
	public var lastMouseY:Float = 0;

	// -- Character Window -- \\
	public var characterDropdown:Dropdown;

	// -- Properties Window -- \\
	public var name:TextInput;
	public var assetPath:TextInput;
	public var healthIcon:TextInput;
	public var deathCharacter:TextInput;
	public var scale:NumericStepper;
	public var singTime:NumericStepper;
	public var xOffsetGlobal:NumericStepper;
	public var yOffsetGlobal:NumericStepper;
	public var danceEvery:NumericStepper;
	public var cameraX:NumericStepper;
	public var cameraY:NumericStepper;
	public var isPixel:Tickbox;
	public var flipX:Tickbox;

	// -- Animation Window -- \\
	public var xOffsetStepper:NumericStepper;
	public var yOffsetStepper:NumericStepper;
	public var animationDropdown:Dropdown;
	public var fpsStepper:NumericStepper;
	public var assetPathField:TextInput;
	public var indicesField:TextInput;
	public var prefixField:TextInput;
	public var animFlipX:Tickbox;
	public var animFlipY:Tickbox;
	public var loopedBox:Tickbox;
	public var ghostBox:Tickbox;
	public var byLabel:Tickbox;

	public function new() {
		super();

		instance = this;
	}

	override function create() {
		super.create();
		FlxG.mouse.visible = true;

		newList = [];

		bgCamera = new FlxCamera();
		FlxG.cameras.add(bgCamera, false);

		charCamera = new FlxCamera();
		charCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(charCamera, false);

		lemonCamera = new FlxCamera();
		lemonCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(lemonCamera, false);

		var bg = new NovaSprite(Paths.image('menus/mainmenu/menuBGdesat'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.camera = bgCamera;
		add(bg);

		var crosshairH = new FlxSprite(-2000, -1).makeGraphic(4000, 2, FlxColor.WHITE);
		var crosshairV = new FlxSprite(-1, -2000).makeGraphic(2, 4000, FlxColor.WHITE);
		crosshairH.camera = charCamera;
		crosshairV.camera = charCamera;
		crosshairH.alpha = 0.5;
		crosshairV.alpha = 0.5;
		add(crosshairH);
		add(crosshairV);

		var menuBar = ElementUtil.buildFromXML(Paths.xml('data/ui/character-editor/menubar')).root;
		var bar:MenuBar = menuBar.findElement('menubar');
		menuBar.camera = lemonCamera;
		
		var newCharacter:MenuItem = menuBar.findElement('newCharacter');
		newCharacter.onClick = ()->{
			bar.closeAll();
			openSubState(new AtlasTypePrompt(
				function() {
					var dialog = new lime.ui.FileDialog();
					dialog.onSelect.add(function(path:String) {
						var id = haxe.io.Path.withoutDirectory(haxe.io.Path.withoutExtension(path));
						var dir = haxe.io.Path.directory(path);
						
						var pngPath = dir + "/" + id + ".png";
						var xmlPath = dir + "/" + id + ".xml";

						if (!FileSystem.exists(pngPath) || !FileSystem.exists(xmlPath)) return;

						var targetFolder = "resources/images/characters/";
						if (!FileSystem.exists(targetFolder)) FileSystem.createDirectory(targetFolder);

						sys.io.File.copy(pngPath, targetFolder + id + ".png");
						sys.io.File.copy(xmlPath, targetFolder + id + ".xml");

						var data:CharacterData = {
							version: "1.0.0",
							name: id,
							assetPath: "characters/" + id,
							offsets: [0, 0],
							cameraOffsets: [150, -100],
							animations: [],
							healthIcon: 'face'
						};

						var xmlContent = sys.io.File.getContent(targetFolder + id + ".xml");
						var xml = Xml.parse(xmlContent).firstElement();
						if (xml != null) {
							var animNames:Array<String> = [];
							var ereg = new EReg("([0-9]+)$", "");
							for (tex in xml.elementsNamed("SubTexture")) {
								var texName = tex.get("name");
								if (texName != null) {
									var cleanName = ereg.replace(texName, "");
									if (StringTools.endsWith(cleanName, " ")) cleanName = cleanName.substr(0, cleanName.length - 1);
									if (!animNames.contains(cleanName)) animNames.push(cleanName);
								}
							}
							for (anm in animNames) {
								data.animations.push({
									name: anm,
									prefix: anm,
									offsets: [0, 0],
									looped: false,
									flipX: false,
									flipY: false,
									frameRate: 24
								});
							}
						}

						CharacterRegistry.characterDatas.set(id, data);
						if (!newList.contains(id)) newList.push(id);
						refreshCharacterDropdown();
						for (i in 0...characterDropdown.options.length) {
							if (characterDropdown.options[i] == id) {
								characterDropdown.selectedIndex = i;
								characterDropdown.onChange(i, id);
								break;
							}
						}
					});
					dialog.browse(lime.ui.FileDialogType.OPEN, null, null, "Select Character PNG or XML");
				},
				function() {
					var dialog = new lime.ui.FileDialog();
					dialog.onSelect.add(function(path:String) {
						if (path == null || path == "") return;
						
						var id = haxe.io.Path.withoutDirectory(path);
						var activeMods = ModdingAPI.getActiveMods();
						var baseTarget = (activeMods != null && activeMods.length > 0) ? "mods/" + activeMods[0].id : Paths.ASSETS_FOLDER; 
						var targetFolder = baseTarget + "/images/characters/" + id;
						
						if (!FileSystem.exists(targetFolder)) FileSystem.createDirectory(targetFolder);

						for (file in FileSystem.readDirectory(path)) {
							sys.io.File.copy(path + "/" + file, targetFolder + "/" + file);
						}

						var data:CharacterData = {
							version: "1.0.0",
							name: id,
							assetPath: "characters/" + id,
							offsets: [0, 0],
							cameraOffsets: [150, -100],
							animations: [],
							healthIcon: 'face'
						};

						var animNames:Array<String> = [];
						var eregNum = new EReg("([0-9]+)$", "");
						var nameRegex = new EReg('"name"\\s*:\\s*"([^"]+)"', "g");

						for (file in FileSystem.readDirectory(targetFolder)) {
							if (StringTools.endsWith(file, ".json")) {
								var content = sys.io.File.getContent(targetFolder + "/" + file);
								var contentToSearch = content;
								while (nameRegex.match(contentToSearch)) {
									var texName = nameRegex.matched(1);
									var cleanName = eregNum.replace(texName, "");
									if (StringTools.endsWith(cleanName, " ")) cleanName = cleanName.substr(0, cleanName.length - 1);
									
									if (!animNames.contains(cleanName) && cleanName != "" && cleanName.toLowerCase() != "sprite" && cleanName.toLowerCase() != "animation") {
										animNames.push(cleanName);
									}
									contentToSearch = nameRegex.matchedRight();
								}
							}
						}

						for (anm in animNames) {
							data.animations.push({
								name: anm,
								prefix: anm,
								offsets: [0, 0],
								looped: false,
								flipX: false,
								flipY: false,
								frameRate: 24
							});
						}

						CharacterRegistry.characterDatas.set(id, data);
						if (!newList.contains(id)) newList.push(id);
						instance.refreshCharacterDropdown();
						for (i in 0...instance.characterDropdown.options.length) {
							if (instance.characterDropdown.options[i] == id) {
								instance.characterDropdown.selectedIndex = i;
								instance.characterDropdown.onChange(i, id);
								break;
							}
						}
					});
					dialog.browse(lime.ui.FileDialogType.OPEN_DIRECTORY, null, null, "Select Texture Atlas Folder");
				}
			));
		}
		
		var newAnimation:MenuItem = menuBar.findElement('newAnimation');
		newAnimation.onClick = ()->{
			bar.closeAll();
			openSubState(new NewAnimationScreen());
		}
		var exitToMenu:MenuItem = menuBar.findElement('exitToMenu');
		exitToMenu.onClick = ()->{
			for (i in newList) if (CharacterRegistry.characterDatas.exists(i)) CharacterRegistry.characterDatas.remove(i);
			ModdingAPI.reloadRegistries();
			FlxG.switchState(new MainMenu());
		};
		cast (menuBar.findElement('saveCharacter'), MenuItem).onClick = save;
		insert(10, menuBar);


		var characterWindow = ElementUtil.buildFromXML(Paths.xml('data/ui/character-editor/character-window')).root;
		characterWindow.x = FlxG.width - characterWindow.width - 10;
		characterWindow.y = 50;
		characterWindow.camera = lemonCamera;
		insert(10, characterWindow);

		var dropdown = ElementUtil.buildFromXML(Paths.xml('data/ui/character-editor/dropdown-window')).root;
		dropdown.x = FlxG.width - dropdown.width - 20 - characterWindow.width;
		dropdown.y = 50;
		dropdown.camera = lemonCamera;
		insert(10, dropdown);

		characterDropdown = dropdown.findElement('characterDropdown');

		name = characterWindow.findElement('name');
		assetPath = characterWindow.findElement('globalAssetPath');
		healthIcon = characterWindow.findElement('healthIcon');
		deathCharacter = characterWindow.findElement('deathCharacter');
		scale = characterWindow.findElement('scale');
		xOffsetGlobal = characterWindow.findElement('xOffsetGlobal');
		yOffsetGlobal = characterWindow.findElement('yOffsetGlobal');
		danceEvery = characterWindow.findElement('danceEvery');
		cameraX = characterWindow.findElement('cameraX');
		cameraY = characterWindow.findElement('cameraY');
		singTime = characterWindow.findElement('singTime');
		flipX = characterWindow.findElement('flipX');
		isPixel = characterWindow.findElement('isPixel');

		animationDropdown = characterWindow.findElement('animationDropdown');
		indicesField = characterWindow.findElement('frameIndices');
		assetPathField = characterWindow.findElement('assetPath');
		xOffsetStepper = characterWindow.findElement('xOffset');
		yOffsetStepper = characterWindow.findElement('yOffset');
		prefixField = characterWindow.findElement('prefixField');
		fpsStepper = characterWindow.findElement('fpsStepper');
		animFlipX = characterWindow.findElement('animFlipX');
		animFlipY = characterWindow.findElement('animFlipY');
		loopedBox = characterWindow.findElement('isLooped');
		ghostBox = characterWindow.findElement('isGhost');
		byLabel = characterWindow.findElement('byLabel');
		
		characterDropdown.onChange = function(v:Int, v2:String) {
			if (character != null) remove(character);
			if (ghost != null) remove(ghost);

			animationList = [];

			var selectedId = characterDropdown.options[v];

			ghost = new Character(selectedId);
			ghost.debug = true;
			ghost.allowOnComplete = false;
			ghost.camera = charCamera;
			ghost.updateHitbox();
			ghost.screenCenter();
			ghost.alpha *= 0.5;
			ghost.x -= ghost.globalOffset.x;
			ghost.y -= ghost.globalOffset.y;
			ghost.canDance = false;
			@:privateAccess ghost.__baseFlipped = false;
			add(ghost);

			character = new Character(selectedId);
			character.debug = true;
			character.allowOnComplete = false;
			character.camera = charCamera;
			character.updateHitbox();
			character.screenCenter();
			character.x -= character.globalOffset.x;
			character.y -= character.globalOffset.y;
			character.canDance = false;
			@:privateAccess character.__baseFlipped = false;
			add(character);

			if (newList.contains(selectedId)) {
				character._data = CharacterRegistry.characterDatas.get(selectedId);
				ghost._data = character._data;
			} else {
				ghost._data = character._data = character.cloneData();
			}

			name.text = character._data.name;
			assetPath.text = character._data.assetPath;
			healthIcon.text = character._data.healthIcon;
			deathCharacter.text = character._data.deathCharacter ?? '';
			scale.value = character._data.scale ?? 1;
			xOffsetGlobal.value = (character._data.offsets ?? [0, 0])[0];
			yOffsetGlobal.value = (character._data.offsets ?? [0, 0])[1];
			danceEvery.value = character._data.danceEvery;
			cameraX.value = character._data.cameraOffsets[0];
			cameraY.value = character._data.cameraOffsets[1];
			singTime.value = character._data.singTime;
			isPixel.checked = character._data.isPixel;
			flipX.checked = character._data.flipX;
			// singTime.value = character._data.singTime;

			// Yummy lambdas
			name.onChange = value -> character._data.name = value;
			healthIcon.onChange = value -> character._data.healthIcon = value;
			deathCharacter.onChange = value -> character._data.deathCharacter = value;
			danceEvery.onChange = value -> character._data.danceEvery = value;
			singTime.onChange = value -> character._data.singTime = value;
			xOffsetGlobal.onChange = value -> character._data.offsets[0] = value;
			yOffsetGlobal.onChange = value -> character._data.offsets[1] = value;
			cameraX.onChange = value -> character._data.cameraOffsets[0] = value;
			cameraY.onChange = value -> character._data.cameraOffsets[1] = value;
			isPixel.onChange = value -> character.antialiasing = !(character._data.isPixel = value);

			flipX.onChange = value -> {
				character._data.flipX = value;
				reloadCharacters();
			}

			assetPath.onChange = function(value:String) {
				assetPath.elementColor = 0xFF3d3f41;
				var imgPath = Paths.image(value);
				if (imgPath != null && imgPath != '' && value != '') {
					character._data.assetPath = value;
					
					var xmlPath = StringTools.replace(imgPath, ".png", ".xml");
					if (FileSystem.exists(xmlPath)) {
						var content = sys.io.File.getContent(xmlPath);
						var xml = Xml.parse(content).firstElement();
						if (xml != null) {
							var newAnims:Array<String> = [];
							var ereg = new EReg("([0-9]+)$", "");
							for (tex in xml.elementsNamed("SubTexture")) {
								var name = tex.get("name");
								if (name != null) {
									var cleanName = ereg.replace(name, "");
									if (StringTools.endsWith(cleanName, " ")) cleanName = cleanName.substr(0, cleanName.length - 1);
									if (!newAnims.contains(cleanName)) newAnims.push(cleanName);
								}
							}
							if (newAnims.length > 0) {
								if (character._data.animations == null) character._data.animations = [];
								for (anm in newAnims) {
									var exists = false;
									for (existing in character._data.animations) {
										if (existing.name == anm) exists = true;
									}
									if (!exists) {
										character._data.animations.push({
											name: anm,
											prefix: anm,
											offsets: [0, 0],
											looped: false,
											flipX: false,
											flipY: false,
											frameRate: 24
										});
									}
								}
							}
						}
					}
					reloadCharacters();
				} else {
					assetPath.elementColor = 0xff751b1b;
				}
			}

			scale.onChange = function(value:Float) {
				scale.elementColor = 0xFF3d3f41;
				if (value != 0) {
					character._data.scale = value;
					reloadCharacters();
				} else {
					assetPath.elementColor = 0xff751b1b;
				}
			}

			animationDropdown.onChange = (index, label) -> {
				character.playAnim(label, true);

				ghostBox.checked = ghostAnim == label;
				ghostBox.onChange = (value:Bool) -> {
					if (value) {
						ghost.playAnim(label, true);
					} else {
						ghost.canDance = true;
						ghost.dance(true);
						ghost.canDance = false;
					}
					ghostBox.checked = ghostAnim == label;
				}
				refreshAnimationDropdown();
				for (i in animationList) {
					if (i.name == label) {
						prefixField.text = i.prefix;
						loopedBox.checked = i.looped;
						animFlipX.checked = i.flipX;
						animFlipY.checked = i.flipY;
						byLabel.checked = i.byLabel ?? false;
						assetPathField.text = i.assetPath ?? '';
						indicesField.text = (i.frameIndices ?? []).indicesToString();
						fpsStepper.value = i.frameRate;
						xOffsetStepper.value = i.offsets[0];
						yOffsetStepper.value = i.offsets[1];
					}
				}

				prefixField.onSubmit = function(value:String) {
					selectedAnimation.prefix = value;
					refreshAnimations();
				}

				assetPathField.onChange = function(value:String) {
					assetPathField.elementColor = 0xFF3d3f41;

					if (value == '') {
						selectedAnimation.assetPath = null;
						refreshAnimations();
						return;
					}
					var animImg = Paths.image(value);
					if (animImg != null && animImg != '') {
						selectedAnimation.assetPath = value;
						refreshAnimations();
					} else {
						assetPathField.elementColor = 0xff751b1b;
					}
				}

				indicesField.onChange = function(value:String) {
					selectedAnimation.frameIndices = value.stringToIndices();
					refreshAnimations();
				}

				loopedBox.onChange = function(value:Bool) {
					selectedAnimation.looped = value;
					refreshAnimations();
				}

				animFlipX.onChange = function(value:Bool) {
					selectedAnimation.flipX = value;
					refreshAnimations();
				}

				animFlipY.onChange = function(value:Bool) {
					selectedAnimation.flipY = value;
					refreshAnimations();
				}

				byLabel.onChange = function(value:Bool) {
					selectedAnimation.byLabel = value;
					refreshAnimations();
				}

				fpsStepper.onChange = function(value:Float) {
					selectedAnimation.frameRate = Math.floor(value);
					refreshAnimations();
				}

				xOffsetStepper.onChange = function(value:Float) {
					selectedAnimation.offsets[0] = value;
					refreshAnimations();
				}

				yOffsetStepper.onChange = function(value:Float) {
					selectedAnimation.offsets[1] = value;
					refreshAnimations();
				}
			}

			refreshCharacterDropdown();
			characterDropdown.selectedText.text = v2;
			refreshAnimationDropdown();
			refreshAnimations(true);
			for (i => label in animationDropdown.listLabels) {
				if (label.text == characterAnim) {
					animationDropdown.onChange(i, label.text);
					break;
				}
			}
		}

		refreshCharacterDropdown();
	}

	public function refreshCharacterDropdown() {
		@:privateAccess characterDropdown.close();
		characterDropdown.clearOptions();
		for (i in characterList) {
			characterDropdown.addOption(CharacterRegistry.characterDatas.get(i).name, i);
			// add(character);
		}
	}

	public function refreshAnimationDropdown() {
		@:privateAccess animationDropdown.close();
		animationDropdown.clearOptions();
		for (i in animationList) {
			animationDropdown.addOption(i.name);
		}
		animationDropdown.selectedText.text = characterAnim ?? '';
		animationDropdown.selectedText.updateHitbox();
	}

	public function refreshAnimations(doArray:Bool = false) {
		var cGA = characterAnim;
		var pGA = ghostAnim;

		if (doArray) {
			animationList.resize(0);
			for (i in character._data.animations) {
				animationDropdown.addOption(i.name);
				animationList.push({
					name: i.name,
					prefix: i.prefix,
					assetPath: i.assetPath,
					offsets: [for (o in i.offsets) o],
					looped: i.looped ?? false,
					flipX: i.flipX ?? false,
					flipY: i.flipY ?? false,
					frameRate: i.frameRate ?? 24,
					frameIndices: i.frameIndices,
					byLabel: i.byLabel ?? true
				});
			}
		}

		for (i in character.animation.getNameList()) {
			character.removeAnim(i);
			ghost.removeAnim(i);
		}

		for (i in animationList) {
			i.offsets ??= [0, 0];
			i.offsets[0] *= -1;
			i.offsets[1] *= -1;
			character.addAnimFromData(i);
			ghost.addAnimFromData(i);
			i.offsets[0] *= -1;
			i.offsets[1] *= -1;
		}

		character.playAnim(cGA, true);
		ghost.playAnim(pGA, true);
		character.animation.finish();
		ghost.animation.finish();
	}

	public function reloadCharacters() {
		final prevCharAnim:String = characterAnim;
		final prevGhostAnim:String = ghostAnim;

		@:privateAccess character.__refresh();
		@:privateAccess ghost.__refresh();

		refreshAnimations();

		character.playAnim(prevCharAnim, true);

		character.camera = charCamera;
		character.updateHitbox();
		character.screenCenter();
		character.x -= character.globalOffset.x;
		character.y -= character.globalOffset.y;
		character.canDance = false;
		@:privateAccess character.__baseFlipped = false;

		ghost.playAnim(prevGhostAnim, true);

		ghost.camera = charCamera;
		ghost.updateHitbox();
		ghost.screenCenter();
		ghost.x -= ghost.globalOffset.x;
		ghost.y -= ghost.globalOffset.y;
		ghost.canDance = false;
		@:privateAccess ghost.__baseFlipped = false;
	}

	public function save() {
		FileUtil.openSaveDialog('Save Character!', FileUtil.characterFilter, (path:String)->{
			if (FileSystem.exists(path)) FileSystem.deleteFile(path);
			var data = character.cloneData();
			data.animations = animationList.copy();
			
			// -- Removes null and unchanged fields -- \\
			for (i in Reflect.fields(data)) if (Reflect.field(data, i) == null) Reflect.deleteField(data, i);
			for (anim in data.animations) {
				for (i in Reflect.fields(anim)) {
					var equal = true;
					if (Std.isOfType(Reflect.field(anim, i), Array)) {
						var a:Array<Float> = cast Reflect.field(violet.data.NullChecker.animationDefaults, i);
						var b:Array<Float> = cast Reflect.field(anim, i);
						for (ind=>v in a) {
							if (v != b[ind]) equal = false;
						}
					} else equal = false;
					if (Reflect.field(anim, i) == null || Reflect.field(anim, i) == Reflect.field(violet.data.NullChecker.animationDefaults, i) || equal) {
						Reflect.deleteField(anim, i);
					}
				}
			}
			// JsonUtil.stringify();
			sys.io.File.saveContent(path, ParseUtil.stringifyYaml(data));
		});
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (ElementUtil.anythingFocused) return;

		var movement:Int = FlxG.keys.pressed.SHIFT ? 20 : 5;
		cameraTarget.x += FlxG.keys.pressed.A ? -movement : FlxG.keys.pressed.D ? movement : 0;
		cameraTarget.y += FlxG.keys.pressed.W ? -movement : FlxG.keys.pressed.S ? movement : 0;
		
		if (FlxG.mouse.wheel != 0) {
			cameraTarget.zoom += (FlxG.mouse.wheel * 0.15) * cameraTarget.zoom;
			cameraTarget.zoom = FlxMath.bound(cameraTarget.zoom, 0.1, 50);
		}

		if (FlxG.mouse.justPressedRight || FlxG.mouse.justPressedMiddle) {
			lastMouseX = FlxG.mouse.screenX;
			lastMouseY = FlxG.mouse.screenY;
		} else if (FlxG.mouse.pressedRight || FlxG.mouse.pressedMiddle) {
			cameraTarget.x -= (FlxG.mouse.screenX - lastMouseX) / charCamera.zoom;
			cameraTarget.y -= (FlxG.mouse.screenY - lastMouseY) / charCamera.zoom;
			lastMouseX = FlxG.mouse.screenX;
			lastMouseY = FlxG.mouse.screenY;
		}

		if (FlxG.keys.pressed.CONTROL) {
			if (FlxG.keys.justPressed.C) {
				copiedOffset[0] = xOffsetStepper.value;
				copiedOffset[1] = yOffsetStepper.value;
			} else if (FlxG.keys.justPressed.V) {
				xOffsetStepper.onChange(copiedOffset[0]);
				yOffsetStepper.onChange(copiedOffset[1]);
			}
		}

		if (FlxG.keys.justPressed.R) {
			cameraTarget.x = 0;
			cameraTarget.y = 0;
			cameraTarget.zoom = 1;
		}

		if (FlxG.keys.justPressed.LEFT) xOffsetStepper.onChange(xOffsetStepper.value += FlxG.keys.pressed.SHIFT ? 1 : 10);
		if (FlxG.keys.justPressed.RIGHT) xOffsetStepper.onChange(xOffsetStepper.value -= FlxG.keys.pressed.SHIFT ? 1 : 10);

		if (FlxG.keys.justPressed.UP) yOffsetStepper.onChange(yOffsetStepper.value += FlxG.keys.pressed.SHIFT ? 1 : 10);
		if (FlxG.keys.justPressed.DOWN) yOffsetStepper.onChange(yOffsetStepper.value -= FlxG.keys.pressed.SHIFT ? 1 : 10);

		if (FlxG.keys.justPressed.SPACE) character.playAnim(characterAnim, true);

		if (FlxG.keys.justPressed.I) {
			animationDropdown.selectedIndex -= 1;
			animationDropdown.onChange(animationDropdown.selectedIndex, animationDropdown.options[animationDropdown.selectedIndex]);
		} else if (FlxG.keys.justPressed.K) {
			animationDropdown.selectedIndex += 1;
			animationDropdown.onChange(animationDropdown.selectedIndex, animationDropdown.options[animationDropdown.selectedIndex]);
		}

		charCamera.scroll.pointLerp(cameraTarget.x, 0.1, X);
		charCamera.scroll.pointLerp(cameraTarget.y, 0.1, Y);
		charCamera.zoom = charCamera.zoom.lerp(cameraTarget.zoom, 0.1);
	}
}

class AtlasTypePrompt extends flixel.FlxSubState {
	var onSparrow:Void->Void;
	var onTexture:Void->Void;

	public function new(onS:Void->Void, onT:Void->Void) {
		super(0x88000000);
		onSparrow = onS;
		onTexture = onT;
	}

	override function create() {
		super.create();
		cameras = [CharacterEditorState.instance.lemonCamera];

		var box = new flixel.FlxSprite().makeGraphic(500, 200, 0xFF222222);
		box.screenCenter();
		add(box);

		var title = new flixel.text.FlxText(0, box.y + 20, 0, "Choose Atlas Format", 24);
		title.screenCenter(flixel.util.FlxAxes.X);
		add(title);

		var txt1 = new flixel.text.FlxText(0, box.y + 75, 0, "1. Sparrow (PNG+XML)", 18);
		txt1.screenCenter(flixel.util.FlxAxes.X);
		add(txt1);

		var txt2 = new flixel.text.FlxText(0, box.y + 115, 0, "2. Texture Atlas (Folder)", 18);
		txt2.screenCenter(flixel.util.FlxAxes.X);
		add(txt2);

		var inst = new flixel.text.FlxText(0, box.y + 165, 0, "Press 1 or 2 (ESC to cancel)", 16);
		inst.screenCenter(flixel.util.FlxAxes.X);
		add(inst);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (flixel.FlxG.keys.justPressed.ONE) {
			close();
			if (onSparrow != null) onSparrow();
		} else if (flixel.FlxG.keys.justPressed.TWO) {
			close();
			if (onTexture != null) onTexture();
		} else if (flixel.FlxG.keys.justPressed.ESCAPE) {
			close();
		}
	}
}