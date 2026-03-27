## InspectionTable — Final station before delivery
## Accepts any finished_* item, single E press to grade it.
## In M1 all items are Standard quality.
## Outputs: "graded_<recipe_id>" (e.g. "graded_iron_dagger")

class_name InspectionTable
extends StationBase

func _setup_station() -> void:
	station_name = "Inspection Table"
	station_id   = "inspection_table"

func can_accept_item(item_id: String) -> bool:
	return item_id.begins_with("finished_") and state == StationState.IDLE

func _on_item_deposited(item_id: String) -> void:
	_set_state(StationState.LOADING)
	print("InspectionTable: Press E to inspect '%s'" % item_id)

# ── Override interact so E = inspect while LOADING ────────────────

func interact(player: CharacterBody2D) -> void:
	match state:
		StationState.IDLE:
			_try_deposit_item(player)
		StationState.LOADING:
			_inspect()
		StationState.READY:
			_collect_output(player)

func can_player_interact(player_carried_items: Array[String]) -> bool:
	if state == StationState.LOADING:
		return true  # always interactable to trigger inspection
	return super(player_carried_items)

func get_interaction_prompt(_carried_items: Array[String]) -> String:
	if state == StationState.LOADING:
		return "Inspect Item (E)"
	return super(_carried_items)

# ── Inspection ────────────────────────────────────────────────────

func _inspect() -> void:
	# Find the finished_* item in held_items
	var finished_item := ""
	for item in held_items:
		if item.begins_with("finished_"):
			finished_item = item
			break

	if finished_item.is_empty():
		push_warning("InspectionTable: No finished item found in held_items")
		return

	# "finished_iron_dagger" → "graded_iron_dagger"
	output_item = finished_item.replace("finished_", ItemData.GRADED_PREFIX)
	held_items.clear()

	# Instant grading — jump straight to READY
	processing_complete.emit(output_item)
	_set_state(StationState.READY)
	output_ready.emit(output_item)
	_update_visual()
	print("InspectionTable: Graded as Standard → %s" % output_item)
