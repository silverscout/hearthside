## GameManager — Autoload singleton
## Owns the top-level phase state machine and gold/stats tracking.
## Phase flow: BOOT → RUSH_PHASE → END_OF_DAY

extends Node

enum Phase {
	BOOT,
	RUSH_PHASE,
	END_OF_DAY,
}

var current_phase: Phase = Phase.BOOT
var total_gold: int = 0
var orders_fulfilled: int = 0
var orders_missed: int = 0

signal phase_changed(new_phase: String)
signal gold_changed(new_total: int, delta: int)
signal rush_timer_updated(seconds_remaining: float)

func _ready() -> void:
	# Defer so all autoloads are fully initialised before we start
	call_deferred("_start_game")

func _start_game() -> void:
	set_phase(Phase.BOOT)

# ── Phase Machine ─────────────────────────────────────────────────

func set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	var phase_name := Phase.keys()[new_phase]
	print("GameManager: → %s" % phase_name)
	phase_changed.emit(phase_name)

	match new_phase:
		Phase.BOOT:       await _on_boot()
		Phase.RUSH_PHASE: _on_rush_phase()
		Phase.END_OF_DAY: _on_end_of_day()

func _on_boot() -> void:
	# Reset all session stats
	total_gold = 0
	orders_fulfilled = 0
	orders_missed = 0
	gold_changed.emit(0, 0)
	# Brief pause so the scene is fully ready before rush starts
	await get_tree().create_timer(0.5).timeout
	set_phase(Phase.RUSH_PHASE)

func _on_rush_phase() -> void:
	InventoryManager.populate_shelf()
	OrderManager.start_spawning()
	DayCycle.start_rush()

func _on_end_of_day() -> void:
	OrderManager.stop_spawning()
	DayCycle.stop_rush()

# ── Public API ────────────────────────────────────────────────────

func add_gold(amount: float) -> void:
	var rounded := roundi(amount)
	total_gold += rounded
	gold_changed.emit(total_gold, rounded)

func record_fulfilled() -> void:
	orders_fulfilled += 1

func record_missed() -> void:
	orders_missed += 1

## Called by DayCycle (or OrderManager) when conditions are met for End of Day
func request_end_of_day() -> void:
	if current_phase == Phase.RUSH_PHASE:
		set_phase(Phase.END_OF_DAY)

## Full scene reload — wipes all state (used by "Play Again")
func reset_game() -> void:
	get_tree().reload_current_scene()
