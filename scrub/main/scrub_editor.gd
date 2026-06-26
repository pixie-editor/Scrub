extends Control
@onready var render_viewport = get_node("midsection/midsection2/viewframe/SubViewport")
@onready var camera = get_node("midsection/midsection2/viewframe/SubViewport/Camera2D")
@onready var render_camera = get_node("midsection/midsection2/viewframe/SubViewport/rendercamera")
@onready var render_control = get_node("midsection/midsection2/viewframe/SubViewport/Control")
@onready var track_timeline = $timeline/videoelements/tracks
@onready var timelabels = $timeline/timelabels
@onready var playhead = $timeline/playhead
@onready var seek_progress = $timeline/projectcontrols/seek
@onready var elapsed_label = $timeline/projectcontrols/elapsedlabel
var tracks = []
var file_menus = {1: do_new, 2: do_save, 3: do_save_as, 0: do_open, 
4: do_import}
var file_importer = null
var zoom_speed = 0.1
var pan_speed = 1.0  # Sensitivity for click-and-drag panning
var is_panning = false
var last_mouse_position = Vector2.ZERO
var frame_sprite: Sprite2D  # This will hold the generated frame image
var mouse_controls = false
var playing = false
var is_dragging : bool = false
var selected_elements : Array = []
var drag_start_pos : Vector2
var drag_anchor_x : int = 0
var current_start : float = 0.0
var current_time : float = 0.0
var current_track_scale : float = 1.0
var max_length : float = 0.0
var scrubbing := false
var last_render_pos : float = 0.0
var max_time : float = 0.0
var frame_seek = false

func _ready() -> void:
	create_camera_frame()
	$timeline/timeline_tex.texture = create_timeline_texture(20)
	playhead.texture = create_playhead(25)

func _process(delta: float) -> void:
	if playing:
		current_time += delta
		seek_play(current_time)
		elapsed_label.text = str(current_time)
		seek_progress.value = current_time
	if is_dragging and selected_elements:
		var mouse_x = get_global_mouse_position().x
		var delta_x = mouse_x - ScrubEditor.drag_start_pos.x
		var anchor_new_x = ScrubEditor.drag_anchor_x + delta_x
		var anchor_delta = anchor_new_x - selected_elements[0].global_position.x
		for i in selected_elements:
			i.global_position.x += anchor_delta
	if scrubbing:
		seek_to(get_local_mouse_position().x)
func deselect_items():
	for item in selected_elements:
		item.deselect()
	selected_elements = []

func get_max_time():
	for track in tracks:
		var track_time = track.get_max_time()
		if track_time > max_time:
			max_time = track_time
	seek_progress.max_value = max_time
	$timeline/projectcontrols/total_timelabel.text = str(max_time)
	return(max_time)

func create_playhead(x_pos: float) -> Texture2D:
	var size = $timeline/playhead.size

	var image := Image.create(
		int(size.x),
		int(size.y),
		false,
		Image.FORMAT_RGBA8
	)

	image.fill(Color.TRANSPARENT)

	# Top grab handle
	var handle_height := 33
	var handle_width := 12

	for y in range(min(handle_height, image.get_height())):
		for x in range(
			max(0, x_pos - handle_width / 2),
			min(image.get_width(), x_pos + handle_width / 2)
		):
			image.set_pixel(x, y, Color.PALE_VIOLET_RED)

	# Main playhead line
	for y in range(handle_height, image.get_height()):
		for x in range(
			max(0, x_pos - 1),
			min(image.get_width(), x_pos + 1)
		):
			image.set_pixel(x, y, Color.ORANGE_RED)

	return ImageTexture.create_from_image(image)

func create_timeline_texture(length_seconds: float) -> Texture2D:
	var width := int(length_seconds * 100.0) # 100 px = 1 second
	var height := 64

	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for x in range(width):
		if x % 100 == 0:
			# 1 second
			for y in range(20, height):
				image.set_pixel(x, y, Color.WHITE)

		elif x % 50 == 0:
			# Half second
			for y in range(30, height):
				image.set_pixel(x, y, Color(0.8, 0.8, 0.8))

		elif x % 25 == 0:
			# Quarter second
			for y in range(40, height):
				image.set_pixel(x, y, Color(0.5, 0.5, 0.5))
	return ImageTexture.create_from_image(image)

func create_camera_frame():
	# Get the camera's visible area
	var half_screen_size = render_camera.get_viewport_rect().size * render_camera.zoom * 0.5
	var camera_position = render_camera.global_position

	# Calculate the dimensions of the frame
	var top_left = camera_position - half_screen_size
	var size = half_screen_size * 2

	# Create an Image and ImageTexture
	var img = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)

	# Draw the borders (frame) on the image
	var color = Color(1, 1, 0, 1)  # Yellow
	var thickness = 4  # Border thickness
	for x in range(int(size.x)):
		for y in range(thickness):  # Top border
			img.set_pixel(x, y, color)
		for y in range(int(size.y) - thickness, int(size.y)):  # Bottom border
			img.set_pixel(x, y, color)
	for y in range(int(size.y)):
		for x in range(thickness):  # Left border
			img.set_pixel(x, y, color)
		for x in range(int(size.x) - thickness, int(size.x)):  # Right border
			img.set_pixel(x, y, color)

	# Create an ImageTexture from the Image
	var texture = ImageTexture.create_from_image(img)

	# Add the frame to a Sprite2D
	if not frame_sprite:
		frame_sprite = Sprite2D.new()
		render_viewport.add_child(frame_sprite)
	frame_sprite.texture = texture

	# Position the sprite to align with the camera's visible area
	frame_sprite.global_position = top_left + half_screen_size  # Center the sprite
	frame_sprite.z_index = 10  # Ensure it renders on top
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _input(event):
	if not mouse_controls:
		return
	# Zoom in and out with the mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom -= Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom += Vector2(zoom_speed, zoom_speed)

		# Clamp zoom values
		camera.zoom.x = clamp(camera.zoom.x, 0.2, 5)
		camera.zoom.y = clamp(camera.zoom.y, 0.2, 5)

	# Start panning when the left mouse button is pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		is_panning = event.pressed
		if is_panning:
			last_mouse_position = event.position
	# Handle panning while dragging
	elif event is InputEventMouseMotion and is_panning:
		var mouse_delta = last_mouse_position - event.position
		camera.position += mouse_delta * camera.zoom * pan_speed
		last_mouse_position = event.position

	# Pan the camera by dragging with the right mouse button
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		camera.position -= event.relative * camera.zoom

func seek_to(time : float):
	playhead.texture = create_playhead(time * current_track_scale)
	current_time = (time / 100 + current_start) * current_track_scale
	for track in tracks:
		track.seek_elements(current_time, playing)

func seek_play(time : float):
	playhead.texture = create_playhead((time - current_start) * 100 * current_track_scale)
	current_time = time
	for track in tracks:
		track.play_elements(current_time)

func _on_file_button_selected(id: int) -> void:
	file_menus[id].call()
	
func import_file_from_manager(path : String) -> void:
	var imported_file = load(path)
	var pathsplits = path.split("/")
	pathsplits.resize(pathsplits.size() - 1)
	var directory = "/".join(pathsplits)
	if imported_file is VideoStreamTheora:
		var newplayer = load("res://elements/video_element.tscn").instantiate()
		var newplayer_video = newplayer.get_child(0)
		newplayer_video.stream = imported_file
		newplayer_video.paused = true
		render_viewport.add_child(newplayer)
		var new_track = add_new_track()
		var imported_media = load("res://tracks/track_media_video.tscn").instantiate()
		var media_name = path.split("/")
		media_name = media_name[len(media_name) - 1]
		var tmp_directory = ProjectSettings.globalize_path("user://") + "tmp/"
		tmp_directory = tmp_directory + media_name + ".ogg"
		OS.execute("ffmpeg", ["-i", path, "-vn", "-acodec", "libvorbis", 
			tmp_directory])
		while not FileAccess.file_exists(tmp_directory):
			pass
		var audio_track = add_new_track()
		var audio_media = load("res://tracks/track_media_audio.tscn").instantiate()
		var audio_stream = load("res://elements/audio_element.tscn").instantiate()
		audio_stream.get_child(0).stream = AudioStreamOggVorbis.load_from_file(tmp_directory)
		audio_media.set_media(audio_stream, media_name, tmp_directory)
		imported_media.set_media(newplayer, media_name)
		audio_track.add_element(audio_media, current_time)
		new_track.add_element(imported_media, current_time)
		get_max_time()
		
func add_new_track():
	var track_n : int = track_timeline.get_child_count() - 1
	if track_n == -1:
		track_n = 0
	var new_track = load("res://tracks/track.tscn").instantiate()
	new_track.track_number = track_n
	track_timeline.add_child(new_track)
	tracks.append(new_track)
	return(new_track)
	
	
func do_import() -> void:
	file_importer = load("res://main/filebrowser.tscn").instantiate()
	file_importer.file_selected.connect(import_file_from_manager)
	add_child(file_importer)
	file_importer.popup()
	
func do_new() -> void:
	pass

func do_save() -> void:
	pass

func do_open() -> void:
	pass

func do_save_as() -> void:
	pass

func _on_viewframe_mouse_entered() -> void:
	mouse_controls = true


func _on_viewframe_mouse_exited() -> void:
	mouse_controls = false

func _on_playbutton_pressed() -> void:
	playing = not playing
	if playing:
		frame_seek = true
	else:
		frame_seek = false

func rerender_tracks(start_pos : float, track_scale : float):
	if last_render_pos == start_pos:
		return
	last_render_pos = start_pos
	timelabels.start = start_pos
	timelabels.timeline_scale = track_scale
	timelabels.queue_redraw()
	for track in tracks:
		track.rerender_track(start_pos, track_scale)

func _on_tracks_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and Input.is_action_pressed("multiselect"):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if current_start == 0:
				return
			current_start -= (current_track_scale * .25)
			rerender_tracks(current_start,  current_track_scale)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_start += (current_track_scale * .25)
			rerender_tracks(current_start,  current_track_scale)

func _on_timelabels_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		scrubbing = event.pressed
		if scrubbing:
			seek_to(event.position.x)


func _on_seek_value_changed(value: float) -> void:
	if frame_seek:
		return
	seek_to(value)
