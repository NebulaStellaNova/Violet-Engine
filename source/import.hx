#if !macro
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import violet.backend.Controls;
import violet.backend.filesystem.Cache;
import violet.backend.filesystem.Paths;
import violet.backend.objects.ClassData;
import violet.backend.objects.NovaSprite;
import violet.backend.objects.NovaText;

#if MOD_SUPPORT
import violet.backend.filesystem.ModdingAPI;
#end

using Lambda;
using StringTools;
#end