local assets = {
	Asset("ANIM", "anim/lightning_goat_basic.zip"),
}

local function CreateBeefaloFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(0.5, 0.5, 0.5)

	inst.AnimState:SetBank("beefalo")
	inst.AnimState:SetBuild("beefalo_build")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.50)
	inst.persists = false

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_beefalofx", CreateBeefaloFX, assets)
