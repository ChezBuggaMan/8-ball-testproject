extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = _on_spawn

	# Only the host actually spawns. Clients receive the spawned
	# nodes automatically via replication they must NOT spawn locally
	if not multiplayer.is_server():
		return

	print("Host spawning players...")

	# Host spawns itself first
	spawn(multiplayer.get_unique_id())

	# Then spawns one for each already-connected peer
	for peer_id in multiplayer.get_peers():
		spawn(peer_id)

func _on_spawn(data):
	var player_scene = preload("res://player.tscn")
	var player_inst = player_scene.instantiate()
	player_inst.ID = data
	return player_inst
