local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")

local EntityRemove = Class(Widget, function(self, context)
	Widget._ctor(self, "tian_whereisit_widget_entity_remove_" .. context.index)
	self.parent_screen = context.main_parent_screen
	self.screen = context.screen
	local button_atlas = "images/button_icons.xml"
	local button_tex = "delete.tex"
	self.entity_remove_button = self:AddChild(ImageButton(button_atlas, button_tex))
	self.entity_remove_button:SetScale(0.05)
	self.entity_remove_button:SetOnClick(function()
		self.parent_screen:RemoveEntity(context.data.name)
		print(context.data.name, "deleted")
	end)
end)

return EntityRemove
