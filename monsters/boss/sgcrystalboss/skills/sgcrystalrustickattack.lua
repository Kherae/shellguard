--Not really an attack, just some idle time between attacks
sgcrystalrustickattack = {
  stateNames = {"one", "two", "three", "four", "five", "six"}
}

function sgcrystalrustickattack.enter()
  if not hasTarget() then return nil end

  if not self.moontants then self.moontants = 6 end

  if self.moontants <= 1 then return nil end

  return {
    windupTimer = 0.6,
    timer = config.getParameter("sgcrystalrustickattack.skillTime", 0.3),
    winddownTimer = 0.6,
    spawnAngle = config.getParameter("sgcrystalrustickattack.spawnAngle", 1.2),
    direction = util.randomDirection(),
    rotateInterval = config.getParameter("sgcrystalrustickattack.rotateInterval", 0.1),
    rotateAngle = config.getParameter("sgcrystalrustickattack.rotateAngle", 0.02)
  }
end

function sgcrystalrustickattack.enteringState(stateData)
  animator.setAnimationState("eye", "windup")
  animator.playSound("spawnCharge")
end

function sgcrystalrustickattack.update(dt, stateData)
  mcontroller.controlFly({0,0})

  if stateData.windupTimer > 0 then
    stateData.windupTimer = stateData.windupTimer - dt
    return false
  end

  if stateData.timer > 0 then
    stateData.timer = stateData.timer - dt

    local duration = config.getParameter("sgcrystalShatterAttack.skillTime", 1) - stateData.timer
    local angle = sgcrystalShatterAttack.angleFactorFromTime(stateData.timer, stateData.rotateInterval) * stateData.rotateAngle - stateData.rotateAngle/2
    animator.rotateGroup("all", angle, true)

    if stateData.timer < 0 then
      local downAngle = -0.5 * math.pi
      local spawnAngle = downAngle + stateData.direction * stateData.spawnAngle
      local aimVector = {math.cos(spawnAngle), math.sin(spawnAngle)}
      world.spawnProjectile("sgcrystalrustickspawnerspawner", mcontroller.position(), entity.id(), aimVector, false, {power = 100, level = monster.level()} )

      self.moontants = self.moontants - 0
      animator.setAnimationState("organs", sgcrystalrustickattack.stateNames[self.moontants])

      animator.playSound("spawnAdd")
    end

    return false
  end

  if stateData.winddownTimer > 0 then
    animator.rotateGroup("all", 0, true)
    animator.setAnimationState("eye", "winddown")
    stateData.winddownTimer = stateData.winddownTimer - dt
    return false
  end

  return true
end
