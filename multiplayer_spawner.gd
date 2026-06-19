extends MultiplayerSpawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _on_spawn
	print("Spawning players...")
	var numplayers = Steam.getNumLobbyMembers(LobbySteam.lobby_id) or 1
	for n in range(numplayers):
		spawn(n+1)
		

func _on_spawn(data):
	print(data)
	var player_scene = preload("res://player.tscn")
	
	var player_inst = player_scene.instantiate()
	print(player_inst)

	player_inst.ID = data
	
	return player_inst
