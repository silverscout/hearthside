## PlayerController
## Top-down CharacterBody2D.
##   - WASD movement
##   - Carry up to 2 items (displayed as floating labels above character)
##   - E key: interact with nearest station / shelf / counter
##   - Hold E: supported for QuenchBarrel and GrindingWheel (interact_released on release)
##
## Scene requirements:
##   $CollisionShape2D  — player hitbox
##   $InteractionArea   — Area2D, detects nearby interactables
##   $ItemDisplay       — VBoxContainer, shows carried items above head
##   $InteractionLabel  — Label, shows context prompt (e.g. "[E] Strike!")

class_name PlayerController
extends CharacterBody2D

const SPEED: float = 200.0
const MAX_CARRY: int = 2

var carried_items: Array[String] = []
var nearby_interactables: Array  = []
var nearby_interactable          = null   # the closest one

var _holding_interact: bool = false

@onready var item_display:       VBoxContainer = $ItemDisplay
@onready var interaction_label:  Label         = $InteractionLabel

func _ready() -> void:
	add_to_group("player")

	var interaction_area: Area2D = $InteractionArea
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)

	if interaction_label:
		interaction_label.visible = false
