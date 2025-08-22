local assets = {
	Asset("ANIM", "anim/rocky.zip"),
}

local function CreateRockyFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(0.5, 0.5, 0.5)

	inst.AnimState:SetBank("rocky")
	inst.AnimState:SetBuild("rocky")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.50)
	inst.persists = false

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_rockyfx", CreateRockyFX, assets)
