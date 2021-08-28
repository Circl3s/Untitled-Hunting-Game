extends Node

func _ready():
	Networking.connect("player_list_update", self, "update_lobby")

func update_lobby():
	update_list()
	if Networking.player_list.size() > 0:
		$Start.disabled = false
	else:
		$Start.disabled = true

func update_list():
	var self_id = get_tree().get_network_unique_id()
	var list = [self_id]
	for pid in Networking.player_list:
		list.append(pid)
	list.sort()
	if list.size() < 4:
		for _a in range(1, 4-list.size()):
			list.append(0)
	var i = 1
	for pid in list:
		if pid == 0:
			update_label(i, "")
		elif pid == self_id:
			update_label(i, Networking.current_player.username)
		else:
			update_label(i, Networking.player_info[pid].username)
		i += 1

func update_label(index, name):
	var label = get_node("PlayerList/Label_%d" % index)
	if name == "":
		label.text = "No Player"
		label.set("custom_colors/font_color", Color("#222222"))
	else:
		label.text = name
		label.set("custom_colors/font_color", Color.white)

# Signals

func _visibility_chnage():
	if self.visible:
		update_list()
		if get_tree().get_network_unique_id() == 1:
			$Start.visible = true
		else:
			$Start.visible = false

func _leave_btn():
	Networking.stop()

func _start_btn():
	Networking.begin_start()
