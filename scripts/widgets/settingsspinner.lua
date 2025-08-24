local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")
local DebugLog = require("utils/debug")

local SettingsSpinner = Class(Widget, function(self, context, config)
	Widget._ctor(self, "Reusable Spinner")
	DebugLog("SettingsSpinner: Initialized")

	self.parent_screen = context.screen
	self.config = config or {}

	-- defaults
	self.config.label = self.config.label or "Option"
	self.config.description = self.config.description or ""
	self.config.description_widget = self.config.description_widget
	self.config.options = self.config.options or { "Option 1", "Option 2" }
	self.config.default = self.config.default or self.config.options[1]
	self.config.on_changed = self.config.on_changed or function() end
	self.config.width = self.config.width or 300
	self.config.height = self.config.height or 30

	-- find default index
	self.current_index = 1
	for i, v in ipairs(self.config.options) do
		if v == self.config.default then
			self.current_index = i
			break
		end
	end
	DebugLog(
		string.format("SettingsSpinner: Default '%s' at index %d", tostring(self.config.default), self.current_index)
	)

	-- spinner widget
	-- TEMPLATES.LabelSpinner(labeltext, spinnerdata, width_label, width_spinner, height, spacing, font, font_size, horiz_offset, onchanged_fn, colour, tooltip_text)
	self.widget = self:AddChild(
		Templates2.LabelSpinner(
			self.config.label,
			self.config.options,
			self.config.width,
			self.config.width,
			self.config.height,
			20,
			NEWFONT,
			20,
			0
		)
	)

	local old_description = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.SETTINGS_BASE_DESCRIPTION

	-- styling + focus behavior
	self.widget.label:SetColour(1, 1, 1, 1)
	self.widget.spinner:SetTextColour(1, 1, 1, 1)
	self.widget:SetOnGainFocus(function()
		DebugLog("SettingsSpinner: Focus gained → showing description: " .. self.config.description)
		self.config.description_widget:SetString(self.config.description)
	end)
	self.widget:SetOnLoseFocus(function()
		DebugLog("SettingsSpinner: Focus lost → reverting description")
		self.config.description_widget:SetString(old_description)
	end)

	-- overlay text
	local center_text = self.widget.spinner:AddChild(Text(NEWFONT, 20))
	center_text:SetPosition(0, 0)
	center_text:SetHAlign(ANCHOR_MIDDLE)
	center_text:SetVAlign(ANCHOR_MIDDLE)

	-- init default state
	self:SetValue(self.current_index)
	center_text:SetString(self:GetIndexString())
	DebugLog("SettingsSpinner: Initialized with value '" .. tostring(self:GetIndexString()) .. "'")

	-- change handler
	self.widget.spinner:SetOnChangedFn(function()
		center_text:SetString(self:GetIndexString())
		self.current_index = self:GetValue()
		DebugLog("SettingsSpinner: Value changed → " .. tostring(self:GetIndexString()))
		self.config.on_changed(self:GetIndexString())
	end)
end)

function SettingsSpinner:SetValue(value)
	DebugLog("SettingsSpinner:SetValue → " .. tostring(value))
	self.widget.spinner:SetSelectedIndex(value)
end

function SettingsSpinner:GetValue()
	local v = self.widget.spinner:GetSelectedIndex()
	DebugLog("SettingsSpinner:GetValue → " .. tostring(v))
	return v
end

function SettingsSpinner:GetIndexString()
	local s = self.widget.spinner:GetSelected()
	DebugLog("SettingsSpinner:GetIndexString → " .. tostring(s))
	return s
end

return SettingsSpinner
