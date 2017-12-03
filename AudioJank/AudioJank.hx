package;

import lime.system.CFFI;
import lime.system.JNI;

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
    public static function createContext() {
        audiojank_create_context();
    }
    private static var audiojank_create_context = CFFI.load("audiojank", "audiojank_create_context", 0);

    public static function playSampleInSpace(sampleId: SampleId, relativeX: Float, relativeY: Float) {
        audiojank_play_sample_in_space(sampleId, relativeX, relativeY);
    }
    private static var audiojank_play_sample_in_space = CFFI.load("audiojank", "audiojank_play_sample_in_space", 3);
}