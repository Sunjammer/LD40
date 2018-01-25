haxelib install all
haxelib run openfl setup
haxelib git fsignal https://github.com/furusystems/FSignal.git
haxelib git hxcpp-debugger https://github.com/HaxeFoundation/hxcpp-debugger.git
haxelib git delta https://github.com/furusystems/Delta.git
cd AudioJank/project/audio_lib && cargo build --release && cd ../../..
openfl rebuild hxcpp windows
openfl rebuild AudioJank windows
openfl test windows
