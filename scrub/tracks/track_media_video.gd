extends ColorRect
var hovered := false
var time_length = 0.0
var selected : bool = false

func set_media(video : VideoStreamPlayer, media_name : String):
	$track_texture.texture = video.get_video_texture()
	$track_name.text = media_name
	set_length(video.get_stream_length())

func set_length(value : float):
	time_length = value
	size = Vector2(value * 10, 69.0)
	$hover_border.size = size

func create_border_texture(tex_size: Vector2, 
		border_color : Color = Color.FLORAL_WHITE) -> Texture2D:
	var img := Image.create(
		int(tex_size.x),
		int(tex_size.y),
		false,
		Image.FORMAT_RGBA8
	)

	img.fill(Color.TRANSPARENT)
	var thickness := 2

	# Top / Bottom
	for x in range(img.get_width()):
		for t in range(thickness):
			img.set_pixel(x, t, border_color)
			img.set_pixel(x, img.get_height() - 1 - t, border_color)

	# Left / Right
	for y in range(img.get_height()):
		for t in range(thickness):
			img.set_pixel(t, y, border_color)
			img.set_pixel(img.get_width() - 1 - t, y, border_color)

	return ImageTexture.create_from_image(img)

func _on_mouse_entered() -> void:
	if not selected:
		$hover_border.texture = create_border_texture(size)
	

func _on_mouse_exited() -> void:
	if not selected:
		$hover_border.texture = null

func deselect():
	selected = false
	$hover_border.texture = null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				ScrubEditor.drag_start_pos = get_global_mouse_position()
				if Input.is_action_pressed("multiselect"):
					ScrubEditor.selected_elements.append(self)
				else:
					ScrubEditor.deselect_items()
					ScrubEditor.selected_elements.append(self)
				$hover_border.texture = create_border_texture(size, Color.INDIAN_RED)
				selected = true
			else:
				ScrubEditor.is_dragging = false

	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !ScrubEditor.is_dragging:
			if get_global_mouse_position().distance_to(
				ScrubEditor.drag_start_pos
			) > 8.0:
				ScrubEditor.is_dragging = true
				ScrubEditor.drag_anchor_x = position.x
			$hover_border.texture = create_border_texture(size, Color.INDIAN_RED)
