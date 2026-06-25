extends Node

func load_audio_img(path : String, name : String, len : float):
	var output = []
	var err = []
	var tmp_path = OS.get_user_data_dir() + "/tmp/" + name + ".png"
	var width = int(len * 100)
	OS.execute("ffmpeg", [
	"-y",
	"-i", path,
	"-filter_complex", "aformat=channel_layouts=mono,showwavespic=s=" + str(width) + "x69:colors=orange",
	"-frames:v", "1",
	tmp_path
], output, true)
	while not FileAccess.file_exists(tmp_path):
		pass
	return(Image.load_from_file(tmp_path))

class TrackElement:
	extends ColorRect
	var hovered := false
	var time_length = 0.0
	var selected : bool = false
	var element_name : String
	var start : float
	var node : Node

	func set_length(value : float):
		time_length = value
		size = Vector2(value * 100, 69.0)
		get_node("hover_border").size = size

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
class VisualElement:
	pass
