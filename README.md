# LD40
Let's make a thing

### How to run
1. `openfl test neko`

### Visual Code code completion
1. Install https://marketplace.visualstudio.com/items?itemName=nadako.vshaxe
1. `openfl display neko > build.hxml`

### Auto-reload
1. `npm install`
1. `npm run start`
1. In a new terminal window run each time you have changed something `openfl build html5`



### Nonstandard dependencies
1. `haxelib git delta https://github.com/furusystems/Delta.git`
2. `cd AudioJank && haxelib dev AudioJank . && openfl rebuild AudioJank windows` (or `mac`) 