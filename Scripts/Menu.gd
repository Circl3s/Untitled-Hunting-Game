extends Node

func _ready():
	randomize()
	var new_name = "Player%d" % rand_range(100, 999)
	Networking.connect("connection_error", self, "show_connection_error")
	Networking.connect("connected", self, "_on_connected")
	Networking.connect("going_down", self, "_when_going_down")
	Networking.current_player.username = new_name
	$Start/Username.text = new_name
	$Start/Username/Color.color = Networking.current_player.color
	Networking.chnage_username(new_name)

func show_connection_error(error = ""):
	show_lobby(false)
	var label = $Start/Join/ErrorLabel
	if error != "":
		label.text = error
	label.visible = true

func show_lobby(show = true):
	$Lobby.visible = show
	$Start.visible = not show

func get_lobby():
	return $Lobby

# Signals

func _host_btn():
	print("HOST")
	Networking.start(true)

func _join_btn():
	print("JOIN") # TODO: get from lineedit
	var split = $Start/Join/LineEdit.text.split(":")
	var port = Networking.DEFAULT_PORT
	if split.size() > 1:
		port = int(split[1])
	Networking.start(false, split[0], port)

func _username_changed(name):
	if name == "":
		$Start/HostButton.disabled = true
		$Start/Join/Button.disabled = true
		return
	if $Start/HostButton.disabled:
		$Start/HostButton.disabled = false
		$Start/Join/Button.disabled = false
	Networking.chnage_username(name)

func _on_connected(_id):
	show_lobby()

func _when_going_down():
	show_lobby(false)
