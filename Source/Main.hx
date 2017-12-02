package;
import coldBoot.Game;
import haxe.Timer;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite {
	var game: Game;
	
	var prevTime: Float;
	public function new () {
		super();
		
		game = new Game();
		addChild(game);
		prevTime = Timer.stamp();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
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
