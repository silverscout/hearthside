## ShelfPickerController
## A small popup shown when the player presses E near the Active Shelf.
## Displays each unique item type currently in stock.
## Controls:  ↑ / ↓  or  W / S  — navigate   |   E — confirm   |   Esc — cancel
##
## Emits:
##   item_selected(item_id: String)  — player confirmed a choice
##   cancelled()                     — player pressed Escape

extends Control

signal item_selected(item_id: String)
signal cancelled()

# List of {item_id, quantity, display_name} dictionaries, one per unique stocked item
var _entries: Array[Dictionary] = []
var _selected_index: int = 0

@onready var title_label:    Label         = $Panel/VBox/TitleLabel
@onready var items_vbox:     VBoxContainer = $Panel/VBox/ItemsBox
@onready var hint_label:     Label         = $Panel/VBox/HintLabel
