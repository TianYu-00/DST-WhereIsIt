local Widget = require("widgets/widget")
local Templates2 = require("widgets/redux/templates")

local EntityAdd = Class(Widget, function(self, context)
	Widget._ctor(self, "tian_whereisit_widget_entity_add")
	self.parent_screen = context.screen
	local button_atlas = "images/button_icons.xml"
	local button_tex = "save.tex"
	local button_onclick = function()
		local text = self.parent_screen.name_input.textinput.textbox:GetString()
		self:AddToEntityList(text)
	end
	-- IconButton(iconAtlas, iconTexture, labelText, sideLabel, alwaysShowLabel, onclick, textinfo, defaultTexture)
	self.entity_add_button = self:AddChild(Templates2.IconButton(button_atlas, button_tex, "", "", "", button_onclick))
	self.entity_add_button:SetScale(0.5)
end)

function EntityAdd:AddToEntityList(entity_name)
	if not entity_name or entity_name:match("^%s*$") then
		return
	end

	-- Clean up the input
	-- "^%s*(.-)%s*$" clears front and back whitespaces and keeps middle content
	entity_name = entity_name:lower():gsub("^%s*(.-)%s*$", "%1")

	-- Check for duplicates in saved entities
	for _, e in ipairs(self.parent_screen.saved_entities) do
		if e.name == entity_name then
			return
		end
	end

	-- new entity
	table.insert(self.parent_screen.saved_entities, {
		name = entity_name,
		icon_atlas = "images/scrapbook_icons3.xml",
		icon_tex = "unknown.tex",
		is_custom = true,
	})

	self.parent_screen:SaveEntities() -- save entity
	self.parent_screen:RefreshEntityList() -- refresh it

	-- Clear the input field
	self.parent_screen.name_input.textinput.textbox:SetString("")
end

return EntityAdd
