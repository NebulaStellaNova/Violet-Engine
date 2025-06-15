package backend.scripts;
import flixel.util.typeLimit.OneOfThree;

typedef Script = OneOfThree<FunkinScript, LuaScript, PythonScript>;