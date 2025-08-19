local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local json = require("json")

local EntityFavouriteState = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_FAVOURITE_STATE .. context.index)
	self.parent_screen = context.main_parent_screen
	self.screen = context.screen
end)

function EntityFavouriteState:GetFavouritePersistentData(callback)
	TheSim:CheckPersistentStringExists(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES, function(exists)
		local favourites = {}

		if exists then
			TheSim:GetPersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES, function(success, str)
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
			SavePersistentString(
				TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES,
				json.encode(favourites),
				false
			)
			callback(favourites)
		end
	end)
end

function EntityFavouriteState:ToggleFavourite(entity_name)
	local favourites = self.parent_screen.favourite_persist_data or {}

	-- Toggle directly by prefab name
	local current = favourites[entity_name] or false
	favourites[entity_name] = not current

	-- Save the updated table
	SavePersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES, json.encode(favourites), false)

	-- Update local memory
	self.favourite_persist_data = favourites
end

function EntityFavouriteState:CheckFavourite(entity_name)
	local favourites = self.parent_screen.favourite_persist_data or {}
	return favourites[entity_name] or false
end

return EntityFavouriteState
