tool
extends Container

signal decks_gui_event

var Card : PackedScene = load("res://Scenes/Card/Card.tscn")
var Deck : PackedScene = load("res://Scenes/Deck/Deck.tscn")

export(int) var vert_separation = 15 setget set_vert_separation
var sort_children_called = false

func _ready() -> void:
	pass

func _process(delta : float) -> void:
	sort_children_called = false

func set_vert_separation(new_sep : int) -> void:
	if (new_sep != vert_separation):
		vert_separation = new_sep
		queue_sort()

func add_child(node : Node, legible_unique_name : bool = false) -> void:
	node.connect("deck_gui_event", self, "_on_deck_gui_event")
	.add_child(node, legible_unique_name)

func remove_child(node : Node) -> void:
	node.disconnect("deck_gui_event", self, "_on_deck_gui_event")
	.remove_child(node)

func _on_deck_gui_event(event : InputEvent, node : TextureButton) -> void:
	emit_signal("decks_gui_event", event, node)

func _on_DecksContainer_sort_children() -> void:
	if (!sort_children_called):
		sort_children_called = true
		var child_offset := Vector2.ZERO
		rect_min_size.y = 0
		# get children
		for child in get_children():
			if (not child is Control):
				continue
			if (child is TextureButton):
				var child_size = child.texture_normal.get_size() * rect_size.x / child.texture_normal.get_width()
				fit_child_in_rect(child, Rect2(child_offset, child_size))
				child_offset.y += child_size.y
		rect_min_size.y = child_offset.y
