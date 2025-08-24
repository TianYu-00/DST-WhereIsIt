local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local EntityRemove = require("widgets/entityremove")
local EntityFavourite = require("widgets/entityfavourite")
local EntityHide = require("widgets/entityhide")
local Text = require("widgets/text")
local DebugLog = require("utils/debug")

local EntityCell = Class(Widget, function(self, context, index)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_CELL .. index)
	DebugLog("EntityCell: Initialized cell " .. index)

	self.parent_screen = context.screen
	local cell_size = context.cell_size
	local base_size = context.base_size
	self.entity_index = index

	-- Root background
	self.cell_root = self:AddChild(ImageButton("images/global.xml", "square.tex"))
	self.cell_root:SetFocusScale(cell_size / base_size + 0.05, cell_size / base_size + 0.05)
	self.cell_root:SetNormalScale(cell_size / base_size, cell_size / base_size)

	-- Tooltip
	self.cell_root:SetOnGainFocus(function()
		if self.data then
			self.parent_screen.tooltip_root:UpdatePosition(self.cell_root, 0, -40)
			self.parent_screen.tooltip_root.tooltip:SetString(self.data.name)
			DebugLog("EntityCell: Focus gained on " .. self.data.name)
		end
	end)
	self.cell_root:SetOnLoseFocus(function()
		self.parent_screen.tooltip_root:HideTooltip(self.cell_root)
		DebugLog("EntityCell: Focus lost")
	end)

	-- Click
	self.cell_root:SetOnClick(function()
		if self.data then
			DebugLog("EntityCell: Clicked on " .. self.data.name)
			SendModRPCToServer(GetModRPC("WhereIsIt", "LocateEntity"), self.data.name, self.data.is_single)
			TIAN_WHEREISIT_GLOBAL_DATA.CURRENT_ENTITY.name = self.data.name
			TIAN_WHEREISIT_GLOBAL_DATA.CURRENT_ENTITY.is_single = self.data.is_single
			self.parent_screen:OnClose()
		end
	end)

	-- Background for the icon (middle layer)
	self.icon_bg = self.cell_root:AddChild(Image("images/scrapbook.xml", "inv_item_background.tex"))
	self.icon_bg:ScaleToSize(63, 63)

	-- Icon (front layer)
	self.icon = self.cell_root:AddChild(Image())
	self.icon:Hide()

	self.custom_name = self:AddChild(Text(NEWFONT_OUTLINE, 20))
	self.custom_name:SetRegionSize(50, 50)
	self.custom_name:SetPosition(1, 0, 0)
	self.custom_name:Hide()

	self.entity_remove_root = self:AddChild(EntityRemove({
		screen = self,
		main_parent_screen = self.parent_screen,
		index = self.entity_index,
	}))

	self.entity_favourite_root = self:AddChild(EntityFavourite({
		screen = self,
		main_parent_screen = self.parent_screen,
		index = self.entity_index,
	}))

	self.entity_hide_root = self:AddChild(EntityHide({
		screen = self,
		main_parent_screen = self.parent_screen,
		index = self.entity_index,
	}))
end)

function EntityCell:SetData(data)
	self.data = data
	if data then
		DebugLog("EntityCell: SetData called for " .. data.name)
	else
		-- DebugLog("EntityCell: SetData called for nil (initial)")
	end

	if not data then
		if self.cell_root.image then
			self.cell_root.image:SetTint(0.3, 0.3, 0.3, 0.3)
		end
		self.icon:Hide()
		self.icon_bg:Hide()
		self.custom_name:Hide()
		self:Disable()
		return
	end

	if self.cell_root.image then
		self.cell_root.image:SetTint(1, 1, 1, 1)
	end

	-- Icon + background
	self.icon_bg:Show()
	self.icon:SetTexture(data.icon_atlas or "images/global.xml", data.icon_tex or "square.tex")
	self.icon:ScaleToSize(data.icon_size_x or 63, data.icon_size_y or 63)
	self.icon:Show()

	-- Custom name/remove
	if data.is_custom then
		local name = (data.custom_name and data.custom_name ~= "" and data.custom_name) or data.name
		self.custom_name:SetTruncatedString(name, nil, 7, true)
		self.custom_name:Show()
	else
		self.custom_name:Hide()
	end

	local favourite_state = self.entity_favourite_root:CheckFavourite(self.data.name)
	if favourite_state then
		self.cell_root.image:SetTint(unpack(UICOLOURS.HIGHLIGHT_GOLD))
	end

	self:Enable()
end

function EntityCell:OnControl(control, down)
	if Widget.OnControl(self, control, down) then
		return true
	end

	-- Favourite
	if down and control == CONTROL_SECONDARY then
		if TheInput:IsKeyDown(KEY_LCTRL) or TheInput:IsKeyDown(KEY_RCTRL) then
			if self.data and self.data.name and self.entity_favourite_root then
				DebugLog("Ctrl+Right Click on: " .. self.data.name)
				self.entity_favourite_root:ToggleFavourite(self.data.name)
				local favourite_state = self.entity_favourite_root:CheckFavourite(self.data.name)
				self.parent_screen.tooltip_root.tooltip:SetString(
					favourite_state and TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.PINNED
						or TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.UNPINNED
				)
			end
			return true
		end
	end

	-- Remove / Hide
	if down and control == CONTROL_SECONDARY then
		if TheInput:IsKeyDown(KEY_LALT) or TheInput:IsKeyDown(KEY_RALT) then
			if self.data and self.data.name then
				DebugLog("Alt+Right Click on: " .. self.data.name)

				if self.data.is_custom and self.entity_remove_root then
					DebugLog("Removing custom entity: " .. self.data.name)
					self.entity_remove_root:RemoveEntity(self.data.name)
				else
					if self.parent_screen and self.parent_screen.hidden_persist_data then
						DebugLog("Toggling hidden state for base entity: " .. self.data.name)
						local hidden = self.parent_screen.hidden_persist_data
						hidden[self.data.name] = not hidden[self.data.name]

						SavePersistentString(
							TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_HIDE_BASE_ENTITY,
							json.encode(hidden),
							false
						)

						self.parent_screen:RefreshEntityList()
					end
				end
			end
			return true
		end
	end

	-- Teleport
	if down and control == CONTROL_SECONDARY then
		if TheInput:IsKeyDown(KEY_LSHIFT) or TheInput:IsKeyDown(KEY_RSHIFT) then
			if TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.IS_ALLOW_TELEPORT then
				if self.data and self.data.name then
					DebugLog("Shift+Right Click (Teleport) on: " .. self.data.name)
					SendModRPCToServer(GetModRPC("WhereIsIt", "TeleportToEntity"), self.data.name)
					self.parent_screen:OnClose()
				end
			else
				self.parent_screen.tooltip_root.tooltip:SetString(
					TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.TELEPORT_PERMISSION_OFF
				)
				DebugLog("Teleport blocked: Permission off")
			end
			return true
		end
	end

	return false
end

return EntityCell
