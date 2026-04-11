package violet.backend.utils;

class AnimationUtil {

	/**
	* Convert string such as "0, 1, 2, 3" or "0...3" to [0,1,2,3].
	*/
	public static function stringToIndices(string:String):Array<Int> {
		if (string == null) return [];
		string = string.replace(' ', '');
		var split = string.split(',');
		var indices = [];
		for (i in split) {
			if (Std.parseInt(i) != null && !i.contains('...'))
				indices.push(Std.parseInt(i));
			else {
				var split2 = i.split('...');
				if (split2[1] != null) {
					var start = Std.parseInt(split2[0]);
					var end = Std.parseInt(split2[1]);
					if (start == null || end == null) continue;
					for (n in start...(end + 1)) indices.push(n);
				}
			}
		}
		return indices;
	}

	/**
	* Convert indices to string.
	*/
	public static function indicesToString(array:Array<Int>) {
		if (array.length == 0) return '';
		var out:Array<String> = [];
		var start:Int = array[0];
		var prev:Int = array[0];
		for (i in 1...array.length) {
			var current = array[i];
			if (current == prev + 1) {
				prev = current;
			} else {
				if (start == prev) {
					out.push(Std.string(start));
				} else {
					out.push(start + '...' + prev);
				}
				start = current;
				prev = current;
			}
		}

		if (start == prev) {
			out.push(Std.string(start));
		} else {
			out.push(start + '...' + prev);
		}

		return out.join(', ');
	}

}