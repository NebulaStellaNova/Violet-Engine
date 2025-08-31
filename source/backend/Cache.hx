package backend;

import backend.objects.NovaSprite;

class Cache {
    public static var spriteCache:Map<String, NovaSprite>;

    public static function init() {
        spriteCache = new Map<String, NovaSprite>();
    }
}