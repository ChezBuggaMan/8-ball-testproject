extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = _on_spawn
	add_to_group("spawner_ready_listeners")
	LobbySteam._notify_scene_ready.rpc()

# Called through "spawner_ready_listeners"
func do_spawn():
	if not multiplayer.is_server():
		return
	if get_child_count() > 0:
		return # avoids double spawns
	
	print("All peers are ready, host is spawning in players.")
	spawn(multiplayer.get_unique_id()) # Spawns in the host
	
	# Spawns in rest of the players
	for peer_id in multiplayer.get_peers():
		spawn(peer_id)

func _on_spawn(data):
	var player_scene = preload("res://player.tscn")
	var player_inst = player_scene.instantiate()
	player_inst.ID = data
	return player_inst
