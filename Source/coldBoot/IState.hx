package coldBoot;
import coldBoot.Game;
import coldBoot.IGameState;

interface IState
{
	function enter(g: Game): Void;
	function update(g: Game, dt: Float): IGameState;
	function exit(g: Game): Void;
}