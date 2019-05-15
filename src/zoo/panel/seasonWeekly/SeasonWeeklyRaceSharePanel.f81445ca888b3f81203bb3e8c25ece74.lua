require "zoo.panel.basePanel.BasePanel"
require "zoo.panel.seasonWeekly.SeasonWeeklyRaceManager"

SeasonWeeklyRaceSharePanel = class(BasePanel)
function SeasonWeeklyRaceSharePanel:create(rewards, levelId, rank, surpass)
	local panel = SeasonWeeklyRaceSharePanel.new()
	panel:init(rewards, levelId, rank, surpass)
	return panel
end

local assumeShareReward = {itemId = 2, num = 100}

function SeasonWeeklyRaceSharePanel:init(rewards, levelId, rank, surpass)
	self:loadRequiredResource("ui/panel_summer_weekly_share.json")
	local ui = self:buildInterfaceGroup('SummerWeeklyRacePanel/SharePanel')
	BasePanel.init(self, ui)

	self.levelId = levelId
	self.place = rank
	self.rewards = self:mergeRewards(rewards or {})
	self.surpass = surpass or 0

	local titleStr = Localization:getInstance():getText("weeklyrace.winter.panel.achievement4", {num = self.surpass})

	self.items = {}
	for i, v in ipairs(rewards) do
		if v.itemId == ItemType.COIN then
			local item = {}
			function item:getPosition()
				return ccp(70, 1050)
			end

			item.itemId = ItemType.COIN
			item.num = v.num
			table.insert(self.items, item)

			self.coinNum = v.num
		end
	end

	local button = GroupButtonBase:create(ui:getChildByName("shareBtn"))
	button:setColorMode(kGroupButtonColorMode.green)
	button:setString(Localization:getInstance():getText("weeklyrace.winter.panel.button1"))
	button:addEventListener(DisplayEvents.kTouchTap, function() self:onBtnTapped() end)
	self.button = button

	local btnTag = ui:getChildByName("btnTag")
	local shareReward = assumeShareReward
	local icon = btnTag:getChildByName("icon")
	icon:setVisible(false)
	local sprite
	if shareReward.itemId == 2 then
		sprite = ResourceManager:sharedInstance():buildGroup("itemIcon2")
	elseif shareReward.itemId == 14 then
		sprite = Sprite:createWithSpriteFrameName("wheel0000")
		sprite:setAnchorPoint(ccp(0, 1))
	else
		if ItemType:isTimeProp(shareReward.itemId) then
			ItemType:getRealIdByTimePropId(shareReward.itemId)
		end
		sprite = ResourceManager:sharedInstance():buildItemGroup(shareReward.itemId)
	end
	local size = sprite:getGroupBounds().size
	size = {width = size.width, height = size.height}
	local iSize = icon:getGroupBounds().size
	sprite:setScale(iSize.width / size.width)
	if sprite:getScale() > iSize.height / size.height then
		sprite:setScale(iSize.height / size.height)
	end
	sprite:setPositionX(icon:getPositionX() + (iSize.width - size.width * sprite:getScale()) / 2)
	sprite:setPositionY(icon:getPositionY() - (iSize.height - size.height * sprite:getScale()) / 2)
	btnTag:addChildAt(sprite, btnTag:getChildIndex(icon))

	local number = btnTag:getChildByName("number")
	number:setText('+'..tostring(shareReward.num))
	local nSize = number:getContentSize()
	number:setPositionX(icon:getPositionX() + (iSize.width - nSize.width) / 2)
	btnTag:setVisible(false)

	local shareTip = ui:getChildByName("shareTip")
	local firstShare = SeasonWeeklyRaceManager:getInstance():isDailyFirstShare()
	shareTip:setVisible(firstShare and false)


	local bgSp = Sprite:create('ui/weeklyMatch/shareBg.jpg')
	bgSp:setAnchorPoint(ccp(0.5, 0.5))
	self.ui:addChildAt(bgSp, 0)
	bgSp:setPosition(ccp(596.6/2, -1060.9/2 + _G.__EDGE_INSETS.top))


	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
	self:setPositionY(self:getPositionY() - 20)

	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local vSize = Director:sharedDirector():getVisibleSize()

	local close = ui:getChildByName("closeBtn")
	close:setPositionX((vSize.width - self:getPositionX()) / self:getScale() - 40)
	close:setPositionY(-self:getPositionY() / self:getScale() - 40)
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
	self.close = close

	local title = ui:getChildByName("title")
	title:setScale(1.3)
	title:setPositionY(-self:getPositionY() / self:getScale() - 100)
	local mid = title:getChildByName("mid")
	mid:setText(tostring(self.place))
	local size = mid:getContentSize()
	mid:setPositionX(-size.width / 2)
	mid:setPositionY(mid:getPositionY() + 25)
	local left = title:getChildByName("left")
	left:setDimensions(CCSizeMake(0, 0))
	left:setString(Localization:getInstance():getText("weeklyrace.winter.panel.desc13"))
	size = left:getContentSize()
	left:setPositionX(mid:getPositionX() - size.width - 20)
	local right = title:getChildByName("right")
	right:setDimensions(CCSizeMake(0, 0))
	right:setString(Localization:getInstance():getText("weeklyrace.winter.panel.desc14"))
	size = right:getContentSize()
	right:setPositionX(-mid:getPositionX() + 20)

	local offset = ccp(-20, -40)

	local rewards = {}
	for k, v in pairs(self.rewards) do
		if v.itemId == SeasonWeeklyRaceConfig:getInstance():getSurpassRewardItemId() then
			rewards.rankRewardNum = 1
		elseif v.itemId == SeasonWeeklyRaceConfig:getInstance():getTotalSurpassRewardItemId() then
			rewards.totalRankRewardNum = 1
		end
	end

	local upAnim, bottomAnim = SeasonWeeklyRaceResultPanel:showShareRewardBubbleAnimation(self.ui, "Parrot", rewards , titleStr, offset, nil, ccp(300, -720))
	upAnim:setPositionY(upAnim:getPositionY() + 40)

	self.ui:runAction(CCCallFunc:create(function()
		local vSize = Director:sharedDirector():getVisibleSize()
		local bgPos = self.ui:convertToNodeSpace(ccp(0, vSize.height))

		local bg = LayerColor:create()
		bg:ignoreAnchorPointForPosition(false)
		bg:setOpacity(150)
		bg:setColor(ccc3(0, 0, 0))
		bg:setContentSize(CCSizeMake(960, 1480))

		bg:setAnchorPoint(ccp(0, 1))
		bg:setPosition(ccp(bgPos.x, bgPos.y))
		self.ui:addChildAt(bg, 0)
	end))
end

-- used by main panel and feed, so common parts only
function SeasonWeeklyRaceSharePanel:buildUI(ui, hiddenRewards)
	local rewardsData = self.rewards
	local friends = self.surpass

	local shareTitle = ui:getChildByName("shareTitle")
	local title = shareTitle:getChildByName("shareTitle")
	title:setText(Localization:getInstance():getText("weeklyrace.winter.panel.achievement4", {num = friends}))
	local size = title:getContentSize()
	title:setPositionX(-size.width / 2)

	local skipSavingItem = false
	if not self.items then self.items = {}
	else skipSavingItem = true end
	for i = 1, 1 do
		local bubble = ui:getChildByName("bubble"..tostring(i))
		local icon = bubble:getChildByName("icon")
		icon:setVisible(false)
		local reward = rewardsData[i]
		if reward and not hiddenRewards then
			local itemId = reward.itemId
			local sprite
			if itemId == 2 then
				sprite = ResourceManager:sharedInstance():buildGroup("stackIcon")
			elseif itemId == 14 then
				sprite = Sprite:createWithSpriteFrameName("wheel0000")
				sprite:setAnchorPoint(ccp(0, 1))
			else
				if ItemType:isTimeProp(itemId) then
					ItemType:getRealIdByTimePropId(itemId)
				end
				sprite = ResourceManager:sharedInstance():buildItemGroup(itemId)
			end
			local size = sprite:getGroupBounds().size
			size = {width = size.width, height = size.height}
			local iSize = icon:getGroupBounds().size
			sprite:setScale(iSize.width / size.width)
			if sprite:getScale() > iSize.height / size.height then
				sprite:setScale(iSize.height / size.height)
			end
			sprite:setPositionX(icon:getPositionX() + (iSize.width - size.width * sprite:getScale()) / 2)
			sprite:setPositionY(icon:getPositionY() - (iSize.height - size.height * sprite:getScale()) / 2)
			bubble:addChildAt(sprite, bubble:getChildIndex(icon))

			local num = bubble:getChildByName("num")
			num:setText('x'..tostring(rewardsData[i].num))
			size = num:getContentSize()
			num:setPositionX(icon:getPositionX() - (size.width - iSize.width)/2)
			if not skipSavingItem then
				table.insert(self.items, {item = sprite, itemId = rewardsData[i].itemId, num = rewardsData[i].num})
			end
		else
			bubble:setVisible(false)
		end
	end
end

function SeasonWeeklyRaceSharePanel:onBtnTapped()
	local function onSuccess()
		if self.isDisposed then return end
		self:playAnim()
		local function showTip(tip, tipType)

			local tType = {
				["negative"] = 1,
				["positive"] = 2,
			}

			local scene = Director:sharedDirector():getRunningScene()
			if scene then
				local panel = CommonTip:create(tip, tType[tipType], nil, 4)
				if not panel then
					return
				end
				function panel:removeSelf()
					if not scene.isDisposed then
						scene:superRemoveChild(self,true)
					end
				end
				local winSize = Director:sharedDirector():getVisibleSize()
				while panel:getPositionY() < 0 or panel:getPositionY() > winSize.height do
					if panel:getPositionY() < 0 then
						panel:setPositionY(panel:getPositionY() + winSize.height)
					end
					if panel:getPositionY() > winSize.height then
						panel:setPositionY(panel:getPositionY() - winSize.height)
					end
				end
				scene:superAddChild(panel)
			end
		end
		local function onTimeOut()
			if self.isDisposed then return end
			local function onSuccess(isAddCount)
				if self.isDisposed then return end
				if isAddCount then
					showTip(Localization:getInstance():getText("weeklyrace.winter.panel.tip4"), "positive")
				else
					if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
						showTip(Localization:getInstance():getText("share.feed.success.tips.mitalk"), "positive")
					else
						showTip(Localization:getInstance():getText("share.feed.success.tips"), "positive")
					end
				end
				DcUtil:doShareWeeklyRankSuccess()
				self:onCloseBtnTapped()
			end
			local function onFail(evt)
				if self.isDisposed then return end
				if evt and evt.data then
					showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
				else
					if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
						showTip(Localization:getInstance():getText("share.feed.faild.tips.mitalk"), "negative")
					else
						showTip(Localization:getInstance():getText("share.feed.faild.tips"), "negative")
					end
				end
			end
			local function onCancel()
				if self.isDisposed then return end
				if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
					showTip(Localization:getInstance():getText("share.feed.cancel.tips.mitalk"), "negative")
				else
					showTip(Localization:getInstance():getText("share.feed.cancel.tips"), "negative")
				end
				--self:onCloseBtnTapped()
			end
			self:shareMessage(onSuccess, onFail, onCancel)
		end
		setTimeOut(onTimeOut, 2)
	end
	local function onFail(event)
		if self.isDisposed then return end

		if event and event.data then
			if tostring(event.data) == '731080' or tostring(event.data) == '731079' then
				self:onCloseBtnTapped()
				return
			end
		end

		-- CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
		self.button:setEnabled(true)

		

	end
	local function onCancel()
		if self.isDisposed then return end
		self.button:setEnabled(true)
	end
	DcUtil:clickWeeklyRankShareBtn()
	self.button:setEnabled(false)
	setTimeOut(function()
		if self.isDisposed then return end
		self.button:setEnabled(true)
	end, 2)
	self:getReward(onSuccess, onFail, onCancel)

	if __WIN32 then
		self:shareMessage(function ( ... )
			-- body
		end, function ( ... )
			-- body
		end, function ( ... )
			-- body
		end)
	end
end

function SeasonWeeklyRaceSharePanel:runFireworkAction()
	local fireworkTable = {}
	local timerId = nil 
	for i=1,5 do
		local firework = SpriteColorAdjust:createWithSpriteFrameName("yanhua_0000.png")
		firework:setAnchorPoint(ccp(0.5, 0.5))
		if i==1 then 
			firework:setPosition(ccp(-70,-150))
			firework:setScale(1.5)
		elseif i==2 then 
			firework:setPosition(ccp(-10,-20))
			firework:setScale(1.5)
		elseif i==3 then 
			firework:setPosition(ccp(120,20))
			firework:setScale(1.5)
		elseif i==4 then 
			firework:setPosition(ccp(280,-30))
			firework:setScale(1.3)
		elseif i==5 then 
			firework:setPosition(ccp(210,-110))
			firework:setScale(2.5)
		end
		table.insert(fireworkTable, firework)
	end
	local fireworkIndex = 1
	local function playFireWork()
		if fireworkIndex>5 or self.isDisposed then 
			if timerId then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(timerId)
			end
			timerId = nil
			return
		end
		local firework = fireworkTable[fireworkIndex]
		self.ui:addChild(firework)
		firework:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("yanhua_%04d.png", 0, 41), 1/20), 0, 1, nil, true)
		fireworkIndex = fireworkIndex + 1
	end
	timerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(playFireWork,0.1,false);
end

function SeasonWeeklyRaceSharePanel:popout(onClosed)
	self.allowBackKeyTap = true
	self.onClosedCallback = onClosed
	PopoutManager:sharedInstance():add(self, true)
end

function SeasonWeeklyRaceSharePanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	SeasonWeeklyRaceManager:getInstance():setLastWeekRankRewardsCancelFlag()
	if self.onClosedCallback then self.onClosedCallback() end
end

function SeasonWeeklyRaceSharePanel:dispose()
	BasePanel.dispose(self)
	if _G.__use_small_res then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("share/yanhua@2x.plist")
	else
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("share/yanhua.plist")
	end

	-- local textureTable = {
	-- 	"ui/weeklyMatch/weeklyPanelBg.jpg",
	-- }
	-- for i,v in ipairs(textureTable) do
	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey(
	-- 		CCFileUtils:sharedFileUtils():fullPathForFilename(
	-- 			SpriteUtil:getRealResourceName(v)
	-- 		)
	-- 	)
	-- end

	CCTextureCache:sharedTextureCache():removeTextureForKey('ui/weeklyMatch/shareBg.jpg')
end

function SeasonWeeklyRaceSharePanel:playAnim()
	local scene = HomeScene:sharedInstance()
	if not scene then return end
	scene:checkDataChange()
	for i, v in ipairs(self.items) do
		local anim = FlyItemsAnimation:create({v})
        local bounds = v.item:getGroupBounds()
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:play()
	end
end

function SeasonWeeklyRaceSharePanel:mergeRewards(rewardTable)
	local rewards = {}
	for i, v in ipairs(rewardTable) do
		local found = false
		for i2, v2 in ipairs(rewards) do
			if v2.itemId == v.itemId then
				found = true
				v2.num = v2.num + v.num
				break
			end
		end
		if not found then
			table.insert(rewards, {itemId = v.itemId, num = v.num})
		end
	end
	return rewards
end

function SeasonWeeklyRaceSharePanel:getReward(successCallback, failCallback, cancelCallback)
	local function onSuccess()
		if successCallback then successCallback() end
	end
	local function onFail(event)
		if failCallback then failCallback(event) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end
	SeasonWeeklyRaceManager:getInstance():receiveLastWeekRankRewards(self.levelId, onSuccess, onFail, onCancel)
end

function SeasonWeeklyRaceSharePanel:shareMessage(successCallback, failCallback, cancelCallback)
	local function onSuccess(isAddCount)
		if successCallback then successCallback(isAddCount) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	self:loadRequiredResource("ui/panel_summer_weekly_share.json")
	local group = self:buildInterfaceGroup("SummerWeeklyRacePanel/SharePanelFeedWinter")
	local numLabel = group:getChildByName("num")
	numLabel:setText(tostring(0))
	numLabel:setAnchorPointCenterWhileStayOrigianlPosition()
	numLabel:setText(tostring(self.surpass))
	if self.surpass < 10 then 
		local pos = numLabel:getPosition()
		numLabel:setPosition(ccp(pos.x + 50, pos.y + 4))
	elseif self.surpass < 100 then 
		local pos = numLabel:getPosition()
		numLabel:setPosition(ccp(pos.x + 25, pos.y + 4))
	end

	local filePath = WeeklyShareUtil.buildShareImageWinter(group)

	local title = ""
	local text = ""
	if filePath then
		SeasonWeeklyRaceManager:getInstance():snsShare(filePath, title, text, onSuccess, onFail, onCancel)
	else
		if failCallback then failCallback() end
	end
end