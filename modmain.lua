local G = GLOBAL
local require = G.require
local Widget = require("widgets/widget")
local WhereIsItMenuScreen = require("screens/menu")
local WhereIsItHudButton = require("widgets/hudbutton")
local DefaultLocalConfig = require("defaultsettings")
local json = require("json")

-- Config Settings
local arrow_limit_per_player = GetModConfigData("Arrow_Limit_Per_Player") or 0
local entity_location_search_cooldown = GetModConfigData("Entity_Location_Search_Cooldown") or 0
local is_allow_teleport = GetModConfigData("Is_Allow_Teleport") or false

-- Language Strings
local GetTextStrings = require("strings/stringloader")
local TextStrings = GetTextStrings()

---- Mod config data
-- Debug settings
local debug_mode = GetModConfigData("Debug_Mode") or false

G.TIAN_WHEREISIT_GLOBAL_DATA = { -- Hopefully no other mods use this same exact name @.@
	SETTINGS = {
		MENU_KEY = DefaultLocalConfig.MENU_KEY,
		REPEAT_LOOKUP_KEY = DefaultLocalConfig.REPEAT_LOOKUP_KEY,
		ARROW_LIMIT_PER_PLAYER = arrow_limit_per_player,
		ENTITY_LOCATION_SEARCH_COOLDOWN = entity_location_search_cooldown,
		IS_ALLOW_TELEPORT = is_allow_teleport,
		MENU_BUTTON_TOGGLE = DefaultLocalConfig.MENU_BUTTON_TOGGLE,
	},
	STRINGS = TextStrings,
	CURRENT_ENTITY = { name = "", is_single = false },
	IDENTIFIER = {
		-- Screens
		SCREEN_MAIN = "tian_whereisit_screen_mainmenu",
		-- Persistent Storage
		PERSIST_SETTINGS = "tian_whereisit_persist_settings",
		PERSIST_CUSTOM_ENTITIES = "tian_whereisit_persist_custom_entities",
		PERSIST_FAVOURITES = "tian_whereisit_persist_entity_favourite_states",
		PERSIST_HIDE_BASE_ENTITY = "tian_whereisit_persist_entity_hide_states",
		-- Widgets
		WIDGET_HUD_BUTTON = "tian_whereisit_widget_hud_button",
		WIDGET_ENTITY_ADD = "tian_whereisit_widget_entity_add",
		WIDGET_ENTITY_CELL = "tian_whereisit_widget_entity_cell_",
		WIDGET_ENTITY_FAVOURITE_STATE = "tian_whereisit_widget_entity_favourite_state_",
		WIDGET_ENTITY_HIDDEN_STATE = "tian_whereisit_widget_entity_hidden_state_",
		WIDGET_ENTITY_INPUT = "tian_whereisit_widget_entity_input",
		WIDGET_ENTITY_REMOVE = "tian_whereisit_widget_entity_remove_",
		WIDGET_ENTITY_SEARCH = "tian_whereisit_widget_entity_search",
		WIDGET_SETTINGS = "tian_whereisit_widget_settings",
		WIDGET_TOOLTIP = "tian_whereisit_widget_tooltip",
		WIDGET_ENTITY_ADD_MENU = "tian_whereisit_widget_entity_add_menu",
		-- Player Attached
		ATTACHED_IS_ALLOW_ENTITY_LOOKUP = "tian_whereisit_attached_is_allow_entity_lookup",
		ATTACHED_LAST_TELEPORT_TARGET_INDEX = "tian_whereisit_attached_last_teleport_target_index",
		ATTACHED_MENU_BUTTON = "tian_whereisit_attached_menu_button",
		-- Entity Attached
		ATTACHED_ENTITY_BASE_POSITION = "tian_whereisit_attached_entity_base_position",
	},
}

G.TIAN_WHEREISIT_GLOBAL_HANDLER = { MENU = nil, REPEAT = nil }

G.TIAN_WHEREISIT_GLOBAL_FUNCTION = {}

local function InGameSettingsInit()
	-- WHEN YOU ADD NEW PERSIST SETTINGS, ADD IT HERE TOO!
	G.TheSim:GetPersistentString(G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_SETTINGS, function(success, str)
		if success and str ~= nil and str ~= "" then
			local ok, data = G.pcall(json.decode, str)
			if ok and data then
				print("Key logging", data.MENU_KEY)
				print("Key logging", data.REPEAT_LOOKUP_KEY)
				print("Toggle logging", data.MENU_BUTTON_TOGGLE)
				G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.MENU_KEY = data.MENU_KEY
					or G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.MENU_KEY
				G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.REPEAT_LOOKUP_KEY = data.REPEAT_LOOKUP_KEY
					or G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.REPEAT_LOOKUP_KEY
				G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.MENU_BUTTON_TOGGLE = data.MENU_BUTTON_TOGGLE
					or G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.MENU_BUTTON_TOGGLE
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
		and (active_screen.name == "HUD" or active_screen.name == G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.SCREEN_MAIN)
end

----------------------------------- AddClassPostConstruct -----------------------------------

AddClassPostConstruct("screens/menu", function(screen)
	screen:SetDebugMode(debug_mode)
end)

AddClassPostConstruct("screens/playerhud", function(self)
	if self ~= nil then
		self[G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_MENU_BUTTON] =
			self:AddChild(WhereIsItHudButton({ screen = self }))
	end
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
		if screen.name == G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.SCREEN_MAIN then
			screen:OnClose()
			DebugLog("Closed Menu")
		end
	end
end

G.TIAN_WHEREISIT_GLOBAL_FUNCTION.TOGGLE_MENU = ToggleMenu

local function ToggleMenuButton()
	local hud = G.ThePlayer and G.ThePlayer.HUD
	if hud then
		local button = hud[G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_MENU_BUTTON]
		if button then
			button:ToggleButton()
		end
	end
end

G.TIAN_WHEREISIT_GLOBAL_FUNCTION.TOGGLE_MENU_BUTTON = ToggleMenuButton

local function FindAllEntity(prefab_name, is_single)
	local entities = {}
	local limit = G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.ARROW_LIMIT_PER_PLAYER
	local counter = 0

	for _, v in pairs(G.Ents) do
		if v.prefab == prefab_name then
			table.insert(entities, v)

			if is_single then
				return entities
			end

			counter = counter + 1
			if limit ~= 0 and counter >= limit then
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

	DebugLog("Current Entity: " .. G.TIAN_WHEREISIT_GLOBAL_DATA.CURRENT_ENTITY.name .. " For Player: " .. player.userid)

	if G.TIAN_WHEREISIT_GLOBAL_DATA.CURRENT_ENTITY.name == "" then
		if player.components.talker then
			player.components.talker:Say(G.TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.NO_ENTITY_SELECTED)
		end
		return
	end

	SendModRPCToServer(
		GetModRPC("WhereIsIt", "LocateEntity"),
		G.TIAN_WHEREISIT_GLOBAL_DATA.CURRENT_ENTITY.name,
		G.TIAN_WHEREISIT_GLOBAL_DATA.CURRENT_ENTITY.is_single
	)
end

local function CheckLookUpState(player)
	local temp_key = G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_IS_ALLOW_ENTITY_LOOKUP

	if player[temp_key] then
		if player.components.talker then
			player.components.talker:Say(G.TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.ENTITY_ON_COOLDOWN)
		end
		return false
	end

	player[temp_key] = true

	player:DoTaskInTime(G.TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.ENTITY_LOCATION_SEARCH_COOLDOWN, function()
		player[temp_key] = nil
	end)

	return true
end

----------------------------------- Spawn Point Handlers -----------------------------------

-- ill just put it here for now since its specific to it, and i wont be using it else where
PrefabFiles = {
	"lightninggoatfx",
	"beefalofx",
	"tumbleweedfx",
	"mushgnomefx",
	"rockyfx",
	"minisignfx",
	"radiusfx",
} -- prefab file names without extension

----------------------------------- Lightning Goat Herd
AddPrefabPostInit("lightninggoatherd", function(inst)
	-- client code
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	if not G.TheWorld.ismastersim then
		return
	end

	-- server code
	inst:DoTaskInTime(G.FRAMES, function()
		local fx = G.SpawnPrefab("tian_whereisit_lightninggoatfx")
		fx.entity:SetParent(inst.entity)
	end)
end)

----------------------------------- Beefalo Herd
AddPrefabPostInit("beefaloherd", function(inst)
	-- client code
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	if not G.TheWorld.ismastersim then
		return
	end

	-- server code
	inst:DoTaskInTime(G.FRAMES, function()
		local fx = G.SpawnPrefab("tian_whereisit_beefalofx")
		fx.entity:SetParent(inst.entity)
	end)
end)

----------------------------------- Rocky Herd
AddPrefabPostInit("rockyherd", function(inst)
	-- client code
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	if not G.TheWorld.ismastersim then
		return
	end

	-- server code
	inst:DoTaskInTime(G.FRAMES, function()
		local fx = G.SpawnPrefab("tian_whereisit_rockyfx")
		fx.entity:SetParent(inst.entity)
	end)
end)

----------------------------------- Tumbleweed Spawner
AddPrefabPostInit("tumbleweedspawner", function(inst)
	if not G.TheWorld.ismastersim then
		return
	end

	-- server code
	inst:DoTaskInTime(G.FRAMES, function()
		local fx = G.SpawnPrefab("tian_whereisit_tumbleweedfx")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end)
end)

----------------------------------- Mushgnome Spawner
AddPrefabPostInit("mushgnome_spawner", function(inst)
	if not G.TheWorld.ismastersim then
		return
	end

	-- server code
	inst:DoTaskInTime(G.FRAMES, function()
		local fx = G.SpawnPrefab("tian_whereisit_mushgnomefx")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end)
end)

----------------------------------- Ruin Clockworks
--- Refer to retrofitcavemap_anr.lua line 241 - local respawner = SpawnPrefab(spawnerprefab.."_ruinsrespawner_inst")
AddPrefabPostInit("bishop_nightmare_ruinsrespawner_inst", function(inst)
	-- If this code is running on a client, don’t execute the rest of the function — just return the prefab now.
	if not G.TheWorld.ismastersim then
		return
	end

	-- server code
	inst:DoTaskInTime(G.FRAMES, function()
		if inst[G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_ENTITY_BASE_POSITION] == nil then
			local fx = G.SpawnPrefab("tian_whereisit_minisignfx")
			fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst[G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_ENTITY_BASE_POSITION] = fx

			local radius = G.SpawnPrefab("tian_whereisit_radiusfx")
			radius.entity:SetParent(fx.entity)
			radius.Transform:SetScale(0.4, 0.4, 0.4)
		end
	end)
end)

AddPrefabPostInit("knight_nightmare_ruinsrespawner_inst", function(inst)
	if not G.TheWorld.ismastersim then
		return
	end

	-- server code
	inst:DoTaskInTime(G.FRAMES, function()
		if inst[G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_ENTITY_BASE_POSITION] == nil then
			local fx = G.SpawnPrefab("tian_whereisit_minisignfx")
			fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst[G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_ENTITY_BASE_POSITION] = fx

			local radius = G.SpawnPrefab("tian_whereisit_radiusfx")
			radius.entity:SetParent(fx.entity)
			radius.Transform:SetScale(0.4, 0.4, 0.4)
		end
	end)
end)

AddPrefabPostInit("rook_nightmare_ruinsrespawner_inst", function(inst)
	if not G.TheWorld.ismastersim then
		return
	end

	-- server code
	inst:DoTaskInTime(G.FRAMES, function()
		if inst[G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_ENTITY_BASE_POSITION] == nil then
			local fx = G.SpawnPrefab("tian_whereisit_minisignfx")
			fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst[G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_ENTITY_BASE_POSITION] = fx

			local radius = G.SpawnPrefab("tian_whereisit_radiusfx")
			radius.entity:SetParent(fx.entity)
			radius.Transform:SetScale(0.4, 0.4, 0.4)
		end
	end)
end)

----------------------------------- MOD RPC -----------------------------------

AddModRPCHandler("WhereIsIt", "LocateEntity", function(player, prefab_name, is_single)
	if not CheckLookUpState(player) then
		return
	end

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
		-- player.SoundEmitter:PlaySound("grotto/common/archive_resonator/beam")
	else
		if player.components.talker then
			player.components.talker:Say(
				string.format(G.TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.FAILED_TO_FIND .. " " .. prefab_name)
			)
		end
	end
end)

AddModRPCHandler("WhereIsIt", "TeleportToEntity", function(player, prefab_name)
	if not player or not prefab_name then
		return
	end

	local temp_key = G.TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.ATTACHED_LAST_TELEPORT_TARGET_INDEX

	player[temp_key] = player[temp_key] or {}

	local matches = {}
	for _, v in pairs(G.Ents) do -- similar to the logic i previously wrote above
		if v.prefab == prefab_name and v:IsValid() then
			table.insert(matches, v)
		end
	end

	if #matches == 0 then
		if player.components.talker then
			player.components.talker:Say(G.TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.FAILED_TO_FIND .. prefab_name)
		end
		return
	end

	local index = (player[temp_key][prefab_name] or 0) + 1
	if index > #matches then
		index = 1
	end

	player[temp_key][prefab_name] = index

	local target = matches[index]
	if target and target:IsValid() then
		local x, y, z = target.Transform:GetWorldPosition()
		player.Transform:SetPosition(x, y, z)
		if player.components.talker then
			player.components.talker:Say(
				G.TIAN_WHEREISIT_GLOBAL_DATA.STRINGS.TELEPORTED_TO
					.. prefab_name
					.. " ("
					.. index
					.. "/"
					.. #matches
					.. ")"
			)
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

	if G.TIAN_WHEREISIT_GLOBAL_HANDLER[handler_type] then
		local old = G.TIAN_WHEREISIT_GLOBAL_HANDLER[handler_type]
		if old ~= nil then
			if old.down_handler ~= nil then
				G.TheInput.onkeydown:RemoveHandler(old.down_handler)
			end
			if old.up_handler ~= nil then
				G.TheInput.onkeyup:RemoveHandler(old.up_handler)
			end
		end
		G.TIAN_WHEREISIT_GLOBAL_HANDLER[handler_type] = nil
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

	G.TIAN_WHEREISIT_GLOBAL_HANDLER[handler_type] = handler_data
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
