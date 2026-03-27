## InventoryManager — Autoload singleton
## Manages the Active Shelf: 12 item slots pre-populated at rush start.

extends Node

const SHELF_SLOTS:         int = 12
const LOW_STOCK_THRESHOLD: int = 2

## Starting shelf contents for M1
const INITIAL_SHELF: Dictionary = {
	"iron_ore": 8,
	"coal":     6,
	"leather":  4,
}

## shelf_slots[i] = { "item_id": String, "quantity": int }
var shelf_slots: Array[Dictionary] = []

signal shelf_item_changed(slot_index: int, item_id: String, quantity: int)
signal shelf_low_stock(item_id: String)

func _ready() -> void:
	_initialize_slots()

func _initialize_slots() -> void:
	shelf_slots.clear()
	for i in SHELF_SLOTS:
		shelf_slots.append({"item_id": "", "quantity": 0})

## Called by GameManager at the start of each rush phase
func populate_shelf() -> void:
	_initialize_slots()
	var slot_index := 0
	for item_id: String in INITIAL_SHELF:
		if slot_index >= SHELF_SLOTS:
			break
		var qty: int = INITIAL_SHELF[item_id]
		shelf_slots[slot_index] = {"item_id": item_id, "quantity": qty}
		shelf_item_changed.emit(slot_index, item_id, qty)
		slot_index += 1
	print("InventoryManager: Shelf populated.")

## Remove one unit of item_id from the shelf. Returns false if none available.
func take_item(item_id: String) -> bool:
	for i in shelf_slots.size():
		var slot := shelf_slots[i]
		if slot["item_id"] == item_id and slot["quantity"] > 0:
			slot["quantity"] -= 1
			if slot["quantity"] <= LOW_STOCK_THRESHOLD and slot["quantity"] > 0:
				shelf_low_stock.emit(item_id)
			if slot["quantity"] == 0:
				slot["item_id"] = ""
			shelf_item_changed.emit(i, slot["item_id"], slot["quantity"])
			return true
	return false

func has_item(item_id: String) -> bool:
	return get_item_count(item_id) > 0

func get_item_count(item_id: String) -> int:
	var total := 0
	for slot in shelf_slots:
		if slot["item_id"] == item_id:
			total += slot["quantity"]
	return total

## Returns the slot index containing item_id, or -1 if not found
func find_slot_with_item(item_id: String) -> int:
	for i in shelf_slots.size():
		if shelf_slots[i]["item_id"] == item_id and shelf_slots[i]["quantity"] > 0:
			return i
	return -1

func get_slot(index: int) -> Dictionary:
	if index >= 0 and index < shelf_slots.size():
		return shelf_slots[index]
	return {"item_id": "", "quantity": 0}

## Returns the first available item on the shelf (for simple shelf interaction)
func get_first_available_item_id() -> String:
	for slot in shelf_slots:
		if slot["item_id"] != "" and slot["quantity"] > 0:
			return slot["item_id"]
	return ""
