## DeliveryCounter — interactable Area2D at the front counter.
## Player presses E while carrying a graded item to attempt order fulfillment.

class_name DeliveryCounter
extends Area2D

func _ready() -> void:
	add_to_group("interactables")

func can_player_interact(player_carried_items: Array[String]) -> bool:
	for item in player_carried_items:
		if ItemData.is_graded(item):
			return true
	return false

func interact(player: CharacterBody2D) -> void:
	for i in player.carried_items.size():
		var item: String = player.carried_items[i]
		if ItemData.is_graded(item):
			var success := OrderManager.try_fulfill_order(item)
			if success:
				player.remove_item_at(i)
				print("DeliveryCounter: Order fulfilled — %s delivered." % item)
			else:
				print("DeliveryCounter: No matching order for '%s'." % item)
			return  # only deliver one item per press

func get_interaction_prompt(carried_items: Array[String]) -> String:
	for item in carried_items:
		if ItemData.is_graded(item):
			return "Deliver " + ItemData.get_display_name(item)
	return "Nothing to deliver"
