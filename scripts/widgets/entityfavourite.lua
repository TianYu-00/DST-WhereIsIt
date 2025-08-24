local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local json = require("json")
local DebugLog = require("utils/debug")

local EntityFavouriteState = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_FAVOURITE_STATE .. context.index)
	self.parent_screen = context.main_parent_screen
	self.screen = context.screen
	DebugLog("EntityFavouriteState: Initialized for index " .. context.index)
end)

function EntityFavouriteState:GetFavouritePersistentData(callback)
	DebugLog("EntityFavouriteState: Loading favourite persistent data")
	TheSim:CheckPersistentStringExists(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES, function(exists)
		local favourites = {}

		if exists then
			TheSim:GetPersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES, function(success, str)
				if success and str and str ~= "" then
					local ok, data = pcall(json.decode, str)
					if ok and type(data) == "table" then
						favourites = data
						DebugLog("EntityFavouriteState: Loaded " .. tostring(#favourites) .. " favourite(s)")
					else
						DebugLog("EntityFavouriteState: Failed to decode favourite data")
					end
				else
					DebugLog("EntityFavouriteState: Persistent string empty or failed to load")
				end
				callback(favourites)
			end)
		else
			-- No string exists yet, create empty table
			SavePersistentString(
				TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES,
				json.encode(favourites),
				false
			)
			DebugLog("EntityFavouriteState: No favourites exist yet, created empty table")
			callback(favourites)
		end
	end)
end

function EntityFavouriteState:ToggleFavourite(entity_name, toggle_value)
	local favourites = self.parent_screen.favourite_persist_data or {}

	if toggle_value ~= nil then
		favourites[entity_name] = toggle_value
		DebugLog("EntityFavouriteState: Set favourite for " .. entity_name .. " to " .. tostring(toggle_value))
	else
		local current = favourites[entity_name] or false
		favourites[entity_name] = not current
		DebugLog(
			"EntityFavouriteState: Toggled favourite for " .. entity_name .. " to " .. tostring(favourites[entity_name])
		)
	end

	-- Save the updated table
	SavePersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES, json.encode(favourites), false)

	-- Update local memory
	self.favourite_persist_data = favourites
end

function EntityFavouriteState:CheckFavourite(entity_name)
	local favourites = self.parent_screen.favourite_persist_data or {}
	local state = favourites[entity_name] or false
	DebugLog("EntityFavouriteState: Checked favourite for " .. entity_name .. " -> " .. tostring(state))
	return state
end

return EntityFavouriteState
