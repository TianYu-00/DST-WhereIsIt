local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Templates = require "widgets/templates"
local Templates2 = require "widgets/redux/templates"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local EntityPrefabs = require "screens/entityprefabs"

-- Assets
Assets = {
  Asset("ATLAS", "images/worldgen_customization.xml"), -- taken from data/images
  Asset("IMAGE", "images/worldgen_customization.tex"), -- taken from data/images

  Asset("ATLAS", "images/worldsettings_customization.xml"), -- taken from data/images
  Asset("IMAGE", "images/worldsettings_customization.tex"), -- taken from data/images
}

local WhereIsItMenuScreen = Class(Screen, function(self, inst)
  self.inst = inst
  self.tasks = {}
  Screen._ctor(self, "WhereIsItMenuScreen") -- screen name. side note: if other mods that has the same name as this, it could potentially cause issues

  --darken everything behind the dialog
  self.black = self:AddChild(Image("images/global.xml", "square.tex"))
  self.black:SetVRegPoint(ANCHOR_MIDDLE)
  self.black:SetHRegPoint(ANCHOR_MIDDLE)
  self.black:SetVAnchor(ANCHOR_MIDDLE)
  self.black:SetHAnchor(ANCHOR_MIDDLE)
  self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
  self.black:SetTint(0,0,0,.75)

  -- Set the inital position for all our future elements
  self.proot = self:AddChild(Widget("ROOT"))
  self.proot:SetVAnchor(ANCHOR_MIDDLE)
  self.proot:SetHAnchor(ANCHOR_MIDDLE)
  self.proot:SetPosition(0,0,0)
  self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

  --throw up the background
  self.bg = self.proot:AddChild(Templates.CurlyWindow(400, 450, 1, 1, 68, -40)) -- sizeX, sizeY, scaleX, scaleY, topCrownOffset, bottomCrownOffset, xOffset

  --title
  self.title = self.proot:AddChild(Text(NEWFONT_OUTLINE, 50))
  self.title:SetPosition(0, 250, 0)
  self.title:SetString("Where is it")
  self.title:SetColour(unpack(GOLD))

  -- FOR DEBUG ONLY
  -- up animation
  self.animationUp = self.proot:AddChild(Text(NEWFONT_OUTLINE, 30, "Y: ", {unpack(RED)}))
  self.animationUp:SetPosition(-520, -350)
  -- Assign the task to the client
  self.tasks[#self.tasks + 1] = self.inst:DoPeriodicTask(.1, function()
    local pos = self.animationUp:GetPosition()
    self.animationUp:SetPosition(pos.x, pos.y > 350 and -350 or pos.y + 5)
    self.animationUp:SetString("Y: " .. pos.y)
  end)
  -- right animation
  self.animationRight = self.proot:AddChild(Text(NEWFONT_OUTLINE, 30, "X: ", {unpack(RED)}))
  self.animationRight:SetPosition(-600, -290)
  -- Assign the task to the client
  self.tasks[#self.tasks + 1] = self.inst:DoPeriodicTask(.1, function()
    local pos = self.animationRight:GetPosition()
    self.animationRight:SetPosition(pos.x > 600 and -600 or pos.x + 5, pos.y)
    self.animationRight:SetString("X: " .. pos.x)
  end)

  -- grid parameters
  local cell_size = 70
  local base_size = 70
  local row_spacing = 10
  local col_spacing = 10

  -- constructor function for each grid item
  -- refer to cookbookpage_crockpot.lua line 407
  local function ScrollWidgetsCtor(context, index)
    local grid_item = Widget("entity-cell-".. index)
    grid_item.cell_root = grid_item:AddChild(ImageButton("images/global.xml", "square.tex"))
    grid_item.cell_root:SetFocusScale(cell_size/base_size + .05, cell_size/base_size + .05)
    grid_item.cell_root:SetNormalScale(cell_size/base_size, cell_size/base_size)

    grid_item.icon = grid_item.cell_root:AddChild(Image())
    grid_item.icon:SetScale(0.5)

    -- tooltips
    grid_item.tooltip = grid_item.cell_root:AddChild(Text(NEWFONT_OUTLINE, 15))
    grid_item.tooltip:SetPosition(0, -40, 0)
    grid_item.tooltip:Hide()

    grid_item.cell_root:SetOnGainFocus(function()
      if grid_item.data ~= nil then
        grid_item.tooltip:SetString(grid_item.data.name)
        grid_item.tooltip:Show()
      end
    end)

    grid_item.cell_root:SetOnLoseFocus(function()
      grid_item.tooltip:Hide()
    end)

    grid_item.cell_root:SetOnClick(function()
      if grid_item.data ~= nil then
        print("Image clicked! Index:", index, " name of:", grid_item.data.name)
        SendModRPCToServer(GetModRPC("WhereIsIt", "LocateEntity"), grid_item.data.name, grid_item.data.single_entity)
        self:OnClose()
      end
    end)

    return grid_item
  end

  local function ScrollWidgetSetData(context, widget, data, index)
    widget.data = data
    if data ~= nil then
      widget.icon:SetTexture(data.icon_atlas or "images/global.xml", data.icon_tex or "square.tex")
      if widget.cell_root and widget.cell_root.image then
          widget.cell_root.image:SetTint(1,1,1,1)
      end
      widget:Enable()
    else
      if widget.cell_root and widget.cell_root.image then
          widget.cell_root.image:SetTint(0.2,0.2,0.2,0.5)
      end
      widget:Disable()
    end
  end

  -- create the scrolling grid
  -- refer to redux templates.lua line 1961 and cookbookpage_crockpot.lua line 540
  self.scroll_list = self.proot:AddChild(Templates2.ScrollingGrid( -- items, options
    EntityPrefabs,
    {
      context = {},
      widget_width  = cell_size + col_spacing,
      widget_height = cell_size + row_spacing,
      force_peek    = true,
      num_visible_rows = 5,
      num_columns      = 7,
      item_ctor_fn = ScrollWidgetsCtor,
      apply_fn     = ScrollWidgetSetData,
      scrollbar_offset = 20,
      scrollbar_height_offset = -60
    }
  ))
  self.scroll_list:SetPosition(0, 0, 0)
end)

function WhereIsItMenuScreen:OnClose()
  -- Cancel any started tasks
  -- This prevents stale components
	for k,v in pairs(self.tasks) do
		if v then
			v:Cancel()
		end
	end
  local screen = TheFrontEnd:GetActiveScreen()
  -- Don't pop the HUD
  if screen and screen.name:find("HUD") == nil then
    -- Remove our screen
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
    self:OnClose()
    return true
  end
end

return WhereIsItMenuScreen


----------------------------------- Comments ----------------------------------- 

-- bigpopupdialog.lua shows the basics to creating ui
-- templates.lua line 593 for CurlyWindow

----------------------------------- Old Code ----------------------------------- 


-- --text
-- self.text = self.proot:AddChild(Text(NEWFONT_OUTLINE, 30))
-- self.text:SetPosition(0, 5, 0)
-- self.text:SetString("My Text")
-- self.text:EnableWordWrap(true)
-- self.text:SetRegionSize(500, 200)
-- self.text:SetColour(unpack(WHITE))

-- self.mybutton2 = self.proot:AddChild(ImageButton("images/worldgen_customization.xml", "beefalo.tex"))
-- self.mybutton2:SetPosition(0, 0, 0)
-- self.mybutton2:SetScale(.5)
-- self.mybutton2:SetOnClick(function()
--   print("Image clicked!")
-- end)