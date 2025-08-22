local assets = {
	Asset("ANIM", "anim/tumbleweed.zip"),
}

local function CreateTumbleweedFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(0.5, 0.5, 0.5)

	inst.AnimState:SetBank("tumbleweed")
	inst.AnimState:SetBuild("tumbleweed")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.50)
	inst.persists = false

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_tumbleweedfx", CreateTumbleweedFX, assets)
