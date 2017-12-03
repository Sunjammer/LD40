package codinghell;
import flash.display.Sprite;
import coldBoot.cpu.*;
import flash.text.TextFormat;
import lime.ui.KeyCode;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.text.AntiAliasType;
import openfl.text.Font;
import openfl.text.GridFitType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
/**
 * ...
 * @author Andreas Kennedy
 */
class CodingHell extends Sprite{
  var output:TextField;
  var input:TextField;

  public function new() {
    super();
    
    
    var tf = new TextFormat("Perfect DOS VGA 437 Win", 16);
    
    output = new TextField();
    input = new TextField();
    
    output.embedFonts = false;
    
    output.defaultTextFormat = input.defaultTextFormat = tf;
    
    input.type = TextFieldType.INPUT;
    output.type = TextFieldType.DYNAMIC;
    output.wordWrap = true;
    
    input.gridFitType = output.gridFitType = GridFitType.PIXEL;
    
    output.text = "Output here";
    input.text = "Input here";
    
    addChild(output);
    addChild(input);
    input.autoSize = TextFieldAutoSize.LEFT;
    
    input.addEventListener(FocusEvent.FOCUS_IN, onInputFocus);
    input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    
    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
  }
  
  function onKeyDown(e:KeyboardEvent):Void {
    if (e.keyCode == KeyCode.RETURN){
      output.text = input.text;
      input.text = "";
    }
  }
  
  function onInputFocus(e:FocusEvent):Void {
    input.text = "";
  }
  
  function onAddedToStage(e:Event):Void {
    removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    input.y = stage.stageHeight - input.height;
    input.width = output.width = stage.stageWidth;
    output.height = stage.stageHeight - input.height;
  }
  
}