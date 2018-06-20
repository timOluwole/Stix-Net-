package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import NetGrouper;
	import NetGrouperEvent;
	
	
	public class Net3DPairs extends MovieClip {
		
		private var netgrouper:NetGrouper;
		
		private var playerID:String;
		private var opponentID:String;
		private var opponent:MovieClip;
		
		private var isMatched:Boolean = false;
		
		private var clientController:HumanController;
		
		
		public function Net3DPairs() {
						
			netgrouper = new NetGrouper();
			
			netgrouper.addEventListener( NetGrouperEvent.CONNECT, onConnected );
			
			netgrouper.addEventListener( NetGrouperEvent.NEIGHBOR_CONNECT, onOpponentConnected );
			
			netgrouper.addEventListener( NetGrouperEvent.NEIGHBOR_DISCONNECT, onOpponentDisconnected );
			
			netgrouper.addEventListener( NetGrouperEvent.RECEIVE, onReceivePost );
			
			
			
			red_b.addEventListener( MouseEvent.CLICK, connectPlayer );
			
		}
		
		private function connectPlayer(C:MouseEvent):void {
			if (C) {
				connectCirrus();					
			}
		}
		
		public function connectCirrus():void {
			//Connect over Adobe's Cirrus, you don't need to specify a MulticastIP if you do this, but you need to include your Cirrus Developer Key
			//Get your key here: http://labs.adobe.com/technologies/cirrus/
			netgrouper.connect( NetGrouper.CIRRUS_CONNECTION, "TrialRoom" + dummyText.text, "239.0.0.255:4096", "65c1b8088f7d149e66713918-502ba8373649" );
		}
		
		private function onConnected( e:NetGrouperEvent ):void {
			
			playerID = e.message.sender;
			createPlayer();
			
			gameStage.addEventListener( Event.ENTER_FRAME, updatePlace );
		}
		
		public function onOpponentConnected( e:NetGrouperEvent ):void {
			
			playerID = e.message.pID // overwritten for clarity
			
			trace( "SOMEONE CONNECTED WITH ID ", e.message.oID.substring(0,5) );
			addOpponent( e.message.oID, /* e.message.playerX */ 275, /* e.message.playerY */ 400);
			netgrouper.post( { action:"STATE", paired:isMatched } );
			opponentID = e.message.oID
		}
		
		public function onOpponentDisconnected( e:NetGrouperEvent ):void {
			removeChild(opponent);
			opponent = null;
			isMatched = false;
		}
		
		public function onReceivePost( e:NetGrouperEvent ):void {
			trace("gotten from", opponentID.substring(0,5));
			if (true) {
				switch( e.message.action ) {
					case "PLAYER_UPDATE":				
						opponent.x = e.message.playerX;
						opponent.y = e.message.playerY;
						if (opponent.currentFrame == e.message.playerFrame) {
							opponent.stop();
						} else {
							opponent.gotoAndStop(e.message.playerFrame);
						}
					break;
				}
			}
		}
		
		private function createPlayer():void {
			clientController = new HumanController(new CharController(gameStage), gameStage);			
		}
		
		public function addOpponent( ID:String, oX:Number, oY:Number ):void {
			isMatched = true;
			opponent = new red_default();
			addChild(opponent);
			trace("opponent here");
		}
		
		private function updatePlace( e:Event ):void {
			//update your view of opponent			
			if (isMatched) {
				var pX:Number = clientController.getPlayerUnit().x;
				var pY:Number = clientController.getPlayerUnit().y;
				var pF:int = clientController.getPlayerUnit().currentFrame;
							
				netgrouper.post( { action: "PLAYER_UPDATE", playerX:pX, playerY:pY, playerFrame:pF } );
			}
		}
	}
	
}
