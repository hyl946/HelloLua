

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月25日 16:53:37
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- HiddenBranchBox
---------------------------------------------------
local UIHelper = require 'zoo.panel.UIHelper'

HiddenBranchBox = class(Sprite)

function HiddenBranchBox:init(branchId, branch, BubbleAnimLayer, TipLayer, texture,...)

    self.BubbleAnimLayer = BubbleAnimLayer
    self.TipLayer = TipLayer

	self.resourceManager = ResourceManager:sharedInstance()

	-- --------------
	-- Init Base Class
	-- ----------------
	local sprite = CCSprite:create()
	self:setRefCocosObj(sprite)
	self.refCocosObj:setTexture(texture)

	-- -----------
	-- Get Data
	-- ------------
	self.metaModel = MetaModel:sharedInstance()
	self.branchDataList = self.metaModel:getHiddenBranchDataList()

    self.branchId = branchId

	-- Direction
	self.direction = false
	if tonumber(self.branchDataList[self.branchId].type) == 1 then
		self.direction = HiddenBranchDirection.RIGHT
	elseif tonumber(self.branchDataList[self.branchId].type) == 2 then
		self.direction = HiddenBranchDirection.LEFT
	else
		assert(false)
	end

    -- Position
	self.curBranchData = self.branchDataList[self.branchId]

	local posX = self.curBranchData .x
	local posY = self.curBranchData .y
	self:setPosition(ccp(posX, posY))

	-- Position
	self.curBranchData = self.branchDataList[self.branchId]
    self.branchNode = branch
--    self.reward = self.branchNode.reward
    self.cloud = self.branchNode.cloud

    if not self.metaModel:isHiddenBranchDesign(self.branchId) and not self:isRewardReceived() then
		self:showRewardBox()
	end

    self:runAction(CCCallFunc:create(function() self:showReward() end))
end


function HiddenBranchBox:showRewardBox( ... )

	if self.reward then
		return
	end

	self.reward = Sprite:createEmpty()

	local root = Sprite:createWithSpriteFrameName("hide_reward_root0000")
	local bubble = Sprite:createWithSpriteFrameName("hide_reward_bubble0000")
    bubble:setOpacity(0)
	local highlight = Sprite:createWithSpriteFrameName("hide_reward_box_highlight0000")
	local box = Sprite:createWithSpriteFrameName("hide_reward_box0000")
    local arrow = Sprite:createWithSpriteFrameName("arrow0000")
    arrow:setFlipX(true)
    local guang = Sprite:createWithSpriteFrameName("hide_branch_guang0000") 

    if self.direction == HiddenBranchDirection.LEFT then
        guang:runAction(CCRepeatForever:create(CCRotateBy:create(0.1, -9)))
    else
        guang:runAction(CCRepeatForever:create(CCRotateBy:create(0.1, 9)))
    end
    guang:setScale(1.2)

	if self.direction == HiddenBranchDirection.LEFT then
        self.reward:setScaleX(-1)
		box:setFlipX(true)
	end

	self.reward:setTexture(root:getTexture())
	for _,v in pairs({arrow,guang,bubble,box,highlight,root}) do
		self.reward:addChild(v)
	end
    
    self.reward.bubble = bubble
    self.reward.arrow = arrow

	root:setAnchorPoint(ccp(0.5,0))
	bubble:setAnchorPoint(ccp(0.5,0))
	box:setAnchorPoint(ccp(0.478,0))
	highlight:setAnchorPoint(ccp(0.5,0))
    arrow:setAnchorPoint(ccp(0.5,0.5))
    guang:setAnchorPoint(ccp(0.5,0.5))

	root:setRotation(15)
    arrow:setRotation(0)

	bubble:setPositionY(20+29/0.7)
    bubble:setPositionX(15/0.7)
	box:setPositionY(25+3/0.7)
    box:setPositionX(10/0.7)
    arrow:setPositionY(48/0.7)
    arrow:setPositionX(52/0.7)
	highlight:setPositionY(25)
    highlight:setPositionX(10/0.7)
    guang:setPositionY(25+25/0.7)
    guang:setPositionX(10/0.7)
    
	
    if self.direction == HiddenBranchDirection.RIGHT then
        self.reward:setPositionX(100)
	    self.reward:setPositionY(100)
    else
        self.reward:setPositionX(100-120/0.7)
	    self.reward:setPositionY(100)
    end
	

	highlight:setVisible(false)
    guang:setVisible(false)


    --箭头动画
    local arrayActionTime = 1
    arrow:stopAllActions()
	local array1 = CCArray:create()
    array1:addObject( CCFadeIn:create(arrayActionTime)  )
    array1:addObject( CCMoveBy:create(arrayActionTime, ccp(15, 0 )) )

    local array3 = CCArray:create()
    array3:addObject( CCMoveBy:create(arrayActionTime, ccp(-15, 0 )) )
    array3:addObject( CCFadeOut:create(arrayActionTime) )
    
    local arrowActions = CCArray:create()
    arrowActions:addObject( CCSpawn:create(array1)  )
    arrowActions:addObject( CCSpawn:create(array3)  )
	arrow:runAction( CCRepeatForever:create( CCSequence:create(arrowActions) ) )


    local Instance = self
	function self.reward:showHighlight( ... )
		if self.isDisposed then
			return
		end

		highlight:setVisible(true)
        highlight:setOpacity(0)
--		highlight:runAction(CCRepeatForever:create(
--			CCSequence:createWithTwoActions(
--				CCFadeOut:create(12/24),
--				CCFadeIn:create(12/24)
--			)
--		))

        guang:setVisible(true)
        if Instance then
            Instance:showRewardBox()
            Instance:showReward()
        end
	end
	function self.reward:isShowHighlight( ... )
		if self.isDisposed then
			return
		end

		return highlight:isVisible()		
	end


	function self.reward:playOpenAnim( ... )
		if self.isDisposed then
			return
		end

		root:stopAllActions()
		local rootActions = CCArray:create()
		root:setScaleX(0.08)
		root:setScaleY(0.23)
		rootActions:addObject(CCScaleTo:create(3/24,0.78,1.00))
		rootActions:addObject(CCScaleTo:create(2/24,0.78,1.21))
		rootActions:addObject(CCScaleTo:create(2/24,1.00,1.00))
		root:runAction(CCSequence:create(rootActions))

		box:stopAllActions()
		local boxActions = CCArray:create()
		box:setVisible(false)
		boxActions:addObject(CCDelayTime:create(7/24))
		boxActions:addObject(CCShow:create())
		box:setScaleX(0.29)
		box:setScaleY(0.29)
		boxActions:addObject(CCScaleTo:create(2/24,1.30,1.29))
		boxActions:addObject(CCScaleTo:create(2/24,1.33,0.74))
		boxActions:addObject(CCScaleTo:create(2/24,1.00,1.00))
		box:runAction(CCSequence:create(boxActions))	
	end

	function self.reward:playReceiveAnim( callback )
		if self.isDisposed then
			return
		end

		bubble:setVisible(false)
		root:setVisible(false)
		highlight:setVisible(false)
        guang:setVisible(false)

		self:runAction(CCSequence:createWithTwoActions(
			HiddenBranchAnimation:buildReceiveAnim(self,box),
			CCCallFunc:create(function( ... )
				if callback then
					callback()
				end
			end)
		))

        if Instance then
            Instance:HideReward()
        end
	end

	self.reward:addEventListener(DisplayEvents.kTouchTap, function( ... )
		self:onRewardBoxTapped()
	end)


	self:addChildAt(self.reward,2)
end

function HiddenBranchBox:getRewardBoxNode( ... )
	return self.reward
end

function HiddenBranchBox:onRewardBoxTapped( ... )
	if not self.reward or self.reward.isDisposed then
		return
	end

	if not self:hasEndPassed() then	
	else

		local bounds = self.reward:getBounds()
		local posX = bounds:getMidX()
		local posY = bounds:getMidY()
		
		local function onSuccess( evt )
			self.reward:removeEventListenerByName(DisplayEvents.kTouchTap)

			self.reward:playReceiveAnim(function( ... )
				if self.reward then
					self.reward:removeFromParentAndCleanup(true)
					self.reward = nil
				end
			end)

			UserManager:getInstance():addRewards(evt.data.rewards, true)
			UserService:getInstance():addRewards(evt.data.rewards)
			GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kLevelArea, evt.data.rewards, DcSourceType.kHideAreaReward)

			self:setRewardReceived()

			DcUtil:UserTrack({ category="hide", sub_category="get_hide_stage", t1=self.branchId })


			setTimeOut(function( ... )
				local anim = FlyItemsAnimation:create(evt.data.rewards)
				anim:setWorldPosition(ccp(posX,posY + 30))
				anim:play()
			end,0.3)
		end
		local function onFail( evt ) 
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
		end

	 	local http = GetHideAreaRewardsHttp.new(true)
 		http:ad(Events.kComplete, onSuccess)
		http:ad(Events.kError, onFail)
	 	http:syncLoad(self.branchId)
	end
end

function HiddenBranchBox:setRewardReceived( ... )
	UserManager:getInstance():getUserExtendRef():setHideAreaRewardReceived(self.branchId)
	Localhost:flushCurrentUserData()
end

function HiddenBranchBox:showReward( ... )

    if not self.reward then
		return
	end

    if self.bubble then
        self.bubble:removeFromParentAndCleanup(true)
        self.bubble = nil
    end

    --bubble
    local rewardBubble = self.reward.bubble
    local RewardBubbleWorldPos = rewardBubble:getParent():convertToWorldSpace( rewardBubble:getPosition() )
    local BubblePos = self.BubbleAnimLayer:convertToNodeSpace( RewardBubbleWorldPos )

    FrameLoader:loadArmature( 'skeleton/HiddenBranchAnim' )

    local AnimName = "HiddenBranchAnim/animationxxx"
    if self.reward then
		if self:hasEndPassed() and self.reward:isShowHighlight() then
			AnimName = "HiddenBranchAnim/animationxxx2"
        end
    end

    local bubble = ArmatureNode:create(AnimName) --UIHelper:createArmature2('skeleton/HiddenBranchAnim','HiddenBranchAnim/animationxxx')
--    local bubbleBatch = bubble:wrapWithBatchNode()
    bubble:play('A',0)

    if self.direction == HiddenBranchDirection.LEFT then
        bubble:setPosition( ccp(BubblePos.x+10+1/0.7,BubblePos.y) )
    else
        bubble:setPosition( BubblePos )
    end
    
    self.BubbleAnimLayer:addChildAt( bubble,1 )
    self.bubble = bubble
end

function HiddenBranchBox:HideReward( ... )
    if self.bubble then
        self.bubble:removeFromParentAndCleanup(true)
        self.bubble = nil
    end

    self:showRewardTipPanel( false )
end

function HiddenBranchBox:setRewardArrowShow( bShow )
    if self.reward then
		if self:hasEndPassed() and self.reward:isShowHighlight() then
            self.reward.arrow:setVisible( false ) --可以领奖状态就不出箭头了
        else
            self.reward.arrow:setVisible( bShow )
        end

        if bShow then
            self:showRewardTipPanel( false )
        end
	end

    if self.branchNode.cloud then
        self.branchNode.cloud:updateShow()
    end
	
    local metaModel = MetaModel:sharedInstance()
    if metaModel:isHiddenBranchCanOpen(self.branchId) then
        local uid = UserManager:getInstance().user.uid or '12345'
        if bShow == false then
            --展开隐藏关 设置下次可跳入隐藏关
            CCUserDefault:sharedUserDefault():setIntegerForKey('stayBranchId_'..uid, self.branchId )
            CCUserDefault:sharedUserDefault():flush()
        else
            --关闭的时候取消跳入
            CCUserDefault:sharedUserDefault():setIntegerForKey('stayBranchId_'..uid, 0 )
            CCUserDefault:sharedUserDefault():flush()
        end
    end
end


function HiddenBranchBox:showRewardTipPanel( bShow )

--    if bShow and not self:hasEndPassed() and self.reward then
    if bShow and self.reward then
        if self.RewardTip == nil then
	        local HiddenBranchRewardTipPanel = require "zoo/panel/component/common/HiddenBranchRewardTipPanel"
	        local tipPanel = HiddenBranchRewardTipPanel:create({ rewards=self.curBranchData.hideReward }, nil, nil, nil, false )

	        local levelText = tostring(LevelMapManager.getInstance():getLevelDisplayName(self.curBranchData.endHiddenLevel))
	        tipPanel:setTipString(Localization:getInstance():getText("hide_stage_tips4",{replace=levelText}))
            self.TipLayer:addChild(tipPanel, SceneLayerShowKey.POP_OUT_LAYER)

	        local bounds = self.reward:getGroupBounds()
	        local distance = bounds.size.width/5
	        local pos

            if self.direction == HiddenBranchDirection.LEFT then
                pos = {x=bounds:getMidX()-222/0.7,y=bounds:getMidY()+180/0.7}
                tipPanel:setArrowPointPositionInWorldSpace( false, 20+188/0.7, pos.x, pos.y)
	        else
                pos = {x=bounds:getMidX()-11/0.7,y=bounds:getMidY()+180/0.7}
                tipPanel:setArrowPointPositionInWorldSpace( true, 50, pos.x, pos.y)
	        end 

            self.RewardTip = tipPanel
        else
            self.RewardTip:setVisible(true)
        end
    else
        if self.RewardTip then
            self.RewardTip:setVisible(false)
            self.RewardTip:removeFromParentAndCleanup(true)
            self.RewardTip = nil
        end
    end
end

function HiddenBranchBox:hasEndPassed( ... )
	local endHiddenLevel = self.curBranchData.endHiddenLevel
	return UserManager.getInstance():hasPassedLevel(endHiddenLevel)
end

function HiddenBranchBox:isRewardReceived( ... )
	return UserManager:getInstance():getUserExtendRef():isHideAreaRewardReceived(self.branchId)
end


function HiddenBranchBox:create(branchId,branch,BubbleAnimLayer, TipLayer, texture)
	local newHiddenBranch = HiddenBranchBox.new()
	newHiddenBranch:init(branchId,branch,BubbleAnimLayer, TipLayer, texture)
	return newHiddenBranch
end
