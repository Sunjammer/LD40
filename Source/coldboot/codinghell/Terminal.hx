package coldboot.codinghell;
import coldboot.Game;
import coldboot.cpu.*;
import flash.display.Sprite;
import flash.text.TextFormat;
import lime.ui.KeyCode;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.GridFitType;
import openfl.text.TextField;
import coldboot.rendering.opengl.Shader;
/**
 * ...
 * @author Andreas Kennedy
 */

 enum TerminalState{
  Edit;
  Status;
 }
 
class Terminal extends Sprite{
  var output:TextField;
  var input:TextField;
  var inputTextBfr:String;
  var outputTextBfr:String;
  var state:TerminalState;
  var statusText:openfl.text.TextField;
  static inline var COLOR:Int = 0xFFFFFF;
  static inline var CARETCHAR:String = "//";
  var terminalWidth:Int;
  var game:Game;

  var dims:{width:Float, height:Float, margin:Float};

  public function new(game:Game) {
    super();
    this.game = game;
    this.terminalWidth = 250;
    
    state = Status;
    
    var tf = new TextFormat("Perfect DOS VGA 437 Win", 16, COLOR);
    
    output = new TextField();
    input = new TextField();
    statusText = new TextField();
    
    statusText.embedFonts = input.embedFonts = output.embedFonts = false;
    statusText.defaultTextFormat = output.defaultTextFormat = input.defaultTextFormat = tf;
    
    output.wordWrap = true;
    
    statusText.gridFitType = input.gridFitType = output.gridFitType = GridFitType.PIXEL;
    
    setOutputText("output here\ngolddarnit");
    setInputText("input here");
    statusText.text = "Status";
    statusText.height = 20;
    statusText.selectable = output.selectable = input.selectable = false;
    
    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
   
    updateUi(game.viewportSize.width, game.viewportSize.height, 20);
  }
  
  public function setOutputText(string:String) {
    outputTextBfr = string;
    var i = 0;
    output.text = (i++)+": " + outputTextBfr.split("\n").join("\n" + (i++) + ": ");
  }
  
  public function setInputText(string:String) {
    inputTextBfr = string;
    input.text = inputTextBfr.toUpperCase() +CARETCHAR;
  }
  
  function onKeyDown(e:KeyboardEvent):Void {
    switch(e.keyCode){ 
      case KeyCode.SPACE:
        if(e.ctrlKey)
          Shader.reloadAll();
      case KeyCode.RETURN:
        onReturn();
      case KeyCode.ESCAPE:
        setState(Status);
      case KeyCode.BACKSPACE:
        if(inputTextBfr.length>0)
          setInputText(inputTextBfr.substr(0, inputTextBfr.length - 1));
      default:
        setInputText(inputTextBfr + String.fromCharCode(e.charCode));
    }
  }
  
  function onReturn() {
    switch(state){
      case Edit:
        setInputText("");
      case Status:
        setState(Edit);
    }
  }
  
  function setState(state:TerminalState){
    this.state = state;
    updateUi(dims.width, dims.height, dims.margin);
  }
  
  public function updateUi(inWidth:Float, inHeight:Float, margin:Float) {
    dims = {width:inWidth, height:inHeight, margin:margin};
    var dh = dims.height - dims.margin * 2;
    this.x = dims.width - terminalWidth - dims.margin;
    this.y = dims.margin;
    
    statusText.text = ("mode:" + state).toUpperCase();
    input.width = output.width = statusText.width = terminalWidth;
    removeChildren();
    addChild(statusText);
    addChild(input);
    
    switch(state){
      case Edit:
        input.y = statusText.height;
        input.height = dh - input.y;
      case Status:
        addChild(output);
        input.height = 20;
        output.y = statusText.height;
        output.height = dh - input.height - statusText.height;
        input.y = dh - input.height;
    }
    
    
    graphics.clear();
    graphics.beginFill(0);
    graphics.drawRect(0, 0, terminalWidth, dh);
    
    var linew = 3;
    graphics.beginFill(COLOR);
    graphics.drawRect(0, input.y, terminalWidth, linew);
    graphics.beginFill(COLOR);
    graphics.drawRect(0, statusText.y, terminalWidth, linew);
    graphics.beginFill(COLOR);
    graphics.drawRect(0, 0, linew, dh);
    graphics.beginFill(COLOR);
    graphics.drawRect(0, dh, terminalWidth, linew);
    graphics.beginFill(COLOR);
    graphics.drawRect(terminalWidth, 0, linew, dh+linew);
    
  }
    
  function onAddedToStage(e:Event):Void {
    removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
  }
  
  function onRemovedFromStage(e:Event):Void {
    removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    
  }
  
}