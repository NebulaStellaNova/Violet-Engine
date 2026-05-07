package violet.backend.online;

import flixel.util.typeLimit.OneOfTwo;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.text.FlxText;
import violet.backend.options.Options;
import violet.data.character.Character;
import violet.backend.display.BetterBitmapData;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.ui.Keyboard;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

import io.colyseus.Client;
import io.colyseus.Room;
import io.colyseus.serializer.schema.Callbacks;

class NetworkManager {

    private static var instance:NetworkManager;
    public static function init() instance = new NetworkManager();

	private var client:Client;
	private var room:Room<MyRoomState>;
    private var ms:Float = 0;
    private var canUpdate:Bool = false;

	private var cats:Map<String, Character> = new Map();
    private var names:Map<String, FlxText> = new Map();

    public static var keyPressSignal:FlxTypedSignal<OneOfTwo<FlxKey, String>->Void> = new FlxTypedSignal();
    public static var keyReleaseSignal:FlxTypedSignal<OneOfTwo<FlxKey, String>->Void> = new FlxTypedSignal();

	public function new() {
		// this.client = new Client("ws://192.168.0.5:2567");
		this.client = new Client("ws://violet-engine.playit.plus:1306");

        this.joinRoom();
        this.lobbyRoom();
        this.queueRoom();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		FlxG.signals.preUpdate.add(onUpdate);
        FlxG.signals.focusLost.add(()->{
            if (canUpdate && frame > 10)
                this.room.send('updateUser', { who: this.room.sessionId, displayName: Options.data.displayName + '\nTabbed Out' });

        });
	}

    private function joinRoom():Void {
		this.client.joinOrCreate("my_room", [], MyRoomState, function(err, room) {
            if (err != null) {
                trace("[MyRoom] error: " + err);
                return;
            }

			trace("[MyRoom] roomId: " + room.roomId);

            this.room = room;

            var callbacks = Callbacks.get(this.room);

            callbacks.onAdd("players", (player, key) -> {
                trace("PLAYER ADDED AT: ", key);

                /* var cat = new Character('bf');
                cat.flipX = true;
                this.cats.set(key, cat);
                cat.x = player.x;
                cat.y = player.y;
                FlxG.state.add(cat);

                var displayNameText = new FlxText(0, 0, 0, 'Loading...');
                this.names.set(key, displayNameText);
                displayNameText.y = player.y - 50;
                displayNameText.antialiasing = false;
                displayNameText.size = 25;
                cat.updateHitbox();
                displayNameText.updateHitbox();
                displayNameText.extra.set('offsetX', (cat.width/2)  - (displayNameText.width/2));
                displayNameText.x = player.x + displayNameText.extra.get('offsetX');
                FlxG.state.add(displayNameText); */

				callbacks.onChange(player, () -> {
				});

                /* callbacks.listen(player, "displayName", (value, previousValue) -> {
                    trace("PLAYER displayName CHANGED: " + value + " => " + previousValue);
                }); */

                /* callbacks.listen(player, "x", (value, previousValue) -> {
                    trace("PLAYER X CHANGED: " + value + " => " + previousValue);
					this.cats.get(key).x = player.x;
					this.names.get(key).x = player.x + this.names.get(key).extra.get('offsetX');
                });

                callbacks.listen(player, "y", (value, previousValue) -> {
                    trace("PLAYER Y CHANGED: " + value + " => " + previousValue);
					this.cats.get(key).y = player.y;
					this.names.get(key).y = player.y - 50;
					this.names.get(key).y += this.cats.get(key)._data.offsets[1];
                }); */

                callbacks.listen(player, "disconnected", (value, previousValue) -> {
                    // flag disconnecting players with alpha 0.5
                    /* this.cats.get(key).alpha = (value) ? 0.5 : 1;
					this.names.get(key).text = "Disconnected..."; */
                });

                callbacks.onAdd(player, "items", (item, key) -> {
                    // FlxTimer.wait(1, ()->canUpdate = true);
                    trace("ITEM ADDED AT: " + key + " => " + item);
                });

                callbacks.onRemove(player, "items", (item, key) -> {
                    trace("ITEM REMOVED AT: " + key + " => " + item);
                });

            });

            callbacks.onRemove("players", (player, key) -> {
                trace("PLAYER REMOVED AT: ", key);
                /* FlxG.state.remove(this.cats.get(key));
                FlxG.state.remove(this.names.get(key));
                this.cats.remove(key);
                this.names.remove(key); */
            });

            callbacks.listen("currentTurn", (turn, previousValue) -> {
                trace("CURRENT TURN: " + turn);
            });

            this.room.onMessage('keyState', (data)->{
                if (data.who != this.room.sessionId) {
                    switch (data.state) {
                        case "down":
                            keyPressSignal.dispatch(data.key);
                        case "up":
                            keyReleaseSignal.dispatch(data.key);
                    }
                }
            });

            this.room.onMessage('playAnim', (data)->{
                // this.cats.get(data.who).playSingAnim(data.direction, false, true);
            });

            this.room.onMessage('updateUser', (data)->{
                if (!canUpdate) return;
                // this.names.get(data.who).text = data.displayName;
            });

            this.room.onStateChange += (state) -> {
            };

            this.room.onMessage("weather", (message) -> {
                // trace("[MyRoom] weather => " + message.weather);
            });

            this.room.onError += (code: Int, message: String) -> {
                trace("[MyRoom] error: " + code + " => " + message);
            };

            var pingTimer = new haxe.Timer(2000); // 2 seconds delay
            pingTimer.run = () -> {
                this.room.ping((latency: Float) -> {
                    ms = latency;
                });
            };

            this.room.onLeave += (code: Int) -> {
                trace("[MyRoom] leave, code: " + code);
                pingTimer.stop();
            };

        });
    }

    private function lobbyRoom():Void {
		this.client.joinOrCreate("lobby", [], function(err, room: Room<Dynamic>) {
            if (err != null) {
                trace("[Lobby] error: " + err);
                return;
            }

			trace("[Lobby] roomId: " + room.roomId);

            room.onMessage("rooms", (rooms: Dynamic) -> {
                trace("[Lobby] rooms: " + rooms);
            });

            room.onMessage("+", (message: Dynamic) -> {
                trace("[Lobby] room added: " + message[0] + " => ");
                trace(message[1]);
            });

            room.onMessage("-", (roomId: String) -> {
                trace("[Lobby] room removed: " + roomId);
            });

            room.onLeave += (code: Int) -> {
                trace("[Lobby] leave, code: " + code);
            };

        });
    }

    private function queueRoom():Void {
		this.client.joinOrCreate("queue", [], function(err, room: Room<Dynamic>) {
            if (err != null) {
                trace("[Queue] error: " + err);
                return;
            }

			trace("[Queue] roomId: " + room.roomId);

            room.onMessage("clients", (clients: Int) -> {
                trace("[Queue] clients: " + clients);
            });

            room.onMessage("seat", (seat: Dynamic) -> {
                trace("[Queue] seat: " + seat);

                // confirm the seat consumption, so the server can close the queue room
                room.send("confirm");

                this.client.consumeSeatReservation(seat, MyRoomState, function(err, newRoom: Room<MyRoomState>) {
                    if (err != null) {
                        trace("[Queue consumeSeatReservation] error: " + err);
                        return;
                    }

                    trace("[Queue consumeSeatReservation] seat consumed: " + room.roomId);

                    newRoom.onLeave += (code: Int) -> {
                        trace("[Queue consumeSeatReservation] newRoom leave, code: " + code);
                    };

                    // for demonstration, we .leave() here, but in a real application you would use the newRoom for the next steps
                    newRoom.leave();
                });

            });

            room.onLeave += (code: Int) -> {
                trace("[Queue] leave, code: " + code);
            };

        });
    }

    var frame = 0;
	private function onUpdate():Void {
        if (canUpdate)
            this.room.send('updateUser', { who: this.room.sessionId, displayName: Options.data.displayName + '\nPing: ${ms}ms' });
        frame++;
    }

	private function onKeyDown(evt:KeyboardEvent):Void {
        if (this.room == null) return;
        if (!FlxG.keys.checkStatus(evt.keyCode, JUST_PRESSED)) return;

        this.room.send('keyState', {
            who: this.room.sessionId,
            key: evt.keyCode,
            state: "down"
        });

        for (group in ['note_left', 'note_down', 'note_up', 'note_right']) {
            for (i in Options.data.controls.get(group)) {
                if (FlxG.keys.checkStatus(FlxKey.fromString(i), JUST_PRESSED)) {
                    this.room.send('keyState', {
                        who: this.room.sessionId,
                        key: group,
                        state: "down"
                    });
                }
            }
        }

        var stuff = [Keyboard.A, Keyboard.S, Keyboard.W, Keyboard.D].indexOf(evt.keyCode);
        if (stuff != -1) {
            this.room.send('playAnim', {
                direction: stuff,
                who: this.room.sessionId
            });
        }
	}

	private function onKeyUp(evt:KeyboardEvent):Void {
        if (this.room == null) return;
        if (!FlxG.keys.checkStatus(evt.keyCode, JUST_RELEASED)) return;
        this.room.send('keyState', {
            who: this.room.sessionId,
            key: evt.keyCode,
            state: "up"
        });

        for (group in ['note_left', 'note_down', 'note_up', 'note_right']) {
            for (i in Options.data.controls.get(group)) {
                if (FlxG.keys.checkStatus(FlxKey.fromString(i), JUST_RELEASED)) {
                    this.room.send('keyState', {
                        who: this.room.sessionId,
                        key: group,
                        state: "up"
                    });
                }
            }
        }
    }
}
