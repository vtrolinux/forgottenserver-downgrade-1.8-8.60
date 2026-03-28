local TEST_AREA_CENTER = Position(1112, 1187, 7)
local TEST_AREA_FROM   = Position(1082, 1157, 7)  -- center - 30
local TEST_AREA_TO     = Position(1142, 1217, 7)  -- center + 30
local TEST_MONSTER_NAME = "Demon"
local instanceCounter = 0


local function cleanupInstanceMonsters(instanceId)
    if instanceId == 0 then
        return
    end

    local searchCenter = TEST_AREA_CENTER
    local rangeX, rangeY = 30, 30
    local area = Game.getInstanceArea(instanceId)
    if area then
        local cx = math.floor((area.fromPos.x + area.toPos.x) / 2)
        local cy = math.floor((area.fromPos.y + area.toPos.y) / 2)
        searchCenter = Position(cx, cy, area.fromPos.z)
        rangeX = math.floor(math.abs(area.toPos.x - area.fromPos.x) / 2)
        rangeY = math.floor(math.abs(area.toPos.y - area.fromPos.y) / 2)
    end

    local spectators = Game.getSpectators(searchCenter, false, false, rangeX, rangeX, rangeY, rangeY)
    for _, spec in ipairs(spectators) do
        if spec:isMonster() and spec:getInstanceId() == instanceId then
            local summons = spec:getSummons()
            if summons then
                for _, summon in ipairs(summons) do
                    summon:remove()
                end
            end
            spec:remove()
        end
    end
end


local function cleanupInstance(player)
    local instanceId = player:getInstanceId()
    cleanupInstanceMonsters(instanceId)
    Game.unregisterInstanceArea(instanceId)
    player:setInstanceId(0)
end


local talkaction = TalkAction("/instancetest")
function talkaction.onSay(player, words, param)
    param = param:lower():gsub("^%s*(.-)%s*$", "%1")
    local args = {}
    for word in param:gmatch("%S+") do
        args[#args + 1] = word
    end

    local action = args[1] or "info"

    if action == "info" then
        local instanceId = player:getInstanceId()
        local pos = player:getPosition()
        local msg = "=== Instance System Info ===\n"
        msg = msg .. "Your Instance ID: " .. instanceId .. "\n"
        msg = msg .. "Position: " .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. "\n"
        if instanceId == 0 then
            msg = msg .. "Status: Global world (no instance)\n"
        else
            msg = msg .. "Status: Inside instance #" .. instanceId .. "\n"
        end
        player:popupFYI(msg)
        return false
    end

    if action == "enter" then
        instanceCounter = instanceCounter + 1
        local instanceId = instanceCounter
        local oldInstance = player:getInstanceId()
        player:setInstanceId(instanceId)

        local dest = player:getClosestFreePosition(TEST_AREA_CENTER, false)
        if dest.x ~= 0 then
            player:teleportTo(dest)
            dest:sendMagicEffect(CONST_ME_TELEPORT, {player})
        else
            player:teleportTo(TEST_AREA_CENTER)
            TEST_AREA_CENTER:sendMagicEffect(CONST_ME_TELEPORT, {player})
        end

        local destPos = player:getPosition()
        local spawnPos = Position(destPos.x + 1, destPos.y, destPos.z)
        local freePos = player:getClosestFreePosition(spawnPos, false)
        if freePos.x == 0 then freePos = spawnPos end

        local monster = Game.createMonster(TEST_MONSTER_NAME, freePos, false, false, CONST_ME_TELEPORT, instanceId)
        if monster then
            monster:setInstanceId(instanceId)
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Failed to create monster.")
        end

        Game.registerInstanceArea(instanceId, TEST_AREA_FROM, TEST_AREA_TO)

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            string.format("You entered instance #%d (previous: #%d).", instanceId, oldInstance))
        return false
    end

    if action == "exit" then
        local oldInstance = player:getInstanceId()
        if oldInstance == 0 then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You are already in the global world (instance 0).")
            return false
        end

        cleanupInstance(player)
        local temple = player:getTown():getTemplePosition()
        player:teleportTo(temple)
        temple:sendMagicEffect(CONST_ME_TELEPORT, {player})

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            string.format("You left instance #%d and returned to the global world.", oldInstance))
        return false
    end

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Usage: /instancetest [enter|exit|info]")
    return false
end
talkaction:separator(" ")
talkaction:register()


local logoutEvent = CreatureEvent("InstanceTestLogout")
function logoutEvent.onLogout(player)
    local instanceId = player:getInstanceId()
    cleanupInstanceMonsters(instanceId)
    Game.unregisterInstanceArea(instanceId)
    return true
end
logoutEvent:type("logout")
logoutEvent:register()


local deathEvent = CreatureEvent("InstanceTestDeath")
function deathEvent.onPrepareDeath(creature, killer)
    local player = creature:getPlayer()
    if not player then
        return true
    end
    cleanupInstance(player)
    local temple = player:getTown():getTemplePosition()
    player:teleportTo(temple)
    temple:sendMagicEffect(CONST_ME_TELEPORT, {player})
    return true
end
deathEvent:type("preparedeath")
deathEvent:register()


local loginEvent = CreatureEvent("InstanceTestLogin")
function loginEvent.onLogin(player)
    player:registerEvent("InstanceTestLogout")
    player:registerEvent("InstanceTestDeath")
    return true
end
loginEvent:type("login")
loginEvent:register()