package coldBoot.ai;

import pathfinder.*;
import lime.math.Vector2;

class GameMap implements IMap {	
	public var rows( default, null ):Int;
	public var cols( default, null ):Int;

	public var cellSize:Float;
	var isWalkableData:Array<Bool>;

	public function new(p_cols:Int, p_rows:Int, cellSize:Float, isWalkableData:Array<Bool>)
	{
		cols = p_cols;
		rows = p_rows;
		this.cellSize = cellSize;
		this.isWalkableData = isWalkableData;
		// create an array of tiles, and determine if they are walkable or obstructed
	}
	
	public function isWalkable(p_x:Int, p_y:Int):Bool
	{
		return isWalkableIdx(posToNodeIdx(p_x, p_y));
	}

	public function isWalkableIdx(nodeIdx:Int):Bool
	{
		return this.isWalkableData[nodeIdx];
	}

	public function toNodeIdx(pos:Vector2):Int {
		return cast(pos.x/cellSize,Int) % cols
			+ cast((pos.y/cellSize) * cols, Int);
	}

	function posToNodeIdx(x:Int, y:Int):Int {
		return x % cols
			+ cast(y * cols, Int);
	}

	public function toCoordinate(nodeIdx:Int):Coordinate {
		return new Coordinate(nodeIdx % cols, cast(nodeIdx / cols, Int));
	}
}

class PathFinding {
	public function new() {

	}

	public function ShortestPath(sourceIdx:Int, toTargetIdx:Int, map:GameMap):Array<Vector2> {
		var source = map.toCoordinate(sourceIdx);
		var toTarget = map.toCoordinate(toTargetIdx);
		var pathFinder = new Pathfinder(map);
		return pathFinder.createPath(new Coordinate(cast(source.x, Int), cast(source.y, Int)), new Coordinate(cast(toTarget.x, Int), cast(toTarget.y, Int)), EHeuristic.PRODUCT, false, false).map(function(coord) {
			return new Vector2(coord.x*map.cellSize+map.cellSize/2, coord.y*map.cellSize+map.cellSize/2);
		});
	}
}