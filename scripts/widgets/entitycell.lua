local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local EntityRemove = require("widgets/entityremove")
local EntitySelected = require("widgets/entityselected")
-- local EntityFavourite = require("widgets/entityfavourite")

local EntityCell = Class(Widget, function(self, context, index)
	Widget._ctor(self, "tian_whereisit_widget_entity_cell_" .. index)

	self.parent_screen = context.screen
	local cell_size = context.cell_size
	local base_size = context.base_size
	self.entity_index = index

	-- Root background with the white square
	self.cell_root = self:AddChild(ImageButton("images/global.xml", "square.tex"))
	self.cell_root:SetFocusScale(cell_size / base_size + 0.05, cell_size / base_size + 0.05)
	self.cell_root:SetNormalScale(cell_size / base_size, cell_size / base_size)

	-- Icon image
	self.icon = self.cell_root:AddChild(Image())

	-- Tooltip handling
	self.cell_root:SetOnGainFocus(function()
		if self.data then
			self:ShowTooltip()
		end
	end)

	self.cell_root:SetOnLoseFocus(function()
		self:HideTooltip()
	end)

	-- Click behavior
	self.cell_root:SetOnClick(function()
		if self.data then
			print("Image clicked! Index:", index, "name:", self.data.name)
			SendModRPCToServer(GetModRPC("WhereIsIt", "LocateEntity"), self.data.name, self.data.is_single)
			EntitySelected.name = self.data.name
			EntitySelected.is_single = self.data.is_single
			self.parent_screen:OnClose()
		end
	end)
end)

function EntityCell:SetData(data)
	self.data = data

	-- Clean up old buttons
	if self.entity_remove then
		self.entity_remove:Kill()
		self.entity_remove = nil
	end

	if not data then
		self.icon:SetScale(0, 0)
		if self.cell_root.image then
			self.cell_root.image:SetTint(0.3, 0.3, 0.3, 0.3)
		end
		self:Disable()
		return
	end

	-- Valid data
	self.icon:SetTexture(data.icon_atlas or "images/global.xml", data.icon_tex or "square.tex")
	self.icon:SetScale(0.52)
	if self.cell_root.image then
		self.cell_root.image:SetTint(1, 1, 1, 1)
	end

	-- Remove button for custom entities
	if data.is_custom then
		self.entity_remove = self:AddChild(EntityRemove({
			screen = self,
			data = data,
			main_parent_screen = self.parent_screen,
			index = self.entity_index,
		}))
		self.entity_remove:SetPosition(20, -18, 0)
	end

	-- Favourite button
	-- self.entity_favourite_root = self:AddChild(EntityFavourite({
	--     screen = self,
	--     data = data,
	--     main_parent_screen = self.parent_screen,
	--     index = self.entity_index,
	-- }))

	self:Enable()
end

function EntityCell:ShowTooltip()
	local function UpdateTooltipPosition()
		local x, y = self:GetPosition():Get()
		local parent = self:GetParent()
		while parent and parent ~= self.parent_screen.proot do
			local px, py = parent:GetPosition():Get()
			x = x + px
			y = y + py
			parent = parent:GetParent()
		end
		self.parent_screen.tooltip:SetString(self.data.name)
		self.parent_screen.tooltip:SetPosition(x, y - 40, 0)
		self.parent_screen.tooltip:MoveToFront()
		self.parent_screen.tooltip:Show()
	end

	UpdateTooltipPosition()
	self.tooltip_task = self.parent_screen.inst:DoPeriodicTask(0.05, UpdateTooltipPosition)
end

function EntityCell:HideTooltip()
	self.parent_screen.tooltip:Hide()
	if self.tooltip_task then
		self.tooltip_task:Cancel()
		self.tooltip_task = nil
	end
end

return EntityCell
