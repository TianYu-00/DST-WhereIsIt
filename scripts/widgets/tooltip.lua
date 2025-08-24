local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")
local DebugLog = require("utils/debug")

local Tooltip = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_TOOLTIP)
	DebugLog("Tooltip: Initialized")

	self.parent_screen = context.screen
	self.tooltip = self:AddChild(Text(NEWFONT_OUTLINE, 15))
	self.current_focus_widget = nil
	self.tooltip:MoveToFront()
	DebugLog("Tooltip: Text widget created and moved to front")
end)

function Tooltip:UpdatePosition(widget, x_offset, y_offset)
	if not widget then
		DebugLog("Tooltip: UpdatePosition called with nil widget")
		return
	end

	self.current_focus_widget = widget
	local x, y = widget:GetPosition():Get()
	local parent = widget:GetParent()
	while parent and parent ~= self.parent_screen.proot do
		local px, py = parent:GetPosition():Get()
		x = x + px
		y = y + py
		parent = parent:GetParent()
	end

	DebugLog(string.format("Tooltip: Updating position → x: %.2f, y: %.2f (offset: %d,%d)", x, y, x_offset, y_offset))

	self.tooltip:SetPosition(x + x_offset, y + y_offset, 0)
	self:ShowTooltip(widget)
end

function Tooltip:ShowTooltip(widget)
	if widget == self.current_focus_widget then
		DebugLog("Tooltip: ShowTooltip for focused widget")
		self.tooltip:Show()
	else
		DebugLog("Tooltip: ShowTooltip skipped (widget mismatch)")
	end
end

function Tooltip:HideTooltip(widget)
	if widget == self.current_focus_widget then
		DebugLog("Tooltip: HideTooltip → hiding and clearing current focus widget")
		self.tooltip:Hide()
		self.current_focus_widget = nil
	else
		DebugLog("Tooltip: HideTooltip skipped (widget mismatch)")
	end
end

return Tooltip
