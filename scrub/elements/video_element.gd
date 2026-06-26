extends ScrubMain.VisualElement
@onready var video = $VideoStreamPlayer

func get_stream_length():
	return(video.get_stream_length())

func get_seek_texture():
	video.play()
	var image = capture_frame()
	video.set_paused(true)
	return(ImageTexture.create_from_image(image))

func get_stream_texture():
	video.get_video_texture()

func seek_to(time : float, playing : bool):
	video.set_stream_position(time)
	video.set_paused(not playing)

func capture_frame():
	seek_to(0.0, true)
	var video_tex = video.get_video_texture()
	seek_to(0.0, false)
	var image = video_tex.get_image()
	return(image)


func _on_video_stream_player_finished() -> void:
	print("HELLO?")
	seek_to(0.0, ScrubEditor.playing)
	video.stop()
