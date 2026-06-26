extends ScrubMain.TrackElement

func set_media(video, media_name : String):
		get_node("track_texture").texture = video.get_seek_texture()
		get_node("track_name").text = media_name
		set_length(video.get_stream_length())
		visual_element = video
		
func seek_to(current_time, playing):
	visual_element.seek_to(current_time, playing)

func continue_play(current_time):
	if current_time < start or current_time > start + time_length:
		visual_element.visible = false
		return
	visual_element.visible = true
	if not visual_element.video.is_playing():
		if start < current_time:
			visual_element.seek_to(current_time - start, true)
		else:
			visual_element.seek_to(start, true)
	
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
				start = position.x / (100 * ScrubEditor.current_track_scale)

	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !ScrubEditor.is_dragging:
			if get_global_mouse_position().distance_to(
				ScrubEditor.drag_start_pos
			) > 8.0:
				ScrubEditor.is_dragging = true
				ScrubEditor.drag_anchor_x = position.x
			$hover_border.texture = create_border_texture(size, Color.INDIAN_RED)
