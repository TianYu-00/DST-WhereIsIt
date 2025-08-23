local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local json = require("json")

local EntityHideState = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_HIDDEN_STATE .. context.index)
	self.parent_screen = context.main_parent_screen
	self.screen = context.screen
end)

-- Load hidden entity state from disk
function EntityHideState:GetHiddenPersistentData(callback)
	TheSim:CheckPersistentStringExists(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_HIDE_BASE_ENTITY, function(exists)
		local hidden = {}

		if exists then
			TheSim:GetPersistentString(
				TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_HIDE_BASE_ENTITY,
				function(success, str)
					if success and str and str ~= "" then
						local ok, data = pcall(json.decode, str)
						if ok and type(data) == "table" then
							hidden = data
						end
					end
					callback(hidden)
				end
			)
		else
			-- No string exists yet, create empty table
			SavePersistentString(
				TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_HIDE_BASE_ENTITY,
				json.encode(hidden),
				false
			)
			callback(hidden)
		end
	end)
end

-- Toggle hide/unhide for an entity
function EntityHideState:ToggleHidden(entity_name)
	local hidden = self.parent_screen.hidden_persist_data or {}

	-- Toggle directly by prefab name
	local current = hidden[entity_name] or false
	hidden[entity_name] = not current

	-- Save the updated table
	SavePersistentString(TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_HIDE_BASE_ENTITY, json.encode(hidden), false)

	-- Update local memory
	self.hidden_persist_data = hidden
end

-- Check if entity is hidden
function EntityHideState:CheckHidden(entity_name)
	local hidden = self.parent_screen.hidden_persist_data or {}
	return hidden[entity_name] or false
end

return EntityHideState
