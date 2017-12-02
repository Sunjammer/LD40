package coldBoot;
import coldBoot.IState;
import coldBoot.Game;

interface IGameState extends IState
{
	function render(g: Game): Void;
}