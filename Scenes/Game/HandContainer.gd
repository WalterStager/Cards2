tool
extends Container

signal hand_gui_event

export(int) var separation = 0 setget set_separation
export(int) var vert_separation = 15 setget set_vert_separation

onready var settings = get_node("/root/Settings")

func _ready() -> void:
	pass

func set_separation(new_sep : int) -> void:
	if (new_sep != separation):
		separation = new_sep
		queue_sort()

func set_vert_separation(new_sep : int) -> void:
	if (new_sep != vert_separation):
		vert_separation = new_sep
		queue_sort()

func add_child(node : Node, legible_unique_name : bool = false) -> void:
	node.connect("card_gui_event", self, "_on_card_gui_event")
	.add_child(node, legible_unique_name)

func remove_child(node : Node) -> void:
	node.disconnect("card_gui_event", self, "_on_card_gui_event")
	.remove_child(node)

func _on_card_gui_event(event : InputEvent, node : TextureButton) -> void:
	emit_signal("hand_gui_event", event, node)

func _on_HandContainer_sort_children() -> void:
	var child_offset := Vector2.ZERO
	var tex_but_children = []
	# get children
	for child in get_children():
		if (not child is Control):
			continue
		if (child is TextureButton):
			tex_but_children.append(child)
	# distribute texture buttons
	for tb in tex_but_children:
		if (child_offset.x + separation > 0):
			child_offset.x += separation
		var child_size = tb.texture_normal.get_size() * rect_size.y / tb.texture_normal.get_height()
		fit_child_in_rect(tb, Rect2(child_offset, child_size))
		child_offset.x += child_size.x
		if (child_offset.x > rect_size.x):
			child_offset.x = 0
			child_offset.y += vert_separation
