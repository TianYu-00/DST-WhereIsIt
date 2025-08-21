local assets = {
	Asset("ANIM", "anim/firefighter_placement.zip"),
}

-- This is taken from my other mod(Lazy-Wortox) but changed its logic to fit
local function CreateRangeIndicator()
	local circle = CreateEntity()
	circle.entity:AddTransform()
	circle.entity:AddAnimState()
	circle.entity:AddNetwork()
	circle.entity:SetPristine()
	circle.Transform:SetRotation(0)
	-- circle.Transform:SetScale(scale, scale, scale)

	circle.AnimState:SetBank("firefighter_placement")
	circle.AnimState:SetBuild("firefighter_placement")
	circle.AnimState:PlayAnimation("idle", true)
	circle.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	circle.AnimState:SetLayer(LAYER_BACKGROUND)
	circle.AnimState:SetSortOrder(3)
	circle.AnimState:SetLightOverride(1)
	circle.AnimState:SetAddColour(unpack(WHITE))
	circle.persists = false

	circle:AddTag("NOCLICK")
	circle:AddTag("placer")

	return circle
end

return Prefab("tian_whereisit_radiusfx", CreateRangeIndicator, assets)
