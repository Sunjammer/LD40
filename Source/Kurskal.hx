import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import glm.Vec2;
import MapGenerator.Direction;
import MapGenerator.Tile;
import MapGenerator.TileMap;

class Node implements Tile {

    public function new() {
        
    }

    public function isOpen(): Bool {
        return false;
    }
    public function isPathOpen(direction: Direction): Bool {
        return false;
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

class Kurskal {
    public static function generate(randomSeed: Int, width: UInt, height: UInt): TileMap {
        var edges = Randomize.shuffle(Edge.generateEdges(width, height));
        var tileCount = width * height;
        var tiles = [for(i in 0...tileCount) new Node()];
        var sets = [for(i in 0...tileCount) new Tree()];

        while (edges.length > 0) {
            var edge = edges.pop();
            
            //var newCoord

        }

        return null;
    }
}