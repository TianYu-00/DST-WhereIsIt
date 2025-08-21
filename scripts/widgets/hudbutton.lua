local Widget = require("widgets/widget")
local Templates = require("widgets/templates")
local ImageButton = require("widgets/imagebutton")
local Text = require("widgets/text")

local HudButton = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_HUD_BUTTON)

	self.hud_button_root = self:AddChild(Widget("hud_button_container"))

	self.hud_button_root:SetHAnchor(ANCHOR_RIGHT)
	self.hud_button_root:SetVAnchor(ANCHOR_BOTTOM)
	self.hud_button_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.hud_button_root:SetPosition(-270, 35) -- x,y

	self.bg = self.hud_button_root:AddChild(ImageButton("images/ui.xml", "button_small.tex"))
	self.bg:SetOnClick(function()
		TIAN_WHEREISIT_GLOBAL_FUNCTION.TOGGLE_MENU()
	end)
	self.bg:SetFocusScale(1.1, 0.8)
	self.bg:SetNormalScale(1, 0.7)
	self.bg:SetText(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.MOD_NAME)
	self.bg:SetFont(NEWFONT)
	self.bg:SetTextColour(unpack(WHITE))
	self.bg:SetTextFocusColour(unpack(WHITE))
	self.bg:SetTextSize(20)
	self.bg.image:SetTint(0, 0, 0, 0.5)
end)

return HudButton
