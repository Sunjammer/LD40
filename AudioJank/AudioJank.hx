package;


import lime.system.CFFI;
import lime.system.JNI;


class AudioJank {
	
	
	public static function sampleMethod (inputValue:Int):Int {
		return audiojank_sample_method(inputValue);
	}
	
	
	private static var audiojank_sample_method = CFFI.load ("audiojank", "audiojank_sample_method", 1);
    
}