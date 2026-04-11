-- NpcType Wrapper
if not _G.OriginalNpcTypeRegister then
	_G.OriginalNpcTypeRegister = NpcType.register
end

function NpcType:register(npcConfig)
	_G.OriginalNpcTypeRegister(self, npcConfig)
	
	local handler = _G.LastCrystalNpcHandler
	if handler then
		-- Clean the manual callbacks defined by the legacy script!
		-- They inject broken signatures. Default behavior restores RevNpcSys.
		self:defaultBehavior()

		-- Create pure RevScript handler
		local revHandler = NpcsHandler(npcConfig.name)
		
		-- 2. Apply Keywords
		local greetNode = revHandler:keyword(revHandler.greetWords)
		
		-- 1. Apply Messages
		if handler.messages[MESSAGE_GREET] then
			greetNode:setGreetResponse({handler.messages[MESSAGE_GREET]})
		end
		if handler.messages[MESSAGE_FAREWELL] then
			revHandler:setFarewellResponse({handler.messages[MESSAGE_FAREWELL]})
		end
		
		if handler.keywordHandler then
			local function applyKwTree(sourceList, revParentNode)
				for _, kw in ipairs(sourceList) do
					local childKw = nil
					if kw.callback == StdModule.say then
						childKw = revParentNode:keyword(kw.keys)
						if kw.parameters and kw.parameters.text then
							childKw:respond(kw.parameters.text)
						end
					elseif kw.callback == StdModule.travel then
						local p = kw.parameters
						local destinations = {}
						destinations[kw.keys[1]] = {
							money = p.cost or 0,
							level = p.level or 0,
							premium = p.premium or false,
							position = p.destination
						}
						revHandler:travelTo(destinations)
						childKw = revParentNode:keyword(kw.keys)
					end
					
					if childKw and kw.children and #kw.children > 0 then
						applyKwTree(kw.children, childKw)
					end
				end
			end
			applyKwTree(handler.keywordHandler.nodes, greetNode)
		end
		
		-- 3. Apply Voices
		if type(npcConfig.voices) == "table" and #npcConfig.voices > 0 then
			local vList = {}
			for _, v in ipairs(npcConfig.voices) do
				table.insert(vList, {
					text = v.text or v.words or "",
					chance = v.chance or npcConfig.voices.chance or 50,
				})
			end
			-- talk expects (params, delay)
			revHandler:talk(vList, npcConfig.voices.interval or 15000)
		end
		
		_G.LastCrystalNpcHandler = nil
	end
end
