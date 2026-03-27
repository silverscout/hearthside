## OrderManager — Autoload singleton
## Spawns orders during the rush phase, tracks patience, handles fulfillment & expiry.

extends Node

const MAX_ORDERS:       int   = 4
const SPAWN_INTERVAL_MIN: float = 30.0
const SPAWN_INTERVAL_MAX: float = 45.0
const INITIAL_SPAWN_DELAY: float = 5.0   # short delay before very first order

var active_orders: Array = []   # Array[OrderData]
var spawn_timer:   float = INITIAL_SPAWN_DELAY
var is_spawning:   bool  = false

signal order_spawned(order: OrderData)
signal order_fulfilled(order: OrderData)
signal order_expired(order: OrderData)

# ── Phase Control ─────────────────────────────────────────────────

func start_spawning() -> void:
	is_spawning = true
	spawn_timer = INITIAL_SPAWN_DELAY
	active_orders.clear()
	print("OrderManager: Spawning started.")

func stop_spawning() -> void:
	is_spawning = false
	print("OrderManager: Spawning stopped.")

# ── Process Loop ──────────────────────────────────────────────────

func _process(delta: float) -> void:
	_tick_patience(delta)
	_clean_finished_orders()

	if not is_spawning:
		return

	if get_active_order_count() < MAX_ORDERS:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_order()
			_reset_spawn_timer()

func _tick_patience(delta: float) -> void:
	for order in active_orders:
		if order.is_fulfilled or order.is_expired:
			continue
		order.patience_remaining -= delta
		if order.patience_remaining <= 0.0:
			_expire_order(order)

func _clean_finished_orders() -> void:
	active_orders = active_orders.filter(
		func(o: OrderData) -> bool: return not o.is_fulfilled and not o.is_expired
	)

# ── Spawning ───────────────────────────────────────────────────────

func _spawn_order() -> void:
	var recipe_id := RecipeDB.get_random_recipe_id()
	if recipe_id.is_empty():
		push_warning("OrderManager: No recipes to spawn from.")
		return

	var types := [
		OrderData.CustomerType.CIVILIAN,
		OrderData.CustomerType.GUARD,
		OrderData.CustomerType.ADVENTURER,
	]
	var customer_type: OrderData.CustomerType = types[randi() % types.size()]

	var order := OrderData.new(recipe_id, customer_type)
	active_orders.append(order)
	order_spawned.emit(order)
	print("OrderManager: Spawned [%s] for %s (patience %.0fs)"
		% [recipe_id, order.get_customer_type_name(), order.patience_max])

func _reset_spawn_timer() -> void:
	spawn_timer = randf_range(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX)

# ── Fulfillment ────────────────────────────────────────────────────

## Called when player delivers a graded item to the counter.
## item_id should be in "graded_<recipe_id>" format.
## Returns true if a matching order was found and fulfilled.
func try_fulfill_order(item_id: String) -> bool:
	var recipe_id := ItemData.get_recipe_id_from_graded(item_id)

	for order in active_orders:
		if order.recipe_id == recipe_id and not order.is_fulfilled and not order.is_expired:
			_fulfill_order(order)
			return true

	push_warning("OrderManager: No active order matches '%s'" % item_id)
	return false

func _fulfill_order(order: OrderData) -> void:
	order.is_fulfilled = true
	var reward := order.get_reward_amount()
	GameManager.add_gold(reward)
	GameManager.record_fulfilled()
	order_fulfilled.emit(order)
	print("OrderManager: Fulfilled [%s] → +%d gold" % [order.recipe_id, reward])

func _expire_order(order: OrderData) -> void:
	order.is_expired = true
	GameManager.record_missed()
	order_expired.emit(order)
	print("OrderManager: Expired [%s]" % order.order_id)

# ── Queries ───────────────────────────────────────────────────────

func get_active_order_count() -> int:
	var count := 0
	for order in active_orders:
		if not order.is_fulfilled and not order.is_expired:
			count += 1
	return count

func get_active_orders() -> Array:
	return active_orders.filter(
		func(o: OrderData) -> bool: return not o.is_fulfilled and not o.is_expired
	)
