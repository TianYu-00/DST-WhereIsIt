-- DST Imports
local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Templates = require("widgets/templates")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")
local json = require("json")
-- My files imports
local EntityList = require("entitylist")
local EntityCell = require("widgets/entitycell")
local EntityInput = require("widgets/entityinput")
local EntitySearch = require("widgets/entitysearch")
local EntityAdd = require("widgets/entityadd")
local EntityFavourite = require("widgets/entityfavourite")

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
	Screen._ctor(self, "tian_whereisit_screen_mainmenu") -- screen name
	local GetTextStrings = require("strings/stringloader")
	local TextStrings = GetTextStrings()

	-- Dark background
	self.black = self:AddChild(Image("images/global.xml", "square.tex"))
	self.black:SetVRegPoint(ANCHOR_MIDDLE)
	self.black:SetHRegPoint(ANCHOR_MIDDLE)
	self.black:SetVAnchor(ANCHOR_MIDDLE)
	self.black:SetHAnchor(ANCHOR_MIDDLE)
	self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0, 0, 0, 0.75)

	-- Root container
	self.proot = self:AddChild(Widget("ROOT"))
	self.proot:SetVAnchor(ANCHOR_MIDDLE)
	self.proot:SetHAnchor(ANCHOR_MIDDLE)
	self.proot:SetPosition(0, 0, 0)
	self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	-- Main Background UI
	self.bg = self.proot:AddChild(Templates.CurlyWindow(400, 450, 1, 1, 68, -40)) -- sizeX, sizeY, scaleX, scaleY, topCrownOffset, bottomCrownOffset, xOffset
	self.bg:SetTint(1, 1, 1, 0.7)

	-- Title
	self.title = self.proot:AddChild(Text(NEWFONT_OUTLINE, 50))
	self.title:SetPosition(0, 250, 0)
	self.title:SetString(TextStrings.MOD_NAME)
	self.title:SetColour(unpack(GOLD))

	-- Input
	self.name_input = self.proot:AddChild(EntityInput({ screen = self }))
	self.name_input:SetPosition(180, 245, 0)

	-- Search
	self.name_search = self.proot:AddChild(EntitySearch({ screen = self }))
	self.name_search:SetPosition(275, 245, 0)

	-- Save
	self.name_add = self.proot:AddChild(EntityAdd({ screen = self }))
	self.name_add:SetPosition(315, 245, 0)

	-- Tooltip text, for my cells
	self.tooltip = self.proot:AddChild(Text(NEWFONT_OUTLINE, 15))
	self.tooltip:Hide()

	-- Initialize favourite list
	EntityFavourite:GetFavouritePersistentData(function(data)
		self.favourite_persist_data = data
	end)

	-- Initialize entity storage
	self.saved_entities = {}
	self.entity_list = {}

	-- Load saved entities and build initial list
	self:LoadSavedEntities()
end)

-- Persistent data functions
function WhereIsItMenuScreen:LoadSavedEntities()
	TheSim:GetPersistentString("tian_whereisit_persist_custom_entities", function(success, str)
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
	SavePersistentString("tian_whereisit_persist_custom_entities", json.encode(self.saved_entities), false)
end

function WhereIsItMenuScreen:RefreshEntityList()
	-- Combine default and saved entities
	self.master_entity_list = {}

	-- Add default entities
	for _, e in ipairs(EntityList) do
		table.insert(self.master_entity_list, e)
	end

	-- Add saved entities
	for _, e in ipairs(self.saved_entities) do
		table.insert(self.master_entity_list, e)
	end

	self.entity_list = {}

	-- Separate favourites and non-favourites
	local favourites = {}
	local non_favourites = {}

	for _, e in ipairs(self.master_entity_list) do
		if self.favourite_persist_data and self.favourite_persist_data[e.name] then
			table.insert(favourites, e)
		else
			table.insert(non_favourites, e)
		end
	end

	-- Put favourites first
	for _, e in ipairs(favourites) do
		table.insert(self.entity_list, e)
	end

	-- Then the rest
	for _, e in ipairs(non_favourites) do
		table.insert(self.entity_list, e)
	end

	self:CreateEntityList()
end

function WhereIsItMenuScreen:AddToEntityList(entity_name)
	if not entity_name or entity_name:match("^%s*$") then
		return
	end

	-- Clean up the input
	-- "^%s*(.-)%s*$" clears front and back whitespaces and keeps middle content
	entity_name = entity_name:lower():gsub("^%s*(.-)%s*$", "%1")

	-- Check for duplicates in saved entities
	for _, e in ipairs(self.saved_entities) do
		if e.name == entity_name then
			return
		end
	end

	-- new entity
	table.insert(self.saved_entities, {
		name = entity_name,
		icon_atlas = "images/scrapbook_icons3.xml",
		icon_tex = "unknown.tex",
		is_custom = true,
	})

	self:SaveEntities() -- save entity
	self:RefreshEntityList() -- refresh it

	-- Clear the input field
	self.name_input.textinput.textbox:SetString("")
end

function WhereIsItMenuScreen:RemoveEntity(entity_name)
	if not entity_name then
		return
	end

	for i, e in ipairs(self.saved_entities) do
		if e.name == entity_name then
			table.remove(self.saved_entities, i)
			break
		end
	end

	self:SaveEntities()
	self:RefreshEntityList()
end

function WhereIsItMenuScreen:FilterEntityList(search)
	local search_lower = search:lower():gsub("^%s*(.-)%s*$", "%1")
	self.entity_list = {}

	if search_lower == "" then
		-- Reset to full list
		for _, e in ipairs(self.master_entity_list) do
			table.insert(self.entity_list, e)
		end
	else
		for _, entity in ipairs(self.master_entity_list) do
			if entity.name:lower():find(search_lower, 1, true) then
				table.insert(self.entity_list, entity)
			end
		end
	end

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

	-- print("WhereIsIt: Create entity list Loaded entities (table dump) ->")
	-- dumptable(self.entity_list, 1, 1)

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
end

function WhereIsItMenuScreen:OnClose()
	if self.name_input.is_focus then
		return -- end function when its input focus
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
		self.name_input.is_focus = false
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
