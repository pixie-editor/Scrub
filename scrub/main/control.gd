extends Control

func _draw():
	var font = ThemeDB.fallback_font

	for i in range(size.x / 25):
		var x = i * 25

		if i % 4 == 0:
			draw_line(Vector2(x, 20), Vector2(x, size.y), Color.WHITE)
			draw_string(
				font,
				Vector2(x + 2, 14),
				str(i / 4)
			)

		elif i % 2 == 0:
			draw_line(Vector2(x, 30), Vector2(x, size.y), Color.GRAY)
			draw_string(font, Vector2(x + 2, 14), str(i / 4) + ".5")

		else:
			draw_line(Vector2(x, 40), Vector2(x, size.y), Color.DARK_GRAY)
