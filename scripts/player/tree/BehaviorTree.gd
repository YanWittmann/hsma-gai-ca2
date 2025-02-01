class_name BehaviorTree
extends Node

var game_manager: GameManager = null
#
var blackboard: Dictionary = {}
var behavior_tree: Task    = null


func _ready() -> void:
    if get_child_count() == 0 or get_child_count() > 1:
        push_error("This controller needs exactly one Task child, got " + str(get_child_count()))

    var child: Node = get_child(0)
    if not (child is Task):
        push_error("Child is not a task: " + child.name)

    behavior_tree = child as Task

    initialize_blackboard()


func initialize_blackboard() -> void:
    blackboard["cached_paths"] = {}


func populate_blackboard():
    blackboard["world"] = game_manager.world
    blackboard["player"] = game_manager.player
    blackboard["camera"] = game_manager.camera
    blackboard["navigation"] = game_manager.tilemap_navigation


func game_tick() -> void:
    populate_blackboard()
    behavior_tree.internal_run(blackboard)
    if Task.print_behavior_tree_evaluation:
        print(" ==> [active state=", blackboard["current_task"], "] [status=", behavior_tree.status, "] [blackboard=", blackboard, "]")

func find_task_by_name(name: String) -> Task:
    return behavior_tree.find_task_by_name(name)
