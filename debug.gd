extends Control

@onready var connection_status: Label = $ConnectionStatus
@onready var peer_status: Label = $PeerStatus
@onready var steam_id: Label = $SteamID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	connection_status.text = "Status: " + str(multiplayer.multiplayer_peer.get_connection_status())
	peer_status.text = "Peers: " + str(multiplayer.get_peers())
	steam_id.text = "SteamID: " + str(Steam.getSteamID())
