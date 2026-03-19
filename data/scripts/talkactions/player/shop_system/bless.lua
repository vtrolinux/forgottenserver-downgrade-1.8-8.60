local talkaction = TalkAction("/bless")

function talkaction.onSay(player, words, param)
	-- Give all 5 blessings
	for i = 1, 5 do
		player:addBlessing(i)
	end

	local message = string.format("%s has received all blessings.", player:getName())
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)

	return false
end

talkaction:separator(" ")
talkaction:register()

