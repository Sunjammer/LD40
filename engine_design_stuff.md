# Engine design stuff

It's sort of meant to be a mess of ideas right now but here are the basic principles

#### Bootstrapping

*Main.hx* has three jobs: 

1. Hold an instance of Game
2. Frame update events from the window and drive the Game with it
3. Read input events from the window and pump to the Game

*Game*  is a Sprite, meaning it is a node in the display list that can hold children and can also draw using the `graphics` api. It is the basic canvas on which we can draw stuff and manage our game. Game also has a very basic state manager that takes instances of IGameState. IGameStates must implement enter, update, render and exit, and they get pointers to the Game where necessary for them to add themselves or remove themselves from the displaylist. 

#### Game states

Anything that implements IGameState can be a game state, but it will make the most sense if it is a DisplayObject like OpenGLView, Sprite, or Shape. When `enter` is called, the state typically adds itself to the `game` as a child so that it can be rendered. You switch game state by calling `game.setState` and then it is the state's responsibility to use the `exit` function to clean up after itself.  *There can never be parallel states in terms of who gets game or render updates*.

```haxe
public function setState(s:IGameState): IGameState
	{
		if (currentState != null)
			currentState.exit(this);
		currentState = s;
		currentState.enter(this);
		return currentState;
	}
```

Generally you don't use the constructor, but rather favor `enter`.

`update(info:UpdateInfo)` is the game update, and the info object contains deltatime, state time, game pointer and whatever else we deem necessary. The state should use this method and this info object to propagate the update to any entities.

`render(info:RenderInfo)`is the render update, and like with `update` this is where you propagate draw calls. Note that the kind of rendering you do here has a bunch of caveats: This is intended for the kind of traditional game loop rendering where you clear the screen every frame, so you'd stick your GL stuff in here or calls to the `graphics` api, but you should never do things with OpenFL's displaylist here. If you addChild a Sprite in your `enter`, and then set its x/y position in the `update`,  OpenFL is already going to render that sprite for you.

#### Input

Input is not managed yet, but I would like to maintain a dictionary of key/mouse states in Game and pass it in the UpdateInfo

#### Rendering

OpenFL is a reimplementation of the Flash API, so it has its own specific idea of how rendering works.  This doesn't give us a lot of hooks for fine control of the render/game update, so we're overriding the `__renderGL` function of Sprite so we can do GL-safe calls during OpenFL's internal render update, whatever form that might have while still have our calls respect OpenFL's internal draw call order, letting us do OpenGL-composited post processing on OpenFL-rendered items like text fields etc. 

We can't rely on **update** happening before **render** or vice versa.

You can see the sort of weird way this works by looking at how SceneRenderBase is hooked in, which is currently just the post processing system but will also probably be where we want to add entities that only draw with GL.

As described above, this mixture of renderers means we have to be aware of what kinds of draw calls go where: If you're not doing debug drawing with `Main.debugDraw` or GL calls, you should generally ignore the `render` update.

Personally I think Sprite/TextField/Bitmap and all that Flash jazz is perfect for UI, but for game rendering we should do as much GL as possible.

#### Entities

Entities are basically our Unity GameObjects, but they're not really developed yet. They're just nodes like what OpenFL has but without all the overhead, so we can really decide for ourselves what to do with them. I imagined Entities would only really be relevant to game updates to represent game state, or to be a graph that can be looked up during a GL-driven render update.