local assets = {
	Asset("ANIM", "anim/grassgecko.zip"),
}

local function CreateGrassgeckoFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(0.7, 0.7, 0.7)

	inst.AnimState:SetBank("grassgecko")
	inst.AnimState:SetBuild("grassgecko")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.50)
	inst.persists = false

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_grassgeckofx", CreateGrassgeckoFX, assets)
