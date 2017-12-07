package coldboot.map;

class Randomize {

	private static var seedRandom:Float;


	public static function setSeedRandom(seed:Float) {
		seedRandom=seed;
	}

	public static function getSeededRandom(multiplicator:Float=1):Float {
		seedRandom=(seedRandom*9301+49297) % 233280;
		if (seedRandom<0) seedRandom*=-1;
		return (seedRandom / 233280.0)*multiplicator;
	}

	public static function getSeededRandomInt(multiplicator:Int=1):Int {
		return Std.int(getSeededRandom(multiplicator));
	}

	public static function getRandom(multiplicator:Float):Float {
		return Math.random()*multiplicator;
	}

	public static function getRandomInt(multiplicator:Int):Int {
		return Std.int(getRandom(multiplicator));
	}

    public static function shuffle<T>(arr:Array<T>):Array<T> {
		if (arr!=null) {
			for (i in 0...arr.length) {
				var j = int(0, arr.length - 1);
				var a = arr[i];
				var b = arr[j];
				arr[i] = b;
				arr[j] = a;
			}
		}
		return arr;
    }

    private static inline function int(from:Int, to:Int):Int {
		return from + Math.floor(((to - from + 1) * Randomize.getSeededRandom()));
    }
}