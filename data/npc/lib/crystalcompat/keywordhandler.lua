-- KeywordHandler Wrapper for Crystal RevScripts
CrystalKeywordNode = {}
CrystalKeywordNode.__index = CrystalKeywordNode

function CrystalKeywordNode:addChildKeyword(keys, moduleCallback, parameters)
	local child = {
		keys = keys,
		callback = moduleCallback,
		parameters = parameters or {},
		children = {}
	}
	table.insert(self.children, child)
	return setmetatable(child, CrystalKeywordNode)
end

function CrystalKeywordNode:addAliasKeyword(keys)
	-- Alias keywords just mean same thing. With NpcsHandler, we could just add another keyword block.
	-- We can mock it safely by ignoring or repeating the last child? For safety just return self.
	return self
end

CrystalKeywordHandler = {}
CrystalKeywordHandler.__index = CrystalKeywordHandler

function CrystalKeywordHandler:new()
	local obj = {
		nodes = {}
	}
	setmetatable(obj, CrystalKeywordHandler)
	return obj
end

function CrystalKeywordHandler:addKeyword(keys, moduleCallback, parameters)
	local node = {
		keys = keys,
		callback = moduleCallback,
		parameters = parameters or {},
		children = {}
	}
	table.insert(self.nodes, node)
	return setmetatable(node, CrystalKeywordNode)
end
