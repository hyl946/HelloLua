------------------------------------------------------------------------
--  Class include: ParticleBatchNode, ParticleSystem, ParticleSystemQuad
-------------------------------------------------------------------------

require "hecore.display.CocosObject"

kParticleDurationInfinity = -1
kParticleDefaultCapacity = 500
--
-- ParticleBatchNode ---------------------------------------------------------
--

ParticleBatchNode = class(CocosObject);

function ParticleBatchNode:ctor( refCocosObj )
  self.touchEnabled = false
  self.touchChildren = false
end
function ParticleBatchNode:toString()
	return string.format("ParticleBatchNode [%s]", self.name and self.name or "nil");
end

--
-- public props ---------------------------------------------------------
--

--maximum particles of the system
function ParticleBatchNode:getTotalParticles() return self.refCocosObj:getTotalParticles() end

--Quantity of particles that are being simulated at the moment
function ParticleBatchNode:getParticleCount() return self.refCocosObj:getParticleCount() end

--CCTexture2D
function ParticleBatchNode:getTexture() return self.refCocosObj:getTexture() end
function ParticleBatchNode:setTexture(v) self.refCocosObj:setTexture(v) end	

function ParticleBatchNode:getBlendFunc() return self.refCocosObj:getBlendFunc() end
function ParticleBatchNode:setBlendFunc(v) self.refCocosObj:setBlendFunc(v) end

function ParticleBatchNode:disableParticle(v) self.refCocosObj:disableParticle(v) end	

function ParticleBatchNode:insertChild(v) self.refCocosObj:insertChild(pSystem, index) end	

function ParticleBatchNode:create(fileImage, capacity)
  if not fileImage then 
    if _G.isLocalDevelopMode then printx(0, "create ParticleBatchNode fail. nill of fnt file") end
    return nil 
  end
  capacity = capacity or kParticleDefaultCapacity
  return ParticleBatchNode.new(CCParticleBatchNode:create(fileImage, capacity))
end

--CCTexture2D
function ParticleBatchNode:createWithTexture(tex, capacity)
  if not tex then 
    if _G.isLocalDevelopMode then printx(0, "create ParticleBatchNode fail. nill of tex") end
    return nil 
  end
  capacity = capacity or kParticleDefaultCapacity
  return ParticleBatchNode.new(CCParticleBatchNode:createWithTexture(tex, capacity))
end

--
-- ParticleSystem ---------------------------------------------------------
--

ParticleSystem = class(CocosObject);

function ParticleSystem:ctor( refCocosObj )
  self.touchEnabled = false
  self.touchChildren = false
end
function ParticleSystem:toString()
	return string.format("ParticleSystem [%s]", self.name and self.name or "nil");
end

--
-- public props ---------------------------------------------------------
--
--CCTexture2D
function ParticleSystem:getTexture() return self.refCocosObj:getTexture() end
function ParticleSystem:setTexture(v) self.refCocosObj:setTexture(v) end	

function ParticleSystem:getBlendFunc() return self.refCocosObj:getBlendFunc() end
function ParticleSystem:setBlendFunc(v) self.refCocosObj:setBlendFunc(v) end

function ParticleSystem:isAutoRemoveOnFinish() return self.refCocosObj:isAutoRemoveOnFinish() end
function ParticleSystem:setAutoRemoveOnFinish(v) self.refCocosObj:setAutoRemoveOnFinish(v) end

function ParticleSystem:getDuration() return self.refCocosObj:getDuration() end
function ParticleSystem:setDuration(v) self.refCocosObj:setDuration(v) end

function ParticleSystem:getAngle() return self.refCocosObj:getAngle() end
function ParticleSystem:setAngle(v) self.refCocosObj:setAngle(v) end

function ParticleSystem:getAngleVar() return self.refCocosObj:getAngleVar() end
function ParticleSystem:setAngleVar(v) self.refCocosObj:setAngleVar(v) end
 
function ParticleSystem:stopSystem() return self.refCocosObj:stopSystem() end
function ParticleSystem:resetSystem() return self.refCocosObj:resetSystem() end

function ParticleSystem:onRemoveFromStage() 
  if not self.removedFromStage and self.parent and self:isAutoRemoveOnFinish() then
    self.removedFromStage = true
    --if _G.isLocalDevelopMode then printx(0, "ParticleSystem:onRemoveFromStage") end
    self.parent:removeChild(self, true, true)
  end
end



function ParticleSystem:create(plistFile)
  if not plistFile then 
    if _G.isLocalDevelopMode then printx(0, "create ParticleSystem fail. nill of fnt file") end
    return nil 
  end
  return ParticleSystem.new(CCParticleSystem:create(plistFile))
end

--
-- ParticleSystemQuad ---------------------------------------------------------
--

ParticleSystemQuad = class(ParticleSystem);

function ParticleSystemQuad:toString()
	return string.format("ParticleSystemQuad [%s]", self.name and self.name or "nil");
end

--CCSpriteFrame
function ParticleSystem:setDisplayFrame(v) self.refCocosObj:setDisplayFrame(v) end

function ParticleSystem:getPosVar() return self.refCocosObj:getPosVar() end
function ParticleSystem:setPosVar(v) self.refCocosObj:setPosVar(v) end

--CCTexture2D, CCRect
function ParticleSystem:setTextureWithRect(v) self.refCocosObj:setTextureWithRect(texture, rect) end

function ParticleSystem:setTotalParticles(v) self.refCocosObj:setTotalParticles(v) end
function ParticleSystem:getTotalParticles(v) return self.refCocosObj:getTotalParticles(v) end

function ParticleSystemQuad:create(plistFile)
  if not plistFile then 
    if _G.isLocalDevelopMode then printx(0, "create ParticleSystemQuad fail. nill of fnt file") end
    return nil 
  end
  return ParticleSystemQuad.new(CCParticleSystemQuad:create(plistFile))
end

if __PURE_LUA__ then
	require "plua.myParticleSystem"
end