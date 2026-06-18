extends Control

@onready var chat_history: VBoxContainer = $ChatBox/ScrollContainer/ChatHistory
@onready var chat_input: LineEdit = $ChatInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chat_input.text_submitted.connect(_on_text_submitted)

func _on_text_submitted(text: String) -> void:
	var clean_text = text.strip_edges()
	if clean_text.is_empty():
		return
	
	var username: String = Steam.getFriendPersonaName(Steam.getSteamID())
	
	rpc("recieve_message", username, clean_text)
	
	chat_input.clear()

@rpc("any_peer", "call_local", "reliable")
func recieve_message(sender_name:String, message_text:String) -> void:
	var label: Label = Label.new()
	label.text = sender_name + ": " + message_text
	#label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	chat_history.add_child(label)
	
	await get_tree().process_frame
	var scroll_container = chat_history.get_parent()
	if scroll_container is ScrollContainer:
		scroll_container.scroll_vertical = int(chat_history.size.y)
