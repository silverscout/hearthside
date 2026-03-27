## RecipeDB — Autoload singleton
## Loads all RecipeData .tres files at startup and provides lookup by recipe_id.
## Adding a new recipe = drop in a new .tres file + add its path to RECIPE_PATHS.
## No code changes needed in any other system.

extends Node

const RECIPE_PATHS: Array[String] = [
	"res://resources/recipes/iron_dagger.tres",
	"res://resources/recipes/short_sword.tres",
	"res://resources/recipes/iron_shield.tres",
]

var _recipes: Dictionary = {}  # recipe_id -> RecipeData

func _ready() -> void:
	_load_all_recipes()

func _load_all_recipes() -> void:
	for path in RECIPE_PATHS:
		if not ResourceLoader.exists(path):
			push_warning("RecipeDB: File not found — %s" % path)
			continue

		var res = ResourceLoader.load(path)
		if not res is RecipeData:
			push_warning("RecipeDB: Not a RecipeData resource — %s" % path)
			continue

		var recipe: RecipeData = res
		if recipe.recipe_id.is_empty():
			push_warning("RecipeDB: Recipe has no recipe_id — %s" % path)
			continue

		_recipes[recipe.recipe_id] = recipe
		print("RecipeDB: Loaded '%s' (%s)" % [recipe.display_name, recipe.recipe_id])

	print("RecipeDB: %d recipes loaded." % _recipes.size())

## Returns the RecipeData for the given id, or null if not found.
func get_recipe(recipe_id: String) -> RecipeData:
	if _recipes.has(recipe_id):
		return _recipes[recipe_id]
	push_warning("RecipeDB: Unknown recipe_id '%s' " % recipe_id)
	return null

## Returns all loaded recipe IDs.
func get_all_recipe_ids() -> Array[String]:
	var ids: Array[String] = []
	for key: String in _recipes.keys():
		ids.append(key)
	return ids

## Returns a random recipe_id from the loaded set.
func get_random_recipe_id() -> String:
	var ids := get_all_recipe_ids()
	if ids.is_empty():
		push_error("RecipeDB: No recipes loaded!")
		return ""
	return ids[randi() % ids.size()]
