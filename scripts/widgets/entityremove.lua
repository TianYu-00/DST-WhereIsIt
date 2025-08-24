local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local json = require("json")
local DebugLog = require("utils/debug")

local EntityRemove = Class(Widget, function(self, context)
	Widget._ctor(self, TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.WIDGET_ENTITY_REMOVE .. context.index)
	self.parent_screen = context.main_parent_screen
	self.screen = context.screen
	DebugLog("EntityRemove: Initialized for index " .. tostring(context.index))
end)

function EntityRemove:RemoveEntity(entity_name)
	if not entity_name then
		DebugLog("EntityRemove: RemoveEntity called with nil")
		return
	end

	DebugLog("EntityRemove: Removing entity -> " .. entity_name)

	for i, e in ipairs(self.parent_screen.saved_entities) do
		if e.name == entity_name then
			table.remove(self.parent_screen.saved_entities, i)
			DebugLog("EntityRemove: Entity removed from saved_entities -> " .. entity_name)
			break
		end
	end

	if self.parent_screen.favourite_persist_data and self.parent_screen.favourite_persist_data[entity_name] ~= nil then
		self.parent_screen.favourite_persist_data[entity_name] = nil
		SavePersistentString(
			TIAN_WHEREISIT_GLOBAL_DATA.IDENTIFIER.PERSIST_FAVOURITES,
			json.encode(self.parent_screen.favourite_persist_data),
			false
		)
		DebugLog("EntityRemove: Entity removed from favourites -> " .. entity_name)
	end

	DebugLog("EntityRemove: Deletion completed -> " .. entity_name)
	self.parent_screen:SaveEntities()
	self.parent_screen:RefreshEntityList()
end

return EntityRemove
