tool
extends Container

signal change_text

func _ready() -> void:
	pass

func add_child(node : Node, legible_unique_name : bool = false) -> void:
	node.rect_size = Vector2.ZERO
	.add_child(node, legible_unique_name)

func remove_child(node : Node) -> void:
	.remove_child(node)

func _on_InvisContainer_sort_children() -> void:
	emit_signal("change_text", get_children().size())
