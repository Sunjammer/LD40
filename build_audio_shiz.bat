cd AudioJank/project/audio_lib && cargo build --release && cd ../../..
cd AudioJank && haxelib dev AudioJank . && openfl rebuild AudioJank windows -64 && cd ..
