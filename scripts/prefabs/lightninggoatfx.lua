local assets = {
	Asset("ANIM", "anim/lightning_goat_build.zip"),
	Asset("ANIM", "anim/lightning_goat_basic.zip"),
}

-- refer to lightninggoat.lua
local function CreateLightningGoatFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(0.5, 0.5, 0.5)

	inst.AnimState:SetBank("lightning_goat")
	inst.AnimState:SetBuild("lightning_goat_build")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.50)
	inst.persists = false

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_lightninggoatfx", CreateLightningGoatFX, assets)
