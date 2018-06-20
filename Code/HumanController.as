package  {
	import flash.events.*;
	import flash.utils.*;
	import flash.display.MovieClip;
	
	public class HumanController {
		
		public var char;
		private var unit;
		
		private var lastPressed:int = 0;
		private var upTime:Number;
		
		private var tapTimeMS:int = 200;
		private var punchTime:Number = 0;
		
		public function HumanController(char_controller, gameStage) {
			// constructor code
			char = char_controller;			
			unit = char.unit;
			
			gameStage.addEventListener(Event.ENTER_FRAME, update_function(gameStage));
		}
		
		public function update_function(gameStage):Function {
			return function(E:Event):void {				
				gameStage.addEventListener(KeyboardEvent.KEY_UP, keysUp);
				gameStage.addEventListener(KeyboardEvent.KEY_DOWN, keysDown);
			}
		}
		
		
		private function keysUp(K:KeyboardEvent):void {
			if (K.keyCode == 37) {
				char.setLeftInput(false);
				lastPressed = K.keyCode;
				upTime = getTimer();
			}
			if (K.keyCode == 39) {
				char.setRightInput(false);
				lastPressed = K.keyCode;
				upTime = getTimer();
			}
			if (K.keyCode == 38) {
				char.setUpInput(false);
			}
			if (K.keyCode == 40) {
				char.setDownInput(false);
			}
			if (K.keyCode == 79) { // o - guard
				char.setGuardInput(false);
			}
			if (K.keyCode == 49) { // number 1 - ability 1 (testing)
				char.setAbility1Input(false);
			}
			if (K.keyCode == 80) { // p - punch
				char.setPunchInput(false);
			}
		}
		
		private function keysDown(K:KeyboardEvent):void {
			if (K.keyCode == 37) {
				char.setLeftInput(true);
				char.setRightInput(false);
				detectDoubleTap(K.keyCode);
			}
			if (K.keyCode == 39) {
				char.setRightInput(true);
				char.setLeftInput(false);
				detectDoubleTap(K.keyCode);
			}
			if (K.keyCode == 38) {
				char.setUpInput(true);
				char.setDownInput(false);
			}
			if (K.keyCode == 40) {
				char.setDownInput(true);
				char.setUpInput(false);
			}
			if (K.keyCode == 79) { // o - guard
				char.setGuardInput(true);
			}
			if (K.keyCode == 49) { // number 1 - ability 1 (testing)
				char.setAbility1Input(true);
			}
			if (K.keyCode == 80) { // p - punch
				char.setPunchInput(true);
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
		
		public function getPlayerUnit():MovieClip {
			return char.getPlayerUnit();
		}

	}
	
}
