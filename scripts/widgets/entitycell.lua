local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local EntityRemove = require("widgets/entityremove")
local EntitySelected = require("widgets/entityselected")
local EntityFavourite = require("widgets/entityfavourite")
local Text = require("widgets/text")

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

	-- Tooltip handling
	self.cell_root:SetOnGainFocus(function()
		if self.data then
			self.parent_screen.tooltip_root:UpdatePosition(self.cell_root, 0, -40)
			self.parent_screen.tooltip_root.tooltip:SetString(self.data.name)
		end
	end)

	self.cell_root:SetOnLoseFocus(function()
		self.parent_screen.tooltip_root:HideTooltip(self.cell_root)
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

	-- -- Clean up old buttons
	-- if self.entity_remove then
	-- 	self.entity_remove:Kill()
	-- 	self.entity_remove = nil
	-- end

	-- if self.entity_favourite_root then
	-- 	self.entity_favourite_root:Kill()
	-- 	self.entity_favourite_root = nil
	-- end

	if self.custom_name then
		self.custom_name:Kill()
		self.custom_name = nil
	end

	if self.icon then
		self.icon:Kill()
		self.icon = nil
	end

	if not data then
		if self.cell_root.image then
			self.cell_root.image:SetTint(0.3, 0.3, 0.3, 0.3)
		end
		self:Disable()
		return
	end

	-- Valid data
	self.icon = self.cell_root:AddChild(Image())
	self.icon:SetTexture(data.icon_atlas or "images/global.xml", data.icon_tex or "square.tex")
	self.icon:ScaleToSize(63, 63)
	-- self.icon:SetScale(0.52)
	if self.cell_root.image then
		self.cell_root.image:SetTint(1, 1, 1, 1)
	end

	-- Remove button for custom entities
	if data.is_custom then
		self.custom_name = self:AddChild(Text(NEWFONT_OUTLINE, 20))
		self.custom_name:SetRegionSize(60, 60)
		self.custom_name:SetPosition(1, 0, 0)
		self.custom_name:EnableWordWrap(true)
		self.custom_name:SetString(data.name)

		-- self.entity_remove = self:AddChild(EntityRemove({
		-- 	screen = self,
		-- 	data = data,
		-- 	main_parent_screen = self.parent_screen,
		-- 	index = self.entity_index,
		-- }))
		-- self.entity_remove:SetPosition(20, -18, 0)
	end

	-- -- Favourite button
	-- self.entity_favourite_root = self:AddChild(EntityFavourite({
	-- 	screen = self,
	-- 	data = data,
	-- 	main_parent_screen = self.parent_screen,
	-- 	index = self.entity_index,
	-- }))
	-- self.entity_favourite_root:SetPosition(20, 18, 0)

	self:Enable()
end

return EntityCell
