package violet.data;

import thx.semver.Version;

class Constants {
    public static var MENU_MUSIC:String = "mainMenuTheme";

    /**
	 * The current version of the engine.
	 */
    public static var ENGINE_VERSION(default, null):Version = "0.0.0"; // Changes at runtime.
    public static final ENGINE_TITLE:String = "Violet Engine";
	public static var ENGINE_SUFFIX:String = "beta";

    /**
	 * The latest version of the engine.
	 */
	public static var LATEST_ENGINE_VERSION(default, null):Version = "0.0.0"; // Changes at runtime.

    /**
	 * If true a new update was released for the engine!
	 */
	public static var UPDATE_AVAILABLE(default, null):Bool = false;

	/**
	 * Health you gain from hitting a note.
	 */
	public static var DEFAULT_HEALTH_GAIN = 0.01;

	/**
	 * Health you lose from missing a note.
	 */
	public static var DEFAULT_HEALTH_LOSS = 0.05;

	/**
	 * The default health icon if it can't find it.
	 */
	public static var DEFAULT_HEALTH_ICON = "face";
}