extends RefCounted

static func decide_bid(
	npc_id: String,
	lot_id: String,
	current_bid: int,
	mc_last_bid: int,
	npc: Dictionary
) -> Dictionary:
	if npc.is_empty():
		return {"action": "pass"}

	if npc_id == "jaka" and lot_id == "lot03":
		var threshold := int(npc.get("bluff_threshold", 230000))
		var increment := int(npc.get("bluff_increment", 30000))
		var candidate := mc_last_bid + increment
		if candidate <= threshold:
			return {
				"action": "bid",
				"amount": candidate,
				"reason": "bluff"
			}
		return {
			"action": "pass",
			"reason": "bluff_threshold"
		}

	var lots: Dictionary = npc.get("lots", {})
	var lot_data: Dictionary = lots.get(lot_id, {})
	var steps: Array = lot_data.get("bid_steps", [])

	for value in steps:
		var amount := int(value)
		if amount > current_bid:
			return {
				"action": "bid",
				"amount": amount,
				"reason": "interest"
			}

	return {"action": "pass"}
