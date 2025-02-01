class_name CampManager
extends Node

var tilemap_types: TileMapTileTypes = TileMapTileTypes.new()
#
var game_manager: GameManager               = null
var tilemap_interactive: TileMapLayerAccess = null
#
var camp_items: Array[Vector2i]   = []
var boat_items: Array[Vector2i]   = []
var camp: Vector2i                = tilemap_types.EMPTY
var campfire: Vector2i            = tilemap_types.EMPTY
var boat_build_location: Vector2i = tilemap_types.EMPTY
var boat_leave_location: Vector2i = tilemap_types.EMPTY
#
var time_of_day: int = 0
var day_length: int  = 1000

@export var required_boat_parts: int = 8


func setup() -> void:
    tilemap_interactive = game_manager.world.tilemap_interactive
    var camp_locations: Array[Vector2i] = tilemap_interactive.get_cells_by_type(tilemap_types.OBJECT_I_TENT)
    if len(camp_locations) > 0:
        camp = camp_locations[0]
    else:
        push_error("No camp location found on tilemap")

    var firepit_locations: Array[Vector2i] = tilemap_interactive.get_cells_by_type_collection(tilemap_types.OBJECT_COLLECTION_FIREPIT)
    if len(firepit_locations) > 0:
        campfire = firepit_locations[0]
    else:
        push_error("No firepit location found on tilemap")

    var boat_build_locations: Array[Vector2i] = tilemap_interactive.get_cells_by_type(tilemap_types.OBJECT_I_BOAT_NO_ENIGNE)
    if len(boat_build_locations) > 0:
        boat_build_location = boat_build_locations[0]
    else:
        push_error("No boat build location found on tilemap")

    var boat_leave_locations: Array[Vector2i] = tilemap_interactive.get_cells_by_type(tilemap_types.OBJECT_I_BOAT_WITH_ENGINE)
    if len(boat_leave_locations) > 0:
        boat_leave_location = boat_leave_locations[0]
        tilemap_interactive.set_cell(boat_leave_location, tilemap_types.EMPTY)
    else:
        push_error("No boat leave location found on tilemap")

    print("CampManager: camp=", camp, " campfire=", campfire, " boat_build_location=", boat_build_location, " boat_leave_location=", boat_leave_location)

    tilemap_interactive.set_cell(campfire, tilemap_types.OBJECT_I_FIREPIT_OFF)


func game_tick_start() -> void:
    time_of_day += 1


func game_tick_end() -> void:
    if time_of_day == day_length:
        EventsTracker.track(EventsTracker.Event.TIME_SUNDOWN)


func is_sundown() -> bool:
    return time_of_day >= day_length


func camp_contains_enough_sticks_to_light_campfire() -> bool:
    return camp_item_count(tilemap_types.OBJECT_I_STICK) >= 2


func camp_contains_item(item: Vector2i) -> bool:
    return camp_items.find(item) != -1


func camp_contains_item_collection(item: Array[Vector2i]) -> bool:
    for i in item:
        if camp_items.find(i) == -1:
            return false
    return true


func camp_item_count(item: Vector2i) -> int:
    var count: int = 0
    for i in camp_items:
        if i == item:
            count += 1
    return count


func camp_item_collection_count(item: Array[Vector2i]) -> int:
    var count: int = 0
    for i in camp_items:
        if item.find(i) != -1:
            count += 1
    return count


func camp_take_item(item: Vector2i, count: int = 1) -> bool:
    if camp_item_count(item) < count:
        push_error("CampManager: not enough items to take: " + str(item))
        EventsTracker.track(EventsTracker.Event.CAMP_TAKE_ITEM_FAILED, {"item": item, "count": count})
        return false

    var taken: int = 0
    for i in range(camp_items.size() - 1, -1, -1):
        if camp_items[i] == item:
            camp_items.remove_at(i)
            taken += 1
            if taken == count:
                break

    EventsTracker.track(EventsTracker.Event.CAMP_TAKEN_ITEM, {"item": item, "count": count})
    return true


func camp_add_item(item: Vector2i) -> void:
    camp_items.append(item)
    EventsTracker.track(EventsTracker.Event.CAMP_ADDED_ITEM, {"item": item, "count": 1, "new_count": camp_item_count(item)})


func campfire_light() -> bool:
    # requires two sticks in the camp
    if camp_take_item(tilemap_types.OBJECT_I_STICK, 2):
        tilemap_interactive.set_cell(campfire, tilemap_types.OBJECT_I_FIREPIT_ON)
        EventsTracker.track(EventsTracker.Event.CAMPFIRE_LIT)
        return true
    else:
        EventsTracker.track(EventsTracker.Event.CAMPFIRE_LIT_FAILED)
        return false


func campfire_extinguish() -> void:
    tilemap_interactive.set_cell(campfire, tilemap_types.OBJECT_I_FIREPIT_OFF)
    EventsTracker.track(EventsTracker.Event.CAMPFIRE_EXTINGUISHED)

var is_sleep_active: bool = false


func sleep_effect() -> void:
    if is_sleep_active:
        return
    is_sleep_active = true
    EventsTracker.track(EventsTracker.Event.SLEEP)

    game_manager.camera.go_to_zooming(game_manager.world.tilemap_player.cell_to_local(camp), 3)
    var tween_in: Tween = game_manager.world.get_tree().create_tween()
    tween_in.tween_method(game_manager.camera.set_vignette_intensity, 0.0, 1.0, 2.0).set_delay(0.5)
    var tween_out: Tween = game_manager.world.get_tree().create_tween()
    tween_out.tween_method(game_manager.camera.set_vignette_intensity, 1.0, 0.0, 2.0).set_delay(4.0)

    await game_manager.world.get_tree().create_timer(6.0).timeout

    print("Sleep effect done")
    is_sleep_active = false
    time_of_day = 0


func populate_camp_visualization(boat_ui: HBoxContainer, camp_ui: HBoxContainer) -> void:
    for child in boat_ui.get_children():
        if child.name != "HeightLabel":
            boat_ui.remove_child(child)

    for boat_part in boat_items:
        var texture: TextureRect = create_item_texture(boat_part)
        boat_ui.add_child(texture)

    for child in camp_ui.get_children():
        if child.name != "HeightLabel":
            camp_ui.remove_child(child)

    for boat_part in camp_items:
        var texture: TextureRect = create_item_texture(boat_part)
        camp_ui.add_child(texture)


func create_item_texture(item: Vector2i) -> TextureRect:
    var item_texture: Texture = game_manager.world.tilemap_interactive.get_cell_texture(item)
    if item_texture:
        var item_texture_rect: TextureRect = TextureRect.new()
        item_texture_rect.texture = item_texture
        item_texture_rect.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH)
        item_texture_rect.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
        return item_texture_rect
    return null
