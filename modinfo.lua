-- Localization
local isCN = locale == "zh" or locale == "zhr" or locale == "zht"
local function localize(en, cn)
    return not isCN and en or cn
end

-- Mod Info
name = not isCN and "Where Is It" or "在哪里"
description = not isCN and [[
󰀅 Where Is It 󰀅
Where Is It is a practical mod for Don't Starve Together that helps players quickly locate creatures, resources, and other entities in the game world. 

The mod provides a menu interface with a smooth scroll bar, allowing players to freely browse, search, add, or remove entities. 

Once a target is selected, a directional beam will point towards the specified location. 

Any entities added by the player will be saved to the current cluster.
]]
or
[[
󰀅 在哪里 󰀅
Where Is It 是一款适用于饥荒联机版的实用模组，可帮助玩家快速定位游戏世界中的生物、资源及其他实体。

该模组提供带平滑滚动条的菜单界面，允许玩家自由浏览、搜索、添加或移除实体。

当选中目标后，方向光束将指向指定位置。玩家添加的任何实体都将保存至当前存档。
]]
author = "Tian || TianYu"
version = "1.0.0"
forumthread = ""

-- Mod Icon
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- Client Or Server Sided
client_only_mod = false
all_clients_require_mod = true

-- Mod Compatibility
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
hamlet_compatible = false
forge_compatible = false

-- Api Version
api_version = 10

-- Tags
server_filter_tags = {
   "where is it", "utility"
}

-- Key Options
local key_options = {}
local keys = {
    "None",
    -- Numbers
    "0","1","2","3","4","5","6","7","8","9",
    "None",
    -- Letters
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "None",
    -- Function keys
    "F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
    "None",
    -- Numpad
    "KP_0","KP_1","KP_2","KP_3","KP_4","KP_5","KP_6","KP_7","KP_8","KP_9",
    "KP_PERIOD","KP_DIVIDE","KP_MULTIPLY","KP_MINUS","KP_PLUS",
    "KP_ENTER","KP_EQUALS",
    "None",
    -- Control & Modifier keys
    "TAB","SPACE","ENTER","ESCAPE","BACKSPACE","INSERT","DELETE","HOME","END","PAGEUP","PAGEDOWN",
    "PAUSE","PRINT","CAPSLOCK","SCROLLOCK","LSHIFT","RSHIFT","LCTRL","RCTRL","LALT","RALT",
    "LSUPER","RSUPER",
    "None",
    -- Symbols / Punctuation
    "MINUS","EQUALS","PERIOD","SLASH","SEMICOLON","LEFTBRACKET","RIGHTBRACKET","BACKSLASH","TILDE",
    "None",
    -- Arrows
    "UP","DOWN","RIGHT","LEFT",
    -- Mouse Buttons -- strings.lua, line 13640
    "\238\132\128", "\238\132\129", "\238\132\130","\238\132\133","\238\132\134","\238\132\131","\238\132\132"
}
for i = 1, #keys do
    key_options[i] = {description = keys[i], data = keys[i]}
end

-- Value Options
local function GenerateValueOptions(min, max, step)
    local options = {}
    local i = 1
    for v = min, max, step or 1 do
        options[i] = { description = v, data = v }
        i = i + 1
    end
    return options
end

-- Mod Config Helper
local function AddSection(lang_en, lang_cn)
    local tempName = "temp_"..lang_en:gsub("%s+", "_"):lower()
    local front_prefix = "☆ "
    local back_prefix = " ────────────────────────────────────"
    local english = front_prefix .. lang_en .. back_prefix
    local chinese = front_prefix .. lang_cn .. back_prefix
    return {
        name = tempName,
        label = localize(english, chinese),
        options = {{description = "", data = 0}},
        default = 0
    }
end

-- Mod Config
configuration_options = {
    AddSection("Settings", "设置"),
    {
        name = "Menu_Key",
        label = localize("Menu Key", "菜单键"),
        hover = localize("Used to open the mod menu", "用于打开模组菜单"),
        options = key_options,
        default = "O",
    },
    {
        name = "Repeat_Lookup_Key",
        label = localize("Repeat Position Lookup Key", "重复定位快键"),
        hover = localize("", ""),
        options = key_options,
        default = "V",
    },
    AddSection("Debug", "调试"),
    {
        name = "Debug_Mode",
        label = localize("Debug Mode", "调试模式"),
        hover = localize(
            "Debug mode will print additional information to the console.\nUseful for troubleshooting or development.",
            "调试模式会在控制台显示额外信息。\n有助于故障排除或开发。"
        ),
        options = {
            { description = localize("True", "是"), data = true },
            { description = localize("False", "否"), data = false },
        },
        default = false,
    }
}
----------------------------------- Comments ----------------------------------- 

-- Emoji Icons
-- Source: https://dst-api-docs.fandom.com/wiki/Icon_codes

-- ["Red skull"] = "󰀀",
-- ["Beefalo"] = "󰀁",
-- ["Chest"] = "󰀂",
-- ["Chester"] = "󰀃",
-- ["Crockpot"] = "󰀄",
-- ["Eye"] = "󰀅",
-- ["Teeth"] = "󰀆",
-- ["Farm"] = "󰀇",

-- ["Fire"] = "󰀈",
-- ["Ghost"] = "󰀉",
-- ["Tombstone"] = "󰀊",
-- ["Meatbat"] = "󰀋",
-- ["Hammer"] = "󰀌",
-- ["Heart"] = "󰀍",
-- ["Stomach"] = "󰀎",
-- ["Lightbulb"] = "󰀏",

-- ["Pig"] = "󰀐",
-- ["Manure"] = "󰀑",
-- ["Red gem"] = "󰀒",
-- ["Brain"] = "󰀓",
-- ["Science machine"] = "󰀔",
-- ["White skull"] = "󰀕",
-- ["Top hat"] = "󰀖",
-- ["Spider net"] = "󰀗",

-- ["Swords"] = "󰀘",
-- ["Strong arm"] = "󰀙",
-- ["Gold nugget"] = "󰀚",
-- ["Torch"] = "󰀛",
-- ["Red flower"] = "󰀜",
-- ["Alchemy engine"] = "󰀝",
-- ["Backpack"] = "󰀞",
-- ["Bee hive"] = "󰀟",

-- ["Berry bush"] = "󰀠",
-- ["Carrot"] = "󰀡",
-- ["Fried egg"] = "󰀢",
-- ["Eyeplant"] = "󰀣",
-- ["Firepit"] = "󰀤",
-- ["Beefalo horn"] = "󰀥",
-- ["Meat"] = "󰀦",
-- ["Diamond"] = "󰀧",

-- ["Salt"] = "󰀨",
-- ["Shadow Manipulator"] = "󰀩",
-- ["Shovel"] = "󰀪",
-- ["Thumb up"] = "󰀫",
-- ["Trap"] = "󰀬",
-- ["Goblet"] = "󰀭",
-- ["Hand"] = "󰀮",
-- ["Wormhole"] = "󰀯"


-- Looking through my code and wanting to mod yourself? have a look at the below links.
-- Links
-- https://dst-api-docs.fandom.com/wiki/Modinfo.lua
-- https://forums.kleientertainment.com/forums/topic/116302-ultromans-tutorial-collection-newcomer-intro/
-- https://forums.kleientertainment.com/forums/topic/126774-documentation-list-of-all-engine-functions/
-- https://dst-api-docs.fandom.com/wiki/AddKeyDownHandler
-- https://forums.kleientertainment.com/forums/topic/118009-tutorial-custom-user-interfaces/