class_name EventsTracker
extends Node

enum Event {
    CAMPFIRE_LIT,
    CAMPFIRE_LIT_FAILED,
    CAMPFIRE_EXTINGUISHED,
    CAMP_ADDED_ITEM,
    CAMP_TAKEN_ITEM,
    CAMP_TAKE_ITEM_FAILED,
    CAMP_BOAT_PART_DELIVERED,
    CAMP_BOAT_COMPLETE,
    SLEEP,
    PLAYER_PICKED_UP_ITEM,
    PLAYER_DROPPED_ITEM,
    PLAYER_USED_ITEM,
    GAME_STATE_WIN,
    NEW_EXPLORATION_GOAL,
    EXPLORATION_GOAL_REACHED,
    EXPLORATION_GOAL_CLOSE_ENOUGH,
    TEMPERATURE_COLD,
    TIME_SUNDOWN,
};
#
static var events: Array[TrackedEvent] = []
static var max_events: int             = 14
static var callbacks: Array[Callable]  = []


static func track(event: Event, params: Dictionary = {}) -> void:
    var tracked_event: TrackedEvent = TrackedEvent.new()
    tracked_event.event = event
    tracked_event.params = params
    events.append(tracked_event)
    print("Event tracked: ", event, " params: ", params)
    if events.size() > max_events:
        events.remove_at(0)
    for cb in callbacks:
        cb.call(event, params)


static func populate_visual_log(visual_events_log: VBoxContainer, game_manager: GameManager) -> void:
    for child in visual_events_log.get_children():
        child.queue_free()
    for event in events:
        event = event as TrackedEvent
        populate_visual_log_create_label(event, visual_events_log, game_manager)


static func populate_visual_log_create_label(event: TrackedEvent, container: Container, game_manager: GameManager) -> void:
    var event_id: int      = event.event
    var params: Dictionary = event.params

    var text: String = ""

    if event_id == Event.CAMPFIRE_LIT:
        text = "Campfire lit"
    elif event_id == Event.CAMPFIRE_LIT_FAILED:
        text = "Campfire lighting failed"
    elif event_id == Event.CAMPFIRE_EXTINGUISHED:
        text = "Campfire extinguished"
    elif event_id == Event.CAMP_ADDED_ITEM:
        text = "Camp added item"
    elif event_id == Event.CAMP_TAKEN_ITEM:
        text = "Camp taken item x" + str(params["count"])
    elif event_id == Event.CAMP_TAKE_ITEM_FAILED:
        text = "Could not take item from camp"
    elif event_id == Event.SLEEP:
        text = "Player slept"
    elif event_id == Event.PLAYER_PICKED_UP_ITEM:
        text = "Took"
    elif event_id == Event.PLAYER_DROPPED_ITEM:
        text = "Dropped"
    elif event_id == Event.PLAYER_USED_ITEM:
        text = "Used"
    elif event_id == Event.CAMP_BOAT_PART_DELIVERED:
        text = "Boat construction"
    elif event_id == Event.CAMP_BOAT_COMPLETE:
        text = "Boat complete"
    elif event_id == Event.GAME_STATE_WIN:
        text = "Game won"
    elif event_id == Event.NEW_EXPLORATION_GOAL:
        text = "New goal " + str(params["goal"])
    elif event_id == Event.EXPLORATION_GOAL_REACHED:
        text = "Goal reached"
    elif event_id == Event.EXPLORATION_GOAL_CLOSE_ENOUGH:
        text = "Got close enough to goal..."
    elif event_id == Event.TEMPERATURE_COLD:
        text = "Temperature is cold: -" + str(params["temperature"])
    elif event_id == Event.TIME_SUNDOWN:
        text = "The sun is setting..."
    else:
        text = "Something happened..."

    var event_label: Label = Label.new()
    event_label.text = text
    event_label.add_theme_font_size_override("font_size", 24 * game_manager.calculate_scale(Vector2(1200, 1200)).y)
    event_label.add_theme_color_override("font_color", Color(0, 0, 0))

    var event_container: HBoxContainer = HBoxContainer.new()
    event_container.add_child(event_label)

    if params.has("item"):
        var item_texture: Texture = game_manager.world.tilemap_interactive.get_cell_texture(params["item"])
        if item_texture:
            var item_texture_rect: TextureRect = TextureRect.new()
            item_texture_rect.texture = item_texture
            item_texture_rect.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH)
            item_texture_rect.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
            event_container.add_child(item_texture_rect)

    container.add_child(event_container)
