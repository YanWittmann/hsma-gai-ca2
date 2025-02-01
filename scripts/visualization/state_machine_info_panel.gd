class_name InfoPanel
extends VBoxContainer

var values: Dictionary      = {}
var last_values: Dictionary = {}
var value_order: Array      = []


func _ready() -> void:
	hide()


func to_str(value) -> String:
	if value is float:
		return str(round(value * 100) / 100)
	elif value is Vector2:
		return "(" + to_str(value.x) + ", " + to_str(value.y) + ")"
	elif value is Vector3:
		return "(" + to_str(value.x) + ", " + to_str(value.y) + ", " + to_str(value.z) + ")"
	elif value is Vector4:
		return "(" + to_str(value.x) + ", " + to_str(value.y) + ", " + to_str(value.z) + ", " + to_str(value.w) + ")"
	return str(value)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_vis_2"):
		if is_visible():
			hide()
		else:
			show()

	for child in self.get_children():
		if child is Label:
			child.queue_free()

	# 1. Update and Track Order of Values
	for value in values.keys():
		if value in value_order:
			# Move to the end (most recent)
			value_order.erase(value)
		value_order.append(value)

	# 2. Display Current Values (Most Recent First)
	for value in value_order:
		if values.has(value):
			var new_label: Label = Label.new()
			new_label.text = value + ": " + to_str(values[value])
			new_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
			self.add_child(new_label)
			last_values[value] = values[value]

	# 3. Display Old Values
	for value in last_values.keys():
		if not values.has(value):
			var new_label: Label = Label.new()
			new_label.text = value + ": " + to_str(last_values[value])
			new_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
			self.add_child(new_label)

	values.clear()
