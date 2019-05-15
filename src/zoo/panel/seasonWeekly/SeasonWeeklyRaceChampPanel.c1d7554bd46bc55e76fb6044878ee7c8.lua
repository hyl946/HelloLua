require "zoo.panel.basePanel.BasePanel"
require "zoo.panel.seasonWeekly.WeeklyShareUtil"

SeasonWeeklyRaceChampPanel = class(BasePanel)

function SeasonWeeklyRaceChampPanel:create()
	local panel = SeasonWeeklyRaceChampPanel.new()
	panel:init()
	return panel
end

local assumeShareReward = {itemId = 2, num = 100}

function SeasonWeeklyRaceChampPanel:init()
	self:loadRequiredResource("ui/panel_summer_weekly_share.json")
	local ui = self:buildInterfaceGroup('SummerWeeklyRacePanel/ChampPanel')
	BasePanel.init(self, ui)

	self:buildUI(ui)

	local realPlistPath, realPngPath = SpriteUtil:addSpriteFramesWithFile("ui/NewSharePanel.plist", "ui/NewSharePanel.png")
	if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ShareHiddenLevel/cell/npc0000") then
		local npc = Sprite:createWithSpriteFrameName("ShareHiddenLevel/cell/npc0000")
		npc:setAnchorPoint(ccp(0, 1))
		npc.name = "trophy"
		local trophy = ui:getChildByName("trophy")
		npc:setPositionXY(trophy:getPositionX(), trophy:getPositionY())
		npc:setPositionX(npc:getPositionX())
		npc:setPositionY(npc:getPositionY())
		ui:addChildAt(npc, ui:getChildIndex(trophy))
		trophy:removeFromParentAndCleanup(true)
	end
	SpriteUtil:removeLoadedPlist("ui/NewSharePanel.plist")
	if not __WP8 then
		CCTextureCache:sharedTextureCache():removeTextureForKey(realPngPath)
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(realPlistPath)
	else
		CCTextureCache:sharedTextureCache():removeUnusedTextures()
	end

	local button = GroupButtonBase:create(ui:getChildByName("shareBtn"))
	button:setString(Localization:getInstance():getText("share.feed.button.achive"))
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
	shareTip:setVisible(firstShare)

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	local vOrigin = Director:sharedDirector():ori_getVisibleOrigin()
	local vSize = Director:sharedDirector():ori_getVisibleSize()
	local layer = LayerColor:create()
	layer:setAnchorPoint(ccp(0, 1))
	layer:ignoreAnchorPointForPosition(false)
	layer:changeWidthAndHeight(vSize.width / self:getScale(), vSize.height / self:getScale())
	layer:setColor(ccc3(0, 0, 0))
	layer:setOpacity(176)
	layer:setPositionXY(-self:getPositionX() / self:getScale(), (-self:getPositionY() + _G.__EDGE_INSETS.top) / self:getScale())
	self:addChildAt(layer, 0)

	local close = ui:getChildByName("closeBtn")
	close:setPositionX((vSize.width - self:getPositionX()) / self:getScale() - 40)
	close:setPositionY(-self:getPositionY() / self:getScale() - 40)
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
	self.close = close

	self:setAnimation(ui)
end

function SeasonWeeklyRaceChampPanel:buildUI(ui)
	local shareTitle = ui:getChildByName("shareTitle")
	if shareTitle then
		local title = shareTitle:getChildByName("shareTitle")
		title:setText(Localization:getInstance():getText("show_off_desc_100"))
		local size = title:getContentSize()
		title:setPositionX(-size.width / 2)
	end
end

function SeasonWeeklyRaceChampPanel:onBtnTapped()
	local function onSuccess(isAddCount)
		if self.isDisposed then return end
		if isAddCount then
			CommonTip:showTip(Localization:getInstance():getText("weeklyrace.winter.panel.tip4"), "positive")
		else
			if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
				CommonTip:showTip(Localization:getInstance():getText("share.feed.success.tips.mitalk"), "positive")
			else
				CommonTip:showTip(Localization:getInstance():getText("share.feed.success.tips"), "positive")
			end
		end
		self:onCloseBtnTapped()
	end
	local function onFail(evt)
		if self.isDisposed then return end
		if evt and evt.data then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
		else
			if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
				CommonTip:showTip(Localization:getInstance():getText("share.feed.faild.tips.mitalk"), "negative")
			else
				CommonTip:showTip(Localization:getInstance():getText("share.feed.faild.tips"), "negative")
			end
		end
		self.button:setEnabled(true)
	end
	local function onCancel()
		if self.isDisposed then return end
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
			CommonTip:showTip(Localization:getInstance():getText("share.feed.cancel.tips.mitalk"), "negative")
		else
			CommonTip:showTip(Localization:getInstance():getText("share.feed.cancel.tips"), "negative")
		end
		self.button:setEnabled(true)
	end

	self.button:setEnabled(false)
	setTimeOut(function()
		if self.isDisposed then return end
		self.button:setEnabled(true)
	end, 2)
	self:shareMessage(onSuccess, onFail, onCancel)
end

function SeasonWeeklyRaceChampPanel:setAnimation(ui)
	local shareTitle = ui:getChildByName("shareTitle")
	shareTitle:setScale(0)
	shareTitle:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1),
		CCEaseBackOut:create(CCScaleTo:create(0.25, 1))))
	local childList = {}
	shareTitle:getVisibleChildrenList(childList)
	for i, v in ipairs(shareTitle) do
		v:setOpacity(0)
		v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1),
			CCEaseIn:create(CCFadeIn:create(0.25))))
	end

	local trophy = ui:getChildByName("trophy")
	trophy:setPositionY(trophy:getPositionY() - 200)
	trophy:setOpacity(0)
	local array = CCArray:create()
	array:addObject(CCEaseBackOut:create(CCMoveBy:create(0.2, ccp(0, 200))))
	array:addObject(CCFadeIn:create(0.2))
	trophy:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCSpawn:create(array)))

	local cup = ui:getChildByName("cup")
	cup:setPositionY(cup:getPositionY() + 100)
	cup:setOpacity(0)
	array = CCArray:create()
	array:addObject(CCEaseIn:create(CCFadeIn:create(0.2)))
	array:addObject(CCEaseBackOut:create(CCMoveBy:create(0.2, ccp(0, -100))))
	cup:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCSpawn:create(array)))

	local circleLightBg = ui:getChildByName("circleLightBg")
	local bg = circleLightBg:getChildByName("bg")
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPositionXY(0, 0)
	bg:setScale(0)
	bg:runAction(CCRepeatForever:create(CCRotateBy:create(1, 100)))
	bg:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.35), CCScaleTo:create(0.15, 2)))
	local bg1 = circleLightBg:getChildByName("bg1")
	bg1:setAnchorPoint(ccp(0.5, 0.5))
	bg1:setPositionXY(0, 0)
	bg1:setScale(0)
	array = CCArray:create()
	array:addObject(CCScaleTo:create(0.15, 2.2))
	array:addObject(CCEaseOut:create(CCFadeOut:create(0.15)))
	bg1:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.35), CCSpawn:create(array)))
	local bg2 = circleLightBg:getChildByName("bg2")
	bg2:setAnchorPoint(ccp(0.5, 0.5))
	bg2:setPositionXY(0, 0)
	bg2:setScale(0)
	array = CCArray:create()
	array:addObject(CCScaleTo:create(0.15, 2.2))
	array:addObject(CCEaseOut:create(CCFadeOut:create(0.15)))
	bg2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.35), CCSpawn:create(array)))

	self:runPaperGroupAction(ui:getChildByName("paper1"))
	self:runPaperGroupAction(ui:getChildByName("paper2"))

	local starGroup3 = ui:getChildByName("starGroup3")
	local starList = {}
	starGroup3:getVisibleChildrenList(starList)
	for i, v in ipairs(starList) do
		local size = v:getGroupBounds().size
		v:setAnchorPoint(ccp(0.5, 0.5))
		v:setPositionXY(v:getPositionX() + size.width / 2, v:getPositionY() - size.height / 2)
		v:setOpacity(0)
		local function onDelayOver()
			array = CCArray:create()
			array:addObject(CCDelayTime:create(math.random() * 0.5))
			local rotateTime = math.random() * 1 + 1
			local array2 = CCArray:create()
			array2:addObject(CCFadeIn:create(rotateTime / 2))
			array2:addObject(CCFadeOut:create(rotateTime / 2))
			array:addObject(CCSpawn:createWithTwoActions(CCRotateBy:create(rotateTime, 180), CCSequence:create(array2)))
			array:addObject(CCDelayTime:create(math.random() * 1 + 0.5))
			v:runAction(CCRepeatForever:create(CCSequence:create(array)))
		end
		v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.6), CCCallFunc:create(onDelayOver)))
	end
end

function SeasonWeeklyRaceChampPanel:runPaperGroupAction(paperGroupUi)
	if paperGroupUi then 
		local paperGroup = {}
		for i=1,5 do
			local paper = {}
			paper.ui = paperGroupUi:getChildByName("paper"..i)
			paper.ui:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
			if i==1 then 
				paper.xDelta = 200
			elseif i==2 then 
				paper.xDelta = 100
			elseif i==3 then 
				paper.xDelta = 50
			elseif i==4 then 
				paper.xDelta = -100
			elseif i==5 then 
				paper.xDelta = -200
			end
			paper.yDelta = math.random(-220,-300)
			paper.height = math.random(30,50)
			paper.time = math.random(14,18)/10
			paper.ui:setOpacity(0)
			table.insert(paperGroup, paper)
		end

		for i,v in ipairs(paperGroup) do
			local sequenceArr = CCArray:create()
			local delayTime = CCDelayTime:create(v.delayTime)
			local spwanArr = CCArray:create()
			local tempTime = 0.4
			local fromPostion = v.ui:getPosition()
			--spwanArr:addObject(CCFadeTo:create(1.5, 0))
			local bezierConfig = ccBezierConfig:new()
			bezierConfig.controlPoint_1 = ccp(fromPostion.x +  v.xDelta/4, fromPostion.y +  v.height*8)
			bezierConfig.controlPoint_2 = ccp(fromPostion.x +  v.xDelta/2, fromPostion.y +  v.height*5)
			bezierConfig.endPosition = ccp(v.xDelta, v.yDelta)
			local bezierAction_1 = CCBezierTo:create(v.time, bezierConfig)

			spwanArr:addObject(bezierAction_1)
			sequenceArr:addObject(CCDelayTime:create(0.3))
			sequenceArr:addObject(delayTime)
			sequenceArr:addObject(CCFadeTo:create(0, 255))
			sequenceArr:addObject(CCSpawn:create(spwanArr))
			local function hidePaper()
				v.ui:setVisible(false)
			end
			sequenceArr:addObject(CCCallFunc:create(hidePaper))
			
			v.ui:stopAllActions();
			v.ui:runAction(CCSequence:create(sequenceArr));
			v.ui:runAction(CCRepeatForever:create(CCRotateBy:create(0.1, 30)))
		end
	end
end

function SeasonWeeklyRaceChampPanel:popout(onCloseCallback)
	PopoutManager:sharedInstance():add(self)
	self.allowBackKeyTap = true
	self.onCloseCallback = onCloseCallback
end

function SeasonWeeklyRaceChampPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	if type(self.onCloseCallback) == "function" then self.onCloseCallback() end
end

function SeasonWeeklyRaceChampPanel:playAnim()
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

function SeasonWeeklyRaceChampPanel:shareMessage(successCallback, failCallback, cancelCallback)
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
	local group = self:buildInterfaceGroup("SummerWeeklyRacePanel/ChampPanelFeed")
	self:buildUI(group)

	local filePath = WeeklyShareUtil.buildShareImage(group)

	local title = ""
	local text = ""
	if filePath then
		SeasonWeeklyRaceManager:getInstance():snsShare(filePath, title, text, onSuccess, onFail, onCancel)
	else
		if failCallback then failCallback() end
	end
end