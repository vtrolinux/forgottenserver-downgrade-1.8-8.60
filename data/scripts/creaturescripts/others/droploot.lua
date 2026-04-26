local DropLoot = CreatureEvent("DropLoot")
local ITEM_GOLD_POUCH = 23721

local function protectGoldPouches(item, inbox)
    if item:getId() == ITEM_GOLD_POUCH then
        return not inbox or not item:moveTo(inbox, 0)
    end

    local container = item:getContainer()
    if not container then
        return false
    end

    local blocked = false
    for _, child in ipairs(container:getItems()) do
        if protectGoldPouches(child, inbox) then
            blocked = true
        end
    end
    return blocked
end

function DropLoot.onDeath(player, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if player:hasFlag(PlayerFlag_NotGenerateLoot) or player:getVocation():getId() == VOCATION_NONE then
        return true
    end

    local isRedOrBlack = table.contains({SKULL_RED, SKULL_BLACK}, player:getSkull())


    local amulet = player:getSlotItem(CONST_SLOT_NECKLACE)
    if amulet and amulet:getId() == ITEM_AMULETOFLOSS and not isRedOrBlack then
        local isPlayer = killer and (killer:isPlayer() or (killer:getMaster() and killer:getMaster():isPlayer()))
        if not isPlayer or not player:hasBlessing(6) then
            player:removeItem(ITEM_AMULETOFLOSS, 1, -1, false)
        end
        if not player:getSlotItem(CONST_SLOT_BACKPACK) then
            player:addItem(ITEM_BAG, 1, false, CONST_SLOT_BACKPACK)
        end
        return true
    end

    local storeInbox = player:getStoreInbox()
    for i = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
        local item = player:getSlotItem(i)
        local blockedByGoldPouch = item and protectGoldPouches(item, storeInbox)
        if item and item:getId() ~= ITEM_GOLD_POUCH and not blockedByGoldPouch then
            if isRedOrBlack then
                if not item:moveTo(corpse) then
                    item:remove()
                end
            else
                local blessCount = 0
                for blessing = 1, 5 do
                    if player:hasBlessing(blessing) then
                        blessCount = blessCount + 1
                    end
                end
                
                local lossChance = 10 - (blessCount * 2)
                if lossChance > 0 then
                    local maxRandom = item:isContainer() and 100 or 1000
                    local randomValue = math.random(1, maxRandom)
                    local threshold = (lossChance / 100) * maxRandom
                    
                    if randomValue <= threshold then
                        if not item:moveTo(corpse) then
                            item:remove()
                        end
                    end
                end
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
