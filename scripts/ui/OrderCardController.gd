## OrderCardController — attached to each OrderCard instance in the queue.
## Shows: recipe name, customer type, patience bar (color-coded by urgency).

extends PanelContainer

var order_data: OrderData = null

@onready var recipe_label:   Label       = $VBox/RecipeLabel
@onready var customer_label: Label       = $VBox/CustomerLabel
@onready var patience_bar:   ProgressBar = $VBox/PatienceBar
@onready var reward_label:   Label       = $VBox/RewardLabel

func setup(order: OrderData) -> void:
	order_data = order

	# Recipe name
	if recipe_label:
		var recipe: RecipeData = RecipeDB.get_recipe(order.recipe_id)
		recipe_label.text = recipe.display_name if recipe else order.recipe_id.capitalize()

	# Customer type
	if customer_label:
		customer_label.text = order.get_customer_type_name()

	# Patience bar
	if patience_bar:
		patience_bar.min_value = 0.0
		patience_bar.max_value = order.patience_max
		patience_bar.value     = order.patience_remaining

	# Gold reward preview
	if reward_label:
		reward_label.text = "⚙ %d g" % order.get_reward_amount()
