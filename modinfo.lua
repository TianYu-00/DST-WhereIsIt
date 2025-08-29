-- Localization
local isCN = locale == "zh" or locale == "zhr" or locale == "zht"
local function localize(en, cn)
	return not isCN and en or cn
end

-- Mod Info
name = not isCN and "Where Is It" or "在哪里"
description = not isCN
		and [[
󰀅 Where Is It 󰀅
Where Is It is a utility mod that allows you to search for entities through a customizable menu and generate a directional beam pointing to their location. It supports adding, removing, or pinning any entity, setting custom hotkeys, teleporting (requires host permission), and displays special entities and spawn points, such as Ruins Clockworks, Volt Goat Herds, Tumbleweeds, Beefalo, Lost Toys, and more.
]]
	or [[
󰀅 在哪里 󰀅
《Where Is It》 是一款实用的模组，可通过自定义菜单搜索实体并生成方向光束指向实体的位置。支持自定义添加/删除/置顶任何实体、设置专属热键、传送（需主机手动开启权限），并显示特殊实体和刷新点，如遗迹发条、伏特羊群，风滚草，牛群、遗失玩具等。
]]
author = "Tian || TianYu"
version = "1.13.0"
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
	"where is it",
	"utility",
	"tian",
}

-- Mod Config Helper
local function AddSection(lang_en, lang_cn)
	local tempName = "temp_" .. lang_en:gsub("%s+", "_"):lower()
	local front_prefix = "☆ "
	local back_prefix =
		" ────────────────────────────────────"
	local english = front_prefix .. lang_en .. back_prefix
	local chinese = front_prefix .. lang_cn .. back_prefix
	return {
		name = tempName,
		label = localize(english, chinese),
		options = { { description = "", data = 0 } },
		default = 0,
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
		default = 0,
	},
	{
		name = "Entity_Location_Search_Cooldown",
		label = localize("Location Search Cooldown (Seconds)", "实体定位冷却时间 (秒)"),
		hover = localize(
			"Entity location search cooldown per player\n0 = no cooldown",
			"每位玩家的实体定位冷却时间。\n0 = 没冷却时间。"
		),
		options = GenerateValueOptions(0, 60),
		default = 0,
	},
	{
		name = "Is_Allow_Teleport",
		label = localize("Allow Teleport", "是否允许传送"),
		hover = localize(
			"Would you like to allow your players to use the teleport feature",
			"是否允许服务器内玩家使用传送功能"
		),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = false,
	},
	{
		name = "Is_Allow_Pause",
		label = localize("Pause When Menu Opened", "菜单打开时暂停"),
		hover = localize(
			"Would you like to pause the game when mod menu opens\nIt would only trigger pause if you are playing by yourself",
			"当模组菜单打开时是否要暂停游戏？\n仅在你独自游玩时才会触发暂停"
		),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	AddSection("Special Display", "特殊显示"),
	{
		name = "Toggle_Lightninggoat",
		label = localize("Volt Goat Herd", "伏特羊群"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	{
		name = "Toggle_Beefalo",
		label = localize("Beefalo Herd", "牛群"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	{
		name = "Toggle_Tumbleweed",
		label = localize("Tumbleweed Spawner", "风滚草"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	{
		name = "Toggle_Rocky",
		label = localize("Rocky Spawner", "石虾"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	{
		name = "Toggle_Mushgnome",
		label = localize("Mushgnome Spawner", "蘑菇地精"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	{
		name = "Toggle_Bishop_Nightmare",
		label = localize("Ruins Bishop Spawner", "遗迹主教"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	{
		name = "Toggle_Knight_Nightmare",
		label = localize("Ruins Knight Spawner", "遗迹战马"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	{
		name = "Toggle_Rook_Nightmare",
		label = localize("Ruins Rook Spawner", "遗迹战车"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
	},
	{
		name = "Toggle_Lost_Toy",
		label = localize("Lost Toys Location", "遗失的玩具"),
		hover = localize("Should it be displayed", "是否显示"),
		options = {
			{ description = localize("True", "是"), data = true },
			{ description = localize("False", "否"), data = false },
		},
		default = true,
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
	},
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
