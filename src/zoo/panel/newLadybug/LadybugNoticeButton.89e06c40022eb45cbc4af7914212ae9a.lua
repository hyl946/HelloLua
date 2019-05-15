
local LadybugNoticeButton = class(BaseUI)

local timeSlice = 0.03

function LadybugNoticeButton:create(cfg)
	local btn = LadybugNoticeButton.new()
	btn:init(cfg)
	return btn
end

function LadybugNoticeButton:init(cfg)

	local ui = ResourceManager:sharedInstance():buildGroup("moduleNotice/ModuleNoticeBtn")
	local icon = ResourceManager:sharedInstance():buildGroup('moduleNotice/module_notice_ladybug')
	icon:setPosition(ccp(-7, 85))
	ui:addChild(icon)
	self.icon = icon
	BaseUI.init(self, ui)

	self.ui:setTouchEnabled(true, 0, true)
	self.ui:ad(DisplayEvents.kTouchTap, function( ... )
		self:onClk()
	end)

	local floatDown = CCMoveBy:create(2.1, ccp(0, -12))
  	local floatUp = CCMoveBy:create(2.1, ccp(0, 12))
	self.ui:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(floatDown, floatUp)))

	self.isPlayingAnim = false
end

function LadybugNoticeButton:onClk()
	DcUtil:UserTrack({
		category="ladybug",
		sub_category="click_icon" ,
		t1 = 1
	})
	
	if PopoutManager:sharedInstance():haveWindowOnScreen() then 
		return 
	end
	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
	LadybugDataManager:getInstance():popoutPanel()
end

function LadybugNoticeButton:removeSelf( ... )
	self.ui:stopAllActions()
	self.ui:removeFromParentAndCleanup(true)
end

function LadybugNoticeButton:playAnim( ... )
	-- body
end

function LadybugNoticeButton:setPosByLevel( level )
	if self.isDisposed then return end

	if self.level then
		local friendStack = HomeScene:sharedInstance().worldScene.levelFriendPicStacksByLevelId[self.level]
		if friendStack then
			friendStack:setVisibleEnabled(true)
			friendStack:setVisible(true)
		end
	end
	self.level = nil


	self.level = level

	local node = HomeScene:sharedInstance().worldScene.levelToNode[self.level]
	local pos = node:getPosition()
	self:setPosition(ccp(pos.x, pos.y))

	local friendStack = HomeScene:sharedInstance().worldScene.levelFriendPicStacksByLevelId[self.level]
	if friendStack then
		friendStack:setVisible(false)
		friendStack:setVisibleEnabled(false)
	end

	self.__level = level

	HomeScene:sharedInstance():updateInviteBtnPosition()

	self:onTopLevelChanged()
end

function LadybugNoticeButton:onTopLevelChanged( playAnim )
	if self.isDisposed then return end


	if self.__level then
		local topLevelId = UserManager.getInstance().user:getTopLevelId()
		self:setVisible(topLevelId ~= self.__level)
		self.ui:setVisible(topLevelId ~= self.__level)

		local topLevelId = UserManager:getInstance().user:getTopLevelId()
		local userIconLevelId = HomeScene:sharedInstance().worldScene.userIconLevelId

		if topLevelId == 63 then
			self:setVisible(false)
			self.ui:setVisible(false)

			if playAnim and self.isPlayingAnim == false then

				self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.8), CCCallFunc:create(function ( ... )
					if self.isDisposed then 
						self.isPlayingAnim = false
						return 
					end

					self:setVisible(true)
					self.ui:setVisible(true)

					self.ui:setScale(0.1)
					self.ui:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 1), CCCallFunc:create(function ( ... )
						self.isPlayingAnim = false
					end)))
				end)))

				self.isPlayingAnim = true
			end
		end
	end
end

return LadybugNoticeButton