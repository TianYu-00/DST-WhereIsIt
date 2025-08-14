local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")

local EntityAdd = Class(Widget, function(self, context)
	Widget._ctor(self, "entity-add")
	self.parent_screen = context.screen
	local button_atlas = "images/button_icons.xml"
	local button_tex = "save.tex"
	local button_onclick = function()
		local text = self.parent_screen.name_input.textinput.textbox:GetString()
		self.parent_screen:AddToEntityList(text)
	end
	-- IconButton(iconAtlas, iconTexture, labelText, sideLabel, alwaysShowLabel, onclick, textinfo, defaultTexture)
	self.entity_add_button = self:AddChild(Templates2.IconButton(button_atlas, button_tex, "", "", "", button_onclick))
	self.entity_add_button:SetScale(0.5)
end)

return EntityAdd
