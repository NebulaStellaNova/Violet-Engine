#!/usr/bin/env bash

mkdir .haxelib
haxelib --global update haxelib
haxelib fixrepo
printf INSTALL HAXELIB LIBS
haxelib install hxp
haxelib install flixel
haxelib install flixel-addons --skip-dependencies
haxelib install hxdiscord_rpc --skip-dependencies
haxelib install hxvlc --skip-dependencies
haxelib install hxWindowColorMode
haxelib install thx.core
haxelib install thx.semver
haxelib install yaml
printf INSTALL GIT LIBS
haxelib git hxcpp https://github.com/FunkinCrew/hxcpp
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis useGrig
haxelib git grig.audio https://github.com/FunkinCrew/grig.audio
haxelib git moonchart https://github.com/MaybeMaru/moonchart.git
haxelib git flxrhythmconductor https://github.com/PurSnake/FlxRhythmConductor --skip-dependencies
haxelib git lemon-ui https://github.com/NebulaStellaNova/LemonUI --skip-dependencies
haxelib git hxcpp-debug-server https://github.com/FunkinCrew/hxcpp-debugger
haxelib git hxhardware https://github.com/Vortex2Oblivion/hxhardware
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git lscript https://github.com/SrtHero278/lscript --skip-dependencies
haxelib git rulescript https://github.com/Kriptel/RuleScript dev
haxelib git flixel-animate https://github.com/NebulaStellaNova/flixel-animate bullshity-fix --skip-dependencies
haxelib git hython https://github.com/Paopun20/hython.git legacy