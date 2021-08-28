extends Node

enum GameState {Lobby, GameSetup, Game}

const MAX_PLAYERS = 4
const DEFAULT_PORT = 1873

var state = GameState.Lobby
var current_player = {
	username = "PLACEHOLDER",
	color = Color.white
}
var player_list = []
var player_info = {}

signal player_list_update
signal player_removed(id)
signal connection_error(message)
signal connected(id)
signal going_down

func _ready():
	randomize()
	current_player.color = Color(randi())
	var tree = get_tree()
	tree.connect("network_peer_connected", self, "_on_network_peer_added")
	tree.connect("network_peer_disconnected", self, "_on_network_peer_remove")
	tree.connect("connected_to_server", self, "_on_connected")
	tree.connect("connection_failed", self, "_on_connection_failed")
	tree.connect("server_disconnected", self, "_on_disconnected")

func start(is_host, address = "", port = DEFAULT_PORT):
	var peer = NetworkedMultiplayerENet.new()
	if is_host:
		peer.create_server(port, MAX_PLAYERS)
	else:
		peer.create_client(address, port)
	var tree = get_tree()
	tree.network_peer = peer
	if is_host:
		emit_signal("connected", 1) # TODO: maybe something else xD
		#$"../Menu".show_lobby()

func stop():
	if get_tree().is_network_server():
		print("STOP HOST")
		rpc("host_going_down")
	else:
		print("STOP")
	emit_signal("going_down")
	if state == GameState.Lobby:
		get_tree().network_peer = null
		#$"../Menu".show_lobby(false)
	else:
		back_to_menu()
	player_list = []
	player_info = {}

func back_to_menu():
	get_tree().network_peer = null
	state = GameState.Lobby
	var err = get_tree().change_scene("res://Menu.tscn")
	print("Scene change result: %s" % str(err))

func chnage_username(name):
	print("New Name: %s" % name)
	current_player.username = name
	# TODO: update username correctly depending on scene

func begin_start():
	get_tree().set_refuse_new_network_connections(true) # TODO: unset when returning to lobby
	rpc("setup_game")

# Signals

func _on_network_peer_added(id):
	print("Peer %d connected" % id)
	rpc_id(id, "register_player", current_player)

func _on_network_peer_remove(id):
	print("Peer %d disconnected" % id)
	player_list.erase(id)
	player_info.erase(id)
	emit_signal("player_list_update")
	emit_signal("player_removed", id)

func _on_disconnected():
	print("Disconnected!")
	player_list = []
	player_info = {}
	if state == GameState.Lobby:
		emit_signal("connection_error", "ERROR: Kicked from server")
	elif state == GameState.Game:
		back_to_menu()

func _on_connected():
	var id = get_tree().get_network_unique_id()
	print("Connected to the Server with ID: %d" % id)
	if state != GameState.Lobby: # Terminate netwokring and go back to menu because the sate was invalid!
		back_to_menu()
		return
	emit_signal("connected", id)
	emit_signal("player_list_update")

func _on_connection_failed():
	print("Failed to connect to the Server")
	if state != GameState.Lobby: # Try connecting not in the Lobby state for some reason, terminating netwokring and going back to Menu
		back_to_menu()
		return
	emit_signal("connection_error", "")

# Remotes

remote func register_player(info):
	var caller_id = get_tree().get_rpc_sender_id()
	player_list.append(caller_id)
	player_info[caller_id] = info
	emit_signal("player_list_update")

remotesync func setup_game():
	var tree = get_tree()
	tree.set_pause(true)
	var err = get_tree().change_scene("res://World.tscn")
	state = GameState.GameSetup
	if err != OK:
		push_error("Faild to load scene! Err: %s" % str(err)) # TODO: handle, somehow lol

var done_players = [] # NOTE: "Temp" variable for setup
remote func done_setup():
	var caller_id = get_tree().get_rpc_sender_id()
	
	assert(get_tree().is_network_server())
	assert(caller_id in player_list)
	assert(not caller_id in done_players)
	
	done_players.append(caller_id)
	if done_players.size() == player_list.size():
		rpc("start_game")

remotesync func start_game():
	var tree = get_tree()
	if 1 == tree.get_rpc_sender_id():
		tree.set_pause(false)
		state = GameState.Game

remote func host_going_down():
	stop()
