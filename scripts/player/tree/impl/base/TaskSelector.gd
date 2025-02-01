class_name TaskSelector
extends Task

func run(blackboard: Dictionary) -> void:
    if get_children().size() == 0:
        status = FAILURE
        status_reason = "no children"
        return

    var running_child: Task = find_running_child()
    for c in slice_at_child(running_child):
        run_child(blackboard, c)
        if c.status == SUCCESS_STOP:
            c.status = SUCCESS
            status = SUCCESS
            status_reason = "stopping at " + c.name + " (STOP)"
            return
        if c.status != FAILURE:
            status = c.status
            status_reason = "stopped at " + c.name
            return
    status = FAILURE
    status_reason = "all children failed"
