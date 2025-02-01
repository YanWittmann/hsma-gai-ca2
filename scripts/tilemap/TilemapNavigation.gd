class_name TilemapNavigation
extends Node

var tilemap_types: TileMapTileTypes = TileMapTileTypes.new()
#
var world: World          = null
var player: PlayerManager = null
#
# Dictionary[Vector2i, Array[Vector2i]] (target, path)
var found_paths: Dictionary           = {}
var failed_positions: Array[Vector2i] = []
var chosen_path: Array[Vector2i]      = []


func game_tick_start() -> void:
    found_paths.clear()
    failed_positions = []
    chosen_path    = []


func game_tick_end() -> void:
    world.tilemap_nav_vis.clear_cells()
    for path in found_paths.values():
        for pos in path:
            world.tilemap_nav_vis.set_cell(pos, tilemap_types.NAVIGATION_CHECKED)
    for pos in failed_positions:
        world.tilemap_nav_vis.set_cell(pos, tilemap_types.NAVIGATION_FAILED)
    for pos in chosen_path:
        world.tilemap_nav_vis.set_cell(pos, tilemap_types.NAVIGATION_CHOSEN)
    # mark last in chosen path as NAVIGATION_TARGET
    if chosen_path.size() > 0:
        world.tilemap_nav_vis.set_cell(chosen_path[chosen_path.size() - 1], tilemap_types.NAVIGATION_TARGET)


static func is_within_radius(position: Vector2i, center: Vector2i, radius: int, record: bool = false) -> bool:
    var is_within: bool = TilemapNavigation.manhattan_distance(position, center) <= radius
    if record:
        if is_within:
            StepVisualization.add_line_tileset(center, position, StepVisualization.LineType.SEARCH_BASE)
        else:
            StepVisualization.add_line_tileset(center, position, StepVisualization.LineType.SEARCH_FAILED)
    return is_within


static func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
    return abs(a.x - b.x) + abs(a.y - b.y)


func manhattan_distance_closest(options: Array[Vector2i], target: Vector2i) -> Vector2i:
    var closest: Vector2i = tilemap_types.NO_TILE_FOUND
    var shortest: int     = 9999999999
    for option in options:
        var distance: int = manhattan_distance(option, target)
        if distance < shortest:
            closest  = option
            shortest = distance
    return closest

var walking_directions: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
var f_score: Dictionary                 = {}


func find_path_allow_neighbors(start_position: Vector2i, end_position: Vector2i, max_radius: int = -1) -> Array[Vector2i]:
    if world.is_walkable(end_position):
        # check the tile itself first, then check the four surrounding tiles
        var path: Array[Vector2i] = find_path(start_position, end_position, max_radius)
        if path.size() != 0:
            return path

    else:
        # be smart about which to check first
        var directions: Array[Vector2i] = []
        if start_position.y < end_position.y:
            directions = [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]
        elif start_position.y > end_position.y:
            directions = [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]
        elif start_position.x < end_position.x:
            directions = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]
        elif start_position.x > end_position.x:
            directions = [Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0)]
        else:
            directions = walking_directions

        for direction in directions:
            var neighbor: Vector2i    = end_position + direction
            var path: Array[Vector2i] = find_path(start_position, neighbor, max_radius)
            if path.size() != 0:
                return path

    return []


func has_arrived(position: Vector2i, path: Array[Vector2i]) -> bool:
    return path.size() > 0 and path[path.size() - 1] == position


func path_still_valid(require_on_path: Vector2i, require_close_end: Vector2i, path: Array[Vector2i]) -> bool:
    # check if:
    # - player is on the path
    # - target is close to the last position in the path (<= 1 step away)
    # - all positions are still walkable

    if not require_on_path == tilemap_types.NO_TILE_FOUND and not path.has(require_on_path):
        return false

    if not require_close_end == tilemap_types.NO_TILE_FOUND and (path.size() == 0 or not is_within_radius(require_close_end, path[path.size() - 1], 1)):
        return false

    for pos in path:
        if not world.is_walkable(pos):
            return false
    return true


func cached_path_allow_neighbors(blackboard: Dictionary, path_key: String, target: Vector2i, max_radius: int = -1) -> Array[Vector2i]:
    var player: PlayerManager = blackboard["player"]

    if blackboard["cached_paths"].has(path_key):
        # clear ALL other that are not the current path
        for key in blackboard["cached_paths"].keys():
            if key != path_key:
                blackboard["cached_paths"].erase(key)
        # check if the path is still valid
        if path_still_valid(player.board_position, target, blackboard["cached_paths"][path_key]):
            return blackboard["cached_paths"][path_key]
        else:
            print("Cached path is invalid, recalculating for ", target, " ", path_key)
            blackboard["cached_paths"].erase(path_key)

    StepVisualization.add_line_tileset(player.board_position, target, StepVisualization.LineType.SEARCH_SELECTED)
    var path: Array[Vector2i] = find_path_allow_neighbors(player.board_position, target, max_radius)
    if path.size() > 0:
        blackboard["cached_paths"][path_key] = path
    return path


func find_path(start_position: Vector2i, end_position: Vector2i, max_radius: int = -1) -> Array[Vector2i]:
    var path: Array[Vector2i] = _find_path_internal(start_position, end_position, max_radius)
    if path.size() > 0:
        found_paths[end_position] = path
    else:
        failed_positions.append(end_position)
    return path


func _find_path_internal(start_position: Vector2i, end_position: Vector2i, max_radius: int = -1) -> Array[Vector2i]:
    if max_radius > -1 and not is_within_radius(end_position, start_position, max_radius):
        return []
    if not world.is_walkable(end_position):
        return []

    var check_nodes                = PriorityQueue.new()  # lowest f_score
    var came_from: Dictionary      = {}
    var g_score: Dictionary        = {}
    var walkable_cache: Dictionary = {}
    f_score = {}

    var visited_nodes: Dictionary = {}

    check_nodes.insert(start_position, 0)
    g_score[start_position] = 0
    f_score[start_position] = manhattan_distance(start_position, end_position) * 1.1  # Heuristic weighting

    while not check_nodes.empty():
        var current: Vector2i = check_nodes.extract()

        if current == end_position:
            var path: Array[Vector2i] = []
            while current in came_from:
                path.insert(0, current)
                current = came_from[current]
            path.insert(0, start_position)
            return path

        visited_nodes[current] = true

        for direction in walking_directions:
            var neighbor: Vector2i = current + direction

            # Combine checks for early skipping
            if neighbor in visited_nodes or (max_radius > -1 and not is_within_radius(neighbor, start_position, max_radius)):
                continue

            if not walkable_cache.has(neighbor):
                walkable_cache[neighbor] = world.is_walkable(neighbor)

            if not walkable_cache[neighbor]:
                continue

            var cost: int              = world.tilemap_ground.get_custom_data(neighbor, "cost", 1)
            var tentative_g_score: int = g_score.get(current, INF) + cost

            if tentative_g_score < g_score.get(neighbor, INF):
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g_score
                f_score[neighbor] = tentative_g_score + manhattan_distance(neighbor, end_position) * 1.1  # Heuristic weighting
                if not check_nodes.contains(neighbor):
                    check_nodes.insert(neighbor, f_score[neighbor])

    return []
