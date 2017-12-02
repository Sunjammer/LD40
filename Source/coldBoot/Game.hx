package coldBoot;
import openfl.display.Shape;
import openfl.display.Sprite;
import tween.Delta;
import tween.easing.Elastic;

interface IState {
	function enter(g: Game): Void;
	function update(g: Game, dt: Float): IState;
	function render(g: Game): Void;
	function exit(g: Game): Void;
}

class InitialState extends Shape implements IState {
	public function new() {
		super();  
		graphics.beginFill(0xff0000);
		graphics.drawCircle(100, 100, 100);
	}
	
	public function enter(g: Game): Void {
		g.addChild(this);
		alpha = 0;
		Delta.tween(this).prop("alpha", 1, 2).ease(Elastic.easeIn);
		trace("Entering initial state");
	}
	
	public function update(g: Game, dt: Float): IState {
		return this;
	}
	
	public function render(g: Game): Void {
		
	}
	
	public function exit(g: Game): Void {
		trace("Exiting initial state");
		g.removeChild(this);
	}
}

class Game extends Sprite
{
	var currentState: IState;
	
	public function new() 
	{
		super();
		setState(new InitialState());
	}
	
	public function update(dt: Float) {
		Delta.step(dt);
		currentState.update(this, dt);
	}
	
	public function render() {
		currentState.render(this);
	}
	
	public function setState(s: IState): IState {
		if (currentState != null) {
			currentState.exit(this);
		}
		currentState = s;
		currentState.enter(this);
		return currentState;
	}
	
}