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
    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
  
  function onAddedToStage(e:Event):Void {
    removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    stage.addEventListener(Event.RESIZE, onStageResize);
		
		debugDraw = new Sprite();
    game = new Game({width:stage.stageWidth, height:stage.stageHeight});
		addChild(game);
		addChild(debugDraw);
		prevTime = Timer.stamp();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		addEventListener(KeyboardEvent.KEY_UP, keyUp);
    
  }
  
  function onStageResize(e:Event):Void {
    game.resize({width:stage.stageWidth, height:stage.stageHeight});
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
    #if !ogl
    game.render(dt);
    #end
	}
}
