## HUDController — attached to the HUD scene root (Control node)
##
## HUD layout (M1):
##   Top edge      — Sun arc rush timer (ProgressBar + glow overlay)
##   Top center    — Gold counter label
##   Bottom-left   — Order queue (up to 4 OrderCard instances)
##   Bottom-right  — Active Shelf display (12 slots)

extends Control

# ── Scene node references ─────────────────────────────────────────
@onready var gold_label:          Label         = $GoldDisplay/GoldLabel
@onready var sun_arc_bar:         ProgressBar   = $SunArc/ArcBar
@onready var sun_arc_glow:        ColorRect     = $SunArc/GlowOverlay
@onready var order_queue:         VBoxContainer = $OrderQueue
@onready var shelf_grid:          GridContainer = $ShelfDisplay/ShelfGrid

# Cached order card nodes: order_id -> Control
var _order_cards: Dictionary = {}

func _ready() -> void:
	# Connect to autoload signals
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.rush_timer_updated.connect(_on_rush_timer_updated)
	GameManager.phase_changed.connect(_on_phase_changed)

	OrderManager.order_spawned.connect(_on_order_spawned)
	OrderManager.order_fulfilled.connect(_on_order_fulfilled)
	OrderManager.order_expired.connect(_on_order_expired)

	InventoryManager.shelf_item_changed.connect(_on_shelf_item_changed)

	_build_shelf_grid()
	_on_gold_changed(0, 0)

# ── Gold ──────────────────────────────────────────────────────────

func _on_gold_changed(new_total: int, _delta: int) -> void:
	if gold_label:
		gold_label.text = "⚙ Gold: %d" % new_total

# ── Sun-arc Timer ─────────────────────────────────────────────────

func _on_rush_timer_updated(seconds_remaining: float) -> void:
	if sun_arc_bar:
		var progress: float = 1.0 - clamp(seconds_remaining / DayCycle.RUSH_DURATION, 0.0, 1.0)
		sun_arc_bar.value = progress

	if sun_arc_glow:
		sun_arc_glow.visible = DayCycle.is_in_final_stretch()

# ── Phase changes ─────────────────────────────────────────────────

func _on_phase_changed(new_phase: String) -> void:
	if new_phase == "END_OF_DAY":
		_spawn_end_of_day_screen()

# ── Order Cards ───────────────────────────────────────────────────

func _on_order_spawned(order: OrderData) -> void:
	var card_scene: PackedScene = load("res://scenes/ui/OrderCard.tscn")
	if card_scene == null:
		push_error("HUD: Cannot load OrderCard.tscn")
		return
	var card: Control = card_scene.instantiate()
	order_queue.add_child(card)
	if card.has_method("setup"):
		card.setup(order)
	_order_cards[order.order_id] = card

func _on_order_fulfilled(order: OrderData) -> void:
	_remove_order_card(order.order_id)

func _on_order_expired(order: OrderData) -> void:
	_remove_order_card(order.order_id)

func _remove_order_card(order_id: String) -> void:
	if _order_cards.has(order_id):
		var card = _order_cards[order_id]
		if is_instance_valid(card):
			card.queue_free()
		_order_cards.erase(order_id)

# ── Shelf Display ─────────────────────────────────────────────────

func _build_shelf_grid() -> void:
	if not shelf_grid:
		return
	for i in InventoryManager.SHELF_SLOTS:
		var lbl := Label.new()
		lbl.name = "Slot%d" % i
		lbl.text = "—"
		lbl.add_theme_font_size_override("font_size", 10)
		shelf_grid.add_child(lbl)

func _on_shelf_item_changed(slot_index: int, item_id: String, quantity: int) -> void:
	if not shelf_grid:
		return
	var slot_node: Label = shelf_grid.get_node_or_null("Slot%d" % slot_index)
	if not slot_node:
		return

	if item_id.is_empty() or quantity == 0:
		slot_node.text = "—"
		slot_node.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	else:
		slot_node.text = "%s x%d" % [ItemData.get_display_name(item_id), quantity]
		var color := ItemData.get_item_color(item_id)
		if quantity <= InventoryManager.LOW_STOCK_THRESHOLD:
			color = Color(1.0, 0.3, 0.3)  # low-stock red
		slot_node.add_theme_color_override("font_color", color)

# ── End of Day Screen ─────────────────────────────────────────────

func _spawn_end_of_day_screen() -> void:
	var eod_scene: PackedScene = load("res://scenes/ui/EndOfDay.tscn")
	if eod_scene == null:
		push_error("HUD: Cannot load EndOfDay.tscn")
		return
	var eod: Control = eod_scene.instantiate()
	add_child(eod)
	if eod.has_method("setup"):
		eod.setup(
			GameManager.total_gold,
			GameManager.orders_fulfilled,
			GameManager.orders_missed
		)
