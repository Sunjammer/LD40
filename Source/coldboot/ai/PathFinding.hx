package coldboot.ai;

import pathfinder.*;
import glm.Vec2;
import fsignal.Signal1;

#if cpp
	import cpp.vm.Thread;
	import cpp.vm.Mutex;
#elseif neko
	import neko.vm.Thread;
	import neko.vm.Mutex;
#end

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

enum ThreadMessage{
	Command(cmd:PathCmd);
	Status(stat:PathStatus);
}

enum PathStatus {
	Dead;
	Idle;
	Searching(handle:Int);
	Resolved(handle:Int, path:Array<Vec2>);
	Failed(handle:Int);
	TimedOut(handle:Int);
}

enum PathCmd {
	Search(handle:Int, sourceIdx:Int, toTargetIdx:Int, map:GameMap);
	Kill;
	Abort(handle:Int);
}

class PathRequest{
	var mutex:Mutex;
	public var onComplete:Signal1<PathRequest>;
	public var onFail:Signal1<PathRequest>;
	public var id:Int;
	public var result:Array<Vec2>;
	public function new(id:Int){
		this.id = id;
		onComplete = new Signal1<PathRequest>();
		onFail = new Signal1<PathRequest>();
	}
}

class PathFindingWorker{
	public static function run(){
		var governorThread:Dynamic = Thread.readMessage(true);
		var msg:ThreadMessage = Thread.readMessage(true); 
		trace("Begin pathfinding");
		switch(msg){
			case Command(cmd):
				switch(cmd){
					case Search(handle, sourceIdx, toTargetIdx, map):
						//TODO: actually search
						trace("Execute search with failure");
						governorThread.sendMessage(Status(Failed(handle)));
					default:
						throw "First command must be a search";
				}
			default:
		}
	}
}

class PathFindingGov{
	public static function run(){
		var mainThread:Thread = Thread.readMessage(true);
		var workers = new Map<Int,Thread>();
		mainThread.sendMessage(Status(Idle));
		var numRequests:Int = 0;

		inline function removeRequest(handle:Int){
			workers.remove(handle);
			numRequests--;
		}

		while(true){
			var msg:ThreadMessage = Thread.readMessage(false);
			if(msg==null)
				continue;
			switch(msg){
				case Command(cmd):
					switch(cmd){
						case Kill:
							break;
						case Abort(id):
							trace("Abort "+id);
							removeRequest(id);
							if(numRequests<=0)
								break;
						case Search(handle, sourceIdx, toTargetIdx, map):
							trace("Start search: "+handle);
							var t = Thread.create(PathFindingWorker.run);
							t.sendMessage(Thread.current());
							t.sendMessage(Command(Search(handle, sourceIdx, toTargetIdx, map)));
							workers[handle] = t;
							numRequests++;
					}
				case Status(stat):
					switch(stat){
						case Resolved(handle, path):
							trace("Path resolved");
							mainThread.sendMessage(Status(Resolved(handle,path)));
							removeRequest(handle);
						case Failed(handle):
							trace("Couldn't resolve path");
							mainThread.sendMessage(Status(Failed(handle)));
							removeRequest(handle);
						default:
					}
			}
		}
		trace("Shutting down");
	}
}

class PathFinding {

	static var status:PathStatus = Dead;
	static var govThread:Thread;
	static var idPool:Int = 0;
	static var requests:Array<PathRequest>;
	static var running:Bool;
	public static function init(){
		if(running)return;
		govThread = Thread.create(PathFindingGov.run);
		govThread.sendMessage(Thread.current());
		requests = [];
		running = true;
	}

	public static function update(){
		if(!running) return;
		var msg:ThreadMessage = Thread.readMessage(false);

		if(msg==null)
			return;

		function findReq(id:Int):PathRequest{
			for(r in requests){
				if(r.id==id){
					return r;
				}
			}
			return null;
		}
		
		switch(msg){
			case Status(stat):
				switch(stat){
					case Resolved(handle, path):
						var r = findReq(handle);
						r.result = path;
						r.onComplete.dispatch(r);
						requests.remove(r);
					case Failed(handle):
						var r = findReq(handle);
						r.onFail.dispatch(r);
						requests.remove(r);
					default:
				}
			default:
		}
	}

	public static function abort(req:PathRequest){
		requests.remove(req);
		sendCmd(Abort(req.id));
	}

	public static function kill(){
		sendCmd(Kill);
		for(r in requests){
			r.onFail.dispatch(r);
		}
		requests = [];
		running = false;
	}

	static inline function sendCmd(cmd:PathCmd){
		govThread.sendMessage(Command(cmd));
	}

	public static function ShortestPathAsync(sourceIdx:Int, toTargetIdx:Int, map:GameMap):PathRequest {
		if(!running) init();
		var id = idPool++;
		var req = new PathRequest(id);
		requests.push(req);
		sendCmd(Search(id, sourceIdx, toTargetIdx, map));
		return req;
	}

	public static function ShortestPath(sourceIdx:Int, toTargetIdx:Int, map:GameMap):Array<Vec2> {
		return shortestPath(sourceIdx, toTargetIdx, map);
	}

	static function shortestPath(sourceIdx:Int, toTargetIdx:Int, map:GameMap):Array<Vec2>{
		var source = map.toCoordinate(sourceIdx);
		var toTarget = map.toCoordinate(toTargetIdx);
		var pathFinder = new Pathfinder(map);
		return pathFinder.createPath(source, toTarget, EHeuristic.PRODUCT, false, false).map(function(coord) {
			return new Vec2(coord.x*map.cellSize+map.cellSize/2, coord.y*map.cellSize+map.cellSize/2);
		});
	}
}