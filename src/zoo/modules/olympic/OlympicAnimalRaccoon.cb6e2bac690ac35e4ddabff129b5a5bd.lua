---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-07-29 17:59:48
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-09 14:23:55
---------------------------------------------------------------------------------------
OlympicAnimalRaccoon = class(CocosObject)

OlympicAnimalRaccoonStatus = {
	kNone = 1,
	kFall = 2,
	kSwoon = 3,
	kJump1 = 4,
	kJump2 = 5,
}

function OlympicAnimalRaccoon:ctor()

end

function OlympicAnimalRaccoon:create()
	local node = OlympicAnimalRaccoon.new(CCNode:create())
	node:init()
	return node
end

function OlympicAnimalRaccoon:dispose()
	if self.animation then
		self.animation:stop()
		self.animation:removeEventListenerByName(ArmatureEvents.COMPLETE)
		self.animation:removeFromParentAndCleanup(true)
		self.animation = nil
	end
	CocosObject.dispose(self)
end

function OlympicAnimalRaccoon:init()
	self:changeStatus(OlympicAnimalRaccoonStatus.kNone)
end

function OlympicAnimalRaccoon:changeStatus(status, onFinished)
	if self.status ~= status then
		self.status = status
		if self.animation then
			self.animation:removeFromParentAndCleanup(true)
			self.animation = nil
		end
		local playTimes = 1
		local animation = nil
		local index = -1
		local posX, posY = -110, 192
		if self.status == OlympicAnimalRaccoonStatus.kFall then
			index = 0
		elseif self.status == OlympicAnimalRaccoonStatus.kSwoon then
			playTimes = 0
			index = 1
		elseif self.status == OlympicAnimalRaccoonStatus.kJump1 then
			index = 2
			posX, posY = -120, 190
		elseif self.status == OlympicAnimalRaccoonStatus.kJump2 then
			index = 3
			posX, posY = -120, 190
		end
		if index >= 0 then
			animation = ArmatureNode:create( "OlympicBanana/animal" )
			animation:playByIndex(index, 1)
			animation:update(0.001)
			animation:stop()
			if onFinished then
				animation:addEventListener(ArmatureEvents.COMPLETE, onFinished)
			end
			animation:playByIndex(index, playTimes)
			self.animation = animation
			animation:setPosition(ccp(posX, posY))
			self:addChild(animation)
		end
	end
end