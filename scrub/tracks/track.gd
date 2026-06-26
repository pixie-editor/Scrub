extends Control
var track_number : int
var elements : Array = []

func add_element(element : Node, position : float):
	elements.append(element)
	add_child(element)

func rerender_track(start : float, timeline_scale : float = 1.0):
	for element in elements:
		var element_end = element.start + element.time_length
		if element_end < start:
			element.position.x = -100000
			continue
		var start_diff = element.start - start
		element.position.x = start_diff * (100 * timeline_scale)

func seek_elements(current_time : float, playing : bool = false):
	for element in elements:
		var element_end = element.start + element.time_length
		if current_time < element.start or element_end < current_time:
			element.visual_element.visible = false
			continue
		element.visual_element.visible = true
		element.seek_to(current_time - element.start, playing)
func play_elements(current_time : float):
	for element in elements:
		var element_end = element.start + element.time_length
		if current_time < element.start or element_end < current_time:
			element.visual_element.visible = false
			continue
		element.visual_element.visible = true
		element.continue_play(current_time)
func get_max_time() -> float:
	var highest = 0.0
	for element in elements:
		var element_end = element.start + element.time_length
		if element_end > highest:
			highest = element_end
	return(highest)
