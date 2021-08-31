extends Spatial

func _ready():
	if get_tree().network_peer == null:
		print("No Network peer present, creating one")
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(6969, 1)
		get_tree().network_peer = peer
		var player = preload("res://Prefabs/NetworkPlayer.tscn").instance()
		add_child(player)
	else:
		if Networking.state == Networking.GameState.GameSetup:
			create_players()
		Networking.connect("player_removed", self, "_remove_player")

func create_players():
	var self_id = get_tree().get_network_unique_id()
	var list = [self_id]
	list.append_array(Networking.player_list)
	for pid in list:
		var player = preload("res://Prefabs/NetworkPlayer.tscn").instance()
		player.set_name(str(pid))
		player.set_network_master(pid)
		if pid != self_id:
			player.set_username(Networking.player_info[pid].username)
			player.set_color(Networking.player_info[pid].color)
			player.remove_child(player.get_node("Camera"))
			player.get_node("Model/SpotLight").visible = false
			player.get_node("Model/Area/PolygonView").visible = false
		else:
			player.set_username(Networking.current_player.username)
			player.set_color(Networking.current_player.color)
		add_child(player)
	if self_id != 1:
		Networking.rpc_id(1, "done_setup")

func _remove_player(id):
	remove_child(get_node(str(id)))
