class_name Task
extends Node

enum {FAILURE = -1, SUCCESS = 1, RUNNING = 0, SUCCESS_STOP = 2}
static var print_behavior_tree_evaluation: bool = false
#
var status: int                     = FAILURE
var status_reason: String           = ""
var tilemap_types: TileMapTileTypes = TileMapTileTypes.new()


func _ready() -> void:
    for c in get_children():
        if not c is Task:
            push_error("Child is not a task: " + c.name + " in " + name)
            return


func internal_run(blackboard: Dictionary) -> void:
    blackboard["current_task"] = self

    var running_child: Task  = find_running_child()
    var extra_string: String = ""
    if running_child != null:
        extra_string = running_child.name

    if print_behavior_tree_evaluation:
        print(" -> ", human_readable(extra_string))
    run(blackboard)
    if print_behavior_tree_evaluation:
        print("   <- ", human_readable(extra_string))


func find_running_child() -> Task:
    for c in get_children():
        if c.status == RUNNING:
            return c
    return null


func run_child(blackboard: Dictionary, p_child: Task) -> void:
    p_child.internal_run(blackboard)
    if p_child.status != RUNNING:
        status = RUNNING


func slice_at_child(start_child: Task) -> Array:
    var children: Array[Node] = get_children()
    if start_child == null:
        return children
    var start_index: int = children.find(start_child)
    if start_index == -1:
        return children
    return children.slice(start_index, children.size())


func run(blackboard: Dictionary) -> void:
    pass


func cancel(blackboard: Dictionary):
    pass


func get_first_child() -> Task:
    if get_child_count() == 0:
        push_error("Task does not have any children: " + name)
        return null
    return get_children()[0] as Task


func human_readable(addon: String = "") -> String:
    var clear_status: String = clear_status()

    var ret: String = name;
    if addon != "":
        ret += " " + addon
    if status_reason != "":
        ret += " [" + clear_status + ", " + status_reason + "]"
    else:
        ret += " [" + clear_status + "]"

    return ret


func clear_status() -> String:
    if status == FAILURE:
        return "FAILURE"
    elif status == SUCCESS:
        return "SUCCESS"
    elif status == RUNNING:
        return "RUNNING"
    elif status == SUCCESS_STOP:
        return "SUCCESS_STOP"
    return "UNKNOWN"


# SECTION: utility

func find_closest_item(blackboard: Dictionary, item_types: Array[Vector2i], memory_key: String, max_distance: int = -1) -> Dictionary:
    var world: World                  = blackboard["world"]
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    var result: Dictionary = {"status": FAILURE, "status_reason": "", "closest_item": null}

    var items: Array[Vector2i] = world.tilemap_interactive.get_cells_by_type_collection(
                                     item_types, player.board_position, max_distance if max_distance > -1 else player.view_distance)

    if len(items) == 0:
        result.status_reason = "No items of type " + str(item_types) + " found"
        return result

    var closest_item: Vector2i = navigation.manhattan_distance_closest(items, player.board_position)
    player.player_memory[memory_key] = closest_item
    StepVisualization.add_line_tileset(player.board_position, closest_item, StepVisualization.LineType.SEARCH_SELECTED)
    if closest_item == tilemap_types.NO_TILE_FOUND:
        result.status_reason = "No closest item of type " + str(item_types) + " found"
        return result

    result.status = SUCCESS
    result.closest_item = closest_item
    return result

func find_task_by_name(name: String) -> Task:
    for c in get_children():
        if c.name == name:
            return c
        if c.get_child_count() > 0:
            var found: Task = c.find_task_by_name(name)
            if found != null:
                return found
    return null
