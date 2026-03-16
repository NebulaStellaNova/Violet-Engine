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

        image = new GenzuSprite(Paths.image(albumArtAsset));
        image.y -= image.height / 2;
        image.antialiasing = true;
        image.angle = 10;
        image.updateHitbox();

        textImage = new GenzuSprite(Paths.image(albumTitleAsset));
        textImage.addAnim("static", "idle", 24);
        textImage.addAnim("switch", "switch", 24);
        textImage.playAnim("static");
        textImage.x -= 4 + albumTitleOffsets[0];
        textImage.y += 115 + albumTitleOffsets[1];
        textImage.antialiasing = true;
        textImage.updateHitbox();

        add(image);
        add(textImage);

        trace(_data);
        this.updateHitbox();
    }
}