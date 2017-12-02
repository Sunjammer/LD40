import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import glm.Vec2;

enum Direction {
    North;
    East;
    South;
    West;
}

interface Tile {
    public function isPathOpen(direction: Direction): Bool;
}

interface TileMap {
    public function getTile(position: Vec2): Tile;
    public function getBitmap(): Bitmap;
    public function getWidth(): UInt;
    public function getHeight(): UInt;
}

class MapGenerator {
    public static function recursiveBacktracking(startPoint: Point, width: UInt, height: UInt): TileMap {
        return RecursiveBacktracking.generate(startPoint, width, height);
    }
}
