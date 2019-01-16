extends Node

var size
var position

func _ready():
	size = $Container/Body_Image.texture.get_size()
	position = $Container/Body_Image.position

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
