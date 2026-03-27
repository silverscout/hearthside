## StationBase — base class for all crafting stations.
## State machine: IDLE → LOADING → PROCESSING → READY → IDLE
##
## Subclasses override:
##   _setup_station()      — set station_name, station_id
##   can_accept_item()     — return true if player can deposit the item in current state
##   _on_item_deposited()  — react to a deposit (start processing, update flags, etc.)
##
## The scene for each station must have:
##   $Sprite       (ColorRect)    — placeholder visual, tinted by state
##   $Label        (Label)        — shows station name + state + output
##   $ProgressBar  (ProgressBar)  — 0..1, visible during PROCESSING

class_name StationBase
extends Area2D

enum StationState {
	IDLE,
	LOADING,
	PROCESSING,
	READY,
}

@export var station_name: String = "Station"
@export var station_id:   String = ""

var state:            StationState = StationState.IDLE
var held_items:       Array[String] = []
var output_item:      String = ""
var process_timer:    float  = 0.0
var process_duration: float  = 0.0

# ── Scene nodes (assigned in _ready if present) ───────────────────
@onready var sprite:       ColorRect  = $Sprite
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label:        Label      = $Label

# ── Signals ───────────────────────────────────────────────────────
signal state_changed(new_state: StationState)
signal item_deposited(item_id: String)
signal processing_complete(output_item_id: String)
signal output_ready(item_id: String)

# ── Lifecycle ─────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("stations")
	_setup_station()
	_update_visual()
	if progress_bar:
		progress_bar.min_value = 0.0
		progress_bar.max_value = 1.0
		progress_bar.value = 0.0
		progress_bar.visible = false

func _process(delta: float) -> void:
	if state == StationState.PROCESSING:
		process_timer -= delta
		_update_progress_bar()
		if process_timer <= 0.0:
			_on_processing_complete()

# ── Overrideable hooks ────────────────────────────────────────────

func _setup_station() -> void:
	pass  # set station_name and station_id here

func can_accept_item(item_id: String) -> bool:
	return false  # override in subclass

# ── Interaction API (called by PlayerController) ──────────────────

## Returns true if the player (with their current carried items) can interact
func can_player_interact(player_carried_items: Array[String]) -> bool:
	match state:
		StationState.READY:
			return true  # always collectable
		StationState.PROCESSING:
			return false
		StationState.IDLE, StationState.LOADING:
			for item in player_carried_items:
				if can_accept_item(item):
					return true
			return false
	return false

## Default interact: deposit item or collect output
func interact(player: CharacterBody2D) -> void:
	match state:
		StationState.IDLE, StationState.LOADING:
			_try_deposit_item(player)
		StationState.READY:
			_collect_output(player)

## Override in hold-based stations (QuenchBarrel, GrindingWheel)
func interact_released(_player: CharacterBody2D) -> void:
	pass

## Short label for the interaction prompt in HUD
func get_interaction_prompt(_carried_items: Array[String]) -> String:
	match state:
		StationState.READY:
			return "Collect %s" % ItemData.get_display_name(output_item)
		_:
			return "Use %s" % station_name

# ── Internal Deposit/Collect ──────────────────────────────────────

func _try_deposit_item(player: CharacterBody2D) -> void:
	for i in player.carried_items.size():
		var item_id: String = player.carried_items[i]
		if can_accept_item(item_id):
			player.remove_item_at(i)
			_deposit_item(item_id)
			return

func _deposit_item(item_id: String) -> void:
	held_items.append(item_id)
	_set_state(StationState.LOADING)
	item_deposited.emit(item_id)
	_on_item_deposited(item_id)
	_update_visual()

func _on_item_deposited(_item_id: String) -> void:
	pass  # override in subclass

func _start_processing(duration: float) -> void:
	process_duration = duration
	process_timer = duration
	_set_state(StationState.PROCESSING)

func _on_processing_complete() -> void:
	processing_complete.emit(output_item)
	_set_state(StationState.READY)
	output_ready.emit(output_item)
	_update_visual()

func _collect_output(player: CharacterBody2D) -> void:
	if output_item.is_empty() or not player.can_carry_more():
		return
	player.add_item(output_item)
	output_item = ""
	held_items.clear()
	_set_state(StationState.IDLE)
	_update_visual()

# ── State & Visuals ───────────────────────────────────────────────

func _set_state(new_state: StationState) -> void:
	state = new_state
	state_changed.emit(new_state)
	_update_visual()

func _update_progress_bar() -> void:
	if not progress_bar:
		return
	if state == StationState.PROCESSING and process_duration > 0.0:
		progress_bar.value = 1.0 - (process_timer / process_duration)
		progress_bar.visible = true
	else:
		progress_bar.visible = false

func _update_visual() -> void:
	if sprite:
		sprite.color = _get_state_color()

	if label:
		var text: String = station_name + "\n[" + StationState.keys()[state] + "]"
		if state == StationState.READY and not output_item.is_empty():
			text += "\n→ " + ItemData.get_display_name(output_item)
		label.text = text

func _get_state_color() -> Color:
	match state:
		StationState.IDLE:       return Color(0.38, 0.38, 0.40)
		StationState.LOADING:    return Color(0.55, 0.52, 0.20)
		StationState.PROCESSING: return Color(0.85, 0.52, 0.10)
		StationState.READY:      return Color(0.20, 0.78, 0.25)
	return Color.GRAY
