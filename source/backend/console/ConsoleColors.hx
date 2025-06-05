package backend.console;

enum abstract ConsoleColors(String) {
	var BLACK =         "\x1b[30m";
	var DARKBLUE =      "\x1b[34m";
	var DARKGREEN =     "\x1b[32m";
	var DARKCYAN =      "\x1b[36m";
	var DARKRED =       "\x1b[31m";
	var DARKMAGENTA =   "\x1b[35m";
	var DARKYELLOW =    "\x1b[33m";
	var LIGHTGRAY =     "\x1b[37m";
	var GRAY =          "\x1b[90m";
	var BLUE =          "\x1b[94m";
	var GREEN =         "\x1b[92m";
	var CYAN =          "\x1b[96m";
	var RED =           "\x1b[91m";
	var MAGENTA =       "\x1b[95m";
	var YELLOW =        "\x1b[93m";
	var WHITE =         "\x1b[97m";
}