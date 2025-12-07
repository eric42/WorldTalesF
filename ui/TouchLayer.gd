extends Control
class_name TouchLayer

var dragging_unit = null
var map = null

func _ready():
    set_process_unhandled_input(true)
    map = get_tree().get_first_node_in_group("battle_map")

func _unhandled_input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            for u in map.units.get_children():
                var global_rect = Rect2(u.global_position - Vector2(24,24), Vector2(48,48))
                if global_rect.has_point(event.position):
                    dragging_unit = u
                    dragging_unit.start_drag()
                    return
        else:
            if dragging_unit:
                dragging_unit.end_drag(event.position)
                dragging_unit = null
    elif event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            for u in map.units.get_children():
                var global_rect = Rect2(u.global_position - Vector2(24,24), Vector2(48,48))
                if global_rect.has_point(event.position):
                    dragging_unit = u
                    dragging_unit.start_drag()
                    return
        elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            if dragging_unit:
                dragging_unit.end_drag(get_global_mouse_position())
                dragging_unit = null
