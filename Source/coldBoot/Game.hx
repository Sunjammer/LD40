package coldBoot;
import coldBoot.Game;
import coldBoot.Game.IGameState;
import flash.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;
import tween.easing.Elastic;

typedef Entity = DisplayObjectContainer;

interface IState
{
	function enter(g: Game): Void;
	function update(g: Game, dt: Float): IGameState;
	function exit(g: Game): Void;
}

interface IGameState extends IState
{
	function render(g: Game): Void;
}

class InitialState extends Shape implements IGameState
{
	public function new()
	{
		super();
		graphics.beginFill(0xff0000);
		graphics.drawCircle(100, 100, 100);
	}

	public function enter(g: Game): Void
	{
		g.addChild(this);
		alpha = 0;
		Delta.tween(this).prop("alpha", 1, 2).ease(Elastic.easeIn);
		trace("Entering initial state");
	}

	public function update(g: Game, dt: Float): IGameState
	{
		return this;
	}

	public function render(g: Game): Void
	{

	}

	public function exit(g: Game): Void
	{
		trace("Exiting initial state");
		g.removeChild(this);
	}
}

class GamePlayState extends DisplayObjectContainer implements IGameState
{
	var rootEntity: Entity;
	
	public function new() 
	{
		super();
	}
	
	public function render(g:Game):Void
	{
		
	}

	public function enter(g:Game):Void
	{
		g.addChild(this);
	}

	public function update(g:Game, dt:Float):IGameState
	{
		
	}

	public function exit(g:Game):Void
	{
		g.removeChild(this);
	}
}

class Game extends Sprite
{
	var currentState: IGameState;

	public function new()
	{
		super();
		setState(new InitialState());
	}

	public function update(dt: Float)
	{
		Delta.step(dt);
		currentState.update(this, dt);
	}

	public function render()
	{
		currentState.render(this);
	}

	public function setState(s: IGameState): IGameState
	{
		if (currentState != null)
		{
			currentState.exit(this);
		}
		currentState = s;
		currentState.enter(this);
		return currentState;
	}

}