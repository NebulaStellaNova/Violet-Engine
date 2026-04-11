package violet.ui.freeplay;

import flixel.group.FlxSpriteGroup;
import violet.ui.freeplay.AlbumData;
import violet.backend.utils.ParseUtil;
import violet.backend.objects.special_thanks.GenzuSprite;

class Album extends FlxSpriteGroup {

	public var id:String;
	public var _data:AlbumData;

	public var name(get, never):String;
	function get_name():String {
		return _data?.name ?? id;
	}

	public var ostText(get, never):String;
	function get_ostText():String {
		return _data?.ostText ?? 'OFFICIAL OST';
	}

	public var artists(get, never):Array<String>;
	function get_artists():Array<String> {
		return (_data?.artists ?? []).copy();
	}

	public var albumArtAsset(get, never):String;
	function get_albumArtAsset():String {
		return _data?.albumArtAsset ?? '';
	}

	public var albumTitleAsset(get, never):String;
	function get_albumTitleAsset():String {
		return _data?.albumTitleAsset ?? '';
	}

	public var albumTitleOffsets(get, never):Array<Float>;
	function get_albumTitleOffsets():Array<Float> {
		return (_data?.albumTitleOffsets ?? []).copy();
	}

	public function new(id:String) {
		super();
		setAlbum(id);
	}

	var prevAlbum:String;
	var image:GenzuSprite;
	var textImage:GenzuSprite;
	public function setAlbum(id:String) {
		if (prevAlbum == id) return;
		prevAlbum = id;

		_data = ParseUtil.yaml('data/ui/freeplay/albums/$id');
		if (image != null) remove(image);
		if (textImage != null) remove(textImage);

		image = new GenzuSprite(1028, 250, Paths.image(albumArtAsset));
		image.antialiasing = true;
		image.scale.set(1.25, 1.25);
		image.updateHitbox();
		image.angle = 10;

		textImage = new GenzuSprite(1010, 530, Paths.image(albumTitleAsset));
		textImage.addAnim('static', 'idle', 24);
		textImage.addAnim('switch', 'switch', null, [], 24);
		textImage.playAnim('switch');
		textImage.animation.onFinish.add((_)->{
			textImage.playAnim('static');
		});
		textImage.antialiasing = true;
		textImage.scale.set(1.25, 1.25);
		textImage.x += albumTitleOffsets[0];
		textImage.y += albumTitleOffsets[1];
		textImage.updateHitbox();

		add(image);
		add(textImage);
	}

}