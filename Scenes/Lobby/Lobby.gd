extends Control

var tree : SceneTree
var buttonJoin : Button
var buttonHost : Button
var buttonStart : Button
var labelNumPlayers : Label
var labelListPlayers : Label
var labelAddress : Label
var lineEditName : LineEdit

func _ready():
	randomize()
	tree = get_tree()
	buttonJoin = $MarginContainer/MenuOptions/ButtonJoinGame
	buttonHost = $MarginContainer/MenuOptions/ButtonHostGame
	buttonStart = $MarginContainer/MenuOptions/ButtonStartGame
	labelNumPlayers = $MarginContainer/MenuOptions/LabelNumPlayers
	labelListPlayers = $MarginContainer/MenuOptions/LabelListPlayers
	lineEditName = $MarginContainer/MenuOptions/LineEditName
	labelAddress = $MarginContainer/MenuOptions/LabelAddress
	tree.connect("network_peer_connected", self, "_on_player_connected")
	tree.connect("network_peer_disconnected", self, "_on_player_disconnected")

sync func start_game():
	var game = preload("res://Scenes/Game/Game.tscn").instance()
	tree.get_root().add_child(game)
	hide()

sync func get_player_name(return_id : int):
	rpc_id(return_id, "return_player_name", tree.get_network_unique_id(), lineEditName.text)

sync func return_player_name(id : int, name : String):
	Settings.otherPlayerNames[id] = name
	labelListPlayers.text = str(Settings.otherPlayerNames.values()).lstrip('[,]').rstrip('[,]')

func _on_player_connected(id : int):
	print("player ", id, " connected")
	Settings.otherPlayerIds.append(id)
	rpc_id(id, "get_player_name", tree.get_network_unique_id())
	labelNumPlayers.text = "Players: " + str(Settings.otherPlayerIds.size())
	if (Settings.otherPlayerIds.size() > 0):
		buttonStart.disabled = false
	

func _on_player_disconnected(id : int):
	print("player ", id, " disconnected")
	Settings.otherPlayerIds.erase(id)
	Settings.otherPlayerNames.erase(id)
	labelListPlayers.text = str(Settings.otherPlayerNames.values()).lstrip('[,]').rstrip('[,]')
	labelNumPlayers.text = "Players: " + str(Settings.otherPlayerIds.size())
	if (Settings.otherPlayerIds.size() <= 0):
		buttonStart.disabled = true


func _on_ButtonJoinGame_pressed():
	print("Joining network")
	var host = NetworkedMultiplayerENet.new()
	var res = host.create_client(Settings.serverAddr, 4242)
	if (res != OK):
		print("Error connecting to server")
		return
	buttonJoin.disabled = true
	buttonHost.disabled = true
	get_tree().set_network_peer(host)


func _on_ButtonHostGame_pressed():
	print("Hosting network")
	var host = NetworkedMultiplayerENet.new()
	var res = host.create_server(4242)
	if (res != OK):
		print("Error creating server")
		return
	labelAddress.text = "Addresses: " + str(IP.get_local_addresses())
	buttonJoin.disabled = true
	buttonHost.disabled = true
	tree.set_network_peer(host)	

func _on_ButtonStartGame_pressed():
	if (tree.is_network_server()):
		rpc("start_game")

func button_adjust():
	if (Settings.selfName != "" && Settings.serverAddr != ""):
		buttonJoin.disabled = false
		buttonHost.disabled = false
	elif (Settings.selfName != ""):
		buttonJoin.disabled = true
		buttonHost.disabled = false
	else:
		buttonJoin.disabled = true
		buttonHost.disabled = true

func _on_LineEditName_text_entered(new_text):
	Settings.selfName = new_text
	button_adjust()


func _on_LineEditAddr_text_entered(new_text):
	Settings.serverAddr = new_text
	button_adjust()
