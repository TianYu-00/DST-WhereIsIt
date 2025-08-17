# DST-WhereIsIt

**Where Is It**

**Where Is It** is a utility mod for **Don't Starve Together** that helps players quickly locate creatures, resources, and other entities in the game world. The mod provides a menu interface with a smooth scroll bar, allowing players to freely browse, search, add, remove or favourite entities. Once a target is selected, a directional beam will point towards the specified location. Any entities that the player add will persist across different servers if the "Where Is It" mod is installed.

Inspired by [**Where You Are?**](https://steamcommunity.com/sharedfiles/filedetails/?id=2823963520&searchtext=Where+you+are), but mod was coded from scratch.

**在哪里**

**Where Is It** 是一款适用于**饥荒联机版**的实用模组，可帮助玩家快速定位游戏世界中的生物、资源及其他实体。该模组提供带平滑滚动条的菜单界面，允许玩家自由浏览、搜索、添加、删除或标记实体。当选中目标后，方向光束将指向指定位置。玩家添加的实体在安装了“Where Is It”模组的服务器间可同步显示。

受[**Where You Are?**](https://steamcommunity.com/sharedfiles/filedetails/?id=2823963520&searchtext=Where+you+are)启发，可是模组是从零开始编写的。

## TO DO LIST
- [x] Features
    - [x] Minimum Viable Product (MVP)
        - [x] Custom menu screen
        - [x] Find entities 
        - [x] Directional beam
        - [x] Menu scroller
        - [x] Base entities
    - [x] Additional Features
        - [x] Search entity from menu
        - [x] Add entity to menu
        - [x] Save the new added entity as persistent string
        - [x] Remove entity from menu
        - [x] Update more base entities
        - [x] Volt goat herd position
        - [x] Repeat previous entity search
        - [x] Clear old directional beam when new beam is generated
        - [x] Favourite entity
        - [ ] Allow players to have their own keybinds


### Code refactor
Ok lets refactor some of the codes first before player in game key binds. 
Player in game key binds would prob gonna be a lot of logic so its best to do refactor before it.

### Allow users to have their own keybinds

- Move all keybinds to in game instead of mod config.

    