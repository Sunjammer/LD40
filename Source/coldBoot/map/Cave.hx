package coldBoot.map;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import glm.Vec2;
import coldBoot.map.MapGenerator.Direction;
import coldBoot.map.MapGenerator.DirectionExtensions;
import coldBoot.map.MapGenerator.Tile;
import coldBoot.map.MapGenerator.TileMap;

class Grid {
    private var grid:Array<Bool>;
    private var width:UInt;
    private var height:UInt;

    public function new(width: UInt, height: UInt) {
        this.width = width;
        this.height = height;
        grid = [for(i in 0...(width * height)) false];
    }

    public function get(x: UInt, y: UInt): Bool {
        return grid[y * width + x];
    }

    public function set(x: UInt, y: UInt, b: Bool) {
        grid[y * width + x] = b;
    }

    public function clone(): Grid {
        var newGrid = new Grid(width, height);
        for (y in 0...height) {
            for (x in 0...width) {
                newGrid.set(x, y, get(x, y));
            }
        }
        return newGrid;
    }

    public function countAliveNeighbours(x: UInt, y: UInt): Int {
        var count = 0;
        for (i in -1...2) {
            for (j in -1...2) {
                var nx = x + i;
                var ny = y + j;
                if (i == 0 && j == 0) {
                } else if (nx < 0 || nx >= width || ny < 0 || ny >= height) {
                    count++;
                } else if (get(nx, ny)) {
                    count++;
                }
            }
        }
        return count;
    }
}

class Cave {

    static var CHANCE_TO_START_ALIVE: Float = 0.4;
    static var DEATH_LIMIT: Int = 3;
    static var BIRTH_LIMIT: Int = 4;

    var chanceToStartAlive: Float = CHANCE_TO_START_ALIVE;
    public var deathLimit: Int = DEATH_LIMIT;
    public var birthLimit: Int = BIRTH_LIMIT;

    public var bitmap: Bitmap;
    public var width: UInt;
    public var height: UInt;

    var grid: Grid;
    
    public function new(seed: Int, chanceToStartAlive: Float, width: UInt, height: UInt) {
        this.chanceToStartAlive = chanceToStartAlive;
        this.width = width;
        this.height = height;
        Randomize.setSeedRandom(seed);
        grid = new Grid(width, height);
        initializeGrid(grid);
    }

    public function getBitmap(): Bitmap {
        var bitmapData = new BitmapData(width, height, false, 0xff000000);
        for (y in 0...height) {
            for (x in 0...width) {
                if (grid.get(x, y)) {
                    bitmapData.setPixel(x, y, 0xffffffff);
                }
            }
        }
        return new Bitmap(bitmapData);
    }

    public function doSimulationStep() {
        this.grid = simulationStep(this.grid);
    }

    private function simulationStep(oldGrid: Grid): Grid {
        var newGrid = oldGrid.clone();
        for (x in 0...width) {
            for (y in 0...height) {
                var neighbourCount = oldGrid.countAliveNeighbours(x, y);
                if (oldGrid.get(x, y)) {
                    if (neighbourCount < deathLimit)
                        newGrid.set(x, y, false);
                    else
                        newGrid.set(x, y, true);
                } else {
                    if (neighbourCount > birthLimit)
                        newGrid.set(x, y, true);
                    else
                        newGrid.set(x, y, false);
                }
            }
        }
        return newGrid;
    }

    private function initializeGrid(grid: Grid) {
        for (y in 0...height) {
            for (x in 0...width) {
                grid.set(x, y, Randomize.getSeededRandom() < chanceToStartAlive);
            }
        }
    }
}