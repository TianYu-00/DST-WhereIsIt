-- DST Imports
local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Templates = require("widgets/templates")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")
local json = require("json")
local ImageButton = require("widgets/imagebutton")
local Image = require("widgets/image")
-- My files imports
local EntityList = require("entitylist")
local EntityCell = require("widgets/entitycell")
local EntityInput = require("widgets/entityinput")
local EntitySearch = require("widgets/entitysearch")
local EntityAdd = require("widgets/entityadd")
local EntityFavourite = require("widgets/entityfavourite")
local EntityHide = require("widgets/entityhide")
local Tooltip = require("widgets/tooltip")
local Settings = require("widgets/settings")
local AddMenu = require("widgets/entityaddmenu")

-- Assets
-- NOTE: USE SCRAPBOOK ICONS INSTEAD!! databundles/images/images/scrapbook_icons1 2 and 3
-- Change images-backup folder to images and uncomment this section here only if dst changed its scrapbook icons to something completely different or no longer match my entity name, atlas and tex.
-- This will save about 16mb when not using it
-- Assets = {
-- 	Asset("ATLAS", "images/scrapbook_icons1.xml"),
-- 	Asset("IMAGE", "images/scrapbook_icons1.tex"),

-- 	Asset("ATLAS", "images/scrapbook_icons2.xml"),
-- 	Asset("IMAGE", "images/scrapbook_icons2.tex"),

-- 	Asset("ATLAS", "images/scrapbook_icons3.xml"),
-- 	Asset("IMAGE", "images/scrapbook_icons3.tex"),
-- }

local WhereIsItMenuScreen = Class(Screen, function(self, inst)
	self.inst = inst
	self.tasks = {}
	Screen._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.SCREEN_MAIN) -- screen name

	----------------------------------- creating the base menu ui
	-- Dark background
	self.black = self:AddChild(Image("images/global.xml", "square.tex"))
	self.black:SetVRegPoint(ANCHOR_MIDDLE)
	self.black:SetHRegPoint(ANCHOR_MIDDLE)
	self.black:SetVAnchor(ANCHOR_MIDDLE)
	self.black:SetHAnchor(ANCHOR_MIDDLE)
	self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0, 0, 0, 0.75)

	self.background_button = self:AddChild(ImageButton("images/global.xml", "square.tex"))
	self.background_button.image:SetHAnchor(ANCHOR_MIDDLE)
	self.background_button.image:SetVAnchor(ANCHOR_MIDDLE)
	self.background_button.image:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.background_button.image:SetHRegPoint(ANCHOR_MIDDLE)
	self.background_button.image:SetVRegPoint(ANCHOR_MIDDLE)
	self.background_button.image:SetTint(0, 0, 0, 0.75)
	self.background_button:SetOnClick(function()
		self:OnClose()
	end)

	-- Root container
	self.proot = self:AddChild(Widget("ROOT"))
	self.proot:SetVAnchor(ANCHOR_MIDDLE)
	self.proot:SetHAnchor(ANCHOR_MIDDLE)
	self.proot:SetPosition(0, 0, 0)
	self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	-- Settings menu container
	self.sroot = self:AddChild(Widget("SETTINGS_ROOT"))
	self.sroot:SetVAnchor(ANCHOR_MIDDLE)
	self.sroot:SetHAnchor(ANCHOR_MIDDLE)
	self.sroot:SetPosition(0, 0, 0)
	self.sroot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	-- Main Background UI
	self.bg = self.proot:AddChild(Templates.CurlyWindow(400, 450, 1, 1, 68, -40)) -- sizeX, sizeY, scaleX, scaleY, topCrownOffset, bottomCrownOffset, xOffset
	self.bg:SetTint(1, 1, 1, 0.7)

	-- Title
	self.title = self.proot:AddChild(Text(NEWFONT_OUTLINE, 50))
	self.title:SetPosition(0, 250, 0)
	self.title:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.MOD_NAME)
	self.title:SetColour(unpack(GOLD))

	----------------------------------- create scroll list

	self.scroll_list = nil

	-- Initialize entity storage
	self.saved_entities = {}
	self.entity_list = {}

	-- Load saved entities and build initial list
	self:LoadSavedEntities()

	----------------------------------- creating the base interactions

	-- Input focus
	self.focused_input_widget = nil

	-- Input
	self.name_input = self.proot:AddChild(EntityInput({ screen = self }))
	self.name_input:SetPosition(180, 245, 0)

	-- Search
	self.name_search = self.proot:AddChild(EntitySearch({ screen = self }))
	self.name_search:Hide()
	-- self.name_search:SetPosition(275, 245, 0)

	-- Save
	self.name_add = self.proot:AddChild(EntityAdd({ screen = self }))
	self.name_add:SetPosition(275, 245, 0)

	self.tooltip_root = self.proot:AddChild(Tooltip({ screen = self }))

	self.title = self.proot:AddChild(Text(NEWFONT, 20))
	self.title:SetPosition(0, -240, 0)
	self.title:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.INTERACTION_HELPER)

	----------------------------------- Settings menu
	self.sroot:Hide()
	self.settings_root = self.sroot:AddChild(Settings({ screen = self }))
	self.settings_root:CreateMenu()
	self.settings_button = self.proot:AddChild(self.settings_root:CreateSettingsButton())
	self.settings_button:SetPosition(310, 245, 0)

	----------------------------------- Category
	-- Tables for each category
	self.all_entities = {}
	self.favourite_entities = {}
	self.hidden_entities = {}

	-- default
	self.default_button = self.proot:AddChild(
		Templates2.IconButton("images/crafting_menu_icons.xml", "filter_none.tex", "", "", "", function()
			self:SetCategory("default")
		end)
	)
	self.default_button:SetPosition(-250, 245)
	self.default_button:SetScale(0.5)

	self.default_button:SetOnGainFocus(function()
		self.tooltip_root:UpdatePosition(self.default_button, 0, -25)
		self.tooltip_root.tooltip:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.DEFAULT)
	end)

	self.default_button:SetOnLoseFocus(function()
		self.tooltip_root:HideTooltip(self.default_button)
	end)

	-- favourite
	self.fav_button = self.proot:AddChild(
		Templates2.IconButton("images/crafting_menu_icons.xml", "filter_favorites.tex", "", "", "", function()
			self:SetCategory("favourite")
		end)
	)
	self.fav_button:SetPosition(-210, 245)
	self.fav_button:SetScale(0.5)

	self.fav_button:SetOnGainFocus(function()
		self.tooltip_root:UpdatePosition(self.fav_button, 0, -25)
		self.tooltip_root.tooltip:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.FAVOURITE)
	end)

	self.fav_button:SetOnLoseFocus(function()
		self.tooltip_root:HideTooltip(self.fav_button)
	end)

	-- hidden
	self.hidden_button = self.proot:AddChild(
		Templates2.IconButton("images/crafting_menu_icons.xml", "station_hermitcrab_shop.tex", "", "", "", function()
			self:SetCategory("hidden")
		end)
	)
	self.hidden_button:SetPosition(-170, 245)
	self.hidden_button:SetScale(0.5)

	self.hidden_button:SetOnGainFocus(function()
		self.tooltip_root:UpdatePosition(self.hidden_button, 0, -25)
		self.tooltip_root.tooltip:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.HIDDEN)
	end)

	self.hidden_button:SetOnLoseFocus(function()
		self.tooltip_root:HideTooltip(self.hidden_button)
	end)

	-- custom
	self.custom_button = self.proot:AddChild(
		Templates2.IconButton("images/crafting_menu_icons.xml", "filter_modded.tex", "", "", "", function()
			self:SetCategory("custom")
		end)
	)
	self.custom_button:SetPosition(-130, 245)
	self.custom_button:SetScale(0.5)

	self.custom_button:SetOnGainFocus(function()
		self.tooltip_root:UpdatePosition(self.custom_button, 0, -25)
		self.tooltip_root.tooltip:SetString(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.CUSTOM)
	end)

	self.custom_button:SetOnLoseFocus(function()
		self.tooltip_root:HideTooltip(self.custom_button)
	end)

	self:InitCategoryAfterAsyncLoad()

	----------------------------------- Add Menu
	self.addmenu_root = self.proot:AddChild(AddMenu({ screen = self }))
	self.addmenu_root:CreateMenu()
	self.addmenu_root:CloseMenu()
	self.addmenu_root:SetPosition(0, 0, 0)
end)

function WhereIsItMenuScreen:InitCategoryAfterAsyncLoad()
	local fav_loaded, hidden_loaded = false, false

	local function tryRefresh()
		if fav_loaded and hidden_loaded then
			self.current_category = "default"
			self:RefreshEntityList()
		end
	end

	EntityFavourite:GetFavouritePersistentData(function(data)
		self.favourite_persist_data = data
		fav_loaded = true
		tryRefresh()
	end)

	EntityHide:GetHiddenPersistentData(function(data)
		self.hidden_persist_data = data
		hidden_loaded = true
		tryRefresh()
	end)
end

function WhereIsItMenuScreen:SetCategory(category)
	local valid_categories = {
		default = true,
		favourite = true,
		hidden = true,
		custom = true,
	}

	if valid_categories[category] then
		self.current_category = category
		self:RefreshEntityList()
	end
end

function WhereIsItMenuScreen:LoadSavedEntities()
	TheSim:GetPersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_CUSTOM_ENTITIES, function(success, str)
		if success and str ~= nil and str ~= "" then
			local ok, data = pcall(json.decode, str)
			if ok and data then
				self.saved_entities = data
			else
				print("WhereIsIt: Failed to decode saved entities")
			end
		else
			print("WhereIsIt: No saved entities found")
		end
		self:RefreshEntityList()
	end)
end

function WhereIsItMenuScreen:SaveEntities()
	SavePersistentString(
		TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_CUSTOM_ENTITIES,
		json.encode(self.saved_entities),
		false
	)
end

function WhereIsItMenuScreen:RefreshEntityList()
	-- Combine default and saved entities
	self.master_entity_list = {}
	for _, e in ipairs(EntityList) do
		table.insert(self.master_entity_list, e)
	end
	for _, e in ipairs(self.saved_entities) do
		table.insert(self.master_entity_list, e)
	end

	-- Reset category tables
	self.default_entities = {}
	self.favourite_entities = {}
	self.hidden_entities = {}
	self.custom_entities = {}

	local fav_data = self.favourite_persist_data or {}
	local hidden_data = self.hidden_persist_data or {}

	local function insertFavFirst(list, entity, is_fav)
		if is_fav then
			table.insert(list, 1, entity)
		else
			table.insert(list, entity)
		end
	end

	for _, e in ipairs(self.master_entity_list) do
		local is_fav = fav_data[e.name] or false
		local is_hidden = hidden_data[e.name] or false
		local is_custom = e.is_custom or false

		-- Normal category: non-hidden
		if not is_hidden then
			insertFavFirst(self.default_entities, e, is_fav)
		end

		-- Favourites category
		if is_fav then
			table.insert(self.favourite_entities, e)
		end

		-- Hidden category
		if is_hidden then
			insertFavFirst(self.hidden_entities, e, is_fav)
		end

		-- Custom category
		if is_custom then
			insertFavFirst(self.custom_entities, e, is_fav)
		end
	end

	-- Set the entity list for the current category
	self.entity_list = self.current_category == "default" and self.default_entities
		or self.current_category == "favourite" and self.favourite_entities
		or self.current_category == "hidden" and self.hidden_entities
		or self.current_category == "custom" and self.custom_entities

	self:CreateEntityList()
end

function WhereIsItMenuScreen:CreateEntityList()
	if self.scroll_list then
		self.scroll_list:Kill()
		self.scroll_list = nil
	end

	-- Grid parameters
	local cell_size = 70
	local base_size = 70
	local row_spacing = 10
	local col_spacing = 10

	-- Create scrolling grid
	-- refer to redux templates.lua line 1961 and cookbookpage_crockpot.lua line 540
	self.scroll_list = self.proot:AddChild(Templates2.ScrollingGrid(self.entity_list, {
		scroll_context = { screen = self, cell_size = cell_size, base_size = base_size },
		widget_width = cell_size + col_spacing,
		widget_height = cell_size + row_spacing,
		force_peek = true,
		num_visible_rows = 5,
		num_columns = 7,
		item_ctor_fn = function(context, index)
			return EntityCell(context, index)
		end,
		apply_fn = function(context, widget, data, index)
			widget:SetData(data)
		end,
		scrollbar_offset = 20,
		scrollbar_height_offset = -60,
	}))
	self.scroll_list:SetPosition(0, 0, 0)
	-- self.scroll_list:MoveToBack()
end

function WhereIsItMenuScreen:OnClose()
	if
		self.focused_input_widget
		and self.focused_input_widget.textbox
		and self.focused_input_widget.textbox.editing
	then
		return
	end

	-- Cancel any started tasks
	-- This prevents stale components
	for k, task in pairs(self.tasks) do
		if task then
			task:Cancel()
		end
	end
	local screen = TheFrontEnd:GetActiveScreen()
	if screen and screen.name:find("HUD") == nil then
		-- Remove my screen only not hud
		TheFrontEnd:PopScreen()
	end
end

function WhereIsItMenuScreen:OnControl(control, down)
	-- Sends clicks to the screen
	if WhereIsItMenuScreen._base.OnControl(self, control, down) then
		return true
	end
	-- Close UI on ESC
	if not down and (control == CONTROL_PAUSE or control == CONTROL_CANCEL) then
		self.focused_input_widget = nil
		self:OnClose()
		return true
	end
end

----------------------------------- Debug -----------------------------------

function WhereIsItMenuScreen:SetDebugMode(state)
	self.debug_mode = state
	if state and not self.debug_elements then
		self.debug_elements = true
		self:SetupDebugElements()
	end
end

function WhereIsItMenuScreen:SetupDebugElements()
	-- y animation
	self.animationUp = self.proot:AddChild(Text(NEWFONT_OUTLINE, 30, "Y: ", { unpack(RED) }))
	self.animationUp:SetPosition(-520, -350)
	-- Assign the task to the client
	self.tasks[#self.tasks + 1] = self.inst:DoPeriodicTask(0.1, function()
		local pos = self.animationUp:GetPosition()
		self.animationUp:SetPosition(pos.x, pos.y > 350 and -350 or pos.y + 5)
		self.animationUp:SetString("Y: " .. pos.y)
	end)
	-- x animation
	self.animationRight = self.proot:AddChild(Text(NEWFONT_OUTLINE, 30, "X: ", { unpack(RED) }))
	self.animationRight:SetPosition(-600, -290)
	-- Assign the task to the client
	self.tasks[#self.tasks + 1] = self.inst:DoPeriodicTask(0.1, function()
		local pos = self.animationRight:GetPosition()
		self.animationRight:SetPosition(pos.x > 600 and -600 or pos.x + 5, pos.y)
		self.animationRight:SetString("X: " .. pos.x)
	end)
end

return WhereIsItMenuScreen

----------------------------------- Comments -----------------------------------

-- bigpopupdialog.lua shows the basics to creating ui
-- templates.lua line 593 for CurlyWindow
