class_name DTreeNode
extends GraphNode

var left_slots: Array[String]   = []
var right_slots: Array[String]  = []
var color_normal: StyleBoxFlat  = StyleBoxFlat.new()
var color_success: StyleBoxFlat = StyleBoxFlat.new()
var color_executed: StyleBoxFlat = StyleBoxFlat.new()
var color_checked: StyleBoxFlat = StyleBoxFlat.new()


func _ready() -> void:
    color_normal.bg_color      = Color(1.0, 1.0, 1.0)
    color_success.bg_color = Color(0.25490198, 0.78431374, 0.9529412)
    color_executed.bg_color = Color(0.5058824, 0.9529412, 0.30588236)
    color_checked.bg_color = Color(0.6509804, 0.9254902, 0.5372549)


func add_label(label_text: String, left: bool, right: bool) -> Vector3i:
    var new_label: Label = Label.new()
    new_label.text = label_text
    new_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))

    self.add_child(new_label)

    var child_index: int = self.get_child_count() - 1
    if left:
        self.set_slot_enabled_left(child_index, true)
        self.set_slot_color_left(child_index, Color(0.9, 0.9, 0.9, 1))
        left_slots.append(label_text)
    if right:
        self.set_slot_enabled_right(child_index, true)
        self.set_slot_color_right(child_index, Color(0.9, 0.9, 0.9, 1))
        right_slots.append(label_text)

    # the port index is counted separately from the left and right slots
    return Vector3i(child_index, left_slots.size() - 1, right_slots.size() - 1)


func set_body_color(color: StyleBoxFlat) -> void:
    self.add_theme_stylebox_override("panel", color)

func set_label_text(label_index: int, text: String) -> void:
    var label: Label = self.get_child(label_index) as Label
    label.text = text
