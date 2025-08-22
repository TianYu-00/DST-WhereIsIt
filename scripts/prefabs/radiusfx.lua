local assets = {
	Asset("ANIM", "anim/firefighter_placement.zip"),
}

-- This is taken from my other mod(Lazy-Wortox) but changed its logic to fit
local function CreateRangeIndicator()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetRotation(0)
	-- inst.Transform:SetScale(scale, scale, scale)

	inst.AnimState:SetBank("firefighter_placement")
	inst.AnimState:SetBuild("firefighter_placement")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetAddColour(unpack(WHITE))
	inst.persists = false

	inst:AddTag("NOCLICK")
	inst:AddTag("placer")

	return inst
end

return Prefab("tian_whereisit_radiusfx", CreateRangeIndicator, assets)
