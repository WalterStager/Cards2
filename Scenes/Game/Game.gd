extends Control

# sync - runs on all machines
# remote - runs on remote machines
# master - runs on network master
# slave - runs on non network master


var Card : PackedScene = preload("res://Scenes/Card/Card.tscn")
var Deck : PackedScene = preload("res://Scenes/Deck/Deck.tscn")

var hand_container : Container
var deck_container : Container
var field_container : Container
var op_hands_container : Container

var focused : Node = null
enum {NULL, FIELD, DECKS, OP_HANDS, HAND}
var focused_area := NULL

var op_decks_dict = {}
var cards = {}
var decks = {}

func _ready() -> void:
	hand_container = $VSplitContainer/HBoxContainer2/HandContainer
	deck_container = $VSplitContainer/HBoxContainer/DecksScroll/DecksContainer
	field_container = $VSplitContainer/HBoxContainer/FieldScroll/FieldContainer
	op_hands_container = $VSplitContainer/HBoxContainer2/ScrollContainer/OPHandsContainer
	
	if (get_tree().is_network_server()):
		rpc("set_seed_all", randi())
	for id in Settings.otherPlayerIds:
		var op_hand = Deck.instance()
		op_hands_container.add_child(op_hand)
		op_hand.set_name_text(Settings.otherPlayerNames[id])
		op_hand.set_name("Deck" + str(id))
		op_hand.player_id = id
		op_decks_dict[id] = op_hand
	
	var nd : TextureButton = Deck.instance()
	deck_container.add_child(nd)
	decks[0] = nd
	nd.deck_id = 0
	for i in range(52):
		var nc : TextureButton = Card.instance()
		nc.inst_init(i)
		nc.set_name("Card" + str(i))
		nc.card_id = i
		cards[i] = nc
		nd.add_card(nc)

func _init() -> void:
	pass

sync func set_seed_all(value : int) -> void:
	print("seed set ", value)
	seed(value)








func set_focus(node : Node, focus_area : int) -> void:
	focused = node
	focused_area = focus_area
	node.set_focus(true)

func clear_focus() -> void:
	focused.set_focus(false)
	focused = null
	focused_area = NULL

sync func flip_card(card_id : int) -> void:
	cards[card_id].flip()

sync func shuffle_cards(deck_id : int) -> void:
	decks[deck_id].shuffle()

sync func new_deck() -> void:
	var nd = Deck.instance()
	deck_container.add_child(nd)
	nd.deck_id = decks.size()
	decks[nd.deck_id] = nd

## FIELD
func field_null(node : Node) -> void:
	set_focus(node, FIELD)
sync func field_field(card_id1 : int, card_id2 : int):
	field_container.swap_cards(cards[card_id1], cards[card_id2])
sync func field_area_decks(deck_id : int, loc : Vector2) -> void:
	var mov_card = decks[deck_id].draw_card()
	if (mov_card != null):
		field_container.add_card_at_loc(mov_card, loc)
func field_area_hand_local() -> void:
	var loc : Vector2 = get_viewport().get_mouse_position()
	hand_container.remove_child(focused)
	field_container.add_card_at_loc(focused, loc)
	rpc("field_area_hand_remote", get_tree().get_network_unique_id(), loc, focused.card_id)
	clear_focus()
remote func field_area_hand_remote(player_id : int, loc : Vector2, card_id : int) -> void:
	op_decks_dict[player_id].remove_card(cards[card_id])
	field_container.add_card_at_loc(cards[card_id], loc)
sync func field_area_field(card_id : int, loc : Vector2) -> void:
	field_container.remove_child(cards[card_id])
	field_container.add_card_at_loc(cards[card_id], loc)


## DECKS
func decks_null(node : Node) -> void:
	set_focus(node, DECKS)
func decks_decks(node : Node) -> void:
	node.get_parent().move_child(focused, node.get_index())
	clear_focus()
func decks_hand_local(node : Node) -> void:
	hand_container.remove_child(focused)
	node.add_card(focused)
	rpc("decks_hand_remote", get_tree().get_network_unique_id(), node.deck_id, focused.card_id)
	clear_focus()
remote func decks_hand_remote(player_id : int, deck_id : int, card_id : int) -> void:
	op_decks_dict[player_id].remove_card(cards[card_id])
	decks[deck_id].add_card(cards[card_id])
sync func decks_field(card_id : int, deck_id : int) -> void:
	field_container.remove_child(cards[card_id])
	decks[deck_id].add_card(cards[card_id])


## HAND
func hand_null(node : Node) -> void:
	set_focus(node, HAND)
func hand_hand(node : Node) -> void:
	node.get_parent().move_child(focused, node.get_index())
	clear_focus()
func hand_decks_local() -> void:
	var mov_card = focused.draw_card()
	if (mov_card != null):
		hand_container.add_child(mov_card)
		rpc("hand_decks_remote", get_tree().get_network_unique_id(), focused.deck_id, mov_card.card_id)
	clear_focus()
remote func hand_decks_remote(player_id : int, deck_id : int, card_id : int) -> void:
	decks[deck_id].remove_card(cards[card_id])
	op_decks_dict[player_id].add_card(cards[card_id])
func hand_field_local() -> void:
	field_container.remove_child(focused)
	hand_container.add_child(focused)
	rpc("hand_field_remote", get_tree().get_network_unique_id(), focused.card_id)
	clear_focus()
remote func hand_field_remote(player_id : int, card_id : int) -> void:
	field_container.remove_child(cards[card_id])
	op_decks_dict[player_id].add_card(cards[card_id])

# OTHER PLAYER HANDS
func oph_null(node : Node) -> void:
	set_focus(node, OP_HANDS)
func oph_hand_local(node : Node) -> void:
	hand_container.remove_child(focused)
	node.add_card(focused)
	rpc("oph_hand_remote", get_tree().get_network_unique_id(), node.player_id, focused.card_id)
	clear_focus()
remote func oph_hand_remote(take_player_id : int, give_player_id : int, card_id : int) -> void:
	if (give_player_id == get_tree().get_network_unique_id()):
		op_decks_dict[take_player_id].remove_card(cards[card_id])
		hand_container.add_child(cards[card_id])
	else:
		op_decks_dict[take_player_id].remove_card(cards[card_id])
		op_decks_dict[give_player_id].add_card(cards[card_id])
func oph_decks_local(node : Node) -> void:
	var mov_card = focused.draw_card()
	if (mov_card != null):
		node.add_card(mov_card)
		rpc("oph_decks_remote", node.player_id, focused.deck_id, mov_card.card_id)
	clear_focus()
remote func oph_decks_remote(give_player_id : int, deck_id : int, card_id : int) -> void:
	if (give_player_id == get_tree().get_network_unique_id()):
		decks[deck_id].remove_card(cards[card_id])
		hand_container.add_child(cards[card_id])
	else:
		decks[deck_id].remove_card(cards[card_id])
		op_decks_dict[give_player_id].add_card(cards[card_id])
func oph_field_local(node : Node) -> void:
	field_container.remove_child(focused)
	node.add_card(focused)
	rpc("oph_field_remote", node.player_id, focused.card_id)
	clear_focus()
remote func oph_field_remote(give_player_id : int, card_id : int) -> void:
	if (give_player_id == get_tree().get_network_unique_id()):
		field_container.remove_child(cards[card_id])
		hand_container.add_child(cards[card_id])
	else:
		field_container.remove_child(cards[card_id])
		op_decks_dict[give_player_id].add_card(cards[card_id])
func oph_oph(node : Node) -> void:
	node.get_parent().move_child(focused, node.get_index())
	clear_focus()










### local input handlers

func _on_FieldContainer_field_gui_event(event : InputEvent, node : Node) -> void:
	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_RIGHT):
		rpc("flip_card", node.card_id)
		
	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT):
		if (focused == null):
			field_null(node)
		elif (focused_area == FIELD):
			rpc("field_field", node.card_id, focused.card_id)
			clear_focus()

func _on_FieldContainer_gui_input(event) -> void:
	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT):
		if (focused_area == DECKS):
			rpc("field_area_decks", focused.deck_id, get_viewport().get_mouse_position())
			clear_focus()
		elif (focused_area == HAND):
			field_area_hand_local()
		elif (focused_area == FIELD):
			rpc("field_area_field", focused.card_id, get_viewport().get_mouse_position())
			clear_focus()

func _on_DecksContainer_decks_gui_event(event : InputEvent, node : Node) -> void:
	if (event is InputEventKey and not event.pressed):
		if (event.scancode == KEY_S and focused_area == DECKS):
			rpc("shuffle_cards", focused.deck_id)
			clear_focus()
		if (event.scancode == KEY_N and focused_area == DECKS):
			rpc("new_deck")
			clear_focus()

	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT):
		if (focused == null):
			decks_null(node)
		elif (focused_area == HAND):
			decks_hand_local(node)
		elif (focused_area == FIELD):
			rpc("decks_field", focused.card_id, node.deck_id)
			clear_focus()
		elif (focused_area == DECKS):
			decks_decks(node)

func _on_DecksContainer_gui_input(event) -> void:
	pass
#	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT):
#		if (deck_container.get_children().back().invis_container.get_child_count() != 0):
#			add_deck()

func _on_HandContainer_hand_gui_event(event : InputEvent, node : Node) -> void:
	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_RIGHT):
		rpc("flip_card", node.card_id)
			
	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT):
		if (focused == null):
			hand_null(node)
		elif (focused_area == HAND):
			hand_hand(node)
		elif (focused_area == DECKS):
			hand_decks_local()
		elif (focused_area == FIELD):
			hand_field_local()

func _on_HandContainer_gui_input(event):	
	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT):
		if (focused_area == DECKS):
			hand_decks_local()
		elif (focused_area == FIELD):
			hand_field_local()

func _on_OPHandsContainer_op_hands_gui_event(event : InputEvent, node : Node) -> void:
	if (event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT):
		if (focused == null):
			oph_null(node)
		elif (focused_area == HAND):
			oph_hand_local(node)
		elif (focused_area == DECKS):
			oph_decks_local(node)
		elif (focused_area == FIELD):
			oph_field_local(node)
		elif (focused_area == OP_HANDS):
			oph_oph(node)
