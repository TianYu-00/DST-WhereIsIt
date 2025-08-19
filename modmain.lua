local G = GLOBAL
local require = G.require
local WhereIsItMenuScreen = require("screens/menu")
local EntitySelected = require("widgets/entityselected")
local json = require("json")

-- Language Strings
local GetTextStrings = require("strings/stringloader")
local TextStrings = GetTextStrings()

---- Mod config data
-- Debug settings
local debug_mode = GetModConfigData("Debug_Mode") or false

GLOBAL.TIAN_WHEREISIT_GLOBAL_DATA = { -- Hopefully no other mods use this same exact name @.@
	SETTINGS = { MENU_KEY = "O", REPEAT_LOOKUP_KEY = "V" },
}

GLOBAL.TIAN_WHEREISIT_GLOBAL_HANDLER = { MENU = nil, REPEAT = nil }

GLOBAL.TIAN_WHEREISIT_GLOBAL_FUNCTION = {}

local function InGameSettingsInit()
	G.TheSim:GetPersistentString("tian_whereisit_persist_settings", function(success, str)
		if success and str ~= nil and str ~= "" then
			local ok, data = G.pcall(json.decode, str)
			if ok and data then
				print("Key logging", data.MENU_KEY)
				print("Key logging", data.REPEAT_LOOKUP_KEY)
				G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.MENU_KEY = data.MENU_KEY
					or G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.MENU_KEY
				G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.REPEAT_LOOKUP_KEY = data.REPEAT_LOOKUP_KEY
					or G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.REPEAT_LOOKUP_KEY
			else
				DebugLog("Failed to decode saved entities")
			end
		else
			print("No persistent string found")
		end
		G.TIAN_WHEREISIT_GLOBAL_FUNCTION.UpdateKeyBindings()
	end)
end

AddSimPostInit(function()
	InGameSettingsInit()
end)

----------------------------------- Debug Mode -----------------------------------

local function DebugLog(msg)
	if not debug_mode then
		return
	end
	print("[Where Is It] " .. msg)
end

AddSimPostInit(function()
	if not debug_mode then
		return
	end
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

----------------------------------- Checks -----------------------------------

local function IsInteractionAllowed()
	-- check playerhud.lua for more screens
	local active_screen = G.TheFrontEnd:GetActiveScreen()
	-- DebugLog("Screen:" .. tostring(active_screen and active_screen.name or "nil"))
	-- DebugLog("IsCraftingOpen:" .. tostring(G.ThePlayer.HUD:IsCraftingOpen()))
	-- DebugLog("IsChatOpen:" .. tostring(G.ThePlayer.HUD:IsChatInputScreenOpen()))
	-- DebugLog("IsConsoleOpen:" .. tostring(G.ThePlayer.HUD:IsConsoleScreenOpen()))

	return active_screen ~= nil
		and not G.ThePlayer.HUD:IsCraftingOpen()
		and not G.ThePlayer.HUD:IsChatInputScreenOpen()
		and not G.ThePlayer.HUD:IsConsoleScreenOpen()
		and (active_screen.name == "HUD" or active_screen.name == "tian_whereisit_screen_mainmenu")
end

----------------------------------- AddClassPostConstruct -----------------------------------

AddClassPostConstruct("screens/menu", function(screen)
	screen:SetDebugMode(debug_mode)
end)

----------------------------------- Feature -----------------------------------

local function ToggleMenu()
	-- check screens
	if not IsInteractionAllowed() then
		return true
	end

	DebugLog("Function: ToggleMenu() called")
	local screen = G.TheFrontEnd:GetActiveScreen()
	-- End if we can't find the screen name (e.g. asleep)
	if not screen or not screen.name then
		return true
	end
	-- If the hud exists, open the UI
	if screen.name:find("HUD") then
		-- We want to pass in the (clientside) player entity
		G.TheFrontEnd:PushScreen(WhereIsItMenuScreen(G.ThePlayer))
		G.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		DebugLog("Opened Menu")
		return true
	else
		-- If the screen is already open, close it
		if screen.name == "tian_whereisit_screen_mainmenu" then
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

local function RepeatLookUp()
	local player = G.ThePlayer
	if not IsInteractionAllowed() then
		return true
	end

	if EntitySelected.name == "" then
		if player.components.talker then
			player.components.talker:Say(TextStrings.NO_ENTITY_SELECTED)
		end
		return
	end

	SendModRPCToServer(GetModRPC("WhereIsIt", "LocateEntity"), EntitySelected.name, EntitySelected.is_single)
end

----------------------------------- Volt Goat Herd Spawn point -----------------------------------

-- ill just put it here for now since its specific to it, and i wont be using it else where
PrefabFiles = { "lightninggoatfx" }

AddPrefabPostInit("lightninggoatherd", function(inst)
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	if not G.TheWorld.ismastersim then
		return
	end

	inst:DoTaskInTime(G.FRAMES, function()
		local fx = G.SpawnPrefab("tian_whereisit_lightninggoatfx")
		fx.entity:SetParent(inst.entity)
	end)
end)

----------------------------------- MOD RPC -----------------------------------

AddModRPCHandler("WhereIsIt", "LocateEntity", function(player, prefab_name, is_single)
	local entities = FindAllEntity(prefab_name, is_single)
	-- refer to archive_resonator.lua line 195-207 to get a better understanding on how to to create the directional beam
	if #entities > 0 then
		local tag = "whereisit_beam_" .. player.userid
		local old_beams = FindAllEntity("archive_resonator_base", false)
		for _, beam in ipairs(old_beams) do
			if beam and beam:IsValid() and beam:HasTag(tag) then
				beam:Remove()
			end
		end

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
			base:AddTag(tag)
			base.persists = false -- prevent the prefab from being saved in world state. Fixes the issue where saving the world while the beam is active would cause it to stay there on load
			base:DoTaskInTime(8, function(inst)
				inst:Remove()
			end)
		end
		player.SoundEmitter:PlaySound("grotto/common/archive_resonator/beam")
	else
		if player.components.talker then
			player.components.talker:Say(string.format(TextStrings.FAILED_TO_FIND .. " " .. prefab_name))
		end
	end
end)

----------------------------------- KEY HANDLERS -----------------------------------

local function InputHelper(key, on_down_fn, on_up_fn, handler_type)
	if not key or key == "None" then
		return
	end

	local code = G["KEY_" .. key]
	if not code then
		return
	end

	if GLOBAL.TIAN_WHEREISIT_GLOBAL_HANDLER[handler_type] then
		local old = GLOBAL.TIAN_WHEREISIT_GLOBAL_HANDLER[handler_type]
		if old ~= nil then
			if old.down_handler ~= nil then
				G.TheInput.onkeydown:RemoveHandler(old.down_handler)
			end
			if old.up_handler ~= nil then
				G.TheInput.onkeyup:RemoveHandler(old.up_handler)
			end
		end
		GLOBAL.TIAN_WHEREISIT_GLOBAL_HANDLER[handler_type] = nil
	end

	-- Add new handlers
	local handler_data = { down_handler = nil, up_handler = nil }

	if on_down_fn then
		local h = G.TheInput:AddKeyDownHandler(code, on_down_fn)
		handler_data.down_handler = h
	end
	if on_up_fn then
		local h = G.TheInput:AddKeyUpHandler(code, on_up_fn)
		handler_data.up_handler = h
	end

	GLOBAL.TIAN_WHEREISIT_GLOBAL_HANDLER[handler_type] = handler_data
end

function G.TIAN_WHEREISIT_GLOBAL_FUNCTION.UpdateKeyBindings()
	InputHelper(G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.MENU_KEY, ToggleMenu, nil, "MENU")
	InputHelper(G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.REPEAT_LOOKUP_KEY, nil, RepeatLookUp, "REPEAT")
end

----------------------------------- Comments -----------------------------------

-- Globals please use "TIAN_WHEREISIT_GLOBAL_XXX", try and not set globals unless its a must

-- Persistent Strings Please Follow This Format "tian_whereisit_persist_xxx"
-- Screens please follow this format "tian_whereisit_screen_xxx"
-- Widgets please follow this format "tian_whereisit_widget_xxx"
