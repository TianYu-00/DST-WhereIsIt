local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")

local SettingsSpinner = Class(Widget, function(self, context, config)
	Widget._ctor(self, "Reusable Spinner")
	self.parent_screen = context.screen
	self.config = config or {}

	self.config.label = self.config.label or "Option"
	self.config.description = self.config.description or ""
	self.config.description_widget = self.config.description_widget
	self.config.options = self.config.options or { "Option 1", "Option 2" }
	self.config.default = self.config.default or self.config.options[1]
	self.config.on_changed = self.config.on_changed or function() end
	self.config.width = self.config.width or 300
	self.config.height = self.config.height or 30
	self.current_index = 1
	for i, v in ipairs(self.config.options) do
		if v == self.config.default then
			self.current_index = i
			break
		end
	end

	-- spinner
	-- TEMPLATES.LabelSpinner(labeltext, spinnerdata, width_label, width_spinner, height, spacing, font, font_size, horiz_offset, onchanged_fn, colour, tooltip_text)
	self.widget = self:AddChild(Templates2.LabelSpinner(
		self.config.label, -- labeltext
		self.config.options, -- spinnerdata
		self.config.width, -- width_label
		self.config.width, -- width_spinner
		self.config.height, -- height
		20, -- spacing
		NEWFONT, -- font
		20, -- font_size
		0 -- horiz_offset
	))

	local old_description = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.SETTINGS_BASE_DESCRIPTION
	-- styling
	self.widget.label:SetColour(1, 1, 1, 1)
	self.widget.spinner:SetTextColour(1, 1, 1, 1)
	self.widget:SetOnGainFocus(function()
		self.config.description_widget:SetString(self.config.description)
	end)
	self.widget:SetOnLoseFocus(function()
		self.config.description_widget:SetString(old_description)
	end)

	-- text
	local center_text = self.widget.spinner:AddChild(Text(NEWFONT, 20))
	center_text:SetPosition(0, 0)
	center_text:SetHAlign(ANCHOR_MIDDLE)
	center_text:SetVAlign(ANCHOR_MIDDLE)

	-- Initialize spinner to default option
	self:SetValue(self.current_index)
	center_text:SetString(self:GetIndexString())

	self.widget.spinner:SetOnChangedFn(function()
		center_text:SetString(self:GetIndexString())
		self.current_index = self:GetValue()
		self.config.on_changed(self:GetIndexString())
	end)
end)

function SettingsSpinner:SetValue(value)
	self.widget.spinner:SetSelectedIndex(value)
end

function SettingsSpinner:GetValue()
	return self.widget.spinner:GetSelectedIndex()
end

function SettingsSpinner:GetIndexString()
	return self.widget.spinner:GetSelected()
end

return SettingsSpinner
