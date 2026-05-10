local chainStorage = 40001

local chainSystem = TalkAction("!chain")

function chainSystem.onSay(player, words, param)
	param = param:trim():lower()
	if param == "on" then
		player:setStorageValue(chainStorage, 1)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Chain system ativado.")
	elseif param == "off" then
		player:setStorageValue(chainStorage, 0)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Chain system desativado.")
	else
		local state = player:getStorageValue(chainStorage)
		local stateText = (state == 1) and "ativado" or "desativado"
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Chain system: %s. Use !chain on ou !chain off.", stateText))
	end
	return false
end

chainSystem:separator(" ")
chainSystem:register()
