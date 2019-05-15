------------------------------------------------------------------------
--  Class include: ParticleBatchNode, ParticleSystem, ParticleSystemQuad
-------------------------------------------------------------------------

require "hecore.display.CocosObject"

kParticleDurationInfinity = -1
kParticleDefaultCapacity = 500
--
-- ParticleBatchNode ---------------------------------------------------------
--

myParticleBatchNode = class(CocosObject);

function myParticleBatchNode:ctor( refCocosObj )
		
end

function myParticleBatchNode:toString()
	return string.format("ParticleBatchNode [%s]", self.name and self.name or "nil");
end

--
-- public props ---------------------------------------------------------
--

--maximum particles of the system
function myParticleBatchNode:getTotalParticles() 
	return 0
end

--Quantity of particles that are being simulated at the moment
function myParticleBatchNode:getParticleCount() 
	return 0
end

--CCTexture2D
function myParticleBatchNode:getTexture() 
	return self.refCocosObj_Texture
end

function myParticleBatchNode:setTexture(v) 
	self.refCocosObj_Texture = v 
end	

function myParticleBatchNode:getBlendFunc() 
	return self.refCocosObj_setBlendFunc
end

function myParticleBatchNode:setBlendFunc(v) 
	self.refCocosObj_setBlendFunc = v
end

function myParticleBatchNode:disableParticle(v) 
	--self.refCocosObj:disableParticle(v) 
end	

function myParticleBatchNode:insertChild(v) 
	--self.refCocosObj:insertChild(pSystem, index) 
end	

function myParticleBatchNode:create(fileImage, capacity)
--[[  if not fileImage then 
    if _G.isLocalDevelopMode then printx(0, "create ParticleBatchNode fail. nill of fnt file") end
    return nil 
  end
  capacity = capacity or kParticleDefaultCapacity
  return myParticleBatchNode.new(CCParticleBatchNode:create(fileImage, capacity))--]]
	return myParticleBatchNode.new(createCCSprite("a"))
end

--CCTexture2D
function myParticleBatchNode:createWithTexture(tex, capacity)
  --[[if not tex then 
    if _G.isLocalDevelopMode then printx(0, "create ParticleBatchNode fail. nill of tex") end
    return nil 
  end
  capacity = capacity or kParticleDefaultCapacity
  return ParticleBatchNode.new(CCParticleBatchNode:createWithTexture(tex, capacity))--]]
	return myParticleBatchNode.new(createCCSprite("a"))
end

--
-- ParticleSystem ---------------------------------------------------------
--

myParticleSystem = class(CocosObject);

function myParticleSystem:ctor( refCocosObj )
  --[[self.touchEnabled = false
  self.touchChildren = false--]]
end
function myParticleSystem:toString()
	return string.format("ParticleSystem [%s]", self.name and self.name or "nil");
end

--
-- public props ---------------------------------------------------------
--
--CCTexture2D
function myParticleSystem:getTexture() 
	return self.refCocosObj_setTexture 
end

function myParticleSystem:setTexture(v) 
	self.refCocosObj_setTexture = v 
end	

function myParticleSystem:getBlendFunc() 
	return self.refCocosObj_setBlendFunc 
end

function myParticleSystem:setBlendFunc(v) 
	self.refCocosObj_setBlendFunc = v
end

function myParticleSystem:isAutoRemoveOnFinish() 
	return true
end

function myParticleSystem:setAutoRemoveOnFinish(v) 
--	[[self.refCocosObj:setAutoRemoveOnFinish(v) ]]
end

function myParticleSystem:getDuration() 
	return self.refCocosObj_setDuration
end

function myParticleSystem:setDuration(v) 
	self.refCocosObj_setDuration = v
end

function myParticleSystem:getAngle() 
	return self.refCocosObj_setAngle 
end

function myParticleSystem:setAngle(v) 
	self.refCocosObj_setAngle = v
end

function myParticleSystem:getAngleVar() 
	return self.refCocosObj_setAngleVar 
end

function myParticleSystem:setAngleVar(v) 
	self.refCocosObj_setAngleVar = v
end

function myParticleSystem:stopSystem() 
--	return self.refCocosObj:stopSystem() 
end

function myParticleSystem:resetSystem() 
--	return self.refCocosObj:resetSystem() 
end

function myParticleSystem:onRemoveFromStage() 
  --[[if not self.removedFromStage and self.parent and self:isAutoRemoveOnFinish() then
    self.removedFromStage = true
    --if _G.isLocalDevelopMode then printx(0, "ParticleSystem:onRemoveFromStage") end
    self.parent:removeChild(self, true, true)
  end--]]
end

function myParticleSystem:create(plistFile)
  --[[if not plistFile then 
    if _G.isLocalDevelopMode then printx(0, "create ParticleSystem fail. nill of fnt file") end
    return nil 
  end--]]
  return myParticleSystem.new(createCCSprite("a"))
end

--CCSpriteFrame
function myParticleSystem:setDisplayFrame(v) 
--	self.refCocosObj:setDisplayFrame(v) 
end

function myParticleSystem:getPosVar() 
	return self.refCocosObj_setPosVar or ccp(0,0)
end

function myParticleSystem:setPosVar(v) 
	self.refCocosObj_setPosVar = v
end

--CCTexture2D, CCRect
function myParticleSystem:setTextureWithRect(v) 
--	self.refCocosObj:setTextureWithRect(texture, rect) 
end

function myParticleSystem:setTotalParticles(v) 
	self.refCocosObj_setTotalParticles = v 
end
function myParticleSystem:getTotalParticles(v) 
	return self.refCocosObj_setTotalParticles or 0 
end

--
-- ParticleSystemQuad ---------------------------------------------------------
--

myParticleSystemQuad = class(myParticleSystem);

function myParticleSystemQuad:toString()
	return string.format("ParticleSystemQuad [%s]", self.name and self.name or "nil");
end



function myParticleSystemQuad:create(plistFile)
  --[[if not plistFile then 
    if _G.isLocalDevelopMode then printx(0, "create ParticleSystemQuad fail. nill of fnt file") end
    return nil 
  end--]]
  return myParticleSystemQuad.new(createCCSprite("a"))
end

ParticleBatchNode = myParticleBatchNode
ParticleSystem = myParticleSystem
ParticleSystemQuad = myParticleSystemQuad