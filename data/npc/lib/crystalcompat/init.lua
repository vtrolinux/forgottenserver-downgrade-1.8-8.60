-- Crystal Compat initialization
if _G.CrystalCompatLoaded then return end
_G.CrystalCompatLoaded = true

MESSAGE_GREET = MESSAGE_GREET or 1
MESSAGE_FAREWELL = MESSAGE_FAREWELL or 2
MESSAGE_WALKAWAY = MESSAGE_WALKAWAY or 16

local function getTimestamp()
    return os.date("%Y-%m-%d %H:%M:%S") .. string.format(".%03d", math.random(1, 999))
end
print(string.format("[%s] [\27[32minfo\27[0m] >> Loading smart proxy layer for Jiddo...", getTimestamp()))
dofile('data/npc/lib/crystalcompat/keywordhandler.lua')
dofile('data/npc/lib/crystalcompat/npchandler.lua')
dofile('data/npc/lib/crystalcompat/npctype.lua')

if KeywordHandler and NpcHandler then
	if not _G.OriginalKeywordHandlerNew then _G.OriginalKeywordHandlerNew = KeywordHandler.new end
	if not _G.OriginalNpcHandlerNew then _G.OriginalNpcHandlerNew = NpcHandler.new end
	
	-- Hijack keyword handler globally
	function KeywordHandler:new(...)
		local info = debug.getinfo(2, "S")
		local isRevScript = info and info.source and (info.source:match("[\\/]npc[\\/]lua") or info.source:match("crystalcompat"))
		
		if isRevScript then
			return CrystalKeywordHandler:new()
		else
			return _G.OriginalKeywordHandlerNew(self, ...)
		end
	end

	-- Hijack NpcHandler globally
	function NpcHandler:new(...)
		local info = debug.getinfo(2, "S")
		local isRevScript = info and info.source and (info.source:match("[\\/]npc[\\/]lua") or info.source:match("crystalcompat"))
		
		if isRevScript then
			return CrystalNpcHandler:new(...)
		else
			return _G.OriginalNpcHandlerNew(self, ...)
		end
	end
end
