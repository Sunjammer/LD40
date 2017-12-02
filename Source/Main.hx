package;
import coldBoot.Game;
import haxe.Timer;
import hscript.Interp;
import hscript.Parser;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;


class Input {
	public function new() { }
}

class Main extends Sprite {
	var game: Game;
	var input: Input;
	public static var debugDraw: Sprite;
	
	public function test(): Void {
		trace("somethign");
	}
	
	var prevTime: Float;
	public function new () {
		super();
		
		game = new Game();
		debugDraw = new Sprite();
		addChild(game);
		game.addChild(debugDraw);
		prevTime = Timer.stamp();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		addEventListener(KeyboardEvent.KEY_UP, keyUp);
    
	}
	
	function keyUp(e:KeyboardEvent):Void 
	{
		
	}
	
	function keyDown(e:KeyboardEvent):Void 
	{
		
	}
	
	function mouseUp(e:MouseEvent):Void 
	{
		
	}
	
	function mouseDown(e:MouseEvent):Void 
	{
		
	}
	
	function onEnterFrame(e:Event):Void
	{
		var newTime = Timer.stamp();
		var dt = newTime- prevTime;
		prevTime = newTime;
					
		debugDraw.removeChildren();
		debugDraw.graphics.clear();
		
		game.update(dt);
	}
}
