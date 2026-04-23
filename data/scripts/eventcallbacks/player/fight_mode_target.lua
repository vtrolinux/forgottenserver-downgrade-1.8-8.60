local event = Event()

function event.onFightModeChanged(player, stance, chase, secure)
	local target = player:getTarget()
	if not target then
		return
	end

	if player:isChasingEnabled() then
		if not player:getFollowCreature() then
			player:setFollowCreature(target)
		end
	else
		player:setFollowCreature(nil)
		player:stopWalk()
	end
end

event:register()
