local Widget = require("widgets/widget")
local Templates = require("widgets/templates")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")

local Settings = Class(Widget, function(self, context)
	Widget._ctor(self, "tian_whereisit_widget_settings")
	self.parent_screen = context.screen
	self.is_open = false
	self.menu_container = self:AddChild(Widget("settings_menu_container"))
	self.menu_container:Hide()
end)

function Settings:CreateMenu()
	self.bg = self.menu_container:AddChild(Templates.CurlyWindow(400, 450, 1, 1, 68, -40))
	self.bg:SetTint(1, 1, 1, 0.7)

	self.back_button = self.menu_container:AddChild(Templates2.StandardButton(function()
		self:CloseMenu()
	end, "Back"))
	self.back_button:SetScale(0.4)
	local btn_w, btn_h = self.back_button:GetSize()
	btn_w = btn_w * 0.4
	btn_h = btn_h * 0.4
	local padding = 0
	self.back_button:SetPosition(0, -(450 / 2) + (btn_h / 2) + padding, 0)

	self.title = self.menu_container:AddChild(Text(NEWFONT_OUTLINE, 50))
	self.title:SetPosition(0, 250, 0)
	self.title:SetString("Settings")
	self.title:SetColour(unpack(GOLD))
end

function Settings:OpenMenu()
	self.is_open = true
	self.parent_screen.proot:Hide()
	self.parent_screen.sroot:Show()
	self.menu_container:Show()
	self.menu_container:MoveToFront()
end

function Settings:CloseMenu()
	self.is_open = false
	self.parent_screen.proot:Show()
	self.parent_screen.sroot:Hide()
	self.menu_container:Hide()
end

function Settings:CreateSettingsButton()
	local button_atlas = "images/button_icons.xml"
	local button_tex = "configure_mod.tex"
	local button = Templates2.IconButton(button_atlas, button_tex, "", "", "", function()
		if self.parent_screen.sroot:IsVisible() then
			self:CloseMenu()
		else
			self:OpenMenu()
		end
	end)

	button:SetScale(0.5)

	-- Set up tooltips
	button:SetOnGainFocus(function()
		self.parent_screen.tooltip_root:UpdatePosition(button, 0, -25)
		self.parent_screen.tooltip_root.tooltip:SetString("Settings")
	end)

	button:SetOnLoseFocus(function()
		self.parent_screen.tooltip_root:HideTooltip(button)
	end)

	return button
end

return Settings
