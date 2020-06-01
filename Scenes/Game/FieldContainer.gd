tool
extends Container

signal field_gui_event

var scroll_cont : ScrollContainer

var grid_cell_size := Vector2(240, 336) * 0.4
var grid = {}
var rev_grid = {}
var sort_children_called := false



func _ready() -> void:
	scroll_cont = get_parent()

func _process(delta : float) -> void:
	sort_children_called = false

func get_grid_loc(pos : Vector2) -> Vector2:
	return (pos / grid_cell_size).floor()

func get_mouse_grid_loc(loc : Vector2) -> Vector2:
	var pos = loc + Vector2(scroll_cont.get_h_scroll(), scroll_cont.get_v_scroll())
	return (pos / grid_cell_size).floor()

func swap_cards(c1 : Node, c2 : Node) -> void:
	var loc1 : Vector2 = get_grid_loc(c1.rect_position)
	var loc2 : Vector2 = get_grid_loc(c2.rect_position)
	grid[loc1.x][loc1.y] = c2
	grid[loc2.x][loc2.y] = c1
	queue_sort()

func add_card_at_loc(node : Node, loc : Vector2) -> void:
	var grid_loc : Vector2 = get_mouse_grid_loc(loc)
	if (not grid.has(grid_loc.x)):
		grid[grid_loc.x] = {}
	if (not grid[grid_loc.x].has(grid_loc.y)):
		grid[grid_loc.x][grid_loc.y] = node
	node.connect("card_gui_event", self, "_on_card_gui_event")
	add_child(node)

func remove_child(node : Node) -> void:
	var loc = get_grid_loc(node.rect_position)
	grid[loc.x].erase(loc.y)
	node.disconnect("card_gui_event", self, "_on_card_gui_event")
	.remove_child(node)

func _on_card_gui_event(event : InputEvent, node : TextureButton) -> void:
	emit_signal("field_gui_event", event, node)

func _on_FieldContainer_sort_children() -> void:
	if (!sort_children_called):
		sort_children_called = true
		for x in grid.keys():
			for y in grid[x].keys():
				var child_loc = Vector2(x, y) * grid_cell_size
				fit_child_in_rect(grid[x][y], Rect2(child_loc, grid_cell_size))
				if ((child_loc + grid_cell_size * 2).x > rect_min_size.x):
					rect_min_size.x = (child_loc + grid_cell_size * 2).x
				if ((child_loc + grid_cell_size * 2).y > rect_min_size.y):
					rect_min_size.y = (child_loc + grid_cell_size * 2).y
