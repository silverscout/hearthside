## DayCycle — Autoload singleton
## Manages the 8-minute rush timer and grace-period transition to End of Day.

extends Node

const RUSH_DURATION:     float = 480.0  # 8 minutes
const EOD_GRACE_PERIOD:  float = 60.0   # extra 60 s after timer hits 0
const FINAL_STRETCHAt_SECS: float = 120.0  # last 2 minutes — UI glows gold

var rush_timer:     float = 0.0
var is_running:     bool  = false
var grace_timer:    float = 0.0
var in_grace_period: bool = false

func start_rush() -> void:
	rush_timer = RUSH_DURATION
	grace_timer = 0.0
	in_grace_period = false
	is_running = true
	print("DayCycle: Rush started (%.0fs)" % RUSH_DURATION)

func stop_rush() -> void:
	is_running = false
	in_grace_period = false
	print("DayCycle: Rush stopped.")

func _process(delta: float) -> void:
	if not is_running:
		return

	if not in_grace_period:
		rush_timer = max(0.0, rush_timer - delta)
		GameManager.rush_timer_updated.emit(rush_timer)

		if rush_timer <= 0.0:
			_start_grace_period()
	else:
		grace_timer -= delta
		# End of Day triggers when grace period expires OR queue is already empty
		if grace_timer <= 0.0 or OrderManager.get_active_order_count() == 0:
			GameManager.request_end_of_day()

# ── Helpers ───────────────────────────────────────────────────────

func _start_grace_period() -> void:
	print("DayCycle: Timer expired — grace period (%.0fs)" % EOD_GRACE_PERIOD)
	in_grace_period = true
	grace_timer = EOD_GRACE_PERIOD
	OrderManager.stop_spawning()

## 0.0 = just started, 1.0 = time fully elapsed
func get_rush_progress() -> float:
	return clamp(1.0 - (rush_timer / RUSH_DURATION), 0.0, 1.0)

func get_seconds_remaining() -> float:
	return rush_timer

## True during the last 2 minutes — used by HUD sun arc to glow gold
func is_in_final_stretch() -> bool:
	return is_running and not in_grace_period and rush_timer <= FINAL_STRETCH_SECS
