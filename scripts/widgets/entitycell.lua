local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local EntityRemove = require("widgets/entityremove")

local EntityCell = Class(Widget, function(self, context, index)
	-- refer to cookbookpage_crockpot.lua line 407
	Widget._ctor(self, "entity-cell-" .. index)

	self.parent_screen = context.screen
	local cell_size = context.cell_size
	local base_size = context.base_size

	self.cell_root = self:AddChild(ImageButton("images/global.xml", "square.tex"))
	self.cell_root:SetFocusScale(cell_size / base_size + 0.05, cell_size / base_size + 0.05)
	self.cell_root:SetNormalScale(cell_size / base_size, cell_size / base_size)

	-- Icon inside
	self.icon = self.cell_root:AddChild(Image())
	self.icon:SetScale(0.52)

	-- Tooltip + focus behavior
	self.cell_root:SetOnGainFocus(function()
		if self.data ~= nil then
			self:ShowTooltip()
		end
	end)

	self.cell_root:SetOnLoseFocus(function()
		self:HideTooltip()
	end)

	-- Click behavior
	self.cell_root:SetOnClick(function()
		if self.data ~= nil then
			print("Image clicked! Index:", index, " name of:", self.data.name)
			SendModRPCToServer(GetModRPC("WhereIsIt", "LocateEntity"), self.data.name, self.data.is_single)
			self.parent_screen:OnClose()
		end
	end)
end)

function EntityCell:SetData(data)
	self.data = data

	-- Remove any previous EntityRemove button
	if self.entity_remove ~= nil then
		self.entity_remove:Kill()
		self.entity_remove = nil
	end

	if data ~= nil then
		-- Set icon
		self.icon:SetTexture(data.icon_atlas or "images/global.xml", data.icon_tex or "square.tex")
		if self.cell_root.image then
			self.cell_root.image:SetTint(1, 1, 1, 1)
		end

		-- Add remove button if custom
		if data.is_custom then
			self.entity_remove = self:AddChild(EntityRemove({
				screen = self,
				data = data,
				main_parent_screen = self.parent_screen,
			}))
			self.entity_remove:SetPosition(20, -18, 0)
		end

		self:Enable()
	else
		-- Reset icon to blank/default
		self.icon:SetTexture("images/global.xml", "square.tex")
		if self.cell_root.image then
			self.cell_root.image:SetTint(0.2, 0.2, 0.2, 0.5)
		end

		self:Disable()
	end
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
