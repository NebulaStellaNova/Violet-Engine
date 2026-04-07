mkdir .haxelib
haxelib --global update haxelib
haxelib fixrepo
haxelib install hxp
haxelib install lime
haxelib install openfl
haxelib run lime setup
haxelib run openfl setup
haxelib git hxcpp https://github.com/FunkinCrew/hxcpp
haxelib git hxcpp-debug-server https://github.com/FunkinCrew/hxcpp-debugger