extends Control

func _ready():
	if not DirAccess.dir_exists_absolute("user://tmp"):
		DirAccess.make_dir_absolute("user://tmp")
	else:
		clean_user_temp()
	queue_free()
func clean_user_temp():
	clear_directory_recursive("user://tmp")

func clear_directory_recursive(dir_path: String) -> void:
	# Open the targeted directory
	var dir = DirAccess.open(dir_path)
	
	if dir:
		# Start listing files and subdirectories
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name != "." and file_name != "..":
				var full_path = dir_path.path_join(file_name)
				
				if dir.current_is_dir():
					# Recursively clear subfolders
					clear_directory_recursive(full_path)
				else:
					# Delete individual files
					dir.remove(file_name)
					
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("Failed to open or find directory: ", dir_path)
