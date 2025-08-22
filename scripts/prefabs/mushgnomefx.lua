local assets = {
	Asset("ANIM", "anim/grotto_mushgnome.zip"),
}

local function CreateMushgnomeFX()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:SetPristine()
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(0.5, 0.5, 0.5)

	inst.AnimState:SetBank("grotto_mushgnome")
	inst.AnimState:SetBuild("grotto_mushgnome")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.50)
	-- inst.AnimState:SetHighlightColour(1, 1, 1, 0.5) -- this just highlights it
	-- inst.AnimState:SetLightOverride(1) -- this sets the entity to glow in the dark, doesnt affect surroundings, little bit better. Think ill go with this.
	inst.persists = false

	-- amulet.lua line 599
	-- little glow light similar to the yellow amulet, little bit cheaty tho.
	-- inst.entity:AddLight()
	-- inst.Light:SetRadius(2)
	-- inst.Light:SetFalloff(0.7)
	-- inst.Light:SetIntensity(0.65)
	-- inst.Light:SetColour(223 / 255, 208 / 255, 69 / 255)
	-- inst.Light:Enable(true)

	inst:AddTag("FX")
	return inst
end

return Prefab("tian_whereisit_mushgnomefx", CreateMushgnomeFX, assets)
