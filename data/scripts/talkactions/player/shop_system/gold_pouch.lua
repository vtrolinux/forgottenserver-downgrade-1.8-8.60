local config = {
	goldPouchId = 23721,
	goldPouchPrice = 50000
}

local function normalizeParam(param)
	return param:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local talkaction = TalkAction("!buy")
function talkaction.onSay(player, words, param)
	local buyParam = normalizeParam(param)
	if buyParam ~= "gold pouch" and buyParam ~= "gold puch" then
		player:sendCancelMessage("Usage: !buy gold pouch")
		return false
	end

	if player:getItemCount(config.goldPouchId) > 0 then
		player:sendCancelMessage("You already have a Gold Pouch.")
		return false
	end

	if not player:removeTotalMoney(config.goldPouchPrice) then
		player:sendCancelMessage("You need " .. config.goldPouchPrice .. " gold to buy a Gold Pouch.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local item = player:addItem(config.goldPouchId, 1, true)
	if not item then
		player:addMoney(config.goldPouchPrice)
		player:sendCancelMessage("Could not deliver the Gold Pouch. Your money was refunded.")
		return false
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You bought a Gold Pouch for " .. config.goldPouchPrice .. " gold.")
	player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
	return false
end
talkaction:separator(" ")
talkaction:register()
