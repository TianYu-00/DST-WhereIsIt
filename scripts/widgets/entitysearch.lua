local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")

local EntitySearch = Class(Widget, function(self, context)
	Widget._ctor(self, "tian_whereisit_widget_entity_search")
	self.parent_screen = context.screen

	-- search button is pretty useless at this point as i already implemented on input searchers
	-- well figure out what to do with it later on
	local button_atlas = "images/button_icons.xml"
	local button_tex = "submit.tex"
	local button_onclick = function()
		self:FilterEntityList(self.parent_screen.name_input.textinput.textbox:GetString())
	end
	-- IconButton(iconAtlas, iconTexture, labelText, sideLabel, alwaysShowLabel, onclick, textinfo, defaultTexture)
	self.search_button = self:AddChild(Templates2.IconButton(button_atlas, button_tex, "", "", "", button_onclick))
	self.search_button:SetScale(0.5)
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
			if entity.name:lower():find(search_lower, 1, true) then
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
