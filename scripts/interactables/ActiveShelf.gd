## ActiveShelf — interactable Area2D placed along the front wall.
## Pressing E opens the ShelfPicker popup so the player can choose which item to take.
## The picker emits item_selected(item_id) → we pull it from InventoryManager and
## hand it to the player.

class_name ActiveShelf
extends Area2D

const PICKER_SCENE := "res://scenes/ui/ShelfPicker.tscn"

# Tracks whether the picker is currently open (prevents double-opening)
var _picker_open: bool = false

func _ready() -> void:
	add_to_group("interactables")
