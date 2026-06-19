extends Node

var lobby_id: int = 0

var is_host: bool = false
var is_joining: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Steam init: ", Steam.steamInit(480, true))
	
	Steam.initRelayNetworkAccess()
	
	Steam.lobby_created.connect(_on_lobby_created)
	
	Steam.lobby_joined.connect(_on_lobby_joined)
	
	# Peer layer
	multiplayer.peer_connected.connect(_peer_connected)
	
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	## Setting up pop-up
	#popup_panel.exclusive = false
	#
	#popup_panel.popup_window = true

func _process(_delta: float) -> void:
	# Crucial: This must run every frame to process Steam network messages and handshakes
	Steam.run_callbacks()

func create_steam_lobby(player_count):
	print("Creating Lobby")
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, player_count)

func _on_lobby_created(result: int, lobby_id_in: int):
	if result == Steam.Result.RESULT_OK:
		is_host = true
		self.lobby_id = lobby_id_in
		print("Lobby created with ID: ", lobby_id)
		
		var peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		print("Peer:", multiplayer.multiplayer_peer)
		print("Connection:", multiplayer.multiplayer_peer.get_connection_status())
		
		# Copying ID to clipboard
		DisplayServer.clipboard_set(str(lobby_id))
		
		#Creating/Removing player function goes here

func join_steam_lobby(target_lobby_id: int):
	print("Attempting Connection to LobbyID: ", target_lobby_id)
	is_joining = true
	Steam.joinLobby(target_lobby_id)

func _on_lobby_joined(lobby_id: int, permissions: int, response: int, userid: int):
	print("Lobby joined callback!")
	print("Lobby:", lobby_id)
	print("Response:", response)
	print("Owner:", Steam.getLobbyOwner(lobby_id))
	
	if !is_joining:
		return
	
	self.lobby_id = lobby_id
	var peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer
	print("Joined Steam Lobby!")
	print("Peer:", multiplayer.multiplayer_peer)
	print("Connection:", multiplayer.multiplayer_peer.get_connection_status())
	
	is_joining = false

func _peer_connected(id):
	print("Peer connected: ", id)

func _peer_disconnected(id):
	print("Peer disconnected: ", id)
