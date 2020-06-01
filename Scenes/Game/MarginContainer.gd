extends MarginContainer



var margin_lr : int = 50
var margin_tb : int = 50

func _ready():
	pass

func _on_MarginContainer_resized():
	pass
#	if (self.rect_size.x < margin_lr*2 + 480):
#		margin_lr = max(0, int((self.rect_size.x - 480) / 2))
#	else:
#		margin_lr = 50
#
#	if (self.rect_size.y < margin_tb*2 + (36*2 + 24)):
#		margin_tb = max(0, int((self.rect_size.y - (36*2 + 24)) / 2))
#	else:
#		margin_tb = 50
#
#	set("custom_constants/margin_left", margin_lr)
#	set("custom_constants/margin_right", margin_lr)	
#	set("custom_constants/margin_top", margin_tb)
#	set("custom_constants/margin_bottom", margin_tb)
