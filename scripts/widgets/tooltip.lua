local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")

local Tooltip = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_TOOLTIP)
	self.parent_screen = context.screen
	self.tooltip = self:AddChild(Text(NEWFONT_OUTLINE, 15))
	self.current_focus_widget = nil
	self.tooltip:MoveToFront()
end)

function Tooltip:UpdatePosition(widget, x_offset, y_offset)
	self.current_focus_widget = widget
	local x, y = widget:GetPosition():Get()
	local parent = widget:GetParent()
	while parent and parent ~= self.parent_screen.proot do
		local px, py = parent:GetPosition():Get()
		x = x + px
		y = y + py
		parent = parent:GetParent()
	end
	-- print("updating tooltip x:" .. x .. "updating tooltip y:" .. y)
	self.tooltip:SetPosition(x + x_offset, y + y_offset, 0)
	self:ShowTooltip(widget)
end

function Tooltip:ShowTooltip(widget)
	if widget == self.current_focus_widget then
		self.tooltip:Show()
	end
end

function Tooltip:HideTooltip(widget)
	if widget == self.current_focus_widget then
		self.tooltip:Hide()
		self.current_focus_widget = nil
	end
end

return Tooltip
