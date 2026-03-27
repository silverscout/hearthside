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
