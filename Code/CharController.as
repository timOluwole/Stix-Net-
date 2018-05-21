package  {
	import flash.events.*;
	import flash.filters.BlurFilter; 
	
	public class CharController {
		
		public var unit:red_default;
		
		private var lKeyDown:Boolean = false;
		private var rKeyDown:Boolean = false;
		private var uKeyDown:Boolean = false;
		private var dKeyDown:Boolean = false;
		
		private var guardKeyDown:Boolean = false;
		
		private var dashEnabled:Boolean = false;
		private var dashDirection:String;
		
		private var grounded:Boolean = true;
		
		private var groundLevel:int;
		private var fallSpeed:Number = 0;
		
		private var gameFPS:Number;

		public function CharController(game) {
			groundLevel = game.stage.stageHeight;
			// constructor code
			unit = new red_default();
			unit.x = 275;			
			unit.y = groundLevel;
			game.addChild(unit);
			
			gameFPS = game.stage.frameRate;
			
			game.addEventListener(Event.ENTER_FRAME, update_function(game));
			
		}
		
		
		private function update_function(g):Function {
			return function(E:Event):void {
				g.addEventListener(Event.ENTER_FRAME, frame_by_frame);
			};
		}
		
		
		private function frame_by_frame(F:Event):void {
			playerMovement();
			playerPhysics();
		}
			
		// KEY STATES ================================================
		
		public function setLeftKeyState(down):void {
			lKeyDown = down;
		}
		
			
		public function setRightKeyState(down):void {
			rKeyDown = down;
		}
			
		public function setUpKeyState(down):void {
			uKeyDown = down;
		}
			
		public function setDownKeyState(down):void {
			dKeyDown = down;
		}
		
		public function setGuardKeyState(down):void {
			guardKeyDown = down;
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
			}
		}
		
		private function standingFrames():void {
			if (lKeyDown) {
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
			} else if (rKeyDown) {
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
			if (uKeyDown) {
				unit.gotoAndPlay("air");
			} else if (dKeyDown) {
				unit.gotoAndPlay("crouch");				
			}
			if (guardKeyDown) {
				unit.gotoAndPlay("guard standing");
				while (unit.previousState != "standing") {
					unit.gotoAndPlay(unit.currentFrame + 1);
				}				
			}
		}
		
		private function walkingFrames():void {
			if (lKeyDown || rKeyDown) {
				if ((lKeyDown && unit.scaleX < 0) || (rKeyDown && unit.scaleX > 0)) {
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
			if (uKeyDown) {
				unit.gotoAndPlay("air");
				moveCharacterY(fallSpeed);
			} else if (dKeyDown) {
				unit.gotoAndPlay("crouch");				
			}
			if (guardKeyDown) {
				unit.gotoAndPlay("guard standing");
				while (unit.previousState != "standing") {
					unit.gotoAndPlay(unit.currentFrame + 1);
				}				
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
				if (lKeyDown || rKeyDown) {
					var airSpeed;
					if ((lKeyDown && playerDirection() == -1) || (rKeyDown && playerDirection() == 1)) {
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
					if (dKeyDown) {
						unit.gotoAndPlay("crouch");	
						while (unit.moveStage != "crouch") {
							unit.gotoAndPlay(unit.currentFrame + 1);
						}
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
				if (dKeyDown) {
					unit.stop();
					if (guardKeyDown) {
						unit.gotoAndPlay("guard crouching");
						while (unit.previousState != "crouch") {
							unit.gotoAndPlay(unit.currentFrame + 1);
						}				
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
				if (guardKeyDown) {
					unit.stop();
					if (dKeyDown) {
						if (unit.currentLabel == "guard standing") {
							unit.gotoAndPlay("guard crouching");
							while (unit.previousState != "guard standing") {
								unit.gotoAndPlay(unit.currentFrame + 1);
							}
						} else if (unit.currentLabel == "guard crouching") {
							
						}
					} else {
						if (unit.currentLabel == "guard crouching") {
							unit.gotoAndPlay("guard standing");
							while (unit.previousState != "guard crouching") {
								unit.gotoAndPlay(unit.currentFrame + 1);
							}
						}
					}
				} else {
					unit.play();
					while (unit.moveStage != "reset") {
						unit.gotoAndPlay(unit.currentFrame + 1);
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
		
		public function getPlayerX():Number {
			return unit.x;
		}
		
		public function getPlayerY():Number {
			return unit.y;
		}
	}		
}
