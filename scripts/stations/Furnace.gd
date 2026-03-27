## Furnace — Smelting station
## Accepts Iron Ore + Coal, auto-processes for 15 seconds, outputs Iron Ingot.
## Both ingredients must be deposited before processing begins.

class_name Furnace
extends StationBase

const PROCESS_TIME: float = 15.0

var has_ore:  bool = false
var has_coal: bool = false

func _setup_station() -> void:
	station_name = "Smelting Furnace"
	station_id   = "furnace"

func can_accept_item(item_id: String) -> bool:
	if state == StationState.PROCESSING or state == StationState.READY:
		return false
	if item_id == ItemData.IRON_ORE and not has_ore:
		return true
	if item_id == ItemData.COAL and not has_coal:
		return true
	return false

func _on_item_deposited(item_id: String) -> void:
	match item_id:
		ItemData.IRON_ORE:  has_ore  = true
		ItemData.COAL:      has_coal = true

	_update_visual()

	# Auto-start once both ingredients are present
	if has_ore and has_coal:
		output_item = ItemData.IRON_INGOT
		_start_processing(PROCESS_TIME)
		print("Furnace: Smelting started (%.0fs)" % PROCESS_TIME)

func _on_processing_complete() -> void:
	super()
	has_ore  = false
	has_coal = false
	print("Furnace: Iron Ingot ready!")

func _update_visual() -> void:
	super()
	if label:
		var ore_txt  := "[Ore ✓] "  if has_ore  else "[Ore ✗] "
		var coal_txt := "[Coal ✓]"  if has_coal else "[Coal ✗]"
		label.text = station_name + "\n" + ore_txt + coal_txt
		if state == StationState.PROCESSING:
			label.text += "\n⚙ Smelting…"
		elif state == StationState.READY:
			label.text += "\n→ " + ItemData.get_display_name(output_item)
