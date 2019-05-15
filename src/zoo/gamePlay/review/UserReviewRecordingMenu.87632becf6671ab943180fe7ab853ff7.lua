local UIHelper = require 'zoo.panel.UIHelper'

local UserReviewRecordingMenu = class(Layer)

function UserReviewRecordingMenu:create( ... )
	-- body
	local i = UserReviewRecordingMenu.new()
	i:initLayer()
	i:initMenu()
	return i
end

function UserReviewRecordingMenu:initMenu( ... )
	local ui = UIHelper:createUI('ui/user_review.json', 'user_review.ui/menu2')
	self:addChild(ui)
	self.ui = ui

	self.stopBtn = self.ui:getChildByPath('stop/btn')
	UIUtils:setTouchHandler(self.stopBtn, function ( ... )
		if self.recordingSeconds and self.recordingSeconds >= 3.5 then
			self:notify('stopRecord')
		end
	end)

	self.time = self.ui:getChildByPath('stop/time')

	self.dot = self.ui:getChildByPath('stop/dot')

	self.nameLabel = self.ui:getChildByPath('logo/name')
end

function UserReviewRecordingMenu:setDelegate( delegate )
	self.delegate = delegate
end

function UserReviewRecordingMenu:notify( message, ... )
	if self.isDisposed then return end
	if self.delegate then
		self.delegate:onMenuCommand(self, message, ...)
	end
end

function UserReviewRecordingMenu:setName( name )
	if self.isDisposed then return end

	local name = TextUtil:ensureTextWidth( tostring(name), self.nameLabel:getFontSize(), self.nameLabel:getDimensions() )
	self.nameLabel:setString(name)
end

function UserReviewRecordingMenu:startRecordingAnim( ... )
	if self.isDisposed then return end
	self.dot:runAction(CCRepeatForever:create(UIHelper:sequence{
		CCDelayTime:create(1), 
		CCFadeOut:create(0),
		CCDelayTime:create(1), 
		CCFadeIn:create(0),
	}))

	self.time:runAction(CCRepeatForever:create(UIHelper:sequence{
		CCCallFunc:create(function ( ... )
			if self.isDisposed then return end
			self.recordingSeconds = Localhost:timeInSec() - self.startTime
			self:updateTimeView()
		end),
		CCDelayTime:create(1)
	}))

	self.startTime = Localhost:timeInSec()
end

function UserReviewRecordingMenu:stopRecordingAnim( ... )
	if self.isDisposed then return end
	self.time:stopAllActions()
	self.dot:stopAllActions()
end

function UserReviewRecordingMenu:reset( ... )
	self.recordingSeconds = 0
end

function UserReviewRecordingMenu:updateTimeView( ... )
	if self.isDisposed then return end
	local minute = math.floor(self.recordingSeconds / 60)
	local second = self.recordingSeconds % 60
	UIHelper:setCenterText(self.time, string.format("%02d:%02d", minute, second), 'fnt/prop_name.fnt')
end

return UserReviewRecordingMenu