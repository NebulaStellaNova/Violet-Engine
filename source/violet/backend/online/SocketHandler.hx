package violet.backend.online;

import violet.backend.utils.NovaUtils;
import flixel.util.FlxSignal;
import violet.states.menus.MainMenu;
import haxe.Json;
import sys.net.Host;
import sys.net.Socket;
import sys.thread.Thread;

typedef RoomData = {
	var title:String;
	var password:String;
	var id:Int;
}

typedef SendData = {
	var event:ClientEvent;
	var ?rooms:Array<RoomData>;
}

typedef ClientOutput = {
	> SendData,
    var uuid:Int;
	var ?roomID:Int;
}


typedef ClientEvent = {
    var type:ClientEventType;

    // Key Press Event
    var ?key:String;

    // Room Events
    var ?roomID:Int;
    var ?roomName:String;
    var ?roomPassword:String;
}

enum abstract ClientEventType(String) {
    var KEY_PRESS = 'press';
    var KEY_RELEASE = 'release';
    var JOIN_ROOM = 'join_room';
    var LEAVE_ROOM = 'leave_room';
    var CREATE_ROOM = 'create_room';
    var GET_ROOMS = 'get_rooms';

    var CONNECT = 'connect';
    var DISCONNECT = 'disconnect';
}

class SocketHandler {
	public static var onDataRecieved:FlxTypedSignal<ClientOutput -> Void> = new FlxTypedSignal<ClientOutput -> Void>();

	static var uuid:Int = FlxG.random.int(100000000, 999999999);
    static var socket:Socket;

	public static var connectedRoom:RoomData;

	@:unreflective
	private static var sendConnectSignal:Bool = false;

	public static function connect() {
		socket = new Socket();
        try {
            socket.connect(new Host("violet-engine.playit.plus"), 1090);
			socket.setBlocking(false);

			Thread.create(()->{
				listenToServer();
			});

        } catch (e:Dynamic) {
            trace("Connection failed: " + e);
        }
		FlxG.signals.preUpdate.add(()->update(FlxG.elapsed));
		sendConnectSignal = true;
	}

	public static function disconnect() {
		sendData({
			event: {
				type: DISCONNECT
			}
		});
	}

	public static function update(elapsed:Float) {
		if (sendConnectSignal) {
			sendConnectSignal = false;
			sendData({
				event: {
					type: CONNECT
				}
			});
		}
		// sendData('$uuid:update');
        // Check for specific HaxeFlixel key states
        if (FlxG.keys.justPressed.SPACE) {
            sendData({
				event: {
					type: KEY_PRESS,
					key: 'SPACE'
				}
			});
        }

        // Example of movement input
        if (Controls.uiUp || Controls.uiDown) {
            sendData({
				event: {
					type: KEY_PRESS,
					key: Controls.uiUp ? 'uiUp' : 'uiDown'
				}
			});
        }

		if (Controls.noteLeft || Controls.noteLeftReleased) {
			sendData({
				event: {
					type: Controls.noteLeft ? KEY_PRESS : KEY_RELEASE,
					key: 'note_left'
				}
			});
		}
		if (Controls.noteUp || Controls.noteUpReleased) {
			sendData({
				event: {
					type: Controls.noteUp ? KEY_PRESS : KEY_RELEASE,
					key: 'note_up'
				}
			});
		}
		if (Controls.noteDown || Controls.noteDownReleased) {
			sendData({
				event: {
					type: Controls.noteDown ? KEY_PRESS : KEY_RELEASE,
					key: 'note_down'
				}
			});
		}
		if (Controls.noteRight || Controls.noteRightReleased) {
			sendData({
				event: {
					type: Controls.noteRight ? KEY_PRESS : KEY_RELEASE,
					key: 'note_right'
				}
			});
		}
    }

	public static function sendData(data:SendData) {
		var out:ClientOutput = {
			uuid: uuid,
			roomID: connectedRoom?.id,
			event: data.event,
			rooms: data.rooms
		}
        if (socket != null) {
            try {
                socket.output.writeString(toData(out) + "\n");
            } catch (e:Dynamic) {
                trace("Send failed: " + e);
            }
        }
    }

	public static function joinRoom(title:String, password:String) {
		sendData({
			event: {
				type: GET_ROOMS
			}
		});
		var waiter = null;
		waiter = (data:ClientOutput) -> {
			if (data.rooms != null) {
				trace(data.rooms);
				onDataRecieved.remove(waiter);
				for (i in data.rooms) {
					if (i.title == title && i.password == password) {
						_joinRoom(i);
						NovaUtils.addNotification('Joined Room', 'Welcome to "${i.title}".', SUCCESS);
						return;
					}
				}
				NovaUtils.addNotification('Could Not Join Room!', 'Room does not exist or password is incorrect.', ERROR);
			}
		}
		onDataRecieved.add(waiter);
	}

	public static function createRoom(title:String, password:String) {
		sendData({
			event: {
				type: CREATE_ROOM,
				roomName: title,
				roomPassword: password
			}
		});
	}

	private static function _joinRoom(room:RoomData) {
		connectedRoom = room;
		sendData({
			event: {
				type: JOIN_ROOM,
				roomID: room.id
			}
		});
	}

	static function listenToServer() {
        try {
            while (true) {
				try {
					var msg = socket.input.readLine();
					var data:ClientOutput = Json.parse(msg);
					var thing = data.roomID != null && data.roomID == connectedRoom?.id;
					if (data.rooms != null) thing = true;
					if (data.uuid != uuid && thing) {
						trace(data);
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