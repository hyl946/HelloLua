SeasonWeeklyRewardBubbleState = {
	
	kNormal = 1 ,
	kProcessing = 2 ,
	kWaitingForReward = 3 ,
	kRewarded = 4 ,
}

SeasonWeeklyRewardBubble = class()
function SeasonWeeklyRewardBubble:create( id , ui )
	local bubble = SeasonWeeklyRewardBubble.new()
	bubble.indexId = id

    bubble:init( ui ) 
    return bubble
end

function SeasonWeeklyRewardBubble:init( ui )
	self.ui = ui
	self.fixScale = 1
	self.icon_rewardTip = self.ui:getChildByName("icon_rewardTip")
	local pos = self.icon_rewardTip:getPosition()
	self.rewardTipPos = {x=pos.x , y=pos.y}
	self.icon_rewardTip:setPosition( ccp( self.rewardTipPos.x , self.rewardTipPos.y) )

	self.touchRect = self.ui:getChildByName("touchRect")
	self.touchRect:getChildByName("rect"):setOpacity( 0 )

	local labelPartUI = self.ui:getChildByName("label")
	local labelBgUI = labelPartUI:getChildByName("bg")
	self.label_target = labelPartUI:getChildByName("label")
	-- self.label_target:setVisible(false)
	self.label_target:changeFntFile("fnt/register2.fnt")
    self.label_target:setColor(hex2ccc3("1890D6"))
	self.label_target:setScale(0.67)
	self.label_target:setAnchorPoint(ccp(0.5, 0.5))

	local bb = labelBgUI:boundingBox()
	self.label_target:setPosition(ccp(bb:getMidX() - 23.5, bb:getMidY()))

	labelPartUI:setVisible(false)
	self.labelPartUI = labelPartUI
	
	self.light = self.ui:getChildByName('light') --todo create animNode
	self:showLight(false)
	self.rewarded = self.ui:getChildByName('rewarded')
	self.normal = self.ui:getChildByName('normal')

	self.rewardBox = {}
	local setBoxState = function ( ctx, newStateName )
		self:showLight(false)
		self.normal:setVisible(false)
		self.rewarded:setVisible(false)
		if newStateName == 'normal' then
			self.normal:setVisible(true)
		elseif newStateName == 'available' then
			self:showLight(true)
			self.normal:setVisible(true)
		elseif newStateName == 'rewarded' then
			self.rewarded:setVisible(true)
		end
	end

	self.rewardBox.setState = setBoxState

	self:setState(SeasonWeeklyRewardBubbleState.kNormal)
end

function SeasonWeeklyRewardBubble:showLight(lightShow)
	if self.light then 
		if self.light:isVisible() == lightShow then return end
		self.light:stopAllActions()
		if lightShow then 
			self.light:setVisible(true)
			self.light:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.5, 0), CCFadeTo:create(0.5, 255))))
		else
			self.light:setVisible(false)
			self.light:setOpacity(255)
		end
	end
end

function SeasonWeeklyRewardBubble:setState( state , datas )

	self:clearProgressLabel()

	if state == SeasonWeeklyRewardBubbleState.kNormal then
		self.icon_rewardTip:setVisible(false)
		self.labelPartUI:setVisible(false)

		self.rewardBox:setState('normal')

		self:stopRewardTipAnimForever()
		self:playBubbleNormalAnimForever()

	elseif state == SeasonWeeklyRewardBubbleState.kProcessing then
		self.icon_rewardTip:setVisible(false)
		self.labelPartUI:setVisible(true)

		
		self.rewardBox:setState('normal')

		self:stopRewardTipAnimForever()

		self:setProgressLabel( datas.curr , datas.total )

		self:playBubbleNormalAnimForever()

	elseif state == SeasonWeeklyRewardBubbleState.kWaitingForReward then

		self.icon_rewardTip:setVisible(true)
		self.labelPartUI:setVisible(false)

		self.rewardBox:setState('available')


		self:playRewardTipAnimForever()

		self:playBubbleNormalAnimForever()

	elseif state == SeasonWeeklyRewardBubbleState.kRewarded then

		self.icon_rewardTip:setVisible(false)
		self.labelPartUI:setVisible(false)
		
		self.rewardBox:setState('rewarded')

		self:stopRewardTipAnimForever()

		self:stopBubbleNormalAnim()
	end
end

function SeasonWeeklyRewardBubble:stopRewardTipAnimForever(...)
	if self.icon_rewardTip:isVisible() then
		self.icon_rewardTip:setScale(1)
		self.icon_rewardTip:setPositionXY( self.rewardTipPos.x , self.rewardTipPos.y )
		self.icon_rewardTip:stopAllActions()
		self.icon_rewardTip:setVisible(false)
	end
end

function SeasonWeeklyRewardBubble:playRewardTipAnimForever(...)

	self:stopRewardTipAnimForever()

	self.icon_rewardTip:setVisible(true)

	local baseTime = 0.5
	local baseScale = 1
	local arr2 = CCArray:create()
	local tpos = self.rewardTipPos
	--arr:addObject(CCDelayTime:create(0.1))

	arr2:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineOut:create( CCMoveTo:create( baseTime , ccp(tpos.x , tpos.y ) ) ), 
		CCEaseSineOut:create( CCScaleTo:create(baseTime, baseScale, baseScale))) )
	arr2:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineIn:create( CCMoveTo:create(baseTime, ccp(tpos.x - 15 , tpos.y - 20)) ), 
		CCEaseSineIn:create( CCScaleTo:create(baseTime, 1, 1))) )

	self.icon_rewardTip:runAction(CCRepeatForever:create(CCSequence:create(arr2)))
end

function SeasonWeeklyRewardBubble:stopBubbleNormalAnim(...)
end	

function SeasonWeeklyRewardBubble:playBubbleNormalAnimForever(...)
	assert(#{...} == 0)
	self:stopBubbleNormalAnim()
end

function SeasonWeeklyRewardBubble:createBubbleAnim(...)
	assert(#{...} == 0)

	-- Same In The Class BubbleItem.lua (getBubbleNormalAnim)

	local animationInfo = {

		secondPerFrame = 1 / 24,

		object = {
			node = self.fg,
			--deltaScaleX	= 71.90 / 67.05,
			--deltaScaleY	= 71.90 / 67.05,
			deltaScaleX	= 93.40 / 67.05,
			deltaScaleY	= 93.40 / 67.05,
			originalScaleX		= 1,
			originalScaleY		= 1,
		},

		keyFrames = {
			-- 1
			{ tweenType = "normal",  x = -4.35, y = 4.40, sx = 1.089, sy = 1.089, frameIndex = 1},
			-- 2
			{ tweenType = "normal",  x = -2.60, y = 4.40, sx = 1.041, sy = 1.089, frameIndex = 11},
			-- 3
			{ tweenType = "normal",  x = -4.35, y = 2.70, sx = 1.089, sy = 1.054, frameIndex = 21},
			-- 4
			{ tweenType = "static",  x = -4.35, y = 4.40, sx = 1.089, sy = 1.089, frameIndex = 26}
		}
	}

	local bubbleAction = FlashAnimBuilder:sharedInstance():buildTimeLineAction(animationInfo)
	return bubbleAction
end


function SeasonWeeklyRewardBubble:showTipPanel(showText)
	printx( 1 , "   SeasonWeeklyRewardBubble:showTipPanel  " , self.indexId)

	local rewards = SeasonWeeklyRaceManager:getInstance():getNextWeeklyReward()
	local reward = rewards[self.indexId]

	if not reward then return end

	local ipt = {}
	for k, v in ipairs(reward.items) do
		local itemId = v.itemId
		if ItemType:isTimeProp(itemId) then
			itemId = ItemType:getRealIdByTimePropId(itemId)
		end
		table.insert(ipt, {itemId = itemId, num = v.num})
	end

	if self.indexId == 6 then
		-- table.insert( ipt , #ipt , {itemId = 10072, num = 1} )
	end

	local tipPanel = BoxRewardTipPanel:create({ rewards=ipt })
	local text = Localization:getInstance():getText("2016_weeklyrace.summer.panel.tip1",{num=reward.needMore})

	if showText then
		tipPanel:setTipString(text)
	else
		tipPanel:setTipString("")
	end
	
	local scene = Director:sharedDirector():getRunningScene()
	scene:addChild(tipPanel , SceneLayerShowKey.TOP_LAYER)
	local bounds = self.touchRect:getGroupBounds()
	--tipPanel:setArrowPointPositionInWorldSpace( bounds.size.width/(2*bubble.fixScale) , bounds:getMidX() , bounds:getMidY() )
	tipPanel:scaleAccordingToResolutionConfig()
	tipPanel:setArrowPointPositionInWorldSpace( bounds.size.width/2 , bounds:getMidX() , bounds:getMidY() + 50)
end

function SeasonWeeklyRewardBubble:setProgressLabel( curr , total)
	self.label_target:setText(string.format('%s/%s ', tostring(curr), tostring(total)))
end

function SeasonWeeklyRewardBubble:clearProgressLabel()
	self.label_target:setText("")
end