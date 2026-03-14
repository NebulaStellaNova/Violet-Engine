mkdir .haxelib
haxelib --global update haxelib
haxelib fixrepo
@REM INSTALL HAXELIB LIBS
haxelib install flixel
haxelib install flixel-addons --skip-dependencies
haxelib install flixel-animate --skip-dependencies
haxelib install hxdiscord_rpc --skip-dependencies
haxelib install hxp
haxelib install hxvlc --skip-dependencies
haxelib install hxWindowColorMode
haxelib install moonchart
haxelib install thx.core
haxelib install thx.semver
haxelib install yaml
@REM INSTALL GIT LIBS
haxelib git flxrhythmconductor https://github.com/PurSnake/FlxRhythmConductor --skip-dependencies
haxelib git hxcpp https://github.com/FunkinCrew/hxcpp
haxelib git lemon-ui https://github.com/NebulaStellaNova/LemonUI --skip-dependencies
haxelib git hxcpp-debug-server https://github.com/FunkinCrew/hxcpp-debugger
haxelib git hxhardware https://github.com/Vortex2Oblivion/hxhardware
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git lscript https://github.com/SrtHero278/lscript
haxelib git rulescript https://github.com/Kriptel/RuleScript dev