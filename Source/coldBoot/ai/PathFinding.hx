package coldBoot.ai;

import pathfinder.*;
import glm.Vec2;

class GameMap implements IMap {	
	public var rows( default, null ):Int;
	public var cols( default, null ):Int;

	public var cellSize:Float;
	public var isWalkableByIdx:Int -> Bool;

	public function new(p_cols:Int, p_rows:Int, cellSize:Float, isWalkableByIdx:Int -> Bool)
	{
		cols = p_cols;
		rows = p_rows;
		this.cellSize = cellSize;
		this.isWalkableByIdx = isWalkableByIdx;
		// create an array of tiles, and determine if they are walkable or obstructed
	}
	
	public function isWalkable(p_x:Int, p_y:Int):Bool
	{
		return isWalkableByIdx(posToNodeIdx(p_x, p_y));
	}

	public function toNodeIdx(pos:Vec2):Int {
		return Math.floor(pos.x/cellSize) % cols
			+ Math.floor(pos.y/cellSize) * cols;
	}

	public function posToNodeIdx(x:Int, y:Int):Int {
		return x % cols
			+ y * cols;
	}

	public function toCoordinate(nodeIdx:Int):Coordinate {
		return new Coordinate(nodeIdx % cols, Math.floor(nodeIdx / cols));
	}
}

class PathFinding {
	public function new() {

	}

	public function ShortestPath(sourceIdx:Int, toTargetIdx:Int, map:GameMap):Array<Vec2> {
		var source = map.toCoordinate(sourceIdx);
		var toTarget = map.toCoordinate(toTargetIdx);
		var pathFinder = new Pathfinder(map);
		return pathFinder.createPath(source, toTarget, EHeuristic.PRODUCT, false, false).map(function(coord) {
			return new Vec2(coord.x*map.cellSize+map.cellSize/2, coord.y*map.cellSize+map.cellSize/2);
		});
	}
}