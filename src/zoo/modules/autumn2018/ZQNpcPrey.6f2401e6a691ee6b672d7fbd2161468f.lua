
local UIHelper = require 'zoo.panel.UIHelper'

ZQNpcPrey = class(CocosObject)

ZQNpcPreyStatus = {
	kStandBy = 1,
	kRun = 2,
	kHarvest = 3,  			--discarded
	kAfraid1 = 4,
	kAfraid2 = 5,
	kAfraidToHappy = 6,
	kDie = 7,
	kRevive = 8,
}

local StatusAniFlag = {
	[ZQNpcPreyStatus.kStandBy] 			= "stand",
	[ZQNpcPreyStatus.kRun] 				= "run",
	[ZQNpcPreyStatus.kHarvest] 			= "harvest",
	[ZQNpcPreyStatus.kAfraid1] 			= "afraid1",
	[ZQNpcPreyStatus.kAfraid2] 			= "afraid2",
	[ZQNpcPreyStatus.kAfraidToHappy] 	= "afraid3",
	[ZQNpcPreyStatus.kDie] 				= "die",
	[ZQNpcPreyStatus.kRevive] 			= "revive",
}

local StatusAniPlayTimes = {
	[ZQNpcPreyStatus.kStandBy] 			= 0,
	[ZQNpcPreyStatus.kRun] 				= 0,
	[ZQNpcPreyStatus.kHarvest] 			= 1,
	[ZQNpcPreyStatus.kAfraid1] 			= 1,
	[ZQNpcPreyStatus.kAfraid2] 			= 0,
	[ZQNpcPreyStatus.kAfraidToHappy] 	= 1,
	[ZQNpcPreyStatus.kDie] 				= 1,
	[ZQNpcPreyStatus.kRevive] 			= 1,
}

function ZQNpcPrey:ctor()
end

function ZQNpcPrey:create()
	local node = ZQNpcPrey.new(CCNode:create())
	node:init()
	return node
end

function ZQNpcPrey:dispose()
	local anis = {self.normalAni, self.dieAni, self.reviveAni}
	for i,v in ipairs(self.aniTable) do
		if v then
			v:stop()
			v:removeAllEventListeners()
			v:removeFromParentAndCleanup(true)
			v = nil
		end
	end
	self.aniTable = nil
	UIHelper:unloadArmature('skeleton/autumn2018/raccoon_ani', true)
	CocosObject.dispose(self)
end

function ZQNpcPrey:init()
	UIHelper:loadArmature('skeleton/autumn2018/raccoon_ani', "raccoon_ani", "raccoon_ani")
	
	self.isAfraid = false

	self.aniTable = {}

	local normalAni = ArmatureNode:create("autumn_2018_raccoon/raccoon_normal")
	normalAni:update(0.001)
	normalAni:stop()
	self:addChild(normalAni:wrapWithBatchNode())
	normalAni:setPosition(ccp(0, 0))
	self.normalAni = normalAni
	table.insert(self.aniTable, normalAni)

	local dieAni = ArmatureNode:create("autumn_2018_raccoon/raccoon_die")
	dieAni:update(0.001)
	dieAni:stop()
	self:addChild(dieAni:wrapWithBatchNode())
	dieAni:setPosition(ccp(0, 0))
	self.dieAni = dieAni
	self.dieAni:setVisible(false)
	table.insert(self.aniTable, dieAni)

	local reviveAni = ArmatureNode:create("autumn_2018_raccoon/raccoon_revive")
	reviveAni:update(0.001)
	reviveAni:stop()
	self:addChild(reviveAni:wrapWithBatchNode())
	reviveAni:setPosition(ccp(0, 0))
	self.reviveAni = reviveAni
	self.reviveAni:setVisible(false)
	table.insert(self.aniTable, reviveAni)
end

function ZQNpcPrey:getAni(status)
	for i,v in ipairs(self.aniTable) do
		v:setVisible(false)
	end
	if status == ZQNpcPreyStatus.kDie then
		self.dieAni:setVisible(true)
		return self.dieAni
	elseif status == ZQNpcPreyStatus.kRevive then
		self.reviveAni:setVisible(true)
		return self.reviveAni
	else
		self.normalAni:setVisible(true)
		return self.normalAni
	end
end

function ZQNpcPrey:changeStatus(status, onFinished)
	if self.status ~= status then
		self.status = status
		if self.status == ZQNpcPreyStatus.kAfraid1 or self.status == ZQNpcPreyStatus.kAfraid2 then
			self.isAfraid = true
		elseif self.status == ZQNpcPreyStatus.kAfraidToHappy or self.status == ZQNpcPreyStatus.kRevive then
			self.isAfraid = false 
		end
		for i,v in ipairs(self.aniTable) do
			v:stop()
			v:removeAllEventListeners()
		end

		local animation = self:getAni(status)
		local aniFlag = StatusAniFlag[status]
		local playTimes = StatusAniPlayTimes[status]
		animation:addEventListener(ArmatureEvents.COMPLETE, function ()
			self:onAniComplete()
			if onFinished then onFinished() end
		end)
		animation:play(aniFlag, playTimes)

		self.jsq = 0
	else
		if onFinished then onFinished() end 
	end
end

function ZQNpcPrey:onAniComplete()
	if self.status == ZQNpcPreyStatus.kStandBy then
		-- local dochange = false
		-- if self.jsq < 7 then
		-- 	if math.random(1 , 100) < 15 then
		-- 		dochange = true
		-- 	end
		-- elseif self.jsq < 25 then
		-- 	if math.random(1 , 100) < 10 then
		-- 		dochange = true
		-- 	end
		-- else
		-- 	if math.random(1 , 100) < 350 then
		-- 		dochange = true
		-- 	end
		-- end
		-- if dochange then 
		-- 	self:changeStatus(ZQNpcPreyStatus.kHarvest)
		-- else
		-- 	local status = ZQNpcPreyStatus.kStandBy
		-- 	local animation = self:getAni(status)
		-- 	local aniFlag = StatusAniFlag[status]
		-- 	local playTimes = StatusAniPlayTimes[status]
		-- 	animation:removeAllEventListeners()
		-- 	animation:addEventListener(ArmatureEvents.COMPLETE, function ()
		-- 		self:onAniComplete()
		-- 	end)
		-- 	animation:play(aniFlag, playTimes)
		-- end
		-- self.jsq = self.jsq + 1
	elseif self.status == ZQNpcPreyStatus.kHarvest then
		if self.isAfraid then
		 	self:changeStatus(ZQNpcPreyStatus.kAfraid2)
		else
			self:changeStatus(ZQNpcPreyStatus.kStandBy)
		end
	elseif self.status == ZQNpcPreyStatus.kAfraid1 then
		self:changeStatus(ZQNpcPreyStatus.kAfraid2)
	elseif self.status == ZQNpcPreyStatus.kAfraidToHappy then
		self:changeStatus(ZQNpcPreyStatus.kStandBy)
	elseif self.status == ZQNpcPreyStatus.kRevive then
		self:changeStatus(ZQNpcPreyStatus.kStandBy)
	end
end