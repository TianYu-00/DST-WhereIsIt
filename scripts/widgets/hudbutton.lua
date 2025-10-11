local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local DebugLog = require("utils/debug")

local HudButton = Class(Widget, function(self, context)
    Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_HUD_BUTTON)
    DebugLog("HudButton: Initialized")

    self.hud_button_root = self:AddChild(Widget("hud_button_container"))
    self.dragging = false
    self.drag_offset = { x = 0, y = 0 }
    self.drag_task = nil -- store the periodic task

    self:CreateButton()
    self:ToggleButton()
end)

function HudButton:CreateButton()
    DebugLog("HudButton: Creating button")

    self.hud_button_root:SetHAnchor(ANCHOR_MIDDLE)
    self.hud_button_root:SetVAnchor(ANCHOR_MIDDLE)
    self.hud_button_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    TheSim:GetPersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS, function(success, str)
        if success and str and str ~= "" then
            local ok, data = pcall(json.decode, str)
            if ok and data and data.HUD_BUTTON_POS then
                local pos = data.HUD_BUTTON_POS
                self.hud_button_root:SetPosition(pos.x, pos.y, pos.z or 0)
            else
                self.hud_button_root:SetPosition(1000, -675, 0)
            end
        else
            self.hud_button_root:SetPosition(1000, -675, 0)
        end
    end)

    self.bg = self.hud_button_root:AddChild(ImageButton("images/ui.xml", "button_small.tex"))
    self.bg:SetFocusScale(1.1, 0.8)
    self.bg:SetNormalScale(1, 0.7)
    self.bg:SetText(TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.MOD_NAME)
    self.bg:SetFont(NEWFONT)
    self.bg:SetTextColour(unpack(WHITE))
    self.bg:SetTextFocusColour(unpack(WHITE))
    self.bg:SetTextSize(20)
    self.bg.image:SetTint(0, 0, 0, 0.5)

    -- Left click toggles menu
    self.bg:SetOnClick(function()
        -- if not self.dragging then
            DebugLog("HudButton: Clicked, toggling menu")
            TIAN_WHEREISIT_GLOBAL_FUNCTION.TOGGLE_MENU()
        -- end
    end)

    -- Right click starts/stops dragging
    self.bg.OnMouseButton = function(_, button, down, x, y)
        if button == MOUSEBUTTON_RIGHT then
            if down then
                local mouse_x, mouse_y = TheInput:GetScreenPosition():Get()
                local pos = self.hud_button_root:GetPosition()
                self.dragging = true
                self.drag_offset.x = mouse_x - pos.x
                self.drag_offset.y = mouse_y - pos.y
                DebugLog("HudButton: Start dragging")
                self:StartDragging()
            else
                if self.dragging then
                    self.dragging = false
                    DebugLog("HudButton: Stop dragging")
                    self:StopDragging()
                end
            end
            return true
        end
    end

    DebugLog("HudButton: Button created")
end

-- Start periodic task for dragging so it updates my mouse position + menu button position per frame
function HudButton:StartDragging()
    if self.drag_task then return end -- if its already running
    self.drag_task = self.inst:DoPeriodicTask(FRAMES, function() self:OnUpdate() end)
end

-- Stop and clean up periodic task
function HudButton:StopDragging()
    if self.drag_task then
        self.drag_task:Cancel()
        self.drag_task = nil
    end

    self:SavePosition()
end

function HudButton:SavePosition()
    TheSim:GetPersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS, function(success, str)
        local data = {}
        if success and str and str ~= "" then
            local ok, decoded = pcall(json.decode, str)
            if ok and decoded then
                data = decoded
            end
        end

        local pos = self.hud_button_root:GetPosition()
        data.HUD_BUTTON_POS = { x = pos.x, y = pos.y, z = pos.z or 0 }

        SavePersistentString(
            TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS,
            json.encode(data),
            false
        )
        DebugLog("HudButton: Position saved: x=" .. pos.x .. ", y=" .. pos.y .. ", z=" .. (pos.z or 0))
    end)
end


-- Update button position while dragging
function HudButton:OnUpdate()
    if self.dragging and TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
        local mouse_x, mouse_y = TheInput:GetScreenPosition():Get()
        self.hud_button_root:SetPosition(mouse_x - self.drag_offset.x, mouse_y - self.drag_offset.y)
    end
end

function HudButton:ToggleButton()
    DebugLog("HudButton: ToggleButton called")
    if TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.MENU_BUTTON_TOGGLE == "true" then
        self.hud_button_root:Show()
        DebugLog("HudButton: Button shown")
    else
        self.hud_button_root:Hide()
        DebugLog("HudButton: Button hidden")
    end
end

return HudButton
