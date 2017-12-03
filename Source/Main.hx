package;
import coldBoot.Game;
import glm.Vec2;
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
		addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		addEventListener(KeyboardEvent.KEY_UP, keyUp);
		
		var p = new Parser();
		var prog = p.parseString(
			"trace('hello world' + foo); funcdood();"
		);
		var i = new Interp();
		i.variables["foo"] = 132;
		i.variables["funcdood"] = test;
		i.execute(prog);
	}
	
	function addedToStage(e:Event):Void 
	{
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
	
		
		removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		
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
		var x = e.localX;
		var y = e.localY;
		trace("MouseX "  + x + ", " + y);
		game.pulse(new Vec2(x,y));
	}
	
	function onEnterFrame(e:Event):Void
	{
		var newTime = Timer.stamp();
		var dt = newTime- prevTime;
		prevTime = newTime;
					
		debugDraw.removeChildren();
		debugDraw.graphics.clear();
		
		game.update(dt);
		game.render();
	}
}
