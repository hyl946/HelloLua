require "zoo.panel.starRewardPanel"

QQStarRewardPanel = class(StarRewardPanel)

local tipInstance = nil
local function disposeTip()
    if tipInstance then 
        tipInstance:hide()
        tipInstance:dispose()
        tipInstance = nil
    end
end

local function showTip(rect, content, propsId)

    disposeTip()

    tipInstance = BubbleTip:create(content, propsId)
    tipInstance.duration = 5
    tipInstance:show(rect)
end

function QQStarRewardPanel:create(starRewardBtnPosInWorldSpace, ...)
	assert(starRewardBtnPosInWorldSpace)
	assert(#{...} == 0)

	local newStarRewardPanel = QQStarRewardPanel.new()
	newStarRewardPanel:loadRequiredResource(PanelConfigFiles.star_reward_panel)
	newStarRewardPanel:init(starRewardBtnPosInWorldSpace , "qqStarRewardPanel")
	return newStarRewardPanel
end

function QQStarRewardPanel:init(starRewardBtnPosInWorldSpace, interfaceGroup , ...)
	StarRewardPanel.init(self , starRewardBtnPosInWorldSpace, interfaceGroup)

	self.moreStarBtnRes		= self.ui:getChildByName("moreStarBtn")
	self.moreStarBtn	= GroupButtonBase:create(self.moreStarBtnRes)

	--local getBtnLabelKey	= "star.reward.panel.get.btn.label"
	--local getBtnLabelValue	= Localization:getInstance():getText(getBtnLabelKey, {})
	--self.moreStarBtn:setString("获得更多星星2")


	self.moreStarBtn:setColorMode(kGroupButtonColorMode.blue)
	self.moreStarBtn:useBubbleAnimation()
	self.moreStarBtn:setVisible(false)
	--self.moreStarBtn:setPositionY(self.getBtn:getPositionY() - 25)

	if self.getBtn.colorMode == kGroupButtonColorMode.green then
		self.getBtn:setPositionY(self.getBtn:getPositionY() + 25)
	end
	

	local itemId = self.rewardItem.itemId
	local number = self.rewardItem.itemNumber

	local isTimeLimit = false
    if ItemType:isTimeProp(itemId) then 
        itemId = ItemType:getRealIdByTimePropId(itemId) 
        isTimeLimit = true
    end

    if self.rewardItem.itemRes then
    	local itemResPosition = self.rewardItem.itemRes:getPosition()
	    local itemResLayer = Layer:create()

	    self.rewardItem.itemResLayer = itemResLayer

	    itemResLayer:setPosition(ccp(itemResPosition.x ,itemResPosition.y))
	    self.rewardItem.ui:addChild(itemResLayer)
	    self.rewardItem.itemRes:removeFromParentAndCleanup(false)
	    itemResLayer:addChild(self.rewardItem.itemRes)
	    self.rewardItem.itemRes:setPosition(ccp(0,0))
	    itemResLayer:setTouchEnabled(true,0)

	    itemResLayer:ad(
	    	DisplayEvents.kTouchTap, 
	    	function () 
	    		self:onRewardItemTapped()
			end)
    end
end


function QQStarRewardPanel:showItemTip(ib, item, isTimeLimit)
	local propsId = item.itemId
    local content = self.builder:buildGroup('bagItemTipContent_starReward')
    local desc = content:getChildByName('desc')
    local title = content:getChildByName('title')

    title:setString(Localization:getInstance():getText("prop.name."..propsId))
    local originSize = desc:getDimensions()
    originSize = {width = originSize.width, height = originSize.height}
    desc:setDimensions(CCSizeMake(originSize.width, 0))
    local descString = Localization:getInstance():getText("level.prop.tip."..propsId, {n = "\n", replace1 = 1})
    if isTimeLimit then
        descString = descString..'\n'..Localization:getInstance():getText('anni.cake.time.limit.desc')
    end
    desc:setString(descString)

    showTip(ib:getGroupBounds(), content, propsId)
end

function QQStarRewardPanel:reinit(...)
	---------
	-- Data
	-- --------
	-- Get Current Star
	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()
	self.curTotalStar	= curTotalStar
	local userExtend 	= UserManager:getInstance().userExtend

	-- Get RewardLevelMeta 
	he_log_warning("reform !")
	local nearestStarRewardLevelMeta	= MetaManager.getInstance():starReward_getRewardLevel(curTotalStar)
	local nextRewardLevelMeta		= MetaManager.getInstance():starReward_getNextRewardLevel(curTotalStar)
	local rewardLevelToPushMeta 		= false

	if nearestStarRewardLevelMeta then

		rewardLevelToPush = userExtend:getFirstNotReceivedRewardLevel(nearestStarRewardLevelMeta.id)

		if rewardLevelToPush then
			-- Has Reward Level
			rewardLevelToPushMeta = MetaManager.getInstance():starReward_getStarRewardMetaById(rewardLevelToPush)
		else
			-- All Reward Level Has Received
		end
	end

	if not rewardLevelToPushMeta then
		-- If Has Next Reward Level, Show It
		if nextRewardLevelMeta then
			rewardLevelToPushMeta = nextRewardLevelMeta
		end
	end

	self.rewardLevelToPushMeta =  rewardLevelToPushMeta

	local itemId		= 0
	local itemNumber	= 0

	if rewardLevelToPushMeta then
		assert(rewardLevelToPushMeta)
		if _G.isLocalDevelopMode then printx(0, rewardLevelToPushMeta.reward[1].num) end
		if _G.isLocalDevelopMode then printx(0, rewardLevelToPushMeta.reward[1].itemId) end

		itemId		= rewardLevelToPushMeta.reward[1].itemId
		itemNumber	= rewardLevelToPushMeta.reward[1].num
	end

	-----------
	-- FLag 
	-- ------
	self.btnTappedState			= self.BTN_TAPPED_STATE_NONE
	
	-----------------------
	-- Create UI Component
	-- -------------------
	--self.rewardItem	= StarRewardItem:create(self.rewardItemRes, itemId, itemNumber)
	self.rewardItem.itemRes:removeFromParentAndCleanup(true)
	self.rewardItem:rebuild(itemId, itemNumber)
    self.rewardItem.itemRes:removeFromParentAndCleanup(false)
    self.rewardItem.itemResLayer:addChild(self.rewardItem.itemRes)
    self.rewardItem.itemRes:setPosition(ccp(0,0))

	if rewardLevelToPushMeta then
		
		if curTotalStar < rewardLevelToPushMeta.starNum then
			local scores = UserManager:getInstance():getScoreRef()
			local counter = 0
			for k, v in pairs(scores) do 
				if LevelType:isMainLevel(v.levelId) and v.star < 3 and v.star > 0 then
					counter = counter + 1
				end
			end
			if counter > 0 then
				self.getBtn:setString(Localization:getInstance():getText('more.star.btn.txt'))
				self.getBtn:setColorMode(kGroupButtonColorMode.blue)
				--self.getBtn.background:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
				--self.getBtn.background:setScaleX(1.3)
				self.moreStarDesc:setString(Localization:getInstance():getText('more.star.star.reward.desc', {num = rewardLevelToPushMeta.starNum - curTotalStar}))
				self.moreStarDesc:setVisible(true)
				self.star:setVisible(true)
				--self.getBtn:setPositionY(self.getBtn:getPositionY() + 25)
			else
				self.getBtn:setEnabled(false)
			end
		end

		self.rewardDesLabel:setString(self:getRewardDesLabelString(rewardLevelToPushMeta))
	else
		self.getBtn:setEnabled(false)
		StarRewardPanel.remove(self)
	end
end

function QQStarRewardPanel:onRewardItemTapped()
	self:showItemTip(self.rewardItem.itemResLayer, {itemId = self.rewardItem.itemId, num = self.rewardItem.itemNumber}, false) 
end


function QQStarRewardPanel:getRewardDesLabelString(rewardLevelToPushMeta)

	local rewardDesLabelKey		= "yingyongbao.tip1"
	local rewardDesLabelValue	= Localization:getInstance():getText(rewardDesLabelKey, {n = rewardLevelToPushMeta.starNum})

	if self.getBtn.colorMode == kGroupButtonColorMode.blue or self.getBtn:getEnabled() == false then
		rewardDesLabelKey = "yingyongbao.tip2"
		rewardDesLabelValue	= Localization:getInstance():getText(rewardDesLabelKey, {n1 = rewardLevelToPushMeta.starNum , n2 = self.curTotalStar})
	end

	return rewardDesLabelValue
end

function QQStarRewardPanel:remove(...)
	if self.isOnCloseBtnTappedCalled then
		StarRewardPanel.remove(self)
	else
		self:reinit()
	end	
end

function QQStarRewardPanel:onSendGetRewardMsgFail(code)
	if tostring(code) == "690" or tostring(code) == "730690" then
		local userExtend = UserManager:getInstance().userExtend
		userExtend:setRewardLevelReceived(self.rewardLevelToPushMeta.id)
	end
	self:reinit()
end