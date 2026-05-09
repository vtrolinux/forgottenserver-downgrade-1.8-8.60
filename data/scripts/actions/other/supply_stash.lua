local SUPPLY_STASH_ITEM_ID = ITEM_SUPPLY_STASH or 28750

local action = Action()
function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not CustomSupplyStash then
        player:sendCancelMessage("The supply stash is not available.")
        return true
    end

    if not CustomSupplyStash.open then
        player:sendCancelMessage("The supply stash is not available.")
        return true
    end

    local ok, err = pcall(function()
        CustomSupplyStash.open(player)
    end)

    if not ok then
        player:sendCancelMessage("Error opening supply stash.")
        return true
    end

    return true
end
action:id(SUPPLY_STASH_ITEM_ID)
action:register()