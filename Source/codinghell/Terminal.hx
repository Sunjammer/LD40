package codinghell;
import coldBoot.Game;
import coldBoot.cpu.*;
import flash.display.Sprite;
import flash.text.TextFormat;
import lime.ui.KeyCode;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.GridFitType;
import openfl.text.TextField;
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
  static inline var COLOR:Int = 0xFF0000;
  static inline var CARETCHAR:String = "//";
  var terminalWidth:Int;
  var game:Game;

  public function new(game:Game, terminalWidth:Int) {
    super();
    this.game = game;
    this.terminalWidth = terminalWidth;
    
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
   
    updateUi();
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
    updateUi();
  }
  
  public function updateUi() {
    x = game.viewportSize.width - terminalWidth;
    
    statusText.text = ("mode:" + state).toUpperCase();
    input.width = output.width = statusText.width = terminalWidth;
    removeChildren();
    addChild(statusText);
    addChild(input);
    
    switch(state){
      case Edit:
        input.y = statusText.height;
        input.height = game.viewportSize.height - input.y;
      case Status:
        addChild(output);
        input.height = 20;
        output.y = statusText.height;
        output.height = game.viewportSize.height - input.height - statusText.height;
        input.y = game.viewportSize.height - input.height;
    }
    
    
    graphics.clear();
    graphics.beginFill(0);
    graphics.drawRect(0, 0, terminalWidth, game.viewportSize.height);
    
    graphics.beginFill(COLOR);
    graphics.drawRect(0, input.y, terminalWidth, 3);
    graphics.beginFill(COLOR);
    graphics.drawRect(0, statusText.y, terminalWidth, 3);
    graphics.beginFill(COLOR);
    graphics.drawRect(0, 0, 2, game.viewportSize.height);
    
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