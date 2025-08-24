local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local json = require("json")
local Image = require("widgets/image")
local Text = require("widgets/text")
local Templates2 = require("widgets/redux/templates")

local EntityAddMenu = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_ADD_MENU)
	self.parent_screen = context.screen
end)

function EntityAddMenu:CreateMenu()
	-- scoreboard_frame.tex -- scoreboard.xml
	self.menu_root = self:AddChild(Widget("MENU_ROOT"))
	self.menu_root:SetPosition(0, 0, 0)

	self.menu = self.menu_root:AddChild(Image("images/scoreboard.xml", "scoreboard_frame.tex"))
	self.menu:SetPosition(0, 0, 0)
	self.menu:SetScale(0.5)

	self.title = self.menu_root:AddChild(Text(NEWFONT_OUTLINE, 30))
	self.title:SetPosition(0, 120, 0)
	self.title:SetString("Add Entity")
	self.title:SetColour(unpack(GOLD))

	local textbox_width = 150
	local textbox_height = 30
	local textbox_font = NEWFONT
	local textbox_fontsize = 25
	local textbox_textlimit = 50

	-- code name
	self.code_name_input = self.menu_root:AddChild(
		Templates2.StandardSingleLineTextEntry(
			"",
			textbox_width,
			textbox_height,
			textbox_font,
			textbox_fontsize,
			"Code Name"
		)
	)
	self.code_name_input.textbox:SetTextLengthLimit(textbox_textlimit)
	self.code_name_input:SetPosition(0, 50, 0)

	-- custom name
	self.custom_name_input = self.menu_root:AddChild(
		Templates2.StandardSingleLineTextEntry(
			"",
			textbox_width,
			textbox_height,
			textbox_font,
			textbox_fontsize,
			"Custom Name"
		)
	)
	self.custom_name_input.textbox:SetTextLengthLimit(textbox_textlimit)
	self.custom_name_input:SetPosition(0, 0, 0)

	self.add_button = self.menu_root:AddChild(Templates2.StandardButton(function()
		-- self:CloseMenu()
		print("Added Entity To Menu")
	end, "Add Entity"))
	self.add_button:SetScale(0.4)
	self.add_button:SetPosition(0, -100, 0)

	self.exit_button = self.menu_root:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
	self.exit_button:SetOnClick(function()
		print("Closed Menu")
	end)
	self.exit_button:SetPosition(200, 120, 0)
	self.exit_button:SetScale(0.4)
end

return EntityAddMenu
