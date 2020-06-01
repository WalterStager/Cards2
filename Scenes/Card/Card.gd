extends TextureButton

signal card_gui_event

const suit = ["C", "D", "H", "S"]
const numb = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

var back : StreamTexture
var front : StreamTexture
var grid_pos := Vector2(0, 0)
var back_up := true
var card_id := -1

func _init() -> void:
	back = load("res://Sprites/card_back.png")
	front = null

func inst_init(id : int) -> void:
	front = load("res://Sprites/" + numb[id % 13] + suit[id / 13] + ".png")

func _on_Card_gui_input(event : InputEvent) -> void:
	emit_signal("card_gui_event", event, self)

func flip() -> void:
	back_up = !back_up
	if (back_up):
		self.set_normal_texture(back)
	else:
		self.set_normal_texture(front)

func set_focus(val : bool) -> void:
	if (val):
		self.self_modulate = Color.lightgreen
	else:
		self.self_modulate = Color.white
