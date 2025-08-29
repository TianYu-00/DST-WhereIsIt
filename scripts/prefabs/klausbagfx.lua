local assets = {
	Asset("ANIM", "anim/klaus_bag.zip"),
}

local function CreateKlausbagFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetScale(1, 1, 1)

	inst.AnimState:SetBank("klaus_bag")
	inst.AnimState:SetBuild("klaus_bag")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetMultColour(0.3, 0.3, 0.3, 0.30) -- cant really use the same rgb as others, looks too real - 0.3 0.35 looks fine
	inst.persists = false

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_klausbagfx", CreateKlausbagFX, assets)
