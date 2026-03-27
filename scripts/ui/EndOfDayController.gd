## EndOfDayController — shown after the rush phase ends.
## Displays stats and a "Play Again" button that resets the scene.

extends Control

@onready var gold_label:      Label  = $Panel/VBox/GoldLabel
@onready var fulfilled_label: Label  = $Panel/VBox/FulfilledLabel
@onready var missed_label:    Label  = $Panel/VBox/MissedLabel
@onready var play_again_btn:  Button = $Panel/VBox/PlayAgainButton

func setup(gold: int, fulfilled: int, missed: int) -> void:
	if gold_label:
		gold_label.text       = "Gold Earned:       %d" % gold
	if fulfilled_label:
		fulfilled_label.text  = "Orders Fulfilled:  %d" % fulfilled
	if missed_label:
		missed_label.text     = "Orders Missed:     %d" % missed

	if play_again_btn:
		play_again_btn.pressed.connect(_on_play_again)

func _on_play_again() -> void:
	GameManager.reset_game()
