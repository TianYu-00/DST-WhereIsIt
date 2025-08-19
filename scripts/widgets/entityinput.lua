local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")
local EntitySearch = require("widgets/entitysearch")

local EntityInput = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_INPUT)
	self.parent_screen = context.screen

	local textbox_width = 150
	local textbox_height = 30
	local textbox_font = NEWFONT
	local textbox_fontsize = 25
	local textbox_placeholder = TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.ENTITY_INPUT_PLACEHOLDER
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
		if self.parent_screen and self.parent_screen.name_search then
			self.parent_screen.name_search:FilterEntityList(self.textinput.textbox:GetString())
		end
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
