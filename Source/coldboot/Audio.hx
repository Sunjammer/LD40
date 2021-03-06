package coldboot;
#if cpp
	import cpp.vm.Thread;
#elseif neko
	import neko.vm.Thread;
#end

/**
 * ...
 * @author Andreas Kennedy
 */

enum AudioStatus {
	Uninitialized;
	Initializing;
	Ready;
}

enum AudioCommand {
	ShutDown;
	PlayBoot(volume:Float);
	SetBgmVolume(volume:Float);
	PlaySound(sampleId:SampleId, relativeX:Float, relativeY:Float);
}

class Audio {

	static var instance:Audio;
	var audioThread:Thread;
	public static function getInstance() {
		if (instance == null)
			instance = new Audio();
		return instance;
	}

	var status:AudioStatus;
	function new() {
		status = Uninitialized;
	}

	public function init() {
		#if audio
		if (audioThread != null) return;
		audioThread = Thread.create(audio);
		audioThread.sendMessage(Thread.current());
		#end
	}

	public function exec(cmd:AudioCommand) {
		#if audio
		audioThread.sendMessage(cmd);
		#end
	}

	public function pollStatus():AudioStatus {
		#if audio
		var msg:AudioStatus = Thread.readMessage(false);
		if (msg == null) return status;
		return status = msg;
		#else
		return Ready;
		#end
	}

	#if AudioJank
	static function audio() {
		var mainThread = Thread.readMessage(true);

		mainThread.sendMessage(Initializing);
		AudioJank.createContext();
		mainThread.sendMessage(Ready);

		while (true) {
			switch (Thread.readMessage(true)) {
				case ShutDown:
					break;
				case PlayBoot(volume):
					AudioJank.playBootSequence(volume);
				case SetBgmVolume(volume):
					AudioJank.setBgmVolume(volume);
				case PlaySound(id, x, y):
					AudioJank.playSampleInSpace(id, x, y);
			}
		}
	}
	#end

}