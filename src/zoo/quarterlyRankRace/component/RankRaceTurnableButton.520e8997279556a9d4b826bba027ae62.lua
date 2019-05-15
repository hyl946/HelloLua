
local RankRaceTurnableButton = class(BaseUI)

local BtnState = {
	kNormal = 0,
	kReward = 1,	
}

function RankRaceTurnableButton:ctor()
end

function RankRaceTurnableButton:init(ui)
	BaseUI.init(self, ui)
	self.arrow = self.ui:getChildByName("arrow")
	self.btnMain = self.ui:getChildByName("main")
	self.light = self.btnMain:getChildByName("lightBg")
	self.rewardFlag = self.btnMain:getChildByName("rewardFlag")

	self.btnState = nil
	self:update(false)
end

local arrowOriPos = {x = 62, y = 134}
local btnMainOriPos = {x = -1, y = 0}
function RankRaceTurnableButton:update(hasReward)
	if self.isDisposed then return end
	local nowState = hasReward and BtnState.kReward or BtnState.kNormal
	if self.btnState and self.btnState == nowState then return end
	self.btnState = nowState
	if self.btnState == BtnState.kReward then 
		local oneFrameTime = 1/30
		--主体
		self.rewardFlag:setVisible(true)
		local arr1 = CCArray:create()
		local arr2 = CCArray:create()
		local arr3 = CCArray:create()
		arr2:addObject(CCScaleTo:create(oneFrameTime * 4, 1, 0.896))
		arr2:addObject(CCScaleTo:create(oneFrameTime * 4, 0.958, 1))
		arr2:addObject(CCScaleTo:create(oneFrameTime * 4, 1.056, 0.944))
		arr2:addObject(CCScaleTo:create(oneFrameTime * 3, 1, 1))

		arr3:addObject(CCEaseSineIn:create(CCMoveTo:create(oneFrameTime * 4, ccp(0, btnMainOriPos.y - 11))))
		arr3:addObject(CCEaseSineOut:create(CCMoveTo:create(oneFrameTime * 4, ccp(0, btnMainOriPos.y + 20))))
		arr3:addObject(CCEaseSineIn:create(CCMoveTo:create(oneFrameTime * 4, ccp(0, btnMainOriPos.y - 6))))
		arr3:addObject(CCEaseSineOut:create(CCMoveTo:create(oneFrameTime * 3, ccp(0, btnMainOriPos.y))))

		arr1:addObject(CCSpawn:createWithTwoActions(CCSequence:create(arr2), CCSequence:create(arr3))) 

		arr1:addObject(CCRotateTo:create(oneFrameTime * 4, 6.5))
		arr1:addObject(CCRotateTo:create(oneFrameTime * 4, -6.7))
		arr1:addObject(CCRotateTo:create(oneFrameTime * 3, 4.2))
		arr1:addObject(CCRotateTo:create(oneFrameTime * 3, -4.2))
		arr1:addObject(CCRotateTo:create(oneFrameTime * 3, 0))
		arr1:addObject(CCDelayTime:create(oneFrameTime * 77))
		self.btnMain:stopAllActions()
		self.btnMain:runAction(CCRepeatForever:create(CCSequence:create(arr1)))
		--光
		local arrLight1 = CCArray:create()
		arrLight1:addObject(CCFadeTo:create(oneFrameTime * 16, 255))
		arrLight1:addObject(CCDelayTime:create(oneFrameTime * 17))
		arrLight1:addObject(CCFadeTo:create(oneFrameTime * 15, 0))
		arrLight1:addObject(CCFadeTo:create(oneFrameTime * 16, 255))
		arrLight1:addObject(CCFadeTo:create(oneFrameTime * 16, 0))
		arrLight1:addObject(CCFadeTo:create(oneFrameTime * 15, 255))
		arrLight1:addObject(CCFadeTo:create(oneFrameTime * 15, 0))
		self.light:stopAllActions()
		self.light:runAction(CCRepeatForever:create(CCSequence:create(arrLight1)))
		--箭头
		self.arrow:setVisible(true)
		local arrArrow1 = CCArray:create()
		arrArrow1:addObject(CCMoveTo:create(oneFrameTime * 14, ccp(arrowOriPos.x + 20, arrowOriPos.y + 20)))
		arrArrow1:addObject(CCMoveTo:create(oneFrameTime * 14, ccp(arrowOriPos.x, arrowOriPos.y)))
		self.arrow:stopAllActions()
		self.arrow:runAction(CCRepeatForever:create(CCSequence:create(arrArrow1)))
	else
		self.arrow:stopAllActions()
		self.arrow:setVisible(false)
		self.arrow:setPosition(ccp(arrowOriPos.x, arrowOriPos.y))

		self.btnMain:stopAllActions()
		self.btnMain:setScale(1)
		self.btnMain:setRotation(0)
		self.btnMain:setPosition(ccp(btnMainOriPos.x, btnMainOriPos.y))

		self.light:stopAllActions()
		self.light:setOpacity(0)

		self.rewardFlag:setVisible(false)
	end
end

function RankRaceTurnableButton:ad(eventName, listener, context)
	self.ui:addEventListener(eventName, listener, context)
end

function RankRaceTurnableButton:setTouchEnabled(isTouchEnable, priority, isSwallowsTouches, hitTestFunc, careParent, alwaysUseHitTestFunc)
	self.ui:setTouchEnabled(isTouchEnable, priority, isSwallowsTouches, hitTestFunc, careParent, alwaysUseHitTestFunc)
end

function RankRaceTurnableButton:setButtonMode(v, donotScaleOnTouch)
	self.ui:setButtonMode(v, donotScaleOnTouch)
end

function RankRaceTurnableButton:create(ui)
	local btn = RankRaceTurnableButton.new()
	btn:init(ui)
	return btn
end

return RankRaceTurnableButton