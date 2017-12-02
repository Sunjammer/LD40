import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import glm.Vec2;
import MapGenerator.Direction;
import MapGenerator.DirectionExtensions;
import MapGenerator.Tile;
import MapGenerator.TileMap;

class Node implements Tile {

    private var north:Bool;
    private var east:Bool;
    private var south:Bool;
    private var west:Bool;

    public function new() {
        north = false;
        east = false;
        south = false;
        west = false;
    }

    public function isOpen(): Bool {
        return north || east || south || west;
    }
    
    public function isPathOpen(direction: Direction): Bool {
        switch (direction) {
            case Direction.North: return north;
            case Direction.East: return east;
            case Direction.South: return south;
            case Direction.West: return west;
        }
    }

    public function setPathOpen(direction: Direction) {
        switch (direction) {
            case Direction.North: north = true;
            case Direction.East: east = true;
            case Direction.South: south = true;
            case Direction.West: west = true;
        }
    }
}

class Tree {
    public var parent:Tree;

    public function new() {
        this.parent = null;
    }

    public function getRoot(): Tree {
        return parent != null ? parent.getRoot() : this;
    }

    public function isConnected(other: Tree): Bool {
        return getRoot() == other.getRoot();
    }

    public function connect(other: Tree) {
        other.getRoot().parent = this;
    }
}

class Edge {
    public var coord: Vec2;
    public var dir: Direction;

    public function new(coord: Vec2, dir: Direction) {
        this.coord = coord;
        this.dir = dir;
    }

    public static function generateEdges(width: UInt, height: UInt): Array<Edge> {
        var edges = new Array<Edge>();
        for (y in 1...height) {
            for (x in 1...width) {
                edges.push(new Edge(new Vec2(x, y), Direction.North));
                edges.push(new Edge(new Vec2(x, y), Direction.West));
            }
        }
        return edges;
    } 
}

class Kurskal implements TileMap {

    private var nodes: Array<Node>;
    private var width: UInt;
    private var height: UInt;

    private function new(width: UInt, height: UInt, nodes: Array<Node>) {
        this.width = width;
        this.height = height;
        this.nodes = nodes;
    }

    public function getTile(position: Vec2): Tile {
        return nodes[offset(position, width, height)];
    }

    public function getBitmap(): Bitmap {
        return null;
    }

    public function getWidth(): UInt {
        return width;
    }

    public function getHeight(): UInt {
        return height;
    }

    private static function offset(coord: Vec2, width: UInt, height: UInt): UInt {
        var x = Math.floor(coord.x);
        var y = Math.floor(coord.y);
        return y * height + x;
    }

    public static function generate(randomSeed: Int, width: UInt, height: UInt): TileMap {
        var edges = Randomize.shuffle(Edge.generateEdges(width, height));
        var tileCount = width * height;
        var tiles = [for(i in 0...tileCount) new Node()];
        var sets = [for(i in 0...tileCount) new Tree()];

        while (edges.length > 0) {
            var edge = edges.pop();   
            var newCoord = edge.coord + DirectionExtensions.toVec2(edge.dir);
            var offset1 = offset(edge.coord, width, height);
            var offset2 = offset(newCoord, width, height);
            var set1 = sets[offset1];
            var set2 = sets[offset2];

            if (!set1.isConnected(set2)) {
                set1.connect(set2);

                var tile1 = tiles[offset1];
                var tile2 = tiles[offset2];

                tile1.setPathOpen(edge.dir);
                tile2.setPathOpen(DirectionExtensions.getOppositeDirection(edge.dir));
            }
        }
        return new Kurskal(width, height, tiles);
    }
}