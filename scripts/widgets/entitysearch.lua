local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")
local DebugLog = require("utils/debug")

local EntitySearch = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_SEARCH)
	self.parent_screen = context.screen
	DebugLog("EntitySearch: Initialized")
end)

function EntitySearch:FilterEntityList(search)
	DebugLog("EntitySearch: FilterEntityList called with -> '" .. tostring(search) .. "'")
	local search_lower = search:lower():gsub("^%s*(.-)%s*$", "%1")
	self.parent_screen.entity_list = {}

	if search_lower == "" then
		DebugLog("EntitySearch: Resetting entity list to full master list")
		for _, e in ipairs(self.parent_screen.master_entity_list) do
			table.insert(self.parent_screen.entity_list, e)
		end
	else
		for _, entity in ipairs(self.parent_screen.master_entity_list) do
			local name_match = entity.name:lower():find(search_lower, 1, true)
			local custom_match = entity.custom_name and entity.custom_name:lower():find(search_lower, 1, true)
			if name_match or custom_match then
				table.insert(self.parent_screen.entity_list, entity)
				DebugLog("EntitySearch: Matched entity -> " .. entity.name)
			end
		end
	end

	DebugLog("EntitySearch: Filtered entity list contains " .. tostring(#self.parent_screen.entity_list) .. " entities")
	self.parent_screen:CreateEntityList()
end

return EntitySearch
