local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")

local EntityRemove = Class(Widget, function(self, context)
	Widget._ctor(self, "tian_whereisit_widget_entity_remove_" .. context.index)
	self.parent_screen = context.main_parent_screen
	self.screen = context.screen
end)

function EntityRemove:RemoveEntity(entity_name)
	if not entity_name then
		return
	end

	for i, e in ipairs(self.parent_screen.saved_entities) do
		if e.name == entity_name then
			table.remove(self.parent_screen.saved_entities, i)
			break
		end
	end

	-- Remove from favourites table if exists
	if self.parent_screen.favourite_persist_data and self.parent_screen.favourite_persist_data[entity_name] ~= nil then
		self.parent_screen.favourite_persist_data[entity_name] = nil
		-- Save updated favourites persistently
		local persist_naming = "tian_whereisit_persist_entity_favourite_states"
		SavePersistentString(persist_naming, json.encode(self.parent_screen.favourite_persist_data), false)
	end
	print(entity_name, "deleted")

	self.parent_screen:SaveEntities()
	self.parent_screen:RefreshEntityList()
end

return EntityRemove
