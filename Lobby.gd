extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const Port = 25565
const Default_Server_IP = "127.0.0.1"
const Max_Connections = 4

var players = {}

# Edited before 
var player_info = {"name": "DefaultPlayer"}

var players_loaded = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(address = ""):
	print("Joining game")
	if address.is_empty():
		address = Default_Server_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, Port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func create_game():
	print("Creating New Game")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, Max_Connections)
	if error:
		print(error)
		return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	
	print("Server started on port ", Port)

func remove_multiplayer_peer():
	print("Removing Multiplayer Peer")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()

# For when the server decides to start the game
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	print("Loading new scene...")
	get_tree().change_scene_to_file(game_scene_path)

# Called for every peer when they have loaded into the game scene
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	print("Player Loaded")
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0

func _on_player_connected(id):
	print("Player connected with ID: ", id)
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	print("Registering player with info: ", new_player_info)
	var new_player_id = multiplayer.get_remote_sender_id()
	print("New ID: ", new_player_id)
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	print("Player Disconnected: ", id)
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	print("Player Successfully connected.")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	print("Played Failed to Connect.")
	remove_multiplayer_peer()

func _on_server_disconnected():
	print("Server Disconnect")
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
