class_name TaskPlannedExploration
extends Task

var last_goals: Array[Vector2i]     = []
var current_goal: Vector2i          = tilemap_types.NO_TILE_FOUND
var closest_distance_to_goal: float = 99999999


func run(blackboard: Dictionary) -> void:
    var world: World                  = blackboard["world"]
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    # check if player distance is < 10 to the camp (world, camp_manager, camp) and if he was closer than the view distance to the goal once (closest_distance_to_goal), reset the goal in that case
    if TilemapNavigation.manhattan_distance(player.board_position, world.camp_manager.camp) < 10 and closest_distance_to_goal < player.view_distance:
        current_goal = tilemap_types.NO_TILE_FOUND
        closest_distance_to_goal = 99999999
        EventsTracker.track(EventsTracker.Event.EXPLORATION_GOAL_CLOSE_ENOUGH, {"item": tilemap_types.OBJECT_I_TENT})
        print("Resetting goal, player close to camp and was close to goal once")

    # check if player distance is < 2 to the current goal
    if current_goal != tilemap_types.NO_TILE_FOUND:
        if TilemapNavigation.manhattan_distance(player.board_position, current_goal) < 3:
            EventsTracker.track(EventsTracker.Event.EXPLORATION_GOAL_REACHED, {"goal": current_goal})
            current_goal = tilemap_types.NO_TILE_FOUND

    if current_goal == tilemap_types.NO_TILE_FOUND:
        find_new_goal(world, player, navigation)
        if current_goal != tilemap_types.NO_TILE_FOUND:
            EventsTracker.track(EventsTracker.Event.NEW_EXPLORATION_GOAL, {"goal": current_goal})
            closest_distance_to_goal = 99999999

    if current_goal == tilemap_types.NO_TILE_FOUND:
        status = Task.FAILURE
        status_reason = "No goal found"
        return

    StepVisualization.add_circle_tileset(current_goal, 2, StepVisualization.CircleType.GOAL)
    StepVisualization.add_line_tileset(player.board_position, current_goal, StepVisualization.LineType.SEARCH_SELECTED)

    var path: Array[Vector2i] = navigation.cached_path_allow_neighbors(blackboard, "exploration_goal", current_goal)
    if path.size() == 0:
        current_goal = tilemap_types.NO_TILE_FOUND
        status = Task.FAILURE
        status_reason = "No path found"
        return

    blackboard["path"] = path

    status = Task.SUCCESS
    status_reason = "goal: " + str(current_goal)


func find_new_goal(world: World, player: PlayerManager, navigation: TilemapNavigation) -> void:
    if last_goals.size() == 0:
        last_goals.append(world.camp_manager.camp)

    # perform search for a new goal X times, pick the one that is furthest away from the last goal
    var best_goal: Vector2i  = tilemap_types.NO_TILE_FOUND
    var best_distance: float = 0

    for i in range(3):
        var goal_consideration: Vector2i = determine_an_interesting_goal(world)
        if goal_consideration == tilemap_types.NO_TILE_FOUND:
            continue
        StepVisualization.add_circle_tileset(goal_consideration, 2, StepVisualization.CircleType.GOAL_CONSIDERATION)
        StepVisualization.add_line_tileset(player.board_position, goal_consideration, StepVisualization.LineType.SEARCH_BASE)

        var distance: float = TilemapNavigation.manhattan_distance(goal_consideration, navigation.manhattan_distance_closest(last_goals, goal_consideration))
        if distance > best_distance:
            best_goal = goal_consideration
            best_distance = distance

    if best_goal != tilemap_types.NO_TILE_FOUND:
        last_goals.append(best_goal)
        current_goal = best_goal


func determine_an_interesting_goal(world: World) -> Vector2i:
    # starting from the camp position (world.camp_manager.camp),
    # pick a random direction (360 degrees, random on x and y then normalize),
    # then step in that direction until the last walkable tile is found
    # (if not walkable, check every step for the next 10 tiles again and only stop if none of them are walkable)
    # then, pick a random walkable tile in the area around that last walkable tile,
    # and check if the player can get there using the navigation system.

    var camp_position: Vector2 = Vector2(world.camp_manager.camp)
    var direction: Vector2     = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()

    var last_walkable: Vector2i     = Vector2i(0, 0)
    var iterations_no_walkable: int = 0

    for i in range(2500):
        var check_position: Vector2i = camp_position + (direction * i * 2).floor()
        if not world.is_walkable(check_position):
            iterations_no_walkable += 1
        else:
            iterations_no_walkable = 0
            last_walkable = check_position

        if iterations_no_walkable > 10:
            break

    if last_walkable == Vector2i(0, 0):
        return tilemap_types.NO_TILE_FOUND

    var picked_goal: Vector2i = Vector2i(0, 0)
    for i in range(10):
        var check_position: Vector2i = last_walkable + Vector2i(randi_range(-10, 10), randi_range(-10, 10))
        if world.is_walkable(check_position) and world.tilemap_ground.get_custom_data(check_position, "cost", 999) < 7:
            picked_goal = check_position
            break

    return picked_goal