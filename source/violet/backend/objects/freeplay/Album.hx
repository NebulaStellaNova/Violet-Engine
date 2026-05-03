package violet.backend.objects.freeplay;

import violet.backend.shaders.RoundCornerShader;
import flixel.group.FlxSpriteGroup;
import violet.backend.utils.ParseUtil;
import violet.backend.objects.NovaSprite;

typedef AlbumData = {
	/**
	 * The name of the Album. This won't show up anywhere in game.
	 */
	public var name:String;
	/**
	 * The OST Text at the top right of Freeplay.
	 * leave it blank for default text.
	 */
	public var ?ostText:String;

	/**
	 * List of Artist that made the Album Art/
	 */
	public var ?artists:Array<String>;
	/**
	 * The asset path of the Album Art.
	 */
	public var ?albumArtAsset:String;

	/**
	 * The asset path to the Album Text. Appears under the art.
	 */
	public var ?albumTitleAsset:String;
	/**
	 * The Offsets for the Album Title.
	 */
	public var ?albumTitleOffsets:Array<Float>;
}

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

	public static var roundCornerShader:RoundCornerShader = new RoundCornerShader();

	var image:NovaSprite;
	public function setAlbum(id:String) {
		this.id = id;

		_data = ParseUtil.jsonOrYaml('data/ui/freeplay/albums/$id');
		if (image != null) remove(image);

		image = new NovaSprite(100, 210, Paths.image(albumArtAsset));
		image.setGraphicSize(250);
		image.updateHitbox();
		image.antialiasing = true;
		image.updateHitbox();
		image.shader = roundCornerShader;

		add(image);
	}

}