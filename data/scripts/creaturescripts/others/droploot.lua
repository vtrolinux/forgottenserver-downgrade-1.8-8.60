local ITEM_GOLD_POUCH = 23721

local function isPlayerOrPlayerSummon(creature)
    if not creature then
        return false
    end

    if creature:isPlayer() then
        return true
    end

    local master = creature:getMaster()
    return master and master:isPlayer()
end

local function moveGoldPouchToInbox(item, inbox)
    if item:getId() == ITEM_GOLD_POUCH then
        if inbox then
            item:moveTo(inbox, 0)
        end
        return true
    end

    return false
end

local function protectNestedGoldPouches(item, inbox)
    local container = item:getContainer()
    if not container then
        return
    end

    for _, child in ipairs(container:getItems(true)) do
        if child:getId() == ITEM_GOLD_POUCH and inbox then
            child:moveTo(inbox, 0)
        end
    end
end

local function getBlessingLossChance(player)
    local blessCount = 0
    for blessing = 1, 5 do
        if player:hasBlessing(blessing) then
            blessCount = blessCount + 1
        end
    end

    return math.max(0, 10 - (blessCount * 2))
end

local function shouldDropItem(item, slot, isRedOrBlack, killedByPlayer, lossChance)
    if isRedOrBlack then
        return true
    end

    if lossChance <= 0 then
        return false
    end

    if slot == CONST_SLOT_BACKPACK and not killedByPlayer then
        return true
    end

    local maxRandom = item:isContainer() and 100 or 1000
    local threshold = (lossChance / 100) * maxRandom
    return math.random(1, maxRandom) <= threshold
end

local function moveToCorpseOrRemove(item, corpse)
    if not corpse then
        return
    end

    if not item:moveTo(corpse) then
        item:remove()
    end
end

local DropLoot = CreatureEvent("DropLoot")
function DropLoot.onDeath(player, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if player:hasFlag(PlayerFlag_NotGenerateLoot) or player:getVocation():getId() == VOCATION_NONE then
        return true
    end

    local isRedOrBlack = table.contains({SKULL_RED, SKULL_BLACK}, player:getSkull())
    local killedByPlayer = isPlayerOrPlayerSummon(killer)


    local amulet = player:getSlotItem(CONST_SLOT_NECKLACE)
    if amulet and amulet:getId() == ITEM_AMULETOFLOSS and not isRedOrBlack then
        if not killedByPlayer or not player:hasBlessing(6) then
            player:removeItem(ITEM_AMULETOFLOSS, 1, -1, false)
        end
        if not player:getSlotItem(CONST_SLOT_BACKPACK) then
            player:addItem(ITEM_BAG, 1, false, CONST_SLOT_BACKPACK)
        end
        return true
    end

    local storeInbox = player:getStoreInbox()
    local lossChance = getBlessingLossChance(player)
    for i = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
        local item = player:getSlotItem(i)
        if item and not moveGoldPouchToInbox(item, storeInbox) then
            protectNestedGoldPouches(item, storeInbox)

            if shouldDropItem(item, i, isRedOrBlack, killedByPlayer, lossChance) then
                moveToCorpseOrRemove(item, corpse)
            end
        end
    end

    if not player:getSlotItem(CONST_SLOT_BACKPACK) then
        player:addItem(ITEM_BAG, 1, false, CONST_SLOT_BACKPACK)
    end
    return true
end
DropLoot:register()

local login = CreatureEvent("DropLogin")
function login.onLogin(player)
    player:registerEvent("DropLoot")
    return true
end
login:register()
