package violet.backend.online;

import flixel.util.FlxSignal;
import violet.states.menus.MainMenu;
import haxe.Json;
import sys.net.Host;
import sys.net.Socket;
import sys.thread.Thread;

typedef ClientOutput = {
    var uuid:Int;
    var event:ClientEvent;
}

typedef ClientEvent = {
    var type:ClientEventType;
    var ?key:String;
}

enum abstract ClientEventType(String) {
    var KEY_PRESS = 'press';
}

class SocketTest {
	public static var onDataRecieved:FlxTypedSignal<ClientOutput -> Void> = new FlxTypedSignal<ClientOutput -> Void>();

	static var uuid:Int = FlxG.random.int(100000000, 999999999);
    static var socket:Socket;
	public static function test() {
		socket = new Socket();
        try {
            socket.connect(new Host("127.0.0.1"), 8000);
			socket.setBlocking(false);
			socket.output.writeString('connect:$uuid');

			Thread.create(()->{
				listenToServer();
			});

        } catch (e:Dynamic) {
            trace("Connection failed: " + e);
        }
		FlxG.signals.preUpdate.add(()->update(FlxG.elapsed));
	}

	public static function update(elapsed:Float) {
		// sendData('$uuid:update');
        // Check for specific HaxeFlixel key states
        if (FlxG.keys.justPressed.SPACE) {
            sendData(toData({
				uuid: uuid,
				event: {
					type: KEY_PRESS,
					key: 'SPACE'
				}
			}));
        }

        // Example of movement input
        if (Controls.uiUp || Controls.uiDown) {
            sendData(toData({
				uuid: uuid,
				event: {
					type: KEY_PRESS,
					key: Controls.uiUp ? 'uiUp' : 'uiDown'
				}
			}));
        }
    }

	public static function sendData(msg:String) {
        if (socket != null) {
            try {
                socket.output.writeString(msg + "\n");
            } catch (e:Dynamic) {
                trace("Send failed: " + e);
            }
        }
    }

	static function listenToServer() {
        try {
            while (true) {
				try {
					var msg = socket.input.readLine();
					trace(msg);
					var data:ClientOutput = Json.parse('$msg'.replace('ACK_', ''));
					trace(data);
					if (data.uuid != uuid) {
						onDataRecieved.dispatch(data);
					}
				} catch (e:Dynamic) {
					// trace(e);
				}
                // This blocks, but only on the background thread!


                // If you need to move a sprite based on this,
                // it's best to store it in a variable and check it in update()
            }
        } catch (e:Dynamic) {
            trace("Lost connection to server.");
        }
    }

	public static function toData(yo:ClientOutput):String {
		return Json.stringify(yo);
	}
}