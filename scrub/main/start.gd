extends Control

func _ready():
	if not DirAccess.dir_exists_absolute("user://tmp"):
		DirAccess.make_dir_absolute("user://tmp")
	else:
		clean_user_temp()
	queue_free()
func clean_user_temp():
	pass
