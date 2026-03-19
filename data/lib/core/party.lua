local CHANNEL_LOOT = 10

function Party.broadcastPartyLoot(self, text)
	self:getLeader():sendChannelMessage("", text, TALKTYPE_CHANNEL_O, CHANNEL_LOOT)
	local membersList = self:getMembers()
	for i = 1, #membersList do
		local player = membersList[i]
		if player then player:sendChannelMessage("", text, TALKTYPE_CHANNEL_O, CHANNEL_LOOT) end
	end
end
