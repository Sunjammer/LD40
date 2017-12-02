package;
import coldBoot.Game;
import haxe.Timer;
import hscript.Interp;
import hscript.Parser;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite {
	var game: Game;
	
	public function test(): Void {
		trace("somethign");
	}
	
	var prevTime: Float;
	public function new () {
		super();
		
		game = new Game();
		addChild(game);
		prevTime = Timer.stamp();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		var p = new Parser();
		var prog = p.parseString(
			"trace('hello world' + foo); funcdood();"
		);
		var i = new Interp();
		i.variables["foo"] = 132;
		i.variables["funcdood"] = test;
		i.execute(prog);
	}
	
	function onEnterFrame(e:Event):Void
	{
		var newTime = Timer.stamp();
		var dt = newTime- prevTime;
		prevTime = newTime;
		
		game.update(dt);
		game.render();
	}
}
