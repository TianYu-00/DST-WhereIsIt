# DST-WhereIsIt

## TO DO LIST
- [x] Features
    - [x] Custom menu screen
    - [x] Find entities 
    - [x] Directional beam
    - [x] Menu scroller
    - [ ] Search bar
    - [ ] Add entity to menu
    - [ ] Save that entity with TheSim:GetPersistentString/TheSim:SetSetting maybe. Need to look into this more

How do i go about doing the add entity to menu?
- input textbox could work for search and entity name to add
- 2 buttons 1 for search 1 for add
- add needs delete too so the entity could be removed from menu

How would the logic look like?
- we already have Entity prefab registry, but the registry imported is directly used. Maybe before we add it to scrolling grid we combine user added entity + base entity.

Some things to look into first.
- buttons have their own xml and tex, i remember messing with it. If i remember correctly its called long button or something along those lines
- for actual input, could use TextEdit template i think - used `Templates2.StandardSingleLineTextEntry` instead 

Ok do these 3 for now and go on from there, maybe work on save entity after that but ill still need some time to look into it.

About time to do some localization now. 

Also found a better alternative to worldgen_customization and worldsettings_customization icons
use scrapbook icons instead `databundles/images/images/scrapbook_icons1` 2 and 3