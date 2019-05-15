

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月25日 16:53:37
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- HiddenBranch
---------------------------------------------------
local UIHelper = require 'zoo.panel.UIHelper'

assert(not HiddenBranchDirection)
HiddenBranchDirection = {
	LEFT	= 1,
	RIGHT	= 2
}

local function checkHiddenBranchDirection(dir)
	assert(dir)

	assert(dir == HiddenBranchDirection.LEFT or
		dir == HiddenBranchDirection.RIGHT)
end

------------------------------------------
-------- Event
---------------------------

assert(not HiddenBranchEvent)

HiddenBranchEvent = 
{
	OPEN_ANIM_FINISHED	= "HiddenBranchEvent.OPEN_ANIM_FINISHED"
}

HiddenBranch = class(Sprite)

function HiddenBranch:init(branchId, initialOpened, texture, ...)
	assert(branchId)
	assert(initialOpened ~= nil)
	assert(type(initialOpened) == "boolean")
	assert(#{...} == 0)

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

	-- ------------
	-- Update View
	-- -------------
	local branch = HiddenBranchAnimation:createStatic()
	self.branch = branch
	self:addChild(branch)

	if self.direction == HiddenBranchDirection.LEFT then
		branch:setScaleX(-1)
	end

	if not initialOpened then
		self.branch:setVisible(false)
	end

--	if not self.metaModel:isHiddenBranchDesign(self.branchId) and not self:isRewardReceived() then
--		self:showReward()
--	end

	function self:hitTestPoint( worldPosition, useGroupTest )
		local bounds = self:getGroupBounds()

		bounds = CCRectMake(
			bounds.origin.x,
			bounds.origin.y - 100,
			bounds.size.width,
			bounds.size.height + 100
		)

		return bounds:containsPoint(worldPosition)
 	end

    --是否完全展开
    self.bAllShow = nil

    --跨天检测
    local instance = self
    local function onPassDay()
        if instance.cloud and not instance.cloud.isDisposed then
            instance.cloud:updateShow()
        end
    end
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, onPassDay )
end

--function HiddenBranch:showReward( ... )

--end

function HiddenBranch:getRewardNode( ... )
    if self.branchBox == nil then
        return nil
    end
	return self.branchBox.reward
end

function HiddenBranch:showCloud(cloudBathNode, textBatchNode, numberBathNode, extraTextContainer, initialShowText)
	if self.cloud then
		return
	end

	self.extraTextContainer = extraTextContainer

	local curBranchData = self.curBranchData

	self.cloud = Sprite:createEmpty()
	
	local cloudSprite = Sprite:createWithSpriteFrameName("hide_cloud0000")
	cloudSprite:setPositionX(cloudSprite:getContentSize().width/2)
	cloudSprite:setPositionY(cloudSprite:getContentSize().height/2)
	cloudSprite:setAnchorPoint(ccp(0.5,0.5))
	if self.direction == HiddenBranchDirection.LEFT then
		cloudSprite:setFlipX(true)
	end 

	local titleSprite = Sprite:createWithSpriteFrameName("hide_cloud_title0000")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	if self.direction == HiddenBranchDirection.LEFT then
		titleSprite:setPositionX(cloudSprite:getContentSize().width/2 - 25)
		titleSprite:setPositionY(cloudSprite:getContentSize().height - 45)		
	else
		titleSprite:setPositionX(cloudSprite:getContentSize().width/2 + 25)
		titleSprite:setPositionY(cloudSprite:getContentSize().height - 45)
	end
   
	self.cloud.title = titleSprite

	self.cloud:setContentSize(cloudSprite:getContentSize())
	self.cloud:setTexture(cloudSprite:getTexture())

	self.cloud:addChild(cloudSprite)
	self.cloud:addChild(titleSprite)

	self.cloud:setAnchorPoint(ccp(0.5,0.5))

	if self.direction == HiddenBranchDirection.LEFT then
		self.cloud:setPositionX(self:getPositionX() - 330)
		self.cloud:setPositionY(self:getPositionY())
	else
		self.cloud:setPositionX(self:getPositionX() + 330)
		self.cloud:setPositionY(self:getPositionY())
	end

	self:updateCountdownShow()

	cloudBathNode:addChild(self.cloud)

	if self.metaModel:isHiddenBranchDesign(self.branchId) then
		-- hide_stage_tips2
		local label = textBatchNode:createLabel(Localization:getInstance():getText("hide_stage_tips3"))
		label:setColor(ccc3(0x0F,0x5B,0x70))
		label:setAnchorPoint(ccp(0.5,0.5))
		label:setScale(0.8)
		if self.direction == HiddenBranchDirection.LEFT then
			label:setPositionX(self.cloud:getPositionX() - 20)
			label:setPositionY(self.cloud:getPositionY())		
		else
			label:setPositionX(self.cloud:getPositionX() + 20)
			label:setPositionY(self.cloud:getPositionY())
		end
		textBatchNode:addChild(label)
		self.cloud.label = label
	else
        ----补星按钮
        local BuXingSprite = Sprite:createWithSpriteFrameName("gotoBuxing0000")

        if self.direction == HiddenBranchDirection.LEFT then
	        BuXingSprite:setPositionX(self.cloud:getPositionX() - 17/0.7)
        else
            BuXingSprite:setPositionX(self.cloud:getPositionX() + 17/0.7)
        end
	    BuXingSprite:setPositionY(self.cloud:getPositionY()-43/0.7)
	    BuXingSprite:setAnchorPoint(ccp(0.5,0.5))
        extraTextContainer:addChild(BuXingSprite)

        local function BuxingClick()
            --打开补星活动 @junsong.ma
            CollectStarsManager:getInstance():doOpenActivity()
            
        end

        UIUtils:setTouchHandler( BuXingSprite ,function ()
            if self.bAllShow then
                BuxingClick()
            end
        end)

        local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
        hand:setAnchorPoint(ccp(0, 1))
        hand:setPosition(ccp(BuXingSprite:getContentSize().width/2,BuXingSprite:getContentSize().height/2))
        BuXingSprite:addChild(hand)
        hand:setVisible(false)
        BuXingSprite.hand = hand
        BuXingSprite:setVisible(false)

        self.cloud.BuXingSprite = BuXingSprite

		-- 
		local startNormalLevel = curBranchData.startNormalLevel
		local endNormalLevel = curBranchData.endNormalLevel

		-- x关全部3星开启（x）
		local label = textBatchNode:createLabel(Localization:getInstance():getText(
			"hide_stage_tips1",
			{ replace1=startNormalLevel,replace2=endNormalLevel }
		))
		label:setScale(0.8)
		label:setColor(ccc3(0x0F,0x5B,0x70))
		label:setAnchorPoint(ccp(0.5,0))
		if self.direction == HiddenBranchDirection.LEFT then
			label:setPositionX(self.cloud:getPositionX() - 20)
			label:setPositionY(self.cloud:getPositionY())		
		else
			label:setPositionX(self.cloud:getPositionX() + 20)
			label:setPositionY(self.cloud:getPositionY())
		end
		textBatchNode:addChild(label)
		self.cloud.label = label

		local number = Sprite:createEmpty()
		number:setTexture(numberBathNode.refCocosObj:getTexture())
		number.refCocosObj:setCascadeOpacityEnabled(true)
			
		local num = endNormalLevel - startNormalLevel + 1
		local number2 = numberBathNode:createLabel("/ " .. num )
		number2:setAnchorPoint(ccp(0,1))
		number2:setPositionX(0)
		number:addChild(number2)

		number:setScale(1.3)
		numberBathNode:addChild(number)	
		self.cloud.number = number
        self.cloud.number2 = number2

		if self.direction == HiddenBranchDirection.LEFT then
			number:setPositionX(self.cloud:getPositionX() - 40)
			number:setPositionY(self.cloud:getPositionY() )
		else
			number:setPositionX(self.cloud:getPositionX())
			number:setPositionY(self.cloud:getPositionY() - 10 )
		end

		local guanSprite = Sprite:createWithSpriteFrameName("hide_cloud_guan0000")
		guanSprite:setAnchorPoint(ccp(0,0))
		self:runAction(CCCallFunc:create(function( ... )
			local worldPos = number:convertToWorldSpace(ccp(number2:boundingBox():getMaxX(),number2:boundingBox():getMinY()))
			local localPos = self.cloud:convertToNodeSpace(worldPos)
			guanSprite:setPositionX(localPos.x + 5)
			guanSprite:setPositionY(localPos.y + 11)
		end))
		self.cloud:addChild(guanSprite)
		self.cloud.guang = guanSprite

		function number:setVisible( isVisible )
			if self.isDisposed then
				return
			end
			Sprite.setVisible(self,isVisible)
			guanSprite:setVisible(isVisible)
		end
	end

	local context = self
	function self.cloud:updateStar( ... )
		if self.isDisposed then
			return
		end
		if not self.number then
			return
		end

		if self.number1 then
			self.number1:removeFromParentAndCleanup(true)
		end

		local totalScore = 0
		local startNormalLevel = curBranchData.startNormalLevel
		local endNormalLevel = curBranchData.endNormalLevel
		for index = startNormalLevel, endNormalLevel do
			local score = UserManager.getInstance():getUserScore(index)
			if score and score.star >= 3 then
				totalScore = totalScore + 1
			end
		end

		self.number1 = numberBathNode:createLabel(tostring(totalScore) .. " ")
		self.number1:setAnchorPoint(ccp(1,1))
		self.number1:setPositionX(0)
		self.number1:setColor(ccc3(0xFF,0xFF,0x00))
		self.number:addChild(self.number1)
	end

	function self.cloud:setVisible( isVisible )
		if self.isDisposed then
			return
		end
		Sprite.setVisible(self,isVisible)

		if self.label then
			self.label:setVisible(isVisible)
		end

		if self.number then
			self.number:setVisible(isVisible)
		end

--        if self.BuXingSprite then
--			self.BuXingSprite:setVisible(isVisible)
--		end

		cloudSprite:setVisible(isVisible)
	end

	function self.cloud:playOpenAnim( ... )
		if self.isDisposed then
			return
		end
		titleSprite:setVisible(false)
		if self.label then
			self.label:setVisible(false)
		end
		if self.number then
			self.number:setVisible(false)
		end

        if self.BuXingSprite then
			self.BuXingSprite:setVisible(false)
		end
		
		cloudSprite:setScaleX(0.21)
		cloudSprite:setScaleY(0.21)
		cloudSprite:setOpacity(0)

		local actions = CCArray:create()
		actions:addObject(CCSpawn:createWithTwoActions(
			 CCScaleTo:create(10/24,1,1),
			 CCFadeIn:create(10/24)
		))
		actions:addObject(CCCallFunc:create(function( ... )
			titleSprite:setVisible(true)
			if self.label then
				self.label:setVisible(true)
			end
			if self.number then
				self.number:setVisible(true)
			end

--            if self.BuXingSprite then
--			    self.BuXingSprite:setVisible(true)
--		    end
		end))
		actions:addObject(CCScaleTo:create(2/24,1.13,1.05))
		actions:addObject(CCScaleTo:create(3/24,1,1))

		cloudSprite:runAction(CCSequence:create(actions))
	end

	local branch = self.branch
	function self.cloud:playUnLockAnim( callback )
		if self.isDisposed or branch.isDisposed then
			return
		end

		if self.title then 
			self.title:removeFromParentAndCleanup(true)
			self.title = nil
		end
		if self.label then
			self.label:removeFromParentAndCleanup(true)
			self.label = nil
		end
		if self.number then
			self.number:removeFromParentAndCleanup(true)
			self.number = nil
		end
		if self.guang then
			self.guang:removeFromParentAndCleanup(true)
			self.guang = nil
		end

        if self.BuXingSprite then
			self.BuXingSprite:removeFromParentAndCleanup(true)
			self.BuXingSprite = nil
		end

		local cloudActions = CCArray:create()
		cloudActions:addObject(CCScaleTo:create(5/24,0.56,0.65))
		cloudActions:addObject(CCCallFunc:create(function( ... )
			cloudSprite:setVisible(false)
		end))
		cloudSprite:runAction(CCSequence:create(cloudActions))

		self:runAction(CCSequence:createWithTwoActions(
			HiddenBranchAnimation:buildUnlockAnim(self,branch),
			CCCallFunc:create(function( ... )
				if callback then
					callback()
				end
			end)
		))
	end

    function self.cloud:updateShow()

        if context.metaModel:isHiddenBranchDesign(context.branchId) then
            --尚未开启
        else
            local isCountDowning = NewAreaOpenMgr.getInstance():isHideAreaCountdownIng(context.branchId)

            if isCountDowning then
                --倒计时
            else
                --已开启
                local bBuXingActivity = true --是否补星活动推荐 @junsong.ma
                bBuXingActivity = CollectStarsManager:getInstance():isInMyArea( context.branchId )
                if _G.isLocalDevelopMode  then printx(1 , " getRecommendationLevelID  bBuXingActivity = " , bBuXingActivity ) end
                if _G.isLocalDevelopMode  then printx(1 , " getRecommendationLevelID  context.branchId = " , context.branchId ) end

                local offsetY = 0

                local metaModel = MetaModel:sharedInstance()
                if bBuXingActivity then
                    offsetY = 20/0.7

                    if self.title then
                        self.title:setScale(0.8)
                    end

                    if self.BuXingSprite then
                        self.BuXingSprite:setVisible(true)
                    end

                    local TopBranchId = metaModel:getTopHiddenBranchId()
                    if context.branchId == TopBranchId then
                        if self.BuXingSprite then
                            self.BuXingSprite:setOpacity(255)
                            self.BuXingSprite:stopAllActions()

                            if context.bAllShow then
                                self.BuXingSprite.hand:setVisible(true)
                            else
                                self.BuXingSprite.hand:setVisible(false)
                            end
                        end
                    else
                        if self.BuXingSprite then
                            self.BuXingSprite:setOpacity(255)
                            self.BuXingSprite:stopAllActions()
                            local array1 = CCArray:create()
                            array1:addObject( CCScaleTo:create(0.5, 1.05)  )
                            array1:addObject( CCScaleTo:create(0.5, 0.95)  )
                            self.BuXingSprite:runAction( CCRepeatForever:create( CCSequence:create(array1) ) )

                            self.BuXingSprite.hand:setVisible(false)
                        end
                    end
                else
                    if self.title then
                        self.title:setScale(1)
                    end

                    if self.BuXingSprite then
                        self.BuXingSprite:setVisible(false)
                        self.BuXingSprite:setOpacity(255)
                        self.BuXingSprite:stopAllActions()
                        self.BuXingSprite.hand:setVisible(false)
                    end
                end

                if context.direction == HiddenBranchDirection.LEFT then

                    if self.label then
			            self.label:setPositionY(self:getPositionY() + offsetY)	
                    end

                    if self.number then
                        self.number:setPositionY(self:getPositionY() + offsetY )	
                    end
		        else
                    if self.label then
			            self.label:setPositionY(self:getPositionY() + offsetY)
                    end

                    if self.number then
                        self.number:setPositionY(self:getPositionY() - 10 + offsetY )
                    end
		        end

                if self.guang then
                    local worldPos = self.number:convertToWorldSpace(ccp(self.number2:boundingBox():getMaxX(),self.number2:boundingBox():getMinY()))
		            local localPos = self:convertToNodeSpace(worldPos)
		            self.guang:setPositionY(localPos.y + 11)
                end
            end
        end
    end

	self.cloud:updateStar()
	
	if not initialShowText then
		self.cloud.title:setVisible(false)
		self.cloud.label:setVisible(false)
		if self.cloud.number then
			self.cloud.number:setVisible(false)
		end
		if self.cloud.guang then
			self.cloud.guang:setVisible(false)
		end

        if self.cloud.BuXingSprite then
			self.cloud.BuXingSprite:setVisible(false)
		end
		
	end
end

function HiddenBranch:updateCountdownShow()
	if not NewAreaOpenMgr.getInstance():isHideAreaCountdownIng(self.branchId) or 
		not MetaModel:sharedInstance():isAllLevelsTreeStarForHideArea(self.branchId) or
		not self.cloud or not self.extraTextContainer then 
		self:stopCountDown()
		return 
	end

	local endTime = NewAreaOpenMgr.getInstance():getHideAreaEndTime(self.branchId)
	if not self.areaCountdownTip then 
	    local label = BitmapText:create('', 'fnt/unlocknew2.fnt')
	    label:setScale(0.8)
	    label:setAnchorPoint(ccp(0, 0.5))
	    self.extraTextContainer:addChild(label)
		if self.direction == HiddenBranchDirection.LEFT then
			label:setPositionX(self.cloud:getPositionX() - 20 - 110)
			label:setPositionY(self.cloud:getPositionY() + 50)		
		else
			label:setPositionX(self.cloud:getPositionX() + 20 - 102)
			label:setPositionY(self.cloud:getPositionY() + 50)
		end

		self.areaCountdownTip = label
	end
	local function onTick()
		if self.isDisposed or self.cloud.isDisposed or self.extraTextContainer.isDisposed then return end
	    local timeStr, isOver = NewAreaOpenMgr.getInstance():getCountdownStr(endTime)
	    if isOver then 
	    	self:stopCountDown()
	    	self:countdownOverUnlock()
	    else
	    	self.areaCountdownTip:setText(timeStr.."后解锁")
	    end
	end
	if not self.oneSecondTimer then 
		self.oneSecondTimer = OneSecondTimer:create()
	    self.oneSecondTimer:setOneSecondCallback(function ()
	        onTick()
	    end)
	    onTick()
	    if self.oneSecondTimer then
	    	self.oneSecondTimer:start()
	    end
	end
end

function HiddenBranch:stopCountDown()
	if self.oneSecondTimer then 
		self.oneSecondTimer:stop()
		self.oneSecondTimer = nil
	end
	if self.areaCountdownTip then 
		self.areaCountdownTip:removeFromParentAndCleanup(true)
	end
	self.areaCountdownTip = nil
end

function HiddenBranch:countdownOverUnlock()
	local worldScene = HomeScene:sharedInstance().worldScene
	if worldScene then 
		local scene = Director:sharedDirector():getRunningScene()
		if scene and scene:is(HomeScene) then 
			worldScene:unlockHiddenBranchCloud(self.branchId, true)
		else
			if self:isClosed() then 
				worldScene.unlockHiddenBranchCloudBranchId = self.branchId
			end
		end
	end
end

function HiddenBranch:showCloudLabel( ... )
	if not self.cloud then
		return
	end

	local function fadeIn( ui )
		ui:stopAllActions()
		ui:setVisible(true)
		ui:runAction(CCFadeIn:create(0.5))
	end

	if self.cloud.title then
		fadeIn(self.cloud.title)
	end
	if self.cloud.label then
		fadeIn(self.cloud.label)
	end
	if self.cloud.number then
		fadeIn(self.cloud.number)
	end
	if self.cloud.guang then
		fadeIn(self.cloud.guang)
	end

    local bBuXingActivity = CollectStarsManager:getInstance():isInMyArea( self.branchId ) --是否补星活动推荐 @junsong.ma
    if self.cloud.BuXingSprite and bBuXingActivity then
        fadeIn(self.cloud.BuXingSprite)
    end

    self.bAllShow = true
    self.cloud:updateShow()
end

function HiddenBranch:hideCloudLabel( ... )
	if not self.cloud then
		return
	end

	local function fadeOut( ui )
		-- ui:stopAllActions()
		-- ui:runAction(CCFadeOut:create(0.5))
		ui:setVisible(false)
	end
	
	if self.cloud.title then
		fadeOut(self.cloud.title)
	end
	if self.cloud.label then
		fadeOut(self.cloud.label)
	end
	if self.cloud.number then
		fadeOut(self.cloud.number)
	end
	if self.cloud.guang then
		fadeOut(self.cloud.guang)
	end

    if self.cloud.BuXingSprite then
        fadeOut(self.cloud.BuXingSprite)
        fadeOut(self.cloud.BuXingSprite.hand)
    end

    self.bAllShow = false
end


function HiddenBranch:getDirection(...)
	assert(#{...} == 0)

	return self.direction
end

function HiddenBranch:playOpenAnim(animLayer)
	local animBranch = nil 

	if self.cloud then
		self.cloud:setVisible(false)
	end

	local function onAnimComplete()
		animBranch:removeFromParentAndCleanup(true)
		self.branch:setVisible(true)
		self:dp(Event.new(HiddenBranchEvent.OPEN_ANIM_FINISHED, self.branchId, self))

		if self.reward then
			self.reward:playOpenAnim()
		end

		if self.cloud then
			self.cloud:setVisible(true)
			self.cloud:playOpenAnim()
		end
	end

	local manualAdjustX = 0
	local manualAdjustY = 0

	animBranch = HiddenBranchAnimation:createAnim(onAnimComplete)
	animBranch:setPosition(ccp(self:getPositionX() + manualAdjustX, self:getPositionY() + manualAdjustY))

	animLayer:addChild(animBranch)
	
	if self.direction == HiddenBranchDirection.LEFT then
		animBranch:setScaleX(-1)
	end
end

function HiddenBranch:isClosed( ... )
	return self.cloud ~= nil
end

function HiddenBranch:create(branchId, initialOpened, texture, ...)
	assert(branchId)
	assert(initialOpened ~= nil)
	assert(type(initialOpened) == "boolean")
	assert(#{...} == 0)

	local newHiddenBranch = HiddenBranch.new()
	newHiddenBranch:init(branchId, initialOpened, texture)

	return newHiddenBranch
end



function HiddenBranch:updateState( ... )
	if self.cloud then
		self:updateCountdownShow()

		self.cloud:updateStar()

		if MetaModel:sharedInstance():isHiddenBranchCanOpen(self.branchId) then
			self.cloud:playUnLockAnim(function( ... )
				if self.cloud then
					self.cloud:removeFromParentAndCleanup(true)
					self.cloud = nil
				end
			end)
		end
	end

    if self.branchBox then
	    if self.branchBox.reward then
		    if self:hasEndPassed() and not self.branchBox.reward:isShowHighlight() then

			    self.branchBox.reward:showHighlight()

			    local uid = UserManager.getInstance().uid
			    local data = Localhost:readLocalBranchDataByBranchId(uid,self.branchId)
			    if not data.canRewardTime then
				    data.canRewardTime = Localhost:time()
				    Localhost:writeLocalLevelDataByBranchId(uid,self.branchId,data)
			    end
		    end
	    end
    end
end


function HiddenBranch:hasEndPassed( ... )
	local endHiddenLevel = self.curBranchData.endHiddenLevel
	return UserManager.getInstance():hasPassedLevel(endHiddenLevel)
end

function HiddenBranch:isRewardReceived( ... )
	return UserManager:getInstance():getUserExtendRef():isHideAreaRewardReceived(self.branchId)
end

function HiddenBranch:setRewardReceived( ... )
	UserManager:getInstance():getUserExtendRef():setHideAreaRewardReceived(self.branchId)
	Localhost:flushCurrentUserData()
end