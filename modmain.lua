local G = GLOBAL
local require = G.require
local WhereIsItMenuScreen = require("screens/menu")

---- Mod config data
-- Settings
local menu_key = GetModConfigData("Menu_Key") or "O"
-- Debud settings
local debug_mode = GetModConfigData("Debug_Mode") or false

----------------------------------- Debug Mode -----------------------------------

local function DebugLog(msg)
	if not debug_mode then
		return
	end
	print("[Where Is It] " .. msg)
end

AddSimPostInit(function()
	G.TheInput:AddKeyHandler(function(key, down)
		if not down then
			return
		end -- Only trigger on key press
		-- Require CTRL for any debug keybinds
		if G.TheInput:IsKeyDown(G.KEY_CTRL) then
			-- Load latest save and run latest scripts
			if key == G.KEY_R then
				if G.TheWorld.ismastersim then
					G.c_reset()
				else
					G.TheNet:SendRemoteExecute("c_reset()")
				end
			end
		end
	end)
end)

----------------------------------- Feature -----------------------------------

local function OpenMenu()
	DebugLog("Function: OpenMenu() called")
	local screen = TheFrontEnd:GetActiveScreen()
	-- End if we can't find the screen name (e.g. asleep)
	if not screen or not screen.name then
		return true
	end
	-- If the hud exists, open the UI
	if screen.name:find("HUD") then
		-- We want to pass in the (clientside) player entity
		TheFrontEnd:PushScreen(WhereIsItMenuScreen(G.ThePlayer))
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		DebugLog("Opened Menu")
		return true
	else
		-- If the screen is already open, close it
		if screen.name == "WhereIsItMenuScreen" then
			screen:OnClose()
			DebugLog("Closed Menu")
		end
	end
end

local function FindAllEntity(prefab_name, is_single)
	local entities = {}
	-- refer to consolecommands.lua line 894
	for k, v in pairs(G.Ents) do
		if v.prefab == prefab_name then
			table.insert(entities, v)
			if is_single then
				return entities
			end
		end
	end
	return entities
end

----------------------------------- MOD RPC -----------------------------------

AddModRPCHandler("WhereIsIt", "LocateEntity", function(player, prefab_name, is_single)
	local entities = FindAllEntity(prefab_name, is_single)
	-- refer to archive_resonator.lua line 195-207 to get a better understanding on how to to create the directional beam
	if #entities > 0 then
		for i, ent in ipairs(entities) do
			local x, y, z = player.Transform:GetWorldPosition()
			local angle = ent:GetAngleToPoint(x, y, z)
			local radius = -3
			local theta = angle * G.DEGREES
			local offset = G.Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
			local base = G.SpawnPrefab("archive_resonator_base")
			base.Transform:SetPosition(x + offset.x, y, z + offset.z)
			base.Transform:SetRotation(angle + 90)
			base.AnimState:PlayAnimation("beam_marker")
			base.AnimState:PushAnimation("idle_marker", true)
			base:DoTaskInTime(8, function(inst)
				inst:Remove()
			end)
		end
		player.SoundEmitter:PlaySound("grotto/common/archive_resonator/beam")
	else
		if player.components.talker then
			player.components.talker:Say(string.format("No " .. prefab_name .. " found"))
		end
	end
end)

----------------------------------- KEY HANDLERS -----------------------------------

local mouse_map = {
	-- strings.lua, line 13640
	["\238\132\128"] = 1000, -- MOUSEBUTTON_LEFT
	["\238\132\129"] = 1001, -- MOUSEBUTTON_RIGHT
	["\238\132\130"] = 1002, -- MOUSEBUTTON_MIDDLE
	["\238\132\133"] = 1003, -- MOUSEBUTTON_SCROLLUP
	["\238\132\134"] = 1004, -- MOUSEBUTTON_SCROLLDOWN
	["\238\132\131"] = 1005, -- MOUSEBUTTON_4
	["\238\132\132"] = 1006, -- MOUSEBUTTON_5
}

local function InputHelper(key, on_down_fn, on_up_fn)
	if not key or key == "None" then
		return
	end

	local code = mouse_map[key] or G["KEY_" .. key]

	if not code then
		return
	end

	DebugLog("CODE for key: " .. key .. " is: " .. tostring(code))

	if code >= 1000 and code <= 1006 then
		-- Mouse key
		G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
			if button == code then
				if down and on_down_fn then
					on_down_fn()
				elseif (not down) and on_up_fn then
					on_up_fn()
				end
			end
		end)
	else
		-- Keyboard key
		if on_down_fn then
			G.TheInput:AddKeyDownHandler(code, on_down_fn)
		end
		if on_up_fn then
			G.TheInput:AddKeyUpHandler(code, on_up_fn)
		end
	end
end

AddSimPostInit(function()
	InputHelper(menu_key, OpenMenu, nil)
end)
