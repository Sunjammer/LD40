package;

import lime.system.CFFI;

@:enum
abstract SampleId(Int) {
    var EnemyDialogueHigh1 = 0;
    var EnemyDialogueHigh2 = 1;
    var EnemyDialogueHigh3 = 2;
    var EnemyDialogueHigh4 = 3;
    var EnemyDialogueHigh5 = 4;
    var EnemyDialogueHigh6 = 5;
    var EnemyDialogueLow1 = 6;
    var EnemyDialogueLow2 = 7;
    var EnemyDialogueLow3 = 8;
    var EnemyDialogueLow4 = 9;
    var EnemyDialogueLow5 = 10;
    var EnemyDialogueLow6 = 11;
}

class AudioJank {
    static var audiojank_create_context;
	public static function createContext():Void {
		trace("Creating audio context");
		if (audiojank_create_context == null)
			audiojank_create_context = CFFI.load("audiojank", "audiojank_create_context", 0);
        audiojank_create_context();
    }

    static var audiojank_play_sample_in_space;
    public static function playSampleInSpace(sampleId: SampleId, relativeX: Float, relativeY: Float) {
		if (audiojank_play_sample_in_space == null)
			audiojank_play_sample_in_space = CFFI.load("audiojank", "audiojank_play_sample_in_space", 3);
        audiojank_play_sample_in_space(sampleId, relativeX, relativeY);
    }
	
	static var audiojank_context_play_boot_sequence_sample;
    public static function playBootSequence(vol: Float) {
		if (audiojank_context_play_boot_sequence_sample == null)
			audiojank_context_play_boot_sequence_sample = CFFI.load("audiojank", "audiojank_context_play_boot_sequence_sample", 1);
        audiojank_context_play_boot_sequence_sample(vol);
    }
	
	
	static var audiojank_context_set_bgm_volume;
    public static function setBgmVolume(vol: Float) {
		if (audiojank_context_set_bgm_volume == null)
			audiojank_context_set_bgm_volume = CFFI.load("audiojank", "audiojank_context_set_bgm_volume", 1);
        audiojank_context_set_bgm_volume(vol);
    }
}