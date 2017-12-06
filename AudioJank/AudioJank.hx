package;

import lime.system.CFFI;

class AudioJank {
  static var audiojank_create_context:Dynamic;
  public static function createContext():Void {
    if (audiojank_create_context == null){
      audiojank_create_context = CFFI.load("audiojank", "audiojank_create_context", 0);
    }
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