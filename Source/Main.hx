package;

import smashgl.SmashGL;
import coldboot.Game;
import haxe.Timer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

class Input
{
	public function new() { }
}

class Main extends Sprite
{
	var game: Game;
	var input: Input;
	public static var debugDraw: Sprite;

	var prevTime: Float;
	public function new ()
	{
		super();

		#if debugger
			new debugger.Local(true);
		#end
    
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	function onAddedToStage(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		stage.addEventListener(Event.RESIZE, onStageResize);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);

		SmashGL.init();

		debugDraw = new Sprite();
		game = new Game({width:stage.stageWidth, height:stage.stageHeight});
		game.debugContainer.addChild(debugDraw);
		addChild(game);
		prevTime = Timer.stamp();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.application.onExit.add(function(code) { game.onExit(); } );
	}

	function onStageResize(e:Event):Void
	{
		game.resize({width:stage.stageWidth, height:stage.stageHeight});
	}

	function keyDown(e:KeyboardEvent):Void
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
