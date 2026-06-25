extends Control
var track_number : int
var elements : Array = []

func add_element(element : Node, position : float):
	elements.append(element)
	add_child(element)

func rerender_track(start : float, timeline_scale : float = 1.0):
	for element in elements:
		var element_end = element.start + element.time_length
		print(element.time_length, "\n\n")
		print("end", "\n", element_end, "\n", start)
		if element_end < start:
			element.position.x = -100000
			continue
		var start_diff = element.start - start
		element.position.x = start_diff * (100 * timeline_scale)
		
