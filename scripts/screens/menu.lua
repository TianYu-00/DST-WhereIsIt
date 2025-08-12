local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Templates = require "widgets/templates"
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
  self.bg = self.proot:AddChild(Templates.CurlyWindow(500, 450, 1, 1, 68, -40))

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

  local menu_columns = 10
  local spacingX, spacingY = 70, 70
  local total_items = #EntityPrefabs
  local rows = math.ceil(total_items / menu_columns)

  -- Calculate total width and height of the grid
  local total_width = menu_columns * spacingX
  local total_height = rows * spacingY

  local function CreateEntityButton(index)
    local entity = {}
    local col = (index - 1) % menu_columns
    local row = math.floor((index - 1) / menu_columns)

    entity.mybutton = self.EntityPrefabs:AddChild(ImageButton(
      EntityPrefabs[index].icon_atlas or "images/global.xml",
      EntityPrefabs[index].icon_tex or "square.tex"
    ))

    entity.mybutton:SetPosition(col * spacingX, -row * spacingY, 0)
    entity.mybutton:SetScale(0.5)
    entity.mybutton:SetOnClick(function()
      print("Image clicked! Index:", index)
    end)

    return entity
  end

  self.EntityPrefabs = self.proot:AddChild(Widget("ROOT"))
  self.EntityPrefabs:SetPosition(-total_width / 2 + spacingX / 2, 180, 0)
  self.EntityPrefabs.entities = {}

  for i = 1, #EntityPrefabs do
    self.EntityPrefabs.entities[i] = CreateEntityButton(i)
  end

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
  TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
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