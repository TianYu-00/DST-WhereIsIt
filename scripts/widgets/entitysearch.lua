local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")

local EntitySearch = Class(Widget, function(self, context)
	Widget._ctor(self, "entity-search")
	self.parent_screen = context.screen
	local button_atlas = "images/button_icons.xml"
	local button_tex = "submit.tex"
	local button_onclick = function()
		self.parent_screen:FilterEntityList(self.parent_screen.name_input.textinput.textbox:GetString())
		self.parent_screen:CreateEntityList()
	end
	-- IconButton(iconAtlas, iconTexture, labelText, sideLabel, alwaysShowLabel, onclick, textinfo, defaultTexture)
	self.search_button = self:AddChild(Templates2.IconButton(button_atlas, button_tex, "", "", "", button_onclick))
	self.search_button:SetScale(0.5)
end)

return EntitySearch

----------------------------------- Comments -----------------------------------

-- This search widget isnt really needed as i added same filter logic on input directly
-- but ill leave it here just in case
