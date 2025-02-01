class_name BehaviorTreeVisualizer
extends Window

const D_TREE_NODE: PackedScene = preload("res://scripts/visualization/d_tree_node.tscn")
@onready var graph_edit: GraphEdit = %GraphEdit

#
var behavior_tree: BehaviorTree
#
var x_spacing: int = 430
var y_spacing: int = 100
#
var all_nodes: Array[DTreeNode] = []
# Dictionary[Task, DTreeNode]
var task_to_node: Dictionary = {}
var parent_nodes: Dictionary = {}
#
var current_lowest_node_pos: Vector2 = Vector2(0, 0)

func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("toggle_graph_edit"):
        if is_visible():
            hide()
        else:
            show()

func build_tree() -> void:
    if not behavior_tree:
        push_error("No behavior tree set.")
        return

    # reset current visualization
    graph_edit.clear_connections()
    for node in all_nodes:
        node.queue_free()
    all_nodes.clear()

    var root_task: Task = behavior_tree.behavior_tree
    if not root_task:
        push_error("Root behavior tree node is null.")
        return

    current_lowest_node_pos = Vector2(0, 0)
    build_tree_from_task(root_task, 0)


func build_tree_from_task(task: Task, depth: int) -> DTreeNode:
    var child_nodes: Array[DTreeNode]        = []
    var child_node_positions: Array[Vector2] = []

    for child in task.get_children():
        var child_node: DTreeNode = build_tree_from_task(child, depth + 1)
        child_nodes.append(child_node)
        child_node_positions.append(child_node.position_offset)

    var current_node: DTreeNode = D_TREE_NODE.instantiate()
    graph_edit.add_child(current_node)
    task_to_node[task] = current_node
    current_node.name = task.get_name() + str(randf())
    current_node.title = human_readable_task_name(task.get_name())
    current_node.add_label("status", true, true)
    all_nodes.append(current_node)

    for child in child_nodes:
        graph_edit.connect_node(current_node.name, 0, child.name, 0)
        parent_nodes[child] = current_node

    if child_node_positions.size() > 0:
        var average_position: Vector2 = Vector2(0, 0)
        for pos in child_node_positions:
            average_position += pos
        average_position /= child_node_positions.size()

        current_node.position_offset = average_position - Vector2(x_spacing, 0)
        # print("as parent: ", current_node.name, " ", current_node.position_offset, " ", depth, " ", child_node_positions)

    else:
        current_node.position_offset = Vector2(current_lowest_node_pos)
        current_node.position_offset.x += depth * x_spacing
        current_lowest_node_pos.y += y_spacing
        # print("as leaf: ", current_node.name, " ", current_node.position_offset, " ", depth)
        pass

    return current_node


func update_task_statuses(blackboard: Dictionary) -> void:
    for t in task_to_node.keys():
        var task: Task            = t as Task
        var node: DTreeNode       = task_to_node[task]
        var status: int           = task.status
        var clear_status: String  = task.clear_status()
        var status_reason: String = task.status_reason

        if status_reason != "":
            node.set_label_text(0, status_reason)
        else:
            node.set_label_text(0, clear_status)

        node.set_body_color(node.color_normal)
        if status == Task.RUNNING or status == Task.SUCCESS or status == Task.SUCCESS_STOP:
            node.set_body_color(node.color_success)

    if blackboard.has("current_task"):
        var selected_node = task_to_node[blackboard["current_task"]]
        if selected_node:
            center_view_on_position(selected_node.position_offset)
            selected_node.set_body_color(selected_node.color_executed)
            while parent_nodes.has(selected_node):
                selected_node = parent_nodes[selected_node]
                selected_node.set_body_color(selected_node.color_checked)


func center_view_on_position(target_position: Vector2) -> void:
    var graph_edit_size: Vector2 = graph_edit.size
    var zoom: float              = graph_edit.zoom
    var offset_x: float          = target_position.x * zoom - graph_edit_size.x / 2
    var offset_y: float          = target_position.y * zoom - graph_edit_size.y / 2
    graph_edit.scroll_offset = Vector2(offset_x, offset_y)


func human_readable_task_name(input: String) -> String:
    var prefixes: Dictionary    = {"sl_": "Selector: ", "sq_": "Sequence: ", "Task": ""}
    var selected_prefix: String = ""

    for prefix in prefixes.keys():
        if input.begins_with(prefix):
            selected_prefix = prefix
            input = input.substr(prefix.length())
            break

    var words: Array[Variant] = []
    var current_word: String  = ""

    for i in range(input.length()):
        var character: String = input[i]
        if character.to_upper() == character and current_word.length() > 0:
            words.append(current_word)
            current_word = "" + character.to_lower()
        elif character == "_":
            if current_word.length() > 0:
                words.append(current_word)
                current_word = ""
        else:
            current_word += character.to_lower()

    if current_word.length() > 0:
        words.append(current_word)

    var result: String = " ".join(words)
    if selected_prefix in prefixes and prefixes[selected_prefix] != "":
        result = prefixes[selected_prefix] + result

    return result


func _on_close_requested() -> void:
    hide()
