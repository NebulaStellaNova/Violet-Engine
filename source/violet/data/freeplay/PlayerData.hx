package violet.data.freeplay;

typedef PlayerData = {
    /**
     * The name of the Player.
     */
    public var name:String;
    /**
     * The character IDs this character is associated with.
     * Song with these IDs will show up in Freeplay.
     */
    public var ownedChars:Array<String>;

    /**
     * Whether to show songs with character IDs that aren't associated with any specific character.
     */
    public var ?showUnownedChars:Bool;
    /**
     * Whether this character is unlocked by default.
     */
    public var ?unlocked:Bool;

    /**
     * Which freeplay style to use for this character.
     */
    public var ?freeplayStyle:Bool;
    /**
     * The default sticker pack to use for songs featuring this playable character.
     * This can be overwritten in any song.
     */
    public var ?stickerPack:Bool;
}