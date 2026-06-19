extends Node

var lobby_id: int = 0

var is_host: bool = false
var is_joining: bool = false

var players = {}

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
	players.clear()
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
	print("Connection:", multiplayer.multiplayer_peer.get_connection_status())
	
	is_joining = false

signal countdown_started(seconds: int)
signal countdown_tick(seconds_left: int)

var countdown_active: bool = false

#Triggered when the hosts requests to start the game early, or when the lobby is full
func request_start_game():
	# Only the host is allowed to actually trigger this
	if not multiplayer.is_server():
		return
	_begin_countdown.rpc()

# Begins the countdown to game start
@rpc("call_local", "reliable")
func _begin_countdown():
	if countdown_active:
		return
	countdown_active = true
	countdown_started.emit(5)
		
	for i in range(5, 0, -1):
		countdown_tick.emit(i)
		await get_tree().create_timer(1.0).timeout
		
	# Only the host actually flips the scene authoritatively;
	# call_local already means this runs on everyone via the RPC itself.
	get_tree().change_scene_to_file("res://test_main.tscn")

# Peer connection callbacks
func _peer_connected(id):
	print("Peer connected: ", id)
	if multiplayer.get_peers().size() == Steam.getLobbyMemberLimit(LobbySteam.lobby_id):
		print("Max Players Reached, starting game in 5 seconds UNFINISHED")

func _peer_disconnected(id):
	print("Peer disconnected: ", id)

# These functions ensure that
var clients_ready: Dictionary = {}

@rpc("any_peer", "call_local", "reliable")
func _notify_scene_ready():
	var sender = multiplayer.get_remote_sender_id()
	if sender == 0:
		sender = multiplayer.get_unique_id() # host calling locally
	clients_ready[sender] = true
	print ("Peer ready: ", sender, ", ready set: ", clients_ready.keys())
	
	if multiplayer.is_server():
		print("Checking if everyone is ready...")
		_check_all_ready()

func _check_all_ready():
	var expected = multiplayer.get_peers()
	expected.append(multiplayer.get_unique_id())
	for id in expected:
		if not clients_ready.has(id):
			print("Not ready!")
			return
	# Otherwise everyone is loaded, and its safe to spawn them
	print("Everyone is ready, calling spawners.")
	get_tree().call_group("spawner_ready_listeners", "do_spawn")
