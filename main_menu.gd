extends Control

# Main gui
@onready var create_button: Button = $CreateButton
@onready var join_button: Button = $JoinButton
@onready var play_button: Button = $PlayButton
@onready var id_editor: LineEdit = $IDEditor
@onready var popup_panel: PopupPanel = $CreateLobbyBox/PopupPanel


# Lobby Creation
@onready var create_lobby_box: Control = $CreateLobbyBox
@onready var host_button: Button = $CreateLobbyBox/Panel/HostButton
@onready var max_player_option_button: OptionButton = $CreateLobbyBox/Panel/MaxPlayerOptionButton

var AttemptedID = ""
var Name = ""
var MaxPlayers = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_button.pressed.connect(open_host_tab)
	join_button.pressed.connect(join_game)
	play_button.pressed.connect(LobbySteam.request_start_game) # Test
	id_editor.text_changed.connect(update_ID)
	host_button.pressed.connect(create_new)
	max_player_option_button.item_selected.connect(max_players_updated)
	$SteamName.text = Steam.getPersonaName()

func open_host_tab():
	create_lobby_box.visible = !create_lobby_box.visible

# Tells steam to create a new lobby with a max player argument
func create_new():
	print("Host button pressed, attempting to creating game")
	
	LobbySteam.create_steam_lobby(MaxPlayers)
	
	popup_panel.popup_centered()
	
	print(LobbySteam.players)

# Tells steam to put us in the requested lobby
func join_game():
	print("Join button pressed, attempting to join game")
	
	LobbySteam.join_steam_lobby(AttemptedID.to_int())

func update_ID(new_text):
	AttemptedID = new_text

# Called when the max players option is changed
func max_players_updated(num):
	MaxPlayers = max_player_option_button.text.to_int()
	print(num, MaxPlayers)

#func start_game():
	#get_tree().change_scene_to_file("res://test_main.tscn")
