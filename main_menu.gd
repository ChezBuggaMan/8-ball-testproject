extends Control

var AttemptedID = ""
var Name = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CreateButton.pressed.connect(create_new)
	$JoinButton.pressed.connect(join_game)
	#$PlayButton
	#$NameEditor.text_changed.connect(update_name)
	$IPEditor.text_changed.connect(update_IP)
	$SteamName.text = Steam.getPersonaName()

func create_new():
	print("Create button pressed, attempting to creating game")
	#Lobby.create_game()
	LobbySteam.create_steam_lobby()

func join_game():
	print("Join button pressed, attempting to join game")
	#Lobby.join_game(AttemptedIP)
	LobbySteam.join_steam_lobby(AttemptedID.to_int())

func update_name(new_text):
	print("Changing name to ", new_text)
	Lobby.player_info["name"] = new_text
	print(Lobby.player_info)

func update_IP(new_text):
	AttemptedID = new_text
