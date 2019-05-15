
local UIHelper = require 'zoo.panel.UIHelper'

ZQNpcHunter = class(CocosObject)

ZQNpcHunterStatus = {
	kAppear = 1,
	kStandBy = 2,
	kDisappear = 3,
	kPause = 4,
}

local StatusAniFlag = {
	[ZQNpcHunterStatus.kAppear] = "appear",
	[ZQNpcHunterStatus.kStandBy] = "stand",
	[ZQNpcHunterStatus.kDisappear] = "disappear",
	[ZQNpcHunterStatus.kPause] = "pause",
}

local StatusAniPlayTimes = {
	[ZQNpcHunterStatus.kAppear] = 1,
	[ZQNpcHunterStatus.kStandBy] = 0,
	[ZQNpcHunterStatus.kDisappear] = 1,
	[ZQNpcHunterStatus.kPause] = 0,
}

function ZQNpcHunter:ctor()
end

function ZQNpcHunter:create()
	local node = ZQNpcHunter.new(CCNode:create())
	node:init()
	return node
end

function ZQNpcHunter:dispose()
	if self.animation then
		self.animation:stop()
		self.animation:removeAllEventListeners()
		self.animation:removeFromParentAndCleanup(true)
		self.animation = nil
	end
	UIHelper:unloadArmature('skeleton/autumn2018/diving_frog_ani', true)
	CocosObject.dispose(self)
end

function ZQNpcHunter:init()
	UIHelper:loadArmature('skeleton/autumn2018/diving_frog_ani', "diving_frog_ani", "diving_frog_ani")

	local animation = ArmatureNode:create("autumn_2018_diving_frog/diving_frog")
	animation:update(0.001)
	animation:stop()
	self:addChild(animation:wrapWithBatchNode())

	-- -110, 192
	animation:setPosition(ccp(0, 0))
	self.animation = animation
end

function ZQNpcHunter:changeStatus(status, onFinished)
	if self.status ~= status then 
		self.status = status
		self.animation:removeAllEventListeners()

		local aniFlag = StatusAniFlag[status]
		local playTimes = StatusAniPlayTimes[status]
		if onFinished then
			self.animation:addEventListener(ArmatureEvents.COMPLETE, onFinished)
		end
		self.animation:play(aniFlag, playTimes)
	else
		if onFinished then onFinished() end
	end
end