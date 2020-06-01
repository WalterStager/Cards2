tool
extends Label

func _ready() -> void:
	pass

func _on_InvisContainer_change_text(num : int) -> void:
	self.text = str(num)
