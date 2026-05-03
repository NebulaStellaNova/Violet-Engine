#!/usr/bin/env sh

set -eu

if ! command -v haxelib >/dev/null 2>&1; then
  echo "Error: haxelib is not installed or not in PATH! Is Haxe installed?" >&2
  exit 1
fi

mkdir -p .haxelib
haxelib --global update haxelib
haxelib fixrepo
haxelib install hxp
haxelib install lime
haxelib install openfl
haxelib git hxcpp https://github.com/FunkinCrew/hxcpp
