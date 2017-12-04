#!/bin/bash
set -x

haxelib install all
haxelib run openfl setup
haxelib git fsignal https://github.com/furusystems/FSignal.git
haxelib git hxcpp-debugger https://github.com/HaxeFoundation/hxcpp-debugger.git
haxelib git delta https://github.com/furusystems/Delta.git
cd AudioJank/project/audio_lib && cargo build --release && cd ../../..
cd AudioJank && haxelib dev AudioJank . && MACOSX_DEPLOYMENT_TARGET=10.7 openfl rebuild AudioJank macos -64 && cd ..
openfl test neko
