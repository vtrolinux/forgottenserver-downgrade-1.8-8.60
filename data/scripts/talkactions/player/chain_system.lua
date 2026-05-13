local chainStorage = 40001

local chainSystem = TalkAction("!chain")

local function isChainSystemEnabled()
	if ChainSystem and ChainSystem.enabled ~= nil then
		return ChainSystem.enabled
	end

	if configManager and configKeys then
		if configKeys.CHAIN_SYSTEM_ENABLED then
			return configManager.getBoolean(configKeys.CHAIN_SYSTEM_ENABLED)
		end

		if configKeys.TOGGLE_CHAIN_SYSTEM then
			return configManager.getBoolean(configKeys.TOGGLE_CHAIN_SYSTEM)
		end
	end

	return true
end

function chainSystem.onSay(player, words, param)
	if not isChainSystemEnabled() then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Chain system is not enabled on this server.")
		return true
	end

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
