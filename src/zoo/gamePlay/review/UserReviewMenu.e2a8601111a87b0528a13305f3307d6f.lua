local UIHelper = require 'zoo.panel.UIHelper'

local UserReviewMenu = class(Layer)

function UserReviewMenu:create( ... )
	-- body
	local i = UserReviewMenu.new()
	i:initLayer()
	i:initMenu()
	return i
end

function UserReviewMenu:initMenu( ... )
	local ui = UIHelper:createUI('ui/user_review.json', 'user_review.ui/menu')
	self:addChild(ui)
	self.ui = ui

	self.speedDownBtn = self.ui:getChildByPath('speed-')
	self.speedUpBtn = self.ui:getChildByPath('speed+')
	self.speedLabel = self.ui:getChildByPath('speedLabel')

	self.playBtn = self.ui:getChildByPath('play_stop/play')
	self.stopBtn = self.ui:getChildByPath('play_stop/stop')

	self.recordBtn = self.ui:getChildByPath('recordBtn')
	self.closeBtn = self.ui:getChildByPath('closeBtn')


	UIUtils:setTouchHandler(self.closeBtn, function ( ... )
		self:notify('close')
	end)

	UIUtils:setTouchHandler(self.recordBtn, function ( ... )
		self:notify('startRecord')
	end)

	UIUtils:setTouchHandler(self.playBtn, function ( ... )
		self:notify('startReplay')
	end)

	UIUtils:setTouchHandler(self.stopBtn, function ( ... )
		self:notify('stopReplay')
	end)

	UIUtils:setTouchHandler(self.speedDownBtn, function ( ... )
		self:notify('speedDown')
	end)

	UIUtils:setTouchHandler(self.speedUpBtn, function ( ... )
		self:notify('speedUp')
	end)

end

function UserReviewMenu:setDelegate( delegate )
	self.delegate = delegate
end

function UserReviewMenu:notify( message, ... )
	if self.isDisposed then return end
	if self.delegate then
		self.delegate:onMenuCommand(self, message, ...)
	end
end

function UserReviewMenu:setSpeed( speed )
	if self.isDisposed then return end

	local speedDisplay = ''
	if speed == 0 then
		speedDisplay = '1'
	elseif speed == 1 then
		speedDisplay = 1.5
	else
		speedDisplay = 2
	end
	-- self.speedLabel:setString('x' .. speedDisplay)
	UIHelper:setCenterText(self.speedLabel, '' .. speedDisplay .. 'x', 'fnt/videoRecord.fnt')
end

function UserReviewMenu:setIsPlaying( b )
	if self.isDisposed then return end
	self.playBtn:setVisible(not b)
	self.stopBtn:setVisible(b)
end

function UserReviewMenu:getNodePos( node )
	if self.isDisposed then return end
	local bounds = node:getGroupBounds()
	local pos = ccp(bounds:getMidX(), bounds:getMidY())
	return pos
end

local UserReviewGuide = require 'zoo.gamePlay.review.UserReviewGuide'

function UserReviewMenu:tryShowGuide_2( ... )
	if self.isDisposed then return end

	self:runAction(CCCallFunc:create(function ( ... )
		if self.isDisposed then return end
		if not UserManager:getInstance():hasGuideFlag(kGuideFlags.kUserReview_2) then
    		UserLocalLogic:setGuideFlag( kGuideFlags.kUserReview_2 )

			local guide = UserReviewGuide:createGuide_2()

			local curScene = Director:sharedDirector():getRunningSceneLua()
			local superGuideLayer = Layer:create()
			curScene:superAddChild(superGuideLayer)


			local pos = self:getNodePos(self.playBtn)
			UserReviewGuide:popGuide(guide, superGuideLayer, pos, 0.8, nil, function ( ... )
				if superGuideLayer and (not superGuideLayer.isDisposed) then
					UserReviewGuide:cacheAnimalPos(guide)
					curScene:superRemoveChild(superGuideLayer)
				end
			end)
			guide:ad(Events.kDispose, function ( ... )
				self:tryShowGuide_3()
			end)
		else
			self:tryShowGuide_3()
		end
	end))

end

function UserReviewMenu:tryShowGuide_3( ... )
	if self.isDisposed then return end
	if not UserManager:getInstance():hasGuideFlag(kGuideFlags.kUserReview_3) then
		UserLocalLogic:setGuideFlag( kGuideFlags.kUserReview_3 )

		local guide = UserReviewGuide:createGuide_3()

		local curScene = Director:sharedDirector():getRunningSceneLua()
		local superGuideLayer = Layer:create()
		curScene:superAddChild(superGuideLayer)


		local pos = self:getNodePos(self.recordBtn)
		UserReviewGuide:popGuide(guide, superGuideLayer, pos, 0.8, nil, function ( ... )
			if superGuideLayer and (not superGuideLayer.isDisposed) then
				curScene:superRemoveChild(superGuideLayer)
			end
		end)

	end
end



return UserReviewMenu