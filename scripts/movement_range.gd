extends Node
class_name MovementRange

func get_reachabe(start: Vector2i, max_range: int) -> Array:
	var cells := []
	for x in range(-max_range, max_range + 1):
		for y in range(-max_range, max_range + 1):
			if abs(x) + abs(y) <= max_range:
				cells.append(start + Vector2i(x, y))
	return cells
