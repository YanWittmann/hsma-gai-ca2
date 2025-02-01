class_name PlayerManager
extends Node

@export var max_health: int = 100
# food system
@export var max_food: int = 250
@export var food_damage: int = 1
@export var food_critical_threshold: int = 50
@export var food_base_threshold: int = 150
# temperature
@export var temperature_set_buff_value: int = 150
@export var temperature_damage: int = 1
@export var temperature_endure: int = 50
# viewing
@export var view_distance: int = 50

var tilemap_types: TileMapTileTypes = TileMapTileTypes.new()
#
var game_manager: GameManager     = null
var last_board_position: Vector2i = Vector2i(0, 0)

var board_position: Vector2i = Vector2i(0, 0):
    set(value):
        last_board_position = board_position
        board_position = value
        update_board()

@onready var behavior_tree: BehaviorTree     = $BehaviorTree

var exploration_task: TaskPlannedExploration = null
var food: int = max_food
# var water: int = 0
var temperature_buff_timer: int = 0
var temperature_timer: int      = 0
var health: int                 = max_health

var inventory_slot: Vector2i  = tilemap_types.EMPTY:
    set(value):
        inventory_slot = value
        update_board()

var player_memory: Dictionary = {}


func _ready() -> void:
    call_deferred("defer_ready")


func defer_ready() -> void:
    behavior_tree.game_manager = game_manager
    var player_start_position: Array[Vector2i] = game_manager.world.tilemap_player.get_cells_by_type(tilemap_types.PLAYER_DOWN)
    if len(player_start_position) > 0:
        board_position = player_start_position[0]
    else:
        push_error("No player start position found on tilemap")
        update_board()
    exploration_task = behavior_tree.find_task_by_name("TaskPlannedExploration")


func _process(delta: float) -> void:
    if Input.is_action_just_pressed("key_1"):
        game_manager.camera.go_to_zooming(game_manager.world.tilemap_player.cell_to_local(board_position), 2)
    if Input.is_action_just_pressed("key_5"):
        pick_up_item(Vector2i(5, 8))
        pick_up_item(Vector2i(9, 9))
    if Input.is_action_just_pressed("key_4"):
        var nearest: Vector2i = find_nearest_object([game_manager.world.tilemap_types.OBJECT_I_TREE_FULL])
        # nearest.x = nearest.x - 1
        walk_towards(nearest)


# SECTION: board access/mangement

func update_board() -> void:
    game_manager.world.tilemap_player.clear_cells()
    # decide what direction the player is facing tilemap_types.PLAYER_DOWN, ...
    var direction: Vector2i = find_direction(last_board_position, board_position)
    game_manager.world.tilemap_player.set_cell(board_position, tilemap_types.player_sprite_from_direction(direction))

    if inventory_slot and inventory_slot != tilemap_types.EMPTY:
        %InventoryContentRect.texture = game_manager.world.tilemap_interactive.get_cell_texture(inventory_slot)
    else:
        %InventoryContentRect.texture = null


# SECTION: inventory system

func pick_up_item(tilemap_pos: Vector2i) -> void:
    var pick_up_cell: TileData = game_manager.world.tilemap_interactive.get_cell(tilemap_pos)
    if not pick_up_cell:
        push_warning("Player trying to pick up item that does not exist at ", tilemap_pos)
        return

    var pick_up_item_type: Vector2i = game_manager.world.tilemap_interactive.tilemap.get_cell_atlas_coords(tilemap_pos)

    # check if inventory contains item that needs to be transformed on dropping
    # this should never be the case, as the pick up item operation should already reflect this transformation
    var tile_drop_item: Vector2i = inventory_slot
    if tile_drop_item == tilemap_types.OBJECT_I_FILLED_BUSH:
        tile_drop_item = tilemap_types.OBJECT_I_BERRY
    elif tile_drop_item == tilemap_types.OBJECT_I_TREE_FULL:
        tile_drop_item = tilemap_types.OBJECT_I_STICK

    # check if tile will transform into another tile upon pickup
    var tile_after_pickup_transform = null
    if pick_up_item_type == tilemap_types.OBJECT_I_FILLED_BUSH:
        tile_after_pickup_transform = tilemap_types.OBJECT_I_EMPTY_BUSH
        pick_up_item_type = tilemap_types.OBJECT_I_BERRY
    elif pick_up_item_type == tilemap_types.OBJECT_I_TREE_FULL:
        tile_after_pickup_transform = tilemap_types.OBJECT_I_TREE_CUT
        pick_up_item_type = tilemap_types.OBJECT_I_STICK

    # check if the inventory slot is empty
    if inventory_slot == tilemap_types.EMPTY:
        inventory_slot = pick_up_item_type
        if tile_after_pickup_transform:
            game_manager.world.tilemap_interactive.set_cell(tilemap_pos, tile_after_pickup_transform)
        else:
            game_manager.world.tilemap_interactive.clear_cell(tilemap_pos)
        print("Picked up item: ", pick_up_item_type)
        EventsTracker.track(EventsTracker.Event.PLAYER_PICKED_UP_ITEM, {"item": pick_up_item_type})

    else:
        # inventory is full, swap the item
        print("Inventory is full. Swapping item: ", inventory_slot, " with item: ", pick_up_item_type)
        EventsTracker.track(EventsTracker.Event.PLAYER_DROPPED_ITEM, {"item": inventory_slot})
        EventsTracker.track(EventsTracker.Event.PLAYER_PICKED_UP_ITEM, {"item": pick_up_item_type})
        if tile_after_pickup_transform:
            game_manager.world.tilemap_interactive.set_cell(tilemap_pos, tile_after_pickup_transform)
            var drop_location: Vector2i = game_manager.world.find_item_drop_location(tilemap_pos)
            if drop_location != tilemap_types.EMPTY:
                game_manager.world.tilemap_interactive.set_cell(drop_location, tile_drop_item)
            else:
                push_warning("Could not find valid drop position for ", inventory_slot)
        else:
            game_manager.world.tilemap_interactive.set_cell(tilemap_pos, tile_drop_item)
        inventory_slot = pick_up_item_type


# SECTION: player movement

func walk_towards(position: Vector2i) -> void:
    var path: Array[Vector2i] = game_manager.tilemap_navigation.find_path(board_position, position)
    walk_along(path)


func walk_along(path: Array[Vector2i]) -> void:
    if len(path) > 1:

        var next_position: Vector2i
        if path.has(board_position):
            var current_index: int = path.find(board_position)
            if current_index < path.size() - 1:
                next_position = path[current_index + 1]
            else:
                next_position = path[1]
        else:
            next_position = path[1]

        var direction: Vector2i = find_direction(board_position, next_position)
        move_player(direction)
        game_manager.tilemap_navigation.chosen_path = path
    else:
        push_warning("walk_along path is empty")


func move_player(direction: Vector2i) -> void:
    var new_position: Vector2 = board_position + direction
    if game_manager.world.is_walkable(new_position):
        board_position = new_position
    else:
        push_warning("Player trying to move to non-walkable position, prevented ", new_position)


func find_nearest_object(object_collection: Array[Vector2i]) -> Vector2i:
    var object_positions: Array[Vector2i] = []

    for obj in object_collection:
        object_positions.append_array(game_manager.world.tilemap_interactive.get_cells_by_type(obj))

    if object_positions.size() == 0:
        push_warning("No " + str(object_collection) + " found!")
        return tilemap_types.NO_TILE_FOUND

    var closest_object: Vector2i = tilemap_types.NO_TILE_FOUND
    var shortest_distance: float = 99999999

    for position in object_positions:
        var distance: float = game_manager.tilemap_navigation.manhattan_distance(board_position, position)
        if closest_object == tilemap_types.NO_TILE_FOUND or distance < shortest_distance:
            closest_object = position
            shortest_distance = distance

    print("Find nearest " + str(object_collection) + " at:", closest_object)
    return closest_object


func find_direction(pos_a: Vector2i, pos_b: Vector2i) -> Vector2i:
    var direction: Vector2i = Vector2i(0, 0)
    if pos_a.x < pos_b.x:
        direction.x = 1
    elif pos_a.x > pos_b.x:
        direction.x = -1

    if pos_a.y < pos_b.y:
        direction.y = 1
    elif pos_a.y > pos_b.y:
        direction.y = -1

    return direction


# SECTION: game tick

func get_current_temperature() -> int:
    return game_manager.world.tilemap_temperature.get_custom_data(board_position, "temperature", 0) as int


func tick_handle_temperature(cell_temperature: int) -> void:
    if temperature_buff_timer > 0:
        temperature_buff_timer -= 1
        return

    if cell_temperature == 0:
        temperature_timer = 0
    elif temperature_timer > temperature_endure:
        temperature_timer += cell_temperature
        health -= temperature_damage


func tick_handle_food():
    if food > 0:
        food -= 1
    if food <= 0:
        health -= food_damage


func game_tick() -> void:
    behavior_tree.game_tick()
    StepVisualization.add_circle_tileset(board_position, view_distance / 1.2, StepVisualization.CircleType.PLAYER_VIEW)

    tick_handle_temperature(get_current_temperature())
    tick_handle_food()

    if health < 0:
        game_manager.player_health_depleted()

    update_board()
