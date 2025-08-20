-- Localization
local isCN = locale == "zh" or locale == "zhr" or locale == "zht"
local function localize(en, cn)
    return not isCN and en or cn
end

-- Mod Info
name = not isCN and "Where Is It" or "在哪里"
description = not isCN and [[
󰀅 Where Is It 󰀅
Where Is It is a quality-of-life mod for Don't Starve Together that makes finding entities much easier. It adds a searchable entity menu with fuzzy search, lets you add and remove custom entities, and gives you the ability to pin important ones so they always appear first. Selecting an entity highlights its location with a directional arrow, helping you quickly track it down in the world.

The mod also features fully customizable hotkeys that can be changed at any time during gameplay. All of your settings, including hotkeys and custom entities, are saved persistently between servers, so your preferences carry over seamlessly across different worlds and sessions.

]]
or
[[
󰀅 在哪里 󰀅
《Where Is It》 是一款专为《饥荒：联机版》打造的实用性模组，让寻找各种物体更加轻松。它提供模糊搜索的实体菜单，让你快速找到目标，还能自由添加或移除自定义实体，并支持将常用或重要的实体置顶，方便随时使用。点击菜单中的实体后，屏幕上会出现方向箭头，指引你前往它所在的位置，再也不用担心迷路或找不到东西。

模组还支持自定义快捷键，并且可以在游戏过程中随时修改。无论是快捷键设置还是自定义实体，都会被自动保存，并在不同的服务器和世界中保持一致，让你的游戏体验更加顺手和省心。

]]
author = "Tian || TianYu"
version = "1.4.0"
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

-- Mod Config
configuration_options = {
    AddSection("Settings", "设置"),
    {
        name = "Arrow_Limit_Per_Player",
        label = localize("Arrow Limit Per Player (Seconds)", "每位玩家的方向箭头上限 (秒)"),
         hover = localize(
            "Sets the limit of directional beams per player.\n0 = unlimited",
            "设置每个玩家的方向光束数量上限。\n0 = 无限。"
        ),
        options = GenerateValueOptions(0, 50),
        default = 0
    },
    {
        name = "Entity_Location_Search_Cooldown",
        label = localize("Location Search Cooldown (Seconds)", "实体定位冷却时间 (秒)"),
         hover = localize(
            "Entity location search cooldown per player\n0 = no cooldown",
            "每位玩家的实体定位冷却时间。\n0 = 没冷却时间。"
        ),
        options = GenerateValueOptions(0, 60),
        default = 0
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
-- https://dst-api-docs.fandom.com/wiki/Home
-- https://dst-api-docs.fandom.com/wiki/Modinfo.lua
-- https://forums.kleientertainment.com/forums/topic/116302-ultromans-tutorial-collection-newcomer-intro/
-- https://forums.kleientertainment.com/forums/topic/126774-documentation-list-of-all-engine-functions/
-- https://dst-api-docs.fandom.com/wiki/AddKeyDownHandler
-- https://forums.kleientertainment.com/forums/topic/118009-tutorial-custom-user-interfaces/
-- https://dst-api-docs.fandom.com/wiki/Persistent_Strings
-- https://dst-api-docs.fandom.com/wiki/TheSim