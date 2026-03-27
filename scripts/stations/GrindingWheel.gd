## GrindingWheel — Sharpening station
## Accepts Tempered Piece, player uolds E for 4 seconds → Sharpened Piece.
## Required for bladed weapon recipes (Dagger, Short Sword) only.

class_name GrindingWheel
extends StationBase

const HOLD_DURATION: float = 4.0

var is_holding: bool  = false
var hold_timer: float = 0.0

func _setup_station() -> void:
	station_name = "Grinding Wheel"
	station_id   = "grinding_wheel"

func can_accept_item(item_id: String) -> bool:
	return item_id == ItemData.TEMPERED_PIECE and state == StationState.IDLE

func _on_item_deposited(_item_id: String) -> void:
	_set_state(StationState.LOADING)
	print("GrindingWheel: Hold E for %.0f seconds to sharpen." % HOLD_DURATION)

# ── Hold mechanic ─────────────────────────────────────────────────

func interact(player: CharacterBody2D) -> void:
	match state:
		StationState.IDLE:
			_try_deposit_item(player)
		StationState.LOADING:
			if not is_holding:
				_start_holding()
		StationState.READY:
			_collect_output(player)

func interact_released(_player: CharacterBody2D) -> void:
	if is_holding:
		_cancel_hold()

func can_player_interact(player_carried_items: Array[String]) -> bool:
	if state == StationState.LOADING:
		return true
	return super(player_carried_items)

func get_interaction_prompt(_carried_items: Array[String]) -> String:
	if state == StationState.LOADING:
		return "Hold E to grind (%.1f s)" % HOLD_DURATION
	return super(_carried_items)

func _start_holding() -> void:
	is_holding = true
	hold_timer = 0.0
	print("GrindingWheel: Holding E…")

func _process(_delta: float) -> void:
	if not is_holding or state != StationState.LOADING:
		return

	hold_timer += _delta
	_update_visual()

	if hold_timer >= HOLD_DURATION:
		_complete_grind()

func _cancel_hold() -> void:
	is_holding = false
	hold_timer = 0.0
	_update_visual()
	print("GrindingWheel: Hold released — progress reset.")

func _complete_grind() -> void:
	is_holding = false
	output_item = ItemData.SHARPENED_PIECE
	held_items.clear()
	processing_complete.emit(output_item)
	_set_state(StationState.READY)
	output_ready.emit(output_item)
	_update_visual()
	print("GrindingWheel: Sharpened Piece ready!")

func _update_visual() -> void:
	super()
	if progress_bar and state == StationState.LOADING:
		progress_bar.value = clamp(hold_timer / HOLD_DURATION, 0.0, 1.0)
		progress_bar.visible = true
	elif progress_bar:
		progress_bar.visible = false

	if label and state == StationState.LOADING:
		if is_holding:
			label.text = station_name + "\n⚙ Grinding… %.1f / %.1f" % [hold_timer, HOLD_DURATION]
		else:
			label.text = station_name + "\n[Hold E to grind]"

func _update_progress_bar() -> void:
	pass
