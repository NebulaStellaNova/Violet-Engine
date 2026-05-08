package violet.backend.objects.freeplay;

import violet.backend.shaders.RoundCornerShader;
import violet.backend.utils.ParseUtil;

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

class Album extends NovaSprite {

	public var id:String;
	public var _data:AlbumData;

	public var ostText(get, never):String;
	function get_ostText():String {
		return _data?.ostText ?? 'OFFICIAL OST';
	}

	public var artists(get, never):Array<String>;
	function get_artists():Array<String> {
		if (_data?.artists == null) return [];
		return _data.artists.copy();
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
		if (_data?.albumTitleOffsets == null) return [];
		return _data.albumTitleOffsets.copy();
	}

	public static var roundCornerShader:RoundCornerShader = new RoundCornerShader();

	public function new(id:String) {
		this.id = id;
		this._data = ParseUtil.jsonOrYaml('data/ui/freeplay/albums/$id');
		super(100, 210, Paths.image(albumArtAsset));
		this.offset.x = 100;
		setGraphicSize(250);
		updateHitbox();
		shader = roundCornerShader;
	}

}