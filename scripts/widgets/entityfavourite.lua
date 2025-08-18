local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local json = require("json")

local EntityFavouriteState = Class(Widget, function(self, context)
	Widget._ctor(self, "tian_whereisit_widget_entity_favourite_state_" .. context.index)
	self.parent_screen = context.main_parent_screen
	self.screen = context.screen
end)

function EntityFavouriteState:GetFavouritePersistentData(callback)
	local persist_naming = "tian_whereisit_persist_entity_favourite_states"
	TheSim:CheckPersistentStringExists(persist_naming, function(exists)
		local favourites = {}

		if exists then
			TheSim:GetPersistentString(persist_naming, function(success, str)
				if success and str and str ~= "" then
					local ok, data = pcall(json.decode, str)
					if ok and type(data) == "table" then
						favourites = data
					end
				end
				callback(favourites)
			end)
		else
			-- No string exists yet, create empty table
			SavePersistentString(persist_naming, json.encode(favourites), false)
			callback(favourites)
		end
	end)
end

function EntityFavouriteState:ToggleFavourite(entity_name)
	local persist_naming = "tian_whereisit_persist_entity_favourite_states"
	local favourites = self.parent_screen.favourite_persist_data or {}

	-- Toggle directly by prefab name
	local current = favourites[entity_name] or false
	favourites[entity_name] = not current

	-- Save the updated table
	SavePersistentString(persist_naming, json.encode(favourites), false)

	-- Update local memory
	self.favourite_persist_data = favourites
end

function EntityFavouriteState:CheckFavourite(entity_name)
	local favourites = self.parent_screen.favourite_persist_data or {}
	return favourites[entity_name] or false
end

return EntityFavouriteState
