#!/bin/bash
set -x 

haxelib install all
haxelib run openfl setup
haxelib git hxcpp-debugger https://github.com/HaxeFoundation/hxcpp-debugger.git
haxelib git delta https://github.com/furusystems/Delta.git
cd AudioJank && haxelib dev AudioJank . && openfl rebuild AudioJank windows && cd ..
openfl test neko