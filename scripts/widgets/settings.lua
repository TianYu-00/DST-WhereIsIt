local Widget = require("widgets/widget")
local Templates = require("widgets/templates")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")
local ImageButton = require("widgets/imagebutton")
local CustomKeyList = require("keylist")
local SettingsSpinner = require("widgets/settingsspinner")
local DefaultSettings = require("defaultsettings")
local json = require("json")
local Image = require("widgets/image")
local DebugLog = require("utils/debug")

local Settings = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_SETTINGS)
	DebugLog("Settings: Initialized")
	self.parent_screen = context.screen
	self.is_open = false
	self.settings_data = deepcopy(DefaultSettings)
	self.menu_container = self:AddChild(Widget("settings_menu_container"))
	self.menu_container:Hide()
end)

function Settings:CreateMenu()
	DebugLog("Settings: Creating menu")
	self.bg = self.menu_container:AddChild(Templates.CurlyWindow(400, 450, 1, 1, 68, -40))
	self.bg:SetTint(1, 1, 1, 0.7)

	self.save_button = self.menu_container:AddChild(Templates2.StandardButton(function()
		DebugLog("Settings: Save button clicked")
		self:SaveSettings()
	end, TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.SAVE))
	self.save_button:SetScale(0.4)
	self.save_button:SetPosition(-150, -200, 0)

	self.reset_button = self.menu_container:AddChild(Templates2.StandardButton(function()
		DebugLog("Settings: Reset button clicked")
		self:ResetToDefaults()
	end, TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.RESET))
	self.reset_button:SetScale(0.4)
	self.reset_button:SetPosition(0, -200, 0)

	self.back_button = self.menu_container:AddChild(Templates2.StandardButton(function()
		DebugLog("Settings: Back button clicked")
		self:CloseMenu()
	end, TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.BACK))
	self.back_button:SetScale(0.4)
	self.back_button:SetPosition(150, -200, 0)

	self.title = self.menu_container:AddChild(Text(NEWFONT_OUTLINE, 50))
	self.title:SetPosition(0, 250, 0)
	self.title:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.SETTINGS)
	self.title:SetColour(unpack(GOLD))

	self.description_background = self.menu_container:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	self.description_background:SetPosition(0, 130, 0)
	self.description_background:SetScale(0.5, 1)
	self.description_background:SetTint(1, 1, 1, 1)

	self.description = self.menu_container:AddChild(Text(NEWFONT, 20))
	self.description:SetPosition(0, 180, 0)
	self.description:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.SETTINGS_BASE_DESCRIPTION)
	self.description:SetColour(unpack(WHITE))
	self.description:SetRegionSize(400, 90)
	self.description:EnableWordWrap(true)

	self:CreateSpinner()
	DebugLog("Settings: Menu created")
end

function Settings:GetSettings(callback)
	DebugLog("Settings: Loading settings")
	TheSim:GetPersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS, function(success, str)
		if not success or str == nil or str == "" then
			DebugLog("Settings: No settings file found, using defaults")
			self.settings_data = deepcopy(DefaultSettings)
			SavePersistentString(
				TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS,
				json.encode(self.settings_data),
				false
			)
		else
			local ok, data = pcall(json.decode, str)
			if ok and data then
				DebugLog("Settings: Settings loaded successfully")
				self.settings_data = data
			else
				DebugLog("Settings: Failed to decode settings, resetting to defaults")
				self.settings_data = deepcopy(DefaultSettings)
				SavePersistentString(
					TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS,
					json.encode(self.settings_data),
					false
				)
			end
		end

		if callback then
			callback()
		end
	end)
end

function Settings:SaveSettings()
	DebugLog("Settings: Saving settings")
	if self.settings_data then
		SavePersistentString(
			TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS,
			json.encode(self.settings_data),
			false
		)
		TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS = self.settings_data
		TIAN_WHEREISIT_GLOBAL_FUNCTION.UpdateKeyBindings()
		TIAN_WHEREISIT_GLOBAL_FUNCTION.TOGGLE_MENU_BUTTON()
		DebugLog("Settings: Settings saved")
	else
		DebugLog("Settings: No settings_data to save, writing defaults")
		self.settings_data = deepcopy(DefaultSettings)
		SavePersistentString(
			TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS,
			json.encode(self.settings_data),
			false
		)
	end
end

function Settings:ResetToDefaults()
	DebugLog("Settings: Resetting to defaults")
	self.settings_data = deepcopy(DefaultSettings)
	if self.spinner_container then
		self.spinner_container:Kill()
	end
	self:CreateSpinner()
end

function Settings:CreateSpinner()
	DebugLog("Settings: Creating spinners")
	self.spinner_container = self.menu_container:AddChild(Widget("spinner_container"))
	self.spinner_container:SetPosition(0, 100, 0)

	self.menu_key_spinner = self.spinner_container:AddChild(SettingsSpinner({ screen = self }, {
		label = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.MENU_KEY,
		description = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.MENU_KEY_DESCRIPTION,
		description_widget = self.description,
		options = CustomKeyList,
		default = self.settings_data.MENU_KEY,
		on_changed = function(value)
			DebugLog("Settings: Menu key changed to: " .. tostring(value))
			self.settings_data.MENU_KEY = value
		end,
		width = 300,
		height = 30,
	}))
	self.menu_key_spinner:SetPosition(0, 0)

	self.repeat_key_spinner = self.spinner_container:AddChild(SettingsSpinner({ screen = self }, {
		label = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.REPEAT_KEY,
		description = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.REPEAT_KEY_DESCRIPTION,
		description_widget = self.description,
		options = CustomKeyList,
		default = self.settings_data.REPEAT_LOOKUP_KEY,
		on_changed = function(value)
			DebugLog("Settings: Repeat key changed to: " .. tostring(value))
			self.settings_data.REPEAT_LOOKUP_KEY = value
		end,
	}))
	self.repeat_key_spinner:SetPosition(0, -50)

	self.menu_button_toggle_spinner = self.spinner_container:AddChild(SettingsSpinner({ screen = self }, {
		label = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.MENU_BUTTON_TOGGLE,
		description = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.MENU_BUTTON_TOGGLE_DESCRIPTION,
		description_widget = self.description,
		options = { "true", "false" },
		default = self.settings_data.MENU_BUTTON_TOGGLE,
		on_changed = function(value)
			DebugLog("Settings: Menu button toggle changed to: " .. tostring(value))
			self.settings_data.MENU_BUTTON_TOGGLE = value
		end,
	}))
	self.menu_button_toggle_spinner:SetPosition(0, -100)
	DebugLog("Settings: Spinners created")
end

function Settings:OpenMenu()
	DebugLog("Settings: Opening menu")
	self.is_open = true
	self.parent_screen.proot:Hide()
	self.parent_screen.sroot:Show()
	self.menu_container:Show()
	self.menu_container:MoveToFront()

	if self.spinner_container then
		self.spinner_container:Kill()
	end

	self:GetSettings(function()
		self:CreateSpinner()
	end)
end

function Settings:CloseMenu()
	DebugLog("Settings: Closing menu")
	self.is_open = false
	self.parent_screen.proot:Show()
	self.parent_screen.sroot:Hide()
	self.menu_container:Hide()
end

function Settings:CreateSettingsButton()
	DebugLog("Settings: Creating settings button")
	local button_atlas = "images/button_icons.xml"
	local button_tex = "configure_mod.tex"
	local button = Templates2.IconButton(button_atlas, button_tex, "", "", "", function()
		DebugLog("Settings button clicked")
		if self.parent_screen.sroot:IsVisible() then
			self:CloseMenu()
		else
			self:OpenMenu()
		end
	end)

	button:SetScale(0.5)

	button:SetOnGainFocus(function()
		self.parent_screen.tooltip_root:UpdatePosition(button, 0, -25)
		self.parent_screen.tooltip_root.tooltip:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.SETTINGS)
	end)

	button:SetOnLoseFocus(function()
		self.parent_screen.tooltip_root:HideTooltip(button)
	end)

	return button
end

return Settings
