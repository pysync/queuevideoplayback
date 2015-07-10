package  {
	
	public class DragDrop {

		public function DragDrop() {
			// constructor code
		}

		
		import flash.display.Sprite;
import flash.geom.Point;
import flash.events.MouseEvent;

// PART I: - setup graphics

// setup right-panel
var panel: Sprite = new Sprite();
this.addChild(panel);
panel.graphics.beginFill(0x0000FF, 0.25);
panel.graphics.lineStyle(1, 0);
panel.graphics.moveTo(0, 0);
panel.graphics.lineTo(0, 300);
panel.graphics.lineTo(100, 300);
panel.graphics.lineTo(100, 0);
panel.graphics.endFill();
panel.x = 10;
panel.y = 50;

// setup left-panel
var holder: Sprite = new Sprite();
this.addChild(holder);
holder.graphics.beginFill(0xFF0000, 0.25);
holder.graphics.lineStyle(1, 0);
holder.graphics.moveTo(0, 0);
holder.graphics.lineTo(0, 300);
holder.graphics.lineTo(100, 300);
holder.graphics.lineTo(100, 0);
holder.graphics.endFill();
holder.x = 350;
holder.y = 50;

// setup default blocks
var blocks: Array = new Array();
var blockCount = 3;
var blockSize = 80;
var align = 10;
var span: Point = new Point(0, 5);

for (var i = 0; i < blockCount; i++) {
	var block: Sprite = new Sprite();
	var color = combineRGB(i * 128, i * 255, i * 128);
	block.graphics.beginFill(color);
	block.graphics.lineStyle(0, 0);
	block.graphics.moveTo(0, 0);
	block.graphics.drawRect(0, 0, blockSize, blockSize);
	block.graphics.endFill();
	block.x = align;
	block.y = blockSize * i + align;

	panel.addChild(block);
	blocks.push(block);
}


// global keep track variables
var movingBlock:Sprite;
var origin:Point = new Point();
var placed:int = 0;

// Part II: Add drag drop function
for (i = 0; i < blockCount; i++){
	blocks[i].addEventListener(MouseEvent.MOUSE_DOWN, startBlockMove);
}

function startBlockMove(event:MouseEvent):void {
	movingBlock = Sprite(event.target);
	origin.x = movingBlock.x;
	origin.y = movingBlock.y;
	
	stage.addEventListener(MouseEvent.MOUSE_MOVE, moveBlock);
}

function moveBlock(event:MouseEvent):void {
	var localMouse = panel.globalToLocal(new Point(stage.mouseX, stage.mouseY));
	movingBlock.x = localMouse.x - blockSize/2;
	movingBlock.y = localMouse.y - blockSize/2;
}
stage.addEventListener(MouseEvent.MOUSE_UP, stopMoving);

function stopMoving(event:MouseEvent):void {
	stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveBlock);
	snapInPlace();
	movingBlock = new Sprite();
	origin = new Point();
}

function snapInPlace():void{
	var hit:Boolean = holder.hitTestObject(movingBlock);
	if (hit) {
		
		panel.removeChild(movingBlock);
		holder.addChild(movingBlock);
		
		movingBlock.x = align;
		movingBlock.y = blockSize * placed + align;
		placed++;
		movingBlock.removeEventListener(MouseEvent.MOUSE_DOWN, startBlockMove);
	}
	else {
		movingBlock.x = origin.x;
		movingBlock.y = origin.y;
	}
}

// utils funcation
function combineRGB(red: Number, green: Number, blue: Number): Number {
	var RGB: Number;
	if (red > 255) {
		red = 255;
	}
	if (green > 255) {
		green = 255;
	}
	if (blue > 255) {
		blue = 255;
	}

	if (red < 0) {
		red = 0;
	}
	if (green < 0) {
		green = 0;
	}
	if (blue < 0) {
		blue = 0;
	}

	RGB = (red << 16) | (green << 8) | blue;

	return RGB;
}

	}
	
}
