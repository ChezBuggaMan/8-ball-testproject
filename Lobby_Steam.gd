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

func _process(_delta: float) -> void:
	# Crucial: This must run every frame to process Steam network messages and handshakes
	Steam.run_callbacks()

func create_steam_lobby():
	print("Creating Lobby")
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 4)

func _on_lobby_created(result: int, lobby_id_in: int):
	if result == Steam.Result.RESULT_OK:
		is_host = true
		self.lobby_id = lobby_id_in
		print("Lobby created with ID: ", lobby_id)
		
		var peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		#Creating/Removing player function goes here

func join_steam_lobby(target_lobby_id: int):
	is_joining = true
	Steam.joinLobby(lobby_id)

func _on_lobby_joined(lobby_id: int, permissions: int, response: int, userid: int):
	
	if !is_joining:
		return
	
	self.lobby_id = lobby_id
	var peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer
	print("Joined Steam Lobby!")
	
	is_joining = false
