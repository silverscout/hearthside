class_name OrderData

## Runtime data for a single customer order.
## Not a Resource — created at runtime by OrderManager.

enum CustomerType {
	CIVILIAN,    # patience: 90s, reward: 1.0x
	GUARD,       # patience: 75s, reward: 1.1x
	ADVENTURER   # patience: 60s, reward: 1.3x
}

var order_id: String = ""
var recipe_id: String = ""
var customer_type: CustomerType = CustomerType.CIVILIAN
var patience_max: float = 90.0
var patience_remaining: float = 90.0
var reward_multiplier: float = 1.0
var is_fulfilled: bool = false
var is_expired: bool = false

static var _id_counter: int = 0

func _init(p_recipe_id: String, p_customer_type: CustomerType) -> void:
	_id_counter += 1
	order_id = "order_%04d" % _id_counter
	recipe_id = p_recipe_id
	customer_type = p_customer_type

	match customer_type:
		CustomerType.CIVILIAN:
			patience_max = 90.0
			reward_multiplier = 1.0
		CustomerType.GUARD:
			patience_max = 75.0
			reward_multiplier = 1.1
		CustomerType.ADVENTURER:
			patience_max = 60.0
			reward_multiplier = 1.3

	patience_remaining = patience_max

func get_customer_type_name() -> String:
	return CustomerType.keys()[customer_type]

## Returns 0.0 (expired) to 1.0 (full patience)
func get_patience_ratio() -> float:
	if patience_max <= 0.0:
		return 0.0
	return clamp(patience_remaining / patience_max, 0.0, 1.0)

func get_reward_amount() -> int:
	var recipe: RecipeData = RecipeDB.get_recipe(recipe_id)
	if recipe == null:
		return 0
	return roundi(recipe.base_gold_value * reward_multiplier)
