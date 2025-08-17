local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local json = require("json")

local EntityFavouriteState = Class(Widget, function(self, context)
	Widget._ctor(self, "tian_whereisit_widget_entity_favourite_state_" .. context.index)
	self.parent_screen = context.main_parent_screen
	self.screen = context.screen
	self.prefab_name = context.data.name
	self.favourite_persist_data = self.parent_screen.favourite_persist_data

	local is_favourite = false
	if self.favourite_persist_data then
		is_favourite = self.favourite_persist_data[self.prefab_name]
		if is_favourite == nil then
			-- default new entries to false
			self.parent_screen.favourite_persist_data[self.prefab_name] = false
			is_favourite = false
		end
	end

	-- Common setup
	local button_atlas = "images/crafting_menu.xml"
	local button_tex = is_favourite and "favorite_checked.tex" or "favorite_unchecked.tex"
	self.entity_favourite_button = self:AddChild(ImageButton(button_atlas, button_tex))
	self.entity_favourite_button:SetScale(0.35)
	self.entity_favourite_button:SetOnClick(function()
		self:ToggleFavourite()
		print(self.prefab_name, "is favourite:", is_favourite)
	end)
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

function EntityFavouriteState:ToggleFavourite()
	local persist_naming = "tian_whereisit_persist_entity_favourite_states"
	local favourites = self.favourite_persist_data or self.parent_screen.favourite_persist_data or {}

	-- Toggle directly by prefab name
	local current = favourites[self.prefab_name] or false
	favourites[self.prefab_name] = not current

	-- Save the updated table
	SavePersistentString(persist_naming, json.encode(favourites), false)

	-- Update local memory
	self.favourite_persist_data = favourites

	-- Update button
	local button_atlas = "images/crafting_menu.xml"
	local button_tex = favourites[self.prefab_name] and "favorite_checked.tex" or "favorite_unchecked.tex"
	if self.entity_favourite_button then
		self.entity_favourite_button:SetTextures(button_atlas, button_tex)
	end
end

return EntityFavouriteState
