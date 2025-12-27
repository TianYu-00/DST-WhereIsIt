[h1]Where Is It[/h1]
Where Is It is a utility mod that allows you to search for entities through a customizable menu and generate a directional beam pointing to their location. It supports adding, removing, or pinning any entity, setting custom hotkeys, teleporting (requires to be toggled on), and displays special entities and spawn points, such as Ruins Clockworks, Volt Goat Herds, Tumbleweeds, Lost Toys, and more.

Inspired by [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2823963520&searchtext=Where+you+are][b]Where You Are?[/b][/url], but mod was coded from scratch.

English version [url=https://dontstarve.wiki.gg/][b]Dont't Starve Together Wiki[/b][/url]

Check [url=https://steamcommunity.com/sharedfiles/filedetails/changelog/3549828735][b]change notes[/b][/url] to see what I have updated.

Please do feel free to report any bugs or crashes. Would appreciate it if you could provide a detailed description on how to reproduce the bug along your server_log file.

[h1]在哪里[/h1]
《Where Is It》 是一款实用模组，可通过自定义菜单搜索实体并生成方向光束指向实体的位置。支持自定义添加/删除/置顶任何实体、设置专属热键、传送（需手动开启权限），并显示特殊实体和刷新点，如遗迹发条、伏特羊群，风滚草，遗失玩具等。

受[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2823963520&searchtext=Where+you+are][b]Where You Are?[/b][/url]启发，可是模组是从零开始编写的。

中文版 [url=https://dontstarve.huijiwiki.com/wiki/Project:%E5%AE%9E%E4%BD%93%E6%A3%80%E7%B4%A2%E5%99%A8][b]饥荒Wiki[/b][/url]

查看 [url=https://steamcommunity.com/sharedfiles/filedetails/changelog/3549828735][b]变更说明[/b][/url] 以了解更新的内容。

如果遇到报错或者什么可以评论区跟我说一下。能提供详细的复现步骤以及服务器日志文件那就更好了，非常感谢。

[h1]v1.16.0 New Features[/h1]
[b]Features[/b]
    [list]
        [*][✔]Added more suggested entities - fissures, oceanwhirlbigportal
        [*][✔]Remove shift-teleport tool tip when teleport is disabled by host
        [*][✔]Menu button is now draggable and would be saved persistently
        [*][✔]Show amount of entities found when looking up
    [/list]
[b]Bug Fixes[/b]
    [list]
        [*][✔]Bug reported by player @云泥之别 should be fixed (added ThePlayer check).
        [*][✔]v1.16.1 Fixed the menu button disappearing issue reported by player @从小就很帅 (caused by resolution differences).
        [*][✔]v1.16.2 Fixed CheckLookupState DoTaskInTime nil issue
        [*][✔]v1.16.3 Removed beefalo spawner fx and rocky spawner fx
    [/list]

[h1]v1.16.0 新加功能[/h1]
[b]功能[/b]
    [list]
        [*][✔]添加了更多建议的实体 - nightmare fissures、oceanwhirlbigportal  
        [*][✔]当传送被主机禁用时，移除 Shift 传送提示  
        [*][✔]菜单按钮现在可以拖动，并且位置会被持久保存  
        [*][✔]搜索实体时显示找到的数量
    [/list]
[b]修复[/b]
    [list]
        [*][✔]应该修复了 @云泥之别 玩家提出的崩溃问题 （加了ThePlayer检测）
        [*][✔]v1.16.1 修复了 @从小就很帅 玩家提出的按钮消失问题 （不同分辨率导致的）
        [*][✔]v1.16.2 修复了CheckLookupState DoTaskInTime导致的问题
        [*][✔]v1.16.3 移除了牛群跟石虾虚影
    [/list]

[h1] Known Issue [/h1]
    [list]
        [*]The mod's in game settings feature doesn't work well with [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2657513551&searchtext=Dont+starve+alone] [b]Don't Starve Alone[/b] [/url]
        [*]Some players have reported that certain fx may cause client lag or crashes, and the specific cause has not yet been identified. If you encounter a similar issue, you can temporarily disable the related effects in the configuration settings and leave feedback to help me investigate further.
       [*]A couple of entity icons are missing due to Klei's changes to image files.
    [/list]
[h1] 已知问题 [/h1]
    [list]
        [*]模组游戏内的设置功能不是很兼容 [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2657513551&searchtext=Dont+starve+alone] [b]独行长路[/b] [/url]
        [*]有玩家反馈部分虚影效果可能导致客户端卡顿或崩溃，目前尚未查明具体原因。若你也遇到类似情况，可在配置设置中暂时关闭相关特效，并留言反馈以便我进一步排查。
        [*]因为科雷对某些图片做出了修改/移除导致了几个实体图片缺失。
    [/list]

[h1]Q&A[/h1]
[h3]How do I reset my in game settings?[/h3]
[list]
	[*]Open WhereIsIt settings menu -> reset -> save
[/list]
Or
[list]
	[*]Navigate to [i]%USERPROFILE%\Documents\Klei\DoNotStarveTogether\<Steam32 ID>\client_save [/i]
	[*]Remove the file named [i]tian_whereisit_persist_settings[/i] and finally reboot the game
[/list]


[h3]如何重置游戏内设置？[/h3]
[list]
	[*]打开游戏内设置菜单 ->  重置 -> 保存
[/list]
Or
[list]
	[*]进入目录 [i]%USERPROFILE%\Documents\Klei\DoNotStarveTogether\<Steam32 ID>\client_save [/i]
	[*]删除名为 [i]tian_whereisit_persist_settings[/i] 的文件，然后重启游戏
[/list]

[h1] Default Keys[/h1]
Menu Key = O
菜单键 = O






<!-- this is used for workshop description formatting
https://codebeautify.org/bbcode-viewer
https://steamcommunity.com/comment/WorkshopItem/formattinghelp
https://steamcommunity.com/comment/Guide/formattinghelp 
https://steamcommunity.com/comment/Recommendation/formattinghelp

[✔]
[✘]
-->