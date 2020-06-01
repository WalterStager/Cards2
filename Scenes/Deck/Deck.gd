extends TextureButton

signal deck_gui_event

const OG_SIZE := Vector2(240, 336)

onready var name_label : Label = $NameLabel
onready var count_label : Label = $CenterContainer/CountLabel
onready var invis_container : Container = $InvisContainer
var player_id : int = -1
var deck_id : int = -1


func _ready() -> void:
	pass

func set_name_text(value : String) -> void:
	name_label.text = value

func draw_card() -> TextureButton:
	var deck_cards = invis_container.get_children()
	if (deck_cards.size() != 0):
		var mov_card = invis_container.get_child(0)
		invis_container.remove_child(mov_card)
		return mov_card
	return null

func add_card(card : Node) -> void:
	invis_container.add_child(card)
	invis_container.move_child(card, 0)

func remove_card(card : Node) -> void:
	invis_container.remove_child(card)

func shuffle() -> void:
	var children = invis_container.get_children()
	children.shuffle()
	var i = 0
	for ch in children:
		invis_container.move_child(ch, i)
		i += 1

func _on_Deck_gui_input(event) -> void:
	emit_signal("deck_gui_event", event, self)

func set_focus(val : bool):
	if (val):
		self.self_modulate = Color.lightgreen
	else:
		self.self_modulate = Color.white
