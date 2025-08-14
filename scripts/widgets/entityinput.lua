local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Templates = require("widgets/templates")
local Templates2 = require("widgets/redux/templates")

local EntityInput = Class(Widget, function(self, context)
	Widget._ctor(self, "entity-input")
	local GetTextStrings = require("strings/stringloader")
	local TextStrings = GetTextStrings()

	self.parent_screen = context.screen

	local textbox_width = 150
	local textbox_height = 30
	local textbox_font = NEWFONT
	local textbox_fontsize = 25
	local textbox_placeholder = TextStrings.ENTITY_INPUT_PLACEHOLDER
	local textbox_textlimit = 50

	-- fieldtext, width_field, height, font, font_size, prompt_text
	-- redux templates.lua line 1077
	self.textinput = self:AddChild(
		Templates2.StandardSingleLineTextEntry(
			"",
			textbox_width,
			textbox_height,
			textbox_font,
			textbox_fontsize,
			textbox_placeholder
		)
	)
	self.textinput.textbox:SetTextLengthLimit(textbox_textlimit)

	self.textinput.textbox.OnTextInputted = function()
		self.parent_screen:FilterEntityList(self.textinput.textbox:GetString())
	end

	self.is_focus = false

	self.textinput:SetOnGainFocus(function()
		self.is_focus = true
	end)

	self.textinput:SetOnLoseFocus(function()
		self.is_focus = false
	end)
end)

return EntityInput
