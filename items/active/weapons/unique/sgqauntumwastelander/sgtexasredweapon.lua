require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

function init()
	animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
	animator.setGlobalTag("directives", "")
	animator.setGlobalTag("bladeDirectives", "")

	self.weapon = Weapon:new()
	self.weapon.currentType = config.getParameter("currentType","blade")

	self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
	self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)

	local primaryAbility = getPrimaryAbility()
	self.weapon:addAbility(primaryAbility)

	local secondaryAttack = getAltAbility()
	if secondaryAttack then
		self.weapon:addAbility(secondaryAttack)
	end

	self.weapon:init()

	self.activeTime = config.getParameter("activeTime", 2.0)
	self.weapon.activeTimer = 0
	
	animator.setAnimationState("blade", self.weapon.currentType.."Idle")
end

function update(dt, fireMode, shiftHeld)
	self.weapon:update(dt, fireMode, shiftHeld)

	local nowActive = self.weapon.currentType == "blade" and ((fireMode == "primary") or (fireMode == "alt" and not shiftHeld))
	if nowActive and self.weapon.currentType == "blade" then
		if self.weapon.activeTimer == 0 then
			animator.setAnimationState("blade", "extend")
		end
		self.weapon.activeTimer = self.activeTime
	elseif self.weapon.activeTimer > 0 then
		self.weapon.activeTimer = math.max(0, self.weapon.activeTimer - dt)
		if self.weapon.activeTimer == 0 then
			animator.setAnimationState("blade", "retract")
		end
	end
end

function uninit()
	self.weapon:uninit()
end