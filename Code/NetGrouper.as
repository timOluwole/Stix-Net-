package {
	
	import flash.events.EventDispatcher;
	import flash.net.NetGroup;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	
	public class NetGrouper extends EventDispatcher {

		public static const LOCAL_CONNECTION:String = 'localconnection';
		public static const CIRRUS_CONNECTION:String = 'cirrusconnection';
		public static const CIRRUS_SERVER:String = "rtmfp://p2p.rtmfp.net/";
		public static const LOCAL_SERVER:String = "rtmfp:";
		
		
		private var _connected:Boolean;
		private var _connectionType:String;
		private var _gid:String;
		
		private var idNo:String;
		
		public var peerID:String;
		
		public var isMatched:Boolean;
		private var opponent:Object;
		private var opponentID:String;
		
		private var nc:NetConnection;
		private var gs:GroupSpecifier;
		private var ng:NetGroup;
		
		//If you're gonna use Adobe's Cirrus server make sure you supply your developer key!
		// public function NetGrouper( ConnectionType:String = NetGrouper.LOCAL_CONNECTION, GroupID:String = null, MulticastIP:String = "239.0.0.255:30304", DeveloperKey:String = "65c1b8088f7d149e66713918-502ba8373649" ):void {
		public function NetGrouper( ConnectionType:String = NetGrouper.CIRRUS_CONNECTION, GroupID:String = null, MulticastIP:String = "239.0.0.255:30304", DeveloperKey:String = "65c1b8088f7d149e66713918-502ba8373649" ):void {	
			_connected = false;
			if( GroupID != null ) {
				
				connect( ConnectionType, GroupID, MulticastIP, DeveloperKey );
			}
			
		}
		
		// public function connect( ConnectionType:String = NetGrouper.LOCAL_CONNECTION, GroupID:String = null, MulticastIP:String = "239.0.0.255:4096", DeveloperKey:String = "65c1b8088f7d149e66713918-502ba8373649" ):void {
		public function connect( ConnectionType:String, GroupID:String, MulticastIP:String, DeveloperKey:String ):void {
			_connectionType = ConnectionType;
			if( GroupID ) {
				_gid = GroupID;
			} else {
				_gid = "RandomNetGroup"
			}
			
			trace( _gid );
			
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			if( _connectionType == NetGrouper.LOCAL_CONNECTION ) {
				
				gs = new GroupSpecifier(_gid);
				gs.postingEnabled = true;
				gs.routingEnabled = true;
				gs.ipMulticastMemberUpdatesEnabled = true;
				gs.addIPMulticastAddress(MulticastIP);
				
				nc.connect( NetGrouper.LOCAL_SERVER );
				
			} else if( _connectionType == NetGrouper.CIRRUS_CONNECTION ) {
				
				gs = new GroupSpecifier(_gid + idNo);
				gs.serverChannelEnabled = true;
				gs.postingEnabled = true;
				gs.routingEnabled = true;
				gs.ipMulticastMemberUpdatesEnabled = true;
				gs.multicastEnabled = true;
				
				nc.connect( NetGrouper.CIRRUS_SERVER + DeveloperKey );
			}
		}
		
		private function onNetStatus( e:NetStatusEvent ):void {
			
			switch(e.info.code) {
				case "NetConnection.Connect.Success":
					trace('NetConnection Connected');
					setupPair();
					break;
					
				case "NetGroup.Connect.Success":
					trace('NetGroup Connected');
					_connected = true;
					isMatched = false;
					peerID = ng.convertPeerIDToGroupAddress(nc.nearID);
					dispatchEvent( new NetGrouperEvent( NetGrouperEvent.CONNECT, {sender:peerID, group:e.info.group } ));
					break;
		 		case "NetGroup.SendTo.Notify":
				case "NetGroup.Posting.Notify":
					// trace( "got message" );
					receiveMessage( e.info.message );
					break;
				
				case "NetGroup.Neighbor.Connect":
					if (!isMatched) {
						trace( "Opponent Connected: ", e.info.neighbor.substring(0,5) , e.info.peerID.substring(0,5) );
						peerID = e.info.peerID;
						addOpponent( e.info.neighbor );
						dispatchEvent( new NetGrouperEvent( NetGrouperEvent.NEIGHBOR_CONNECT, {oID:e.info.neighbor, pID:peerID} ));
					}
					break;
					
				case "NetGroup.Neighbor.Disconnect":
					trace( "Opponent Disconnected: ", e.info.neighbor.substring(0,5) , e.info.peerID.substring(0,5) );
					dispatchEvent( new NetGrouperEvent( NetGrouperEvent.NEIGHBOR_DISCONNECT, {id:e.info.neighbor} ));
					deleteOpponent();
					break;
			}

		}
		
		public function post( message:Object ):void {
			message.sender = peerID // ng.convertPeerIDToGroupAddress(nc.nearID);
			if( _connected ) {
				if( ng.neighborCount < 14 ) {
					ng.sendToAllNeighbors( message );
				} else {
					//post is MUCH slower than sendToAllNeighbors but when there are more than 13 connections
					//however post is more reliable than sendToAllNeighbors because not everyone is peers
					//above 13 connections.
					ng.post( message );
				}
				dispatchEvent( new NetGrouperEvent( NetGrouperEvent.POST, message ) );
			}
		}
		
		private function receiveMessage( message:Object ):void {
			dispatchEvent( new NetGrouperEvent( NetGrouperEvent.RECEIVE, message ) );
		}
		
		
		private function setupPair():void {
			ng = new NetGroup( nc, gs.groupspecWithAuthorizations() );
			ng.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		private function addOpponent( oID:String ):void {
			trace("OPPONENT ID:", oID.substring(0,5));
			opponentID = oID;
			isMatched = true;
		}
		
		
		private function deleteOpponent():void {
			opponentID = null;
			isMatched = false;
		}
		
		
		public function getOpponent():String {
			return opponentID;
		}
		
		public function disconnect():void {
			ng.close();
		}
		
		
	}
	
}
