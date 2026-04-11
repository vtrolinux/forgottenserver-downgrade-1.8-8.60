-- NpcHandler Wrapper for Crystal RevScripts
CrystalNpcHandler = {}
CrystalNpcHandler.__index = CrystalNpcHandler

function CrystalNpcHandler:new(keywordHandler)
	local obj = {
		keywordHandler = keywordHandler,
		messages = {},
		modules = {}
	}
	setmetatable(obj, CrystalNpcHandler)
	
	-- We store it globally so NpcType:register can consume it
	_G.LastCrystalNpcHandler = obj
	
	return obj
end

function CrystalNpcHandler:setMessage(id, message)
	self.messages[id] = message
end

function CrystalNpcHandler:addModule(moduleArgs)
	table.insert(self.modules, moduleArgs)
end

-- Safely mock callbacks to avoid errors when the crystal script assigns them
function CrystalNpcHandler:onThink(npc, interval) end
function CrystalNpcHandler:onAppear(npc, creature) end
function CrystalNpcHandler:onDisappear(npc, creature) end
function CrystalNpcHandler:onMove(npc, creature, fromPos, toPos) end
function CrystalNpcHandler:onSay(npc, creature, msgType, message) end
function CrystalNpcHandler:onCloseChannel(npc, creature) end
