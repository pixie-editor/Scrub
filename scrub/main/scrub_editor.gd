extends Control
@onready var render_viewport = get_node("midsection/midsection2/frame2/viewframe/SubViewport")
@onready var camera = get_node("midsection/midsection2/frame2/viewframe/SubViewport/Camera2D")
@onready var render_camera = get_node("midsection/midsection2/frame2/viewframe/SubViewport/rendercamera")
@onready var render_control = get_node("midsection/midsection2/frame2/viewframe/SubViewport/Control")

var file_menus = {1: do_new, 2: do_save, 3: do_save_as, 0: do_open, 
4: do_import}
var videos = []
var file_importer = null
var zoom_speed = 0.1
var pan_speed = 1.0  # Sensitivity for click-and-drag panning
var is_panning = false
var last_mouse_position = Vector2.ZERO
var frame_sprite: Sprite2D  # This will hold the generated frame image

func _ready() -> void:
	create_camera_frame()


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
func _process(delta: float) -> void:
	pass

func _input(event):
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
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

func _on_file_button_selected(id: int) -> void:
	file_menus[id].call()
	
func import_file_from_manager(path : String) -> void:
	var imported_file = load(path)
	print(imported_file)
	if imported_file is VideoStreamTheora:
		var newplayer = VideoStreamPlayer.new()
		newplayer.stream = imported_file
		newplayer.autoplay = true
		render_viewport.add_child(newplayer)
		newplayer.play()
		newplayer.paused = true
		videos.append(newplayer)
		var slider = $midsection/timeline/ColorRect/tempslider
		slider.max_value = newplayer.get_stream_length()
	
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

func _on_tempslider_value_changed(value: float) -> void:
	videos[0].set_stream_position(value)
