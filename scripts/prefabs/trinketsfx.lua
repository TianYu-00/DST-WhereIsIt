local assets = {
	Asset("ANIM", "anim/trinkets.zip"),
}

local function CreateLostToyFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetScale(1, 1, 1)

	inst.AnimState:SetBank("trinkets")
	inst.AnimState:SetBuild("trinkets")
	inst.AnimState:PlayAnimation("1", true) -- ill set a default here just in case i forgot to later on
	inst.AnimState:SetMultColour(1, 1, 1, 0.50)
	inst.AnimState:SetHaunted(true)
	inst.persists = false

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_losttoyfx", CreateLostToyFX, assets)

----------------------------------------- Comments -----------------------------------------

-- wendy lost toys - refer to lost_toys.lua line 6
-- local toy_trinket_nums = {
-- 	1,
-- 	2,
-- 	7,
-- 	10,
-- 	11,
-- 	14,
-- 	18,
-- 	19,
-- 	42,
-- 	43,
-- }
