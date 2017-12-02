package coldBoot;
import openfl.display.Sprite;

interface IState {
	function enter(g: Game): Void;
	function update(g: Game, dt: Float): IState;
	function render(g: Game): Void;
	function exit(g: Game): Void;
}

class InitialState implements IState {
	public function new() { }
	
	public function enter(g: Game): Void {
		trace("Entering initial state");
	}
	
	public function update(g: Game, dt: Float): IState {
		return this;
	}
	
	public function render(g: Game): Void {
		
	}
	
	public function exit(g: Game): Void {
		trace("Exiting initial state");
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