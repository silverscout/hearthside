class_name ItemData

## Static helpers for item display names and placeholder colors.
## All item ID constants live here as a single source of truth.

# ── Raw Materials ────────────────────────────────────────────────
const IRON_ORE      := "iron_ore"
const COAL          := "coal"
const LEATHER       := "leather"

# ── Intermediate Items ───────────────────────────────────────────
const IRON_INGOT    := "iron_ingot"
const SHAPED_BLANK  := "shaped_blank"
const TEMPERED_PIECE  := "tempered_piece"
const SHARPENED_PIECE := "sharpened_piece"

# ── Near-Final Items ─────────────────────────────────────────────
# LeatherworkingBench maps metal input → finished_* item
const FINISHED_IRON_DAGGER  := "finished_iron_dagger"
const FINISHED_SHORT_SWORD  := "finished_short_sword"
const FINISHED_IRON_SHIELD  := "finished_iron_shield"

# ── Graded Items (post-Inspection) ───────────────────────────────
# Format: "graded_" + recipe_id
# e.g. "graded_iron_dagger", "graded_short_sword", "graded_iron_shield"
const GRADED_PREFIX := "graded_"

# ── Helpers ──────────────────────────────────────────────────────

static func get_display_name(item_id: String) -> String:
	match item_id:
		"iron_ore":         return "Iron Ore"
		"coal":             return "Coal"
		"leather":          return "Leather"
		"iron_ingot":       return "Iron Ingot"
		"shaped_blank":     return "Shaped Blank"
		"tempered_piece":   return "Tempered Piece"
		"sharpened_piece":  return "Sharpened Piece"
		"finished_iron_dagger":  return "Iron Dagger (ungraded)"
		"finished_short_sword":  return "Short Sword (ungraded)"
		"finished_iron_shield":  return "Iron Shield (ungraded)"
		"graded_iron_dagger":    return "Iron Dagger (Standard)"
		"graded_short_sword":    return "Short Sword (Standard)"
		"graded_iron_shield":    return "Iron Shield (Standard)"
		_:
			# Generic fallback — capitalize and replace underscores
			return item_id.replace("_", " ").capitalize()

static func get_item_color(item_id: String) -> Color:
	match item_id:
		"iron_ore":         return Color(0.55, 0.55, 0.65)
	
"coal":             return Color(0.20, 0.20, 0.20)
		"leather":          return Color(0.65, 0.40, 0.20)
		"iron_ingot":       return Color(0.72, 0.72, 0.82)
		"shaped_blank":     return Color(0.60, 0.60, 0.70)
		"tempered_piece":   return Color(0.40, 0.50, 0.75)
		"sharpened_piece":  return Color(0.50, 0.75, 0.95)
		_:
			if item_id.begins_with("finished_"):
				return Color(0.85, 0.72, 0.30)
			if item_id.begins_with("graded_"):
				return Color(1.0, 0.85, 0.20)
			return Color(0.7, 0.7, 0.7)

## Returns true if the item is a graded, deliverable item
static func is_graded(item_id: String) -> bool:
	return item_id.begins_with(GRADED_PREFIX)

## Returns true if the item is a raw material (from the shelf)
static func is_raw_material(item_id: String) -> bool:
	return item_id in [IRON_ORE, COAL, LEATHER]

## Strips "graded_" prefix to recover the recipe_id
static func get_recipe_id_from_graded(item_id: String) -> String:
	return item_id.trim_prefix(GRADED_PREFIX)
