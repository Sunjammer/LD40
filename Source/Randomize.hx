
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
}