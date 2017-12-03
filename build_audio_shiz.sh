#!/bin/bash

cd AudioJank/project/audio_lib && cargo build --release && cd ../../..
cd AudioJank && haxelib dev AudioJank . && MACOSX_DEPLOYMENT_TARGET=10.7 openfl rebuild AudioJank macos -64 && cd ..
