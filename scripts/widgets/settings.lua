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

local Settings = Class(Widget, function(self, context)
	Widget._ctor(self, "tian_whereisit_widget_settings")
	self.parent_screen = context.screen
	self.is_open = false
	self.settings_data = nil
	self.menu_container = self:AddChild(Widget("settings_menu_container"))
	self.menu_container:Hide()
end)

function Settings:CreateMenu()
	self.bg = self.menu_container:AddChild(Templates.CurlyWindow(400, 450, 1, 1, 68, -40))
	self.bg:SetTint(1, 1, 1, 0.7)

	self.save_button = self.menu_container:AddChild(Templates2.StandardButton(function()
		self:SaveSettings()
	end, "Save"))
	self.save_button:SetScale(0.4)
	self.save_button:SetPosition(-150, -200, 0)

	self.reset_button = self.menu_container:AddChild(Templates2.StandardButton(function()
		self.settings_data = nil
		self.spinner_container:Kill()
		self:CreateSpinner()
	end, "Reset"))
	self.reset_button:SetScale(0.4)
	self.reset_button:SetPosition(0, -200, 0)

	self.back_button = self.menu_container:AddChild(Templates2.StandardButton(function()
		self:CloseMenu()
	end, "Back"))
	self.back_button:SetScale(0.4)
	self.back_button:SetPosition(150, -200, 0)

	self.title = self.menu_container:AddChild(Text(NEWFONT_OUTLINE, 50))
	self.title:SetPosition(0, 250, 0)
	self.title:SetString("Settings")
	self.title:SetColour(unpack(GOLD))

	self.description_background = self.menu_container:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	self.description_background:SetPosition(0, 130, 0)
	self.description_background:SetScale(0.5, 1)
	self.description_background:SetTint(1, 1, 1, 1)

	self.description = self.menu_container:AddChild(Text(NEWFONT, 20))
	self.description:SetPosition(0, 180, 0)
	self.description:SetString(
		"All settings are saved across servers, remember to press save to save your new key binds"
	)
	self.description:SetColour(unpack(WHITE))
	self.description:SetRegionSize(400, 90)
	self.description:EnableWordWrap(true)

	self:CreateSpinner()
end

function Settings:GetSettings()
	TheSim:GetPersistentString("tian_whereisit_persist_settings", function(success, str)
		if not success or str == nil or str == "" then
			-- No file or empty, write defaults
			self.settings_data = deepcopy(DefaultSettings) -- deepcopy check util.lua line 905
			SavePersistentString("tian_whereisit_persist_settings", json.encode(self.settings_data), false)
		else
			-- Try decode
			local ok, data = pcall(json.decode, str)
			if ok and data then
				self.settings_data = data
			else
				print("Failed to decode settings, resetting to defaults")
				self.settings_data = deepcopy(DefaultSettings)
				SavePersistentString("tian_whereisit_persist_settings", json.encode(self.settings_data), false)
			end
		end
	end)
end

function Settings:SaveSettings()
	if self.settings_data then
		SavePersistentString("tian_whereisit_persist_settings", json.encode(self.settings_data), false)
		-- local inspect = require("inspect")
		-- print("Current settings:", inspect(self.settings_data))
		TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS = self.settings_data
		TIAN_WHEREISIT_GLOBAL_FUNCTION.UpdateKeyBindings()
	else
		print("No settings_data to save, writing defaults")
		self.settings_data = deepcopy(DefaultSettings)
		SavePersistentString("tian_whereisit_persist_settings", json.encode(self.settings_data), false)
	end
end

function Settings:CreateSpinner()
	self:GetSettings()

	self.spinner_container = self.menu_container:AddChild(Widget("spinner_container"))
	self.spinner_container:SetPosition(0, 100, 0)

	-- Menu Key
	self.menu_key_spinner = self.spinner_container:AddChild(SettingsSpinner({ screen = self }, {
		label = "Menu Key",
		description = "Used to open/close the mod menu",
		description_widget = self.description,
		options = CustomKeyList,
		default = self.settings_data.MENU_KEY,
		on_changed = function(value)
			print("Menu key changed to:", value)
			self.settings_data.MENU_KEY = value
		end,
		width = 300,
		height = 30,
	}))
	self.menu_key_spinner:SetPosition(0, 0)

	-- Repeat Key
	self.repeat_key_spinner = self.spinner_container:AddChild(SettingsSpinner({ screen = self }, {
		label = "Repeat Key",
		description = "Repeat Last Lookup",
		description_widget = self.description,
		options = CustomKeyList,
		default = self.settings_data.REPEAT_LOOKUP_KEY,
		on_changed = function(value)
			print("Repeat key changed to:", value)
			self.settings_data.REPEAT_LOOKUP_KEY = value
		end,
	}))
	self.repeat_key_spinner:SetPosition(0, -50)
end

function Settings:OpenMenu()
	self.is_open = true
	self.parent_screen.proot:Hide()
	self.parent_screen.sroot:Show()
	self.menu_container:Show()
	self.menu_container:MoveToFront()

	if self.spinner_container then
		self.spinner_container:Kill()
	end
	self:CreateSpinner()
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
