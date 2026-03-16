package violet.ui.freeplay;

typedef AlbumData = {
    /**
     * The name of the Album. This won't show up anywhere in game.
     */
    public var name:String;
    /**
     * The OST Text at the top right of Freeplay.
     * leave it blank for defualt text.
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