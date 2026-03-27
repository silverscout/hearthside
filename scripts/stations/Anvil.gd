## Anvil — Forging station
## Accepts Iron Ingot, then triggers a repeated-press mini-game:
##   Press E 5 times within 8 seconds → outputs Shaped Blank.
## Failure resets the mini-game without consuming the ingot (M1 rule).

class_name Anvil
extends StationBase

const STRIKES_REQUIRED: int   = 5
const STRIKE_TIME_LIMIT: float = 8.0

var strike_count:   int   = 0
var strike_timer:   float = 0.0
var minigame_active: bool  = false

signal strike_made(count: int, required: int)
signal minigame_failed()
signal minigame_success()

func _setup_station() -> void:
	station_name = "Anvil"
	station_id   = "anvil"

func can_accept_item(item_id: String) -> bool:
	return item_id == ItemData.IRON_INGOT and state == StationState.IDLE

func _on_item_deposited(_item_id: String) -> void:
	_start_minigame()

# ── Override interact so E = strike during mini-game ──────────────

func interact(player: CharacterBody2D) -> void:
	match state:
		StationState.IDLE:
			_try_deposit_item(player)
		StationState.PROCESSING:
			if minigame_active:
				_on_strike()
		StationState.READY:
			_collect_output(player)

func can_player_interact(player_carried_items: Array[String]) -> bool:
	if state == StationState.PROCESSING and minigame_active:
		return true  # always interactable during mini-game (for striking)
	return super(player_carried_items)

func get_interaction_prompt(_carried_items: Array[String]) -> String:
	if minigame_active:
		return "Strike! [%d/%d]" % [strike_count, STRIKES_REQUIRED]
	return super(_carried_items)

# ── Mini-game ─────────────────────────────────────────────────────

func _start_minigame() -> void:
	strike_count   = 0
	strike_timer   = STRIKE_TIME_LIMIT
	minigame_active = true
	_set_state(StationState.PROCESSING)
	print("Anvil: Mini-game started — strike %d times in %.0fs!" % [STRIKES_REQUIRED, STRIKE_TIME_LIMIT])

func _process(delta: float) -> void:
	if not minigame_active:
		return

	strike_timer -= delta
	_update_visual()

	if strike_timer <= 0.0:
		_fail_minigame()

func _on_strike() -> void:
	strike_count += 1
	strike_made.emit(strike_count, STRIKES_REQUIRED)
	_flash_sprite()
	print("Anvil: Strike %d / %d" % [strike_count, STRIKES_REQUIRED])

	if strike_count >= STRIKES_REQUIRED:
		_complete_minigame()

func _complete_minigame() -> void:
	minigame_active = false
	output_item = ItemData.SHAPED_BLANK
	minigame_success.emit()
	# Bypass the parent timer—call completion directly
	processing_complete.emit(output_item)
	_set_state(StationState.READY)
	output_ready.emit(output_item)
	_update_visual()
	print("Anvil: Shaped Blank ready!")

func _fail_minigame() -> void:
	strike_count   = 0
	strike_timer   = STRIKE_TIME_LIMIT
	minigame_failed.emit()
	print("Anvil: Time out — restarting mini-game")
	# M1 rule: failure restarts without consuming ingot
	_start_minigame()

# ── Visuals ───────────────────────────────────────────────────────

func _flash_sprite() -> void:
	if not sprite:
		return
	var tween := create_tween()
	tween.tween_property(sprite, "color", Color.WHITE, 0.05)
	tween.tween_property(sprite, "color", _get_state_color(), 0.12)

func _update_visual() -> void:
	super()
	if label and minigame_active:
		label.text = station_name + "\n⚒ STRIKE! [%d/%d]\n%.1fs left" % [
			strike_count, STRIKES_REQUIRED, strike_timer
		]
	if progress_bar and minigame_active:
		progress_bar.value = float(strike_count) / float(STRIKES_REQUIRED)
		progress_bar.visible = true
