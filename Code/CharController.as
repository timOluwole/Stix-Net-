package  {
	import flash.events.*;
	import flash.utils.*;
	import flash.filters.BlurFilter; 
	import flash.display.MovieClip;
	
	public class CharController {
		
		public var unit;
		
		private var lInput:Boolean = false;
		private var rInput:Boolean = false;
		private var uInput:Boolean = false;
		private var dInput:Boolean = false;
		
		private var ability1Input:Boolean = false;
		
		private var guardInput:Boolean = false;
		
		private var punchInput:Boolean = false;
		private var punchTimer:Number = 0;
		
		private var attackList:Array = ["P", "PP", "PPP", "PPP-P"];
		
		private var dashEnabled:Boolean = false;
		private var dashDirection:String;
		
		private var grounded:Boolean = true;
		
		private var groundLevel:int;
		private var fallSpeed:Number = 0;
		
		private var gameFPS:Number;

		public function CharController(gameStage) {
			// constructor code
			groundLevel = gameStage.stageHeight;
			unit = new red_default();
			unit.x = 275;			
			unit.y = groundLevel;
			gameStage.addChild(unit);
			
			gameFPS = gameStage.frameRate;
			
			gameStage.addEventListener(Event.ENTER_FRAME, update_function(gameStage));
		}
		
		
		public function update_function(gameStage):Function {
			return function(E:Event):void {
				gameStage.addEventListener(Event.ENTER_FRAME, frame_by_frame);
			};
		}
		
		
		public function frame_by_frame(F:Event):void {
			// trace(unit.currentLabel, unit.x, unit.y, lInput, rInput, uInput, dInput);
			playerMovement();
			playerPhysics();
		}
			
		// KEY STATES ================================================
		
		public function setLeftInput(down):void {
			lInput = down;
		}
			
		public function setRightInput(down):void {
			rInput = down;
		}
			
		public function setUpInput(down):void {
			uInput = down;
		}
			
		public function setDownInput(down):void {
			dInput = down;
		}
		
		public function setGuardInput(down):void {
			guardInput = down;
		}
		
		public function setAbility1Input(down):void {
			ability1Input = down;
		}
		
		public function setPunchInput(down):void {
			if (punchInput != down && down) {
				punchTimer = getTimer();
			}
			punchInput = down;
			// trace(getTimer() - punchTimer);
			if ((getTimer() - punchTimer) < 80) {
				punchInputFired();
			} else {
				punchInputHeld();
			}
		}
		// ============================================================
		
		public function getGrounded():Boolean {
			if (unit.y < groundLevel) {
				grounded = false;
			} else {
				unit.y = groundLevel;
				grounded = true;
			}
			return grounded;
		}
		
		public function playerDirection():int {
			return (unit.scaleX / Math.abs(unit.scaleX));
		}
		
		private function playerPhysics():void {
			if (getGrounded()) {
				fallSpeed = -15;
			} else {
				unit.y = Math.min(unit.y + fallSpeed, 400);
			}
		}
		
		private function playerMovement():void {
			if (unit.currentLabel == "standing") {
				standingFrames();
			} else if (unit.currentLabel.indexOf("walking") == 0) {
				walkingFrames();
			} else if (unit.currentLabel == "air") {
				airFrames();
			} else if (unit.currentLabel.indexOf("dash") == 0) {
				dashFrames();
			} else if (unit.currentLabel == "crouch") {
				crouchFrames();
			} else if (unit.currentLabel.indexOf("guard") == 0) {
				guardFrames();
			} else if (unit.currentLabel.match("[P|K|u|d|f|b|-]+")) {
				attackFrames();
			}
		}
		
		private function standingFrames():void {
			if (lInput) {
				if (dashEnabled) {
					if (unit.scaleX < 0) {
						unit.gotoAndPlay("dash forwards");	
					} else {
						unit.gotoAndPlay("dash backwards");
					}		
				} else {
					if (unit.scaleX < 0) {
						unit.gotoAndPlay("walking forwards");
						moveCharacterX(5);					
					} else {
						unit.gotoAndPlay("walking backwards");
						moveCharacterX(-3);	
					}
				}
			} else if (rInput) {
				if (dashEnabled) {
					if (unit.scaleX > 0) {
						unit.gotoAndPlay("dash forwards");	
					} else {
						unit.gotoAndPlay("dash backwards");
					}		
				} else {
					if (unit.scaleX > 0) {
						unit.gotoAndPlay("walking forwards");
						moveCharacterX(5);					
					} else {
						unit.gotoAndPlay("walking backwards");
						moveCharacterX(-3);					
					}				
				}
			}
			if (uInput) {
				unit.gotoAndPlay("air");
			} else if (dInput) {
				unit.gotoAndPlay("crouch");				
			}
			if (guardInput) {
				unit.gotoAndPlay("guard standing");
				finder("previous state", "standing");
			}
		}
		
		private function walkingFrames():void {
			if (lInput || rInput) {
				if ((lInput && unit.scaleX < 0) || (rInput && unit.scaleX > 0)) {
					if (unit.currentLabel != "walking forwards") { 
						unit.gotoAndPlay("walking forwards");
					}
				} else {				
					if (unit.currentLabel != "walking backwards") { 
						unit.gotoAndPlay("walking backwards");
					}	
				}
				if (unit.moveDirection == "forwards") {
					moveCharacterX(5);
				} else if (unit.moveDirection == "backwards") {
					moveCharacterX(-3);
				}
			} else {			
				unit.gotoAndPlay("standing");					
			}
			if (uInput) {
				unit.gotoAndPlay("air");
				moveCharacterY(fallSpeed);
			} else if (dInput) {
				unit.gotoAndPlay("crouch");				
			}
			if (guardInput) {
				unit.gotoAndPlay("guard standing");
				finder("previous state", "standing");
			}
			if (ability1Input) {
				unit.gotoAndPlay("fire sphere");
			}
		}
		
		private function airFrames():void {
			if (!getGrounded()) {
				fallSpeed += 1;
				if (unit.moveStage == "air") {
					if (fallSpeed < -2) {
						if (unit.moveDirection == "upwards") {
							repeatFrame();
						}
					} else {
						if (unit.moveDirection == "downwards") {
							repeatFrame();
						}
					}
				}
				if (lInput || rInput) {
					var airSpeed;
					if ((lInput && playerDirection() == -1) || (rInput && playerDirection() == 1)) {
						airSpeed = 5;
					} else {
						airSpeed = -3;
					}
					moveCharacterX(airSpeed);										
				}
			} else {
				if (unit.moveStage == "jumping") {
					moveCharacterY(fallSpeed);
				} else if (unit.moveStage == "reset") {
					if (dInput) {
						unit.gotoAndPlay("crouch");
						finder("move stage", "crouch");
					}
				}
			}
		}
		
		private function dashFrames():void {
			if (unit.moveStage == "dash") {
				if (unit.moveDirection == "forwards") {
					moveCharacterX(50);
				} else {
					moveCharacterX(-30);
				}
				setDashEnabled(false);
			}
		}
		
		private function crouchFrames():void {
			if (unit.moveStage == "crouch") {
				if (dInput) {
					unit.stop();
					if (guardInput) {
						unit.gotoAndPlay("guard crouching");
						finder("previous state", "crouch");
					}
				} else {
					unit.play();
				}
			} else {
				unit.play();
			}
		}
		
		private function guardFrames():void {
			if (unit.moveStage == "guard") {
				if (guardInput) {
					unit.stop();
					if (dInput) {
						if (unit.currentLabel == "guard standing") {
							unit.gotoAndPlay("guard crouching");
							finder("previous state", "guard standing");
						} else if (unit.currentLabel == "guard crouching") {
							
						}
					} else {
						if (unit.currentLabel == "guard crouching") {
							unit.gotoAndPlay("guard standing");
							finder("previous state", "guard crouching");
						}
					}
				} else {
					unit.play();
					finder("move stage", "reset");
				}
			}
		}
		
		private function attackFrames():void {
			if (unit.movementX != 0) {
				moveCharacterX(unit.movementX);
			}
			if (unit.movementY != 0) {
				moveCharacterY(unit.movementY);			
			}
		}
		
		public function punchInputFired():void {
			if (unit.currentLabel == "standing" || unit.currentLabel == "walking") {
				unit.gotoAndPlay("P");
			} else if (unit.currentLabel.match("[P|K|u|d|f|b|-]+")) {
				if (unit.moveStage == "window") {
					var newAttack = unit.currentLabel + "P";
					if (attackList.indexOf(newAttack) != -1) {
						unit.gotoAndPlay(newAttack);
					}
				}
			}
		}
		
		public function punchInputHeld():void {
			if (unit.currentLabel.match("[P|K|u|d|f|b|-]+")) {
				if (unit.moveStage == "window") {
					var newAttack = unit.currentLabel + "-P";
					if (attackList.indexOf(newAttack) != -1) {
						unit.gotoAndPlay(newAttack);
					}
				}
			}
		}
		
		public function repeatFrame():void {
			unit.gotoAndPlay(unit.currentFrame - 1);			
		}
		
		public function doubleTapDetected(buttonTapped):void {
			if (buttonTapped == 37 || buttonTapped == 39) {
				if (unit.currentLabel == "standing") {
					setDashEnabled(true);				
				}
			}
		}
		
		public function setDashEnabled(isEnabled):void {
			dashEnabled = isEnabled;
		}
		
		
		private function moveCharacterX(velocity):void {
			velocity *= unit.scaleX / Math.abs(unit.scaleX);
			unit.x = Math.min(Math.max(unit.x + velocity, (75 + (25))), (475 - (25)));			
		}
		
		private function moveCharacterY(velocity):void {
			unit.y = Math.min(unit.y + fallSpeed, groundLevel);			
		}
		
		private function seconds(frameCount):Number {
			return (frameCount / gameFPS);
		}
		
		private function finder(unitTag, tagValue):void {
			if (unitTag == "previous state") {
				while (unit.previousState != tagValue) {
					unit.gotoAndPlay(unit.currentFrame + 1);
				}
			} else if (unitTag == "move stage") {
				while (unit.moveStage != tagValue) {
					unit.gotoAndPlay(unit.currentFrame + 1);
				}				
			}
		}
		
		public function getPlayerX():Number {
			return unit.x;
		}
		
		public function getPlayerY():Number {
			return unit.y;
		}
		
		public function getPlayerUnit():MovieClip {
			return unit;
		}
	}		
}
