-- DST Imports
local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Templates = require("widgets/templates")
local Templates2 = require("widgets/redux/templates")
local Text = require("widgets/text")
local ImageButton = require("widgets/imagebutton")
-- My files imports
local EntityList = require("entitylist")
local EntityCell = require("widgets/entitycell")
local EntityInput = require("widgets/entityinput")

-- Assets
-- NOTE: USE SCRAPBOOK ICONS INSTEAD!! databundles/images/images/scrapbook_icons1 2 and 3
Assets = {
	Asset("ATLAS", "images/worldgen_customization.xml"), -- taken from data/images
	Asset("IMAGE", "images/worldgen_customization.tex"), -- taken from data/images

	Asset("ATLAS", "images/worldsettings_customization.xml"), -- taken from data/images
	Asset("IMAGE", "images/worldsettings_customization.tex"), -- taken from data/images
}

local WhereIsItMenuScreen = Class(Screen, function(self, inst)
	self.inst = inst
	self.tasks = {}
	Screen._ctor(self, "WhereIsItMenuScreen") -- screen name
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

	-- Title
	self.title = self.proot:AddChild(Text(NEWFONT_OUTLINE, 50))
	self.title:SetPosition(0, 250, 0)
	-- self.title:SetString("Where is it")
	self.title:SetString(TextStrings.MOD_NAME)
	self.title:SetColour(unpack(GOLD))

	-- Input
	self.name_input = self.proot:AddChild(EntityInput({ screen = self }))
	self.name_input:SetPosition(180, 245, 0)

	-- Tooltip text, for my cells
	self.tooltip = self.proot:AddChild(Text(NEWFONT_OUTLINE, 15))
	self.tooltip:Hide()

	-- Grid parameters
	local cell_size = 70
	local base_size = 70
	local row_spacing = 10
	local col_spacing = 10

	-- Create scrolling grid
	-- refer to redux templates.lua line 1961 and cookbookpage_crockpot.lua line 540
	self.scroll_list = self.proot:AddChild(Templates2.ScrollingGrid(EntityList, {
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
end)

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
