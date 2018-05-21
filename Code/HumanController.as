package  {
	import flash.events.*;
	import flash.utils.*;
	
	public class HumanController {
		
		public var char;
		private var unit;
		
		private var lastPressed:int = 0;
		private var upTime:Number;
		
		public function HumanController(char_controller, game) {
			// constructor code
			char = char_controller;			
			unit = char.unit;
			
			game.addEventListener(Event.ENTER_FRAME, update_function(game));
		}
		
		
		private function update_function(game):Function {
			return function(E:Event):void {				
				game.addEventListener(KeyboardEvent.KEY_UP, keysUp);
				game.addEventListener(KeyboardEvent.KEY_DOWN, keysDown);
			};
		}
		
		private function keysUp(K:KeyboardEvent):void {
			if (K.keyCode == 37) {
				char.setLeftKeyState(false);
				lastPressed = K.keyCode;
				upTime = getTimer();
			}
			if (K.keyCode == 39) {
				char.setRightKeyState(false);
				lastPressed = K.keyCode;
				upTime = getTimer();
			}
			if (K.keyCode == 38) {
				char.setUpKeyState(false);
			}
			if (K.keyCode == 40) {
				char.setDownKeyState(false);
			}
			if (K.keyCode == 79) { // o - guard
				char.setGuardKeyState(false);
			}
		}
		
		private function keysDown(K:KeyboardEvent):void {
			if (K.keyCode == 37) {
				char.setLeftKeyState(true);
				char.setRightKeyState(false);
				detectDoubleTap(K.keyCode);
			}
			if (K.keyCode == 39) {
				char.setRightKeyState(true);
				char.setLeftKeyState(false);
				detectDoubleTap(K.keyCode);
			}
			if (K.keyCode == 38) {
				char.setUpKeyState(true);
				char.setDownKeyState(false);
			}
			if (K.keyCode == 40) {
				char.setDownKeyState(true);
				char.setUpKeyState(false);
			}
			if (K.keyCode == 79) { // o - guard
				char.setGuardKeyState(true);
			}
		}
		
		private function detectDoubleTap(nextPressed):void {
			if (lastPressed == nextPressed) {
				var downTime = getTimer();
				var delay = (downTime - upTime) * 0.001;
				if (delay <= 0.2) {
					char.doubleTapDetected(nextPressed);
				}
			}
		}
		
		public function getPlayerX():Number {
			return char.getPlayerX();
		}
		
		public function getPlayerY():Number {
			return char.getPlayerY();
		}
	}
	
}
