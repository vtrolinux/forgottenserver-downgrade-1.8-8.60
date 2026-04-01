local talk = TalkAction("/addmount")

function talk.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local split = param:split(",")
	if #split < 2 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /addmount playerName, mountId (or 'all')")
		return false
	end

	local targetName = split[1]:trim()
	local mountParam = split[2]:trim()

	local target = Player(targetName)
	if not target then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Player " .. targetName .. " not found or not online.")
		return false
	end

	if mountParam:lower() == "all" then
		local count = 0
		for id = 1, 96 do
			if target:addMount(id) then
				count = count + 1
			end
		end
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Added " .. count .. " mounts to " .. target:getName() .. ".")
		target:sendTextMessage(MESSAGE_INFO_DESCR, "You received all mounts! Relog to see them.")
	else
		local mountId = tonumber(mountParam)
		if not mountId then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid mount id. Use the mount id from mounts.xml (not clientid/looktype).")
			return false
		end

		if target:addMount(mountId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Mount id " .. mountId .. " added to " .. target:getName() .. ". Player should relog to use it.")
			target:sendTextMessage(MESSAGE_INFO_DESCR, "You received a new mount! Relog to use it.")
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Failed to add mount " .. mountId .. " (already owned or invalid id). Check mounts.xml for valid ids (1-96).")
		end
	end

	return false
end

talk:separator(" ")
talk:access(true)
talk:register()
