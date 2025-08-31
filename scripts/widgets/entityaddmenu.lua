local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local json = require("json")
local Image = require("widgets/image")
local Text = require("widgets/text")
local Templates2 = require("widgets/redux/templates")
local DebugLog = require("utils/debug")

local EntityAddMenu = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_ADD_MENU)
	self.parent_screen = context.screen
	DebugLog("EntityAddMenu: Initialized")
end)

function EntityAddMenu:CreateMenu()
	DebugLog("EntityAddMenu: Creating Menu")

	self.menu_root = self:AddChild(Widget("MENU_ROOT"))
	self.menu_root:SetPosition(0, 0, 0)

	self.background_button = self.menu_root:AddChild(ImageButton("images/global.xml", "square.tex"))
	self.background_button.image:SetHAnchor(ANCHOR_MIDDLE)
	self.background_button.image:SetVAnchor(ANCHOR_MIDDLE)
	self.background_button.image:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.background_button.image:SetHRegPoint(ANCHOR_MIDDLE)
	self.background_button.image:SetVRegPoint(ANCHOR_MIDDLE)
	self.background_button.image:SetTint(0, 0, 0, 0.3)
	self.background_button:SetOnClick(function()
		DebugLog("Background clicked: Closing Menu")
		self:CloseMenu()
	end)

	self.menu = self.menu_root:AddChild(Image("images/scoreboard.xml", "scoreboard_frame.tex"))
	self.menu:SetPosition(0, 0, 0)
	self.menu:SetScale(0.5)

	self.title = self.menu_root:AddChild(Text(NEWFONT_OUTLINE, 30))
	self.title:SetPosition(0, 120, 0)
	self.title:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.ADD_ENTITY)
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
			TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.ENTITY_ADD_INPUT_PLACEHOLDER
		)
	)
	self.code_name_input.textbox:SetTextLengthLimit(textbox_textlimit)
	self.code_name_input:SetPosition(0, 50, 0)
	self.code_name_input.textbox:SetOnGainFocus(function()
		self.parent_screen.focused_input_widget = self.code_name_input
		DebugLog("Code Name Input: Gained Focus")
	end)

	-- custom name
	self.custom_name_input = self.menu_root:AddChild(
		Templates2.StandardSingleLineTextEntry(
			"",
			textbox_width,
			textbox_height,
			textbox_font,
			textbox_fontsize,
			TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.ENTITY_ADD_CUSTOM_PLACEHOLDER
		)
	)
	self.custom_name_input.textbox:SetTextLengthLimit(textbox_textlimit)
	self.custom_name_input:SetPosition(0, 0, 0)
	self.custom_name_input:SetOnGainFocus(function()
		self.parent_screen.focused_input_widget = self.custom_name_input
		DebugLog("Custom Name Input: Gained Focus")
	end)

	self.add_button = self.menu_root:AddChild(Templates2.StandardButton(function()
		local code_name = self.code_name_input.textbox:GetString()
		local custom_name = self.custom_name_input.textbox:GetString()
		DebugLog("Add Button Clicked: code_name=" .. tostring(code_name) .. ", custom_name=" .. tostring(custom_name))
		self:AddToEntityList(code_name, custom_name)
	end, TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.SAVE))
	self.add_button:SetScale(0.4)
	self.add_button:SetPosition(0, -100, 0)

	self.exit_button = self.menu_root:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
	self.exit_button:SetOnClick(function()
		DebugLog("Exit Button Clicked: Closing Menu")
		self:CloseMenu()
	end)
	self.exit_button:SetPosition(200, 120, 0)
	self.exit_button:SetScale(0.4)

	self.select_button = self.menu_root:AddChild(Templates2.IconButton("images/servericons.xml", "search.tex"))
	self.select_button:SetOnClick(function()
		DebugLog("Select Button Clicked")
		self:StartSelect()
	end)
	self.select_button:SetPosition(90, 50, 0)
	self.select_button:SetScale(0.4)

	self.select_button:SetOnGainFocus(function()
		self.parent_screen.tooltip_root:UpdatePosition(self.select_button, 0, -25)
		self.parent_screen.tooltip_root.tooltip:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.SELECT_ENTITY)
		DebugLog("Tooltip shown for Select button")
	end)

	self.select_button:SetOnLoseFocus(function()
		self.parent_screen.tooltip_root:HideTooltip(self.select_button)
		DebugLog("Tooltip hidden for Select button")
	end)

	DebugLog("EntityAddMenu: Menu Created")
end

function EntityAddMenu:StartSelect()
	DebugLog("EntityAddMenu: Started Selection")
	self.parent_screen.proot:Hide()
	self.parent_screen.sroot:Hide()
	self.parent_screen.croot:Show()
	self.parent_screen.background_button:Hide()

	TIAN_WHEREISIT_GLOBAL_FUNCTION.TOGGLE_PAUSE(false)

	self.parent_screen.croot_description:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.ADD_MENU_SELECT_COMMENT)

	self.alt_click_handler = TheInput:AddMouseButtonHandler(function(button, down, x, y)
		-- See entity code name
		if down and button == MOUSEBUTTON_LEFT and TheInput:IsKeyDown(KEY_LALT) or TheInput:IsKeyDown(KEY_RALT) then
			local target = TheInput:GetWorldEntityUnderMouse()
			if target and target.prefab then
				if ThePlayer.components.talker then
					ThePlayer.components.talker:Say(target.prefab or "")
				end
				DebugLog(target.prefab)
			end
		end

		-- select entity
		if down and button == MOUSEBUTTON_RIGHT and TheInput:IsKeyDown(KEY_LALT) or TheInput:IsKeyDown(KEY_RALT) then
			local target = TheInput:GetWorldEntityUnderMouse()
			if target and target.prefab then
				DebugLog(target.prefab)
				self.code_name_input.textbox:SetString(target.prefab or "")
				self:EndSelect()
			end
		end
	end)

	self.q_key_handler = TheInput:AddKeyUpHandler(KEY_Q, function()
		self:EndSelect()
	end)
end

function EntityAddMenu:EndSelect()
	DebugLog("EntityAddMenu: Started Selection")
	self.parent_screen.proot:Show()
	self.parent_screen.sroot:Show()
	self.parent_screen.croot:Hide()
	self.parent_screen.background_button:Show()

	TIAN_WHEREISIT_GLOBAL_FUNCTION.TOGGLE_PAUSE(true)

	TheInput.onmousebutton:RemoveHandler(self.alt_click_handler)
	self.alt_click_handler = nil
	TheInput.onkeyup:RemoveHandler(self.q_key_handler)
	self.q_key_handler = nil
end

function EntityAddMenu:AddToEntityList(code_name, custom_name)
	if not code_name or code_name:match("^%s*$") then
		DebugLog("AddToEntityList: Invalid code_name, skipping")
		return
	end
	code_name = code_name:lower():gsub("^%s*(.-)%s*$", "%1")
	DebugLog("AddToEntityList: Processing entity " .. code_name .. " with custom name " .. tostring(custom_name))

	local function Finalize()
		self.parent_screen:SaveEntities()
		self.parent_screen:RefreshEntityList()
		self.parent_screen.name_input:ClearText()
		self:CloseMenu()
		DebugLog("AddToEntityList: Finalized entity addition for " .. code_name)
	end

	-- Check for duplicates in saved entities
	for i, e in ipairs(self.parent_screen.saved_entities) do
		if e.name == code_name then
			DebugLog("AddToEntityList: Found duplicate for " .. code_name .. ", replacing")
			self.parent_screen.saved_entities[i] = {
				name = code_name,
				icon_atlas = "images/scrapbook.xml",
				icon_tex = "inv_item_background.tex",
				is_custom = true,
				custom_name = custom_name,
			}

			Finalize()
			return
		end
	end

	-- new entity
	table.insert(self.parent_screen.saved_entities, {
		name = code_name,
		icon_atlas = "images/scrapbook.xml",
		icon_tex = "inv_item_background.tex",
		is_custom = true,
		custom_name = custom_name,
	})
	DebugLog("AddToEntityList: Added new entity " .. code_name)

	Finalize()
end

function EntityAddMenu:OpenMenu()
	self.parent_screen.addmenu_root:MoveToFront()
	self.menu_root:Show()
	DebugLog("EntityAddMenu: Opened Menu")
end

function EntityAddMenu:CloseMenu()
	self.menu_root:Hide()
	self.code_name_input.textbox:SetString("")
	self.custom_name_input.textbox:SetString("")
	DebugLog("EntityAddMenu: Closed Menu")
end

return EntityAddMenu
