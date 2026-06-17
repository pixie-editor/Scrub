extends Control
var track_number : int
var elements : Array = []

class TrackElement:
	var element_name : String
	var start : float
	var end : float
	var node : Node

func add_element(element : Node, position : float):
	var te = TrackElement.new()
	te.start = position
	te.end = position + element.time_length
	te.node = element
	add_child(element)
