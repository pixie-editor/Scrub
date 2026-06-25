extends Control

var start: float = 0.0
var timeline_scale: float = 1.0

const QUARTER_SECOND := 0.25
const PIXELS_PER_QUARTER := 25.0

func _draw():
	var font = ThemeDB.fallback_font

	var quarter_px = PIXELS_PER_QUARTER * timeline_scale
	var pixels_per_second = quarter_px / QUARTER_SECOND
	var seconds_per_pixel = 1.0 / pixels_per_second

	var tick_count = int(ceil(size.x / quarter_px))

	for i in range(tick_count + 1):
		var x = int(i * quarter_px)

		# convert pixel position → time
		var time = start + float(x) * seconds_per_pixel

		# major tick (every 1 second)
		if i % 4 == 0:
			draw_line(
				Vector2(x, 20),
				Vector2(x, size.y),
				Color.WHITE
			)

			draw_string(
				font,
				Vector2(x + 2, 14),
				str(snapped(time, 0.01))
			)

		# medium tick (every 0.5 sec)
		elif i % 2 == 0:
			draw_line(
				Vector2(x, 30),
				Vector2(x, size.y),
				Color.GRAY
			)

		# minor tick (every 0.25 sec)
		else:
			draw_line(
				Vector2(x, 40),
				Vector2(x, size.y),
				Color.DARK_GRAY
			)
