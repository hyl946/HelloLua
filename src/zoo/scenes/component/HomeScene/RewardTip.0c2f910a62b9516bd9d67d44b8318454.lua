local PersonalInfoReward = require 'zoo.PersonalCenter.PersonalInfoReward'

local RewardTip = class(Layer)

function RewardTip:create( ui, rewardItem, endTimeInSec, onTimeOutCB )
	local tip = RewardTip.new()
	tip:init( ui, rewardItem, endTimeInSec, onTimeOutCB)
	return tip
end

function RewardTip:init(  ui, rewardItem, endTimeInSec, onTimeOutCB )
	Layer.initLayer(self)

	self.ui = ui
	
	self.onTimeOutCB = onTimeOutCB

	self:addChild(ui)

	self.listener = function ( ... )
		if self.onStatusChange then
			self.onStatusChange()
		end
	end


	
	self.oneSecondTimer	= OneSecondTimer:create()

	local function oneSecondCallback()
		self:oneSecondCallback()
	end

	self.oneSecondTimer:setOneSecondCallback(oneSecondCallback)

	if rewardItem and endTimeInSec then
		self:setData(rewardItem, endTimeInSec)
	end

	local label1 = self.ui:getChildByPath('label1')
	label1:changeFntFile('fnt/profile2018_1.fnt')

	local label2 = self.ui:getChildByPath('label2')
	label2:changeFntFile('fnt/profile2018.fnt')

	label2:setPositionX(label2:getPositionX() + 8)


	PersonalInfoReward.eventDispatcher:ad(PersonalInfoReward.Events.kStatusChange, self.listener)
	
end

function RewardTip:setData( rewardItem, endTimeInSec )
	if self.isDisposed then return end

	self.rewardItem = rewardItem
	self.endTimeInSec = endTimeInSec

	if self.rewardItem and self.endTimeInSec then
		local itemId = self.rewardItem.itemId
		local sp = ResourceManager:sharedInstance():buildItemSprite(itemId)
		UIUtils:positionNode(self.ui:getChildByPath('icon'), sp, true)
		sp:setAnchorPointCenterWhileStayOrigianlPosition()
		sp:setScale(sp:getScale() * 1.2)
		self.ui:getChildByPath('label1'):setText('送')
		self.ui:getChildByPath('label2'):setText('x' .. self.rewardItem.num)
	else
		self:setVisible(false)
	end

	self.oneSecondTimer:stop()
	self:oneSecondCallback()
	self.oneSecondTimer:start()


end

function RewardTip:oneSecondCallback( ... )
	if self.isDisposed then return end
	if self.rewardItem and self.endTimeInSec then



		local now = Localhost:timeInSec()
		local time = self.endTimeInSec - now


		if time >= 0 then
			local h, m, s = math.floor(time / 3600), math.floor(time / 60) % 60, time % 60
			self.ui:getChildByPath('timer'):setString(string.format('%02d:%02d:%02d', h, m, s))
		else
			self:setData()

			if self.onTimeOutCB then
				self.onTimeOutCB()
			end

		end
	else
		self.oneSecondTimer:stop()
	end
end


function RewardTip:dispose( ... )
	PersonalInfoReward.eventDispatcher:rm(PersonalInfoReward.Events.kStatusChange, self.listener)
	self.oneSecondTimer:stop()
	Layer.dispose(self)
	
end

return RewardTip