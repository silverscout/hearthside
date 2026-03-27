class_name RecipeData
extends Resource

## A single crafting recipe, loaded from a .tres resource file.
## Adding a new recipe requires only a new .tres file âƒ no code changes needed.

@export var recipe_id: String = ""
@export var display_name: String = ""
@export var description: String = ""

## Ingredients: Dictionary of {item_id: String -> quantity: int}
@export var ingredients: Dictionary = {}


## Ordered list of station_id strings the item must pass through
@export var station_sequence: Array[String] = []

## Base gold reward before customer-type multiplier
@export var base_gold_value: int = 0

## The final item_id output after all stations are complete
@export var output_item_id: String = ""
