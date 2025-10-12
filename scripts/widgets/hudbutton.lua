local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local DebugLog = require("utils/debug")

local HudButton = Class(Widget, function(self, context)
    Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_HUD_BUTTON)
    DebugLog("HudButton: Initialized")

    self.hud_button_root = self:AddChild(Widget("hud_button_container"))
    self.dragging = false
    self.drag_offset = { x = 0, y = 0 }
    self.drag_task = nil -- this is used to store my periodic task

    self:CreateButton()
    self:ToggleButton()
end)

function HudButton:CreateButton()
    DebugLog("HudButton: Creating button")

    self.hud_button_root:SetHAnchor(ANCHOR_MIDDLE)
    self.hud_button_root:SetVAnchor(ANCHOR_MIDDLE)
    self.hud_button_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    local screen_w, screen_h = TheSim:GetScreenSize()

    -- Load saved position
    TheSim:GetPersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS, function(success, str)
        local x, y = 0, 0
        if success and str and str ~= "" then
            local ok, data = pcall(json.decode, str)
            if ok and data and data.HUD_BUTTON_POS then
                local pos = data.HUD_BUTTON_POS
                x = pos.x * screen_w
                y = pos.y * screen_h
            else
                x = screen_w / 2 - 400
                y = -screen_h / 2 + 50
            end
        else
            x = screen_w / 2 - 400
            y = -screen_h / 2 + 50
        end
        self.hud_button_root:SetPosition(x, y, 0)
    end)

    -- Create button
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
        DebugLog("HudButton: Clicked, toggling menu")
        TIAN_WHEREISIT_GLOBAL_FUNCTION.TOGGLE_MENU()
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

    self.update_task = self.inst:DoPeriodicTask(1, function()
        local screen_w, screen_h = TheSim:GetScreenSize()
        local pos = self.hud_button_root:GetPosition()
        
        local normalized = self.saved_normalized_pos or { 
            x = pos.x / screen_w, 
            y = pos.y / screen_h 
        }

        -- Recalculate pixel position
        local new_x = normalized.x * screen_w
        local new_y = normalized.y * screen_h

        -- Clamp position so the button is always on-screen
        local margin = 25 -- NOTE: Change this based on button size later on if i redesign it
        new_x = math.clamp(new_x, -screen_w/2 + margin, screen_w/2 - margin)
        new_y = math.clamp(new_y, -screen_h/2 + margin, screen_h/2 - margin)

        self.hud_button_root:SetPosition(new_x, new_y, 0)
    end)

    DebugLog("HudButton: Button created")
end

-- Start periodic task for dragging so it updates my mouse position + menu button position per frame
function HudButton:StartDragging()
    if self.drag_task then return end
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

-- Save normalized position
function HudButton:SavePosition()
    local screen_w, screen_h = TheSim:GetScreenSize()
    local pos = self.hud_button_root:GetPosition()
    local normalized_pos = { x = pos.x / screen_w, y = pos.y / screen_h, z = pos.z or 0 }

    TheSim:GetPersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS, function(success, str)
        local data = {}
        if success and str and str ~= "" then
            local ok, decoded = pcall(json.decode, str)
            if ok and decoded then
                data = decoded
            end
        end

        data.HUD_BUTTON_POS = normalized_pos

        SavePersistentString(
            TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS,
            json.encode(data),
            false
        )
        DebugLog(string.format("HudButton: Position saved: x=%.2f, y=%.2f, z=%.2f", pos.x, pos.y, pos.z or 0))
    end)
end

-- Update button position while dragging
function HudButton:OnUpdate()
    if self.dragging and TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
        local mouse_x, mouse_y = TheInput:GetScreenPosition():Get()
        local new_x = mouse_x - self.drag_offset.x
        local new_y = mouse_y - self.drag_offset.y
        self.hud_button_root:SetPosition(new_x, new_y)

        -- Update normalized position for screen resize
        local screen_w, screen_h = TheSim:GetScreenSize()
        self.saved_normalized_pos = {
            x = new_x / screen_w,
            y = new_y / screen_h
        }
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
