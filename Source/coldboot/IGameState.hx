package coldboot;
import coldboot.IState;
import coldboot.RenderInfo;

interface IGameState extends IState
{
	function render(info:RenderInfo): Void;
	function getRootEntity(): Entity;
}