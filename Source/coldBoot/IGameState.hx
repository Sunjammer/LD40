package coldBoot;
import coldBoot.IState;
import coldBoot.RenderInfo;

interface IGameState extends IState
{
	function render(info:RenderInfo): Void;
	function getRootEntity(): Entity;
}