local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")

local EntitySearch = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_SEARCH)
	self.parent_screen = context.screen
end)

-- This needs to be moved to entitysearch.lua
function EntitySearch:FilterEntityList(search)
	local search_lower = search:lower():gsub("^%s*(.-)%s*$", "%1")
	self.parent_screen.entity_list = {}

	if search_lower == "" then
		-- Reset to full list
		for _, e in ipairs(self.parent_screen.master_entity_list) do
			table.insert(self.parent_screen.entity_list, e)
		end
	else
		for _, entity in ipairs(self.parent_screen.master_entity_list) do
			local name_match = entity.name:lower():find(search_lower, 1, true)
			local custom_match = entity.custom_name and entity.custom_name:lower():find(search_lower, 1, true)
			if name_match or custom_match then
				table.insert(self.parent_screen.entity_list, entity)
			end
		end
	end

	self.parent_screen:CreateEntityList()
end

return EntitySearch

----------------------------------- Comments -----------------------------------

-- This search widget isnt really needed as i added same filter logic on input directly
-- but ill leave it here just in case
