local assets = {
	Asset("ANIM", "anim/sign_mini.zip"),
	Asset("ANIM", "anim/firefighter_placement.zip"),
}

local function CreateMiniSignFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(1, 1, 1)

	inst.AnimState:SetBank("sign_mini")
	inst.AnimState:SetBuild("sign_mini")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.50)
	inst.persists = false

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_minisignfx", CreateMiniSignFX, assets)
