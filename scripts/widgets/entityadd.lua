local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")

local EntityAdd = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_ADD)
	self.parent_screen = context.screen
	local button_atlas = "images/button_icons.xml"
	local button_tex = "save.tex"
	local button_onclick = function()
		local text = self.parent_screen.name_input.textinput.textbox:GetString()
		-- self:AddToEntityList(text)
		self.parent_screen.addmenu_root.code_name_input.textbox:SetString(text or "")
		self.parent_screen.addmenu_root:OpenMenu()
	end
	-- IconButton(iconAtlas, iconTexture, labelText, sideLabel, alwaysShowLabel, onclick, textinfo, defaultTexture)
	self.entity_add_button = self:AddChild(Templates2.IconButton(button_atlas, button_tex, "", "", "", button_onclick))
	self.entity_add_button:SetScale(0.5)

	self.entity_add_button:SetOnGainFocus(function()
		self.parent_screen.tooltip_root:UpdatePosition(self.entity_add_button, 0, -25)
		self.parent_screen.tooltip_root.tooltip:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.ADD_ENTITY)
	end)

	self.entity_add_button:SetOnLoseFocus(function()
		self.parent_screen.tooltip_root:HideTooltip(self.entity_add_button)
	end)
end)

return EntityAdd
