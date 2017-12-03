package coldBoot.ai;

import glm.Vec2;
import haxe.ds.GenericStack;
import Random;

class PathMemory {
	var nodesVisited:Map<Int,Bool>;

	public function new() {
	}

	public function hasBeenHere(nodeIdx:Int) {
		return nodesVisited.exists(nodeIdx);
	}
}

interface EnemyController {
	public var position = new Vec2(0,0);
	public function move(dir:Vec2):Void;
}

class Message
{
	public var type:String;
	public var location:Vec2;
}

class SquadController {
	public function new() {
		
	}
	/*var backMessages = new Array<Message>();
	var frontMessages = new Array<Message>();
	var maxRange = 200;

	public function roger(location:Vec2) {
		frontMessages.push(new Message() {
			type: "roger",
			location: location
		});
	}

	public function pullMessage(location:Vec2) {
		for(msg in backMessages) {
			if(Vec2.distance(location, msg.location) < maxRange) {
				return msg;
			}
		}

		return null;
	}

	public function reset() {
		backMessages = frontMessages;
		frontMessages = new Array<Message>();
	}*/
}

class EnemyAI {
	var pathMemory:PathMemory;
	var controller:EnemyController;
	var map:PathFinding.GameMap;
	var enemyMap:PathFinding.GameMap;
	
	var currentPathStack:GenericStack<Int> = new GenericStack<Int>();
	var currentPath:Array<Vec2> = new Array<Vec2>();
	var currentTarget: Vec2;
	var knownWalkablePlaces:Array<Bool>;
	var isLeader:Bool;
	var squadController:SquadController;

	public function new(isLeader:Bool, squadController:SquadController, map:PathFinding.GameMap, controller:EnemyController) {
		this.controller = controller;
		this.isLeader = isLeader;
		this.squadController = squadController;
		pathMemory = new PathMemory();
		this.map = map;
		knownWalkablePlaces = new Array<Bool>();
		for(i in 0...map.cols*map.rows) {
			knownWalkablePlaces[i] = false;
		}
		knownWalkablePlaces[map.toNodeIdx(controller.position)] = true; // Add spawn point

		enemyMap = new PathFinding.GameMap(map.cols, map.rows, map.cellSize, function(idx) { 
			return knownWalkablePlaces[idx];
		});

		currentTarget = controller.position;
	}

	public function performAction() {
		if(currentPath.length == 0 && nearTarget())
		{
			controller.position = currentTarget;
			var currentIdx = map.toNodeIdx(controller.position);
			var currentPos = map.toCoordinate(currentIdx);

			var newStackItems = new Array<Int>();

			if(currentPos.y + 1 < map.rows)
			{
				var forwardIdx = map.posToNodeIdx(currentPos.x, currentPos.y + 1);
				if(map.isWalkableByIdx(forwardIdx) && !knownWalkablePlaces[forwardIdx])
				{
					newStackItems.push(forwardIdx);
					knownWalkablePlaces[forwardIdx] = true;
				}
			}

			if(currentPos.y - 1 >= 0)
			{
				var backwardIdx = map.posToNodeIdx(currentPos.x, currentPos.y - 1);
				if(map.isWalkableByIdx(backwardIdx) && !knownWalkablePlaces[backwardIdx])
				{
					newStackItems.push(backwardIdx);
					knownWalkablePlaces[backwardIdx] = true;
				}
			}

			if(currentPos.x + 1 < map.cols)
			{
				var rightIdx = map.posToNodeIdx(currentPos.x + 1, currentPos.y);
				if(map.isWalkableByIdx(rightIdx) && !knownWalkablePlaces[rightIdx])
				{
					newStackItems.push(rightIdx);
					knownWalkablePlaces[rightIdx] = true;
				}
			}

			if(currentPos.x - 1 >= 0)
			{
				var leftIdx = map.posToNodeIdx(currentPos.x - 1, currentPos.y);
				if(map.isWalkableByIdx(leftIdx) && !knownWalkablePlaces[leftIdx])
				{
					newStackItems.push(leftIdx);
					knownWalkablePlaces[leftIdx] = true;
				}
			}

			/*var msg = squadController.pullMessage(controller.position);
			if(msg != null && msg.type == "followMe" && !isLeader) {
				msg.location
			}
			else*/ {
				for(i in Random.shuffle(newStackItems)) {
					currentPathStack.add(i);
				}
			}

			var nextPath = currentPathStack.pop();
			if(nextPath != null) {
				currentPath = new PathFinding().ShortestPath(currentIdx, nextPath, this.enemyMap);
				currentPath.reverse();
			}

			/*if(isLeader) {
				squadController.followMe(controller.position);
			}*/
		}

		if(nearTarget()) {
			controller.position = currentTarget;
			if(currentPath.length > 0) {
				currentTarget = currentPath.pop();
			}
		}
		
		var dir = new Vec2(0,0);
		Vec2.normalize(currentTarget - controller.position, dir);
		controller.move(dir);
	}

	function nearTarget() {
		return Vec2.distance(currentTarget, controller.position) < 2;
	}
}