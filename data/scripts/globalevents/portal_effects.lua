local portalEffects = GlobalEvent("PortalEffects")
function portalEffects.onThink(interval)
    local effects = {
        {position = Position(997, 995, 7),  text = "Forge",        effect = 30, color = TEXTCOLOR_BLUE},
        {position = Position(1003, 995, 7), text = "Imbuements",   effect = 30, color = TEXTCOLOR_RED},
        {position = Position(997, 998, 7),  text = "Dungeon",      effect = 30, color = TEXTCOLOR_PURPLE},
        {position = Position(1003, 998, 7), text = "Sala de Boss", effect = 30, color = TEXTCOLOR_GREEN},
    }

    for i = 1, #effects do
        local settings = effects[i]
        local spectators = Game.getSpectators(settings.position, false, true, 7, 7, 5, 5)

        if #spectators > 0 then
            if settings.effect then
                settings.position:sendMagicEffect(settings.effect)
            end
            Game.sendAnimatedText(settings.text, settings.position, settings.color)
        end
    end
    return true
end
portalEffects:interval(2000)
portalEffects:register()
