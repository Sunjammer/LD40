package coldBoot;
import coldBoot.IGameState;
import coldBoot.states.InitialState;
import coldBoot.IGameState;
import flash.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;
import tween.easing.Elastic;

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