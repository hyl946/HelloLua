-- 成就主面板
local listWidth = 615
local listHeight
local bClickReceive = false 

local AchiPanelRender = class(ItemInClippingNode)
function AchiPanelRender:create(mainPanel)
	local render = AchiPanelRender.new()
	render:loadRequiredResource("ui/achi_panel.json")
    render:init(mainPanel)
    return render
end

function AchiPanelRender:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function AchiPanelRender:init(mainPanel)
	ItemInClippingNode.init(self)
	local ui = self.builder:buildGroup("achievement/achi_panel_render")
	self:setContent(ui)

	self.mainPanel = mainPanel
	self.ui = ui
	self.bg1 = ui:getChildByName('bg1')
	self.bg2 = ui:getChildByName('bg2')
	self.kuang = ui:getChildByName('kuang')
	self.icon = ui:getChildByName('icon')
	self.icon:setTouchEnabled(true, 2, true)
	self.icon:setButtonMode(true)
	self.icon:setAnchorPoint(ccp(0.5, 0.5))
	self.icon:addEventListener(DisplayEvents.kTouchTap, function()
		self:onRenderClick()
    end)

	self.iconBg = self.icon:getChildByName('bg')
	self.title = ui:getChildByName('title')
	self.info = ui:getChildByName('info')
	self.info1 = ui:getChildByName('info1')
	self.num = self.icon:getChildByName('num')
	self.num:setPositionX(self.num:getPositionX() + 2)
	self.num:changeFntFile('fnt/register2.fnt')
	self.num:setScale(0.9)

	self.progressBg = ui:getChildByName('progress_bg')
	self.progressNum = ui:getChildByName('progress_num')
	local progressMask = Sprite:createWithSpriteFrameName('achievement/prog_mask1_mc0000')
	local progressClippingNode = ClippingNode.new(CCClippingNode:create(progressMask.refCocosObj))
	self.progressBg:addChild(progressClippingNode)
	progressMask:dispose()
	
	progressClippingNode:setPosition(ccp(180, 15))
	progressClippingNode:setInverted(false)
	progressClippingNode:setAnchorPoint(ccp(0, 0))
	progressClippingNode:ignoreAnchorPointForPosition(false)
	progressClippingNode:setAlphaThreshold(0.5)

	self.progressSprite = Sprite:createWithSpriteFrameName('achievement/prog_mask1_mc0000')
	progressClippingNode:addChild(self.progressSprite)
end

local hasShowHand = false
local guideHand = nil

function AchiPanelRender:setData(data)
	if self.isDisposed then return end
	self.data = data
	if data.id == AchiId.kTotalEntryWeeklyCount then
		data:cal() 
	end

	self.num:setColor(ccc3(255, 255, 153))
	self.bg1:setVisible(false)
	self.bg2:setVisible(true)
	self.title:changeFntFile('fnt/register2.fnt')
	self.title:setColor(ccc3(137, 56, 19))
	self.title:setScale(0.9)
	self.title:setText(localize('achievement.name.'..data.id))

	if not self.achi_icon then
		self.achi_icon = SpriteColorAdjust:createWithSpriteFrameName('achievement/icon/icon_'..data.id..'0000')
		self.achi_icon:setPosition(ccp(80, -80))
		self.achi_icon:setScale(0.95)
		self.ui:addChild(self.achi_icon)
	end

	if data.id == AchiId.kUnlockNewObstacle then
		local count = tonumber(data:getCurTarCount()) or 0
		if count > 0 then 
			local obstacleConfig = require "zoo.PersonalCenter.ObstacleIconConfig"
			local name = "area_icon_"..obstacleConfig[count].."0000"
			if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) == nil then
				FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")
			end
			if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) ~= nil then
				local obstacle = Sprite:createWithSpriteFrameName(name)
				self.achi_icon:removeChildren(true)
				self.achi_icon:addChild(obstacle)
				obstacle:setScale(0.51)
				local size = self.achi_icon:getContentSize()
				obstacle:setAnchorPoint(ccp(0.5, 0.5))
				obstacle:setPositionXY(72, 82)
			end
		end
	end

	if data.type ~= AchiType.PROGRES then
		self.progressBg:setVisible(false)
		self.progressNum:setVisible(false)
		self.title:setPositionY(-23)
		self.info:setString('')
		self.info1:setString(localize('achievement.desc.'..data.id))
		local score = data:getSingleLevelScore()
		self.num:setText(tostring(score))
		if score > 99 then
			self.num:setScale(0.7)
			self.num:setPositionY(-32)
		else
			self.num:setScale(0.9)
			self.num:setPositionY(-28)
		end 

	else
		self.info1:setString('')
		local function getFromatNum(num)
			if tonumber(num) > 99999999 then
				local num1 = 100000000
				if num % num1 == 0 then 
					num = math.floor(num / num1) .. "亿"
				else
					num = string.format("%.1f", num / num1) .. "亿"
				end
			elseif tonumber(num) > 9999 then
				local num1 = 10000
				if num % num1 == 0 then 
					num = math.floor(num / num1) .. "万"
				else
					num = string.format("%.1f", num / num1) .. "万"
				end
			end
			return num
		end
		local maxLevel = data.maxLevel
		local nextLevel = math.min(data.level + 1, maxLevel)
		local num = data:getNextTarCount()
		local num1 = data:getSingleLevelScore(nextLevel)
		local progress, progressText, info

		local n = nil
		if data.id == AchiId.kTotalEntryWeeklyCount then
			n = data:getNextTarDate()
		end
		if data.level == maxLevel then
			progress = 1
			progressText = localize('achievement.new.panel.content2')
			info = localize('achievement.desc.'..data.id, {num = getFromatNum(num), num1 = num1, name = localize('achievement.blocker.name.'..num), n = n})
		else
			local reachCount =  math.min(data.reachCount, data:getCurTarCount(maxLevel))
			progress = math.min(reachCount / num, 1)
			if data.id == AchiId.kTotalEntryWeeklyCount then 
				progressText = math.min(reachCount, num)..'/'..num
			else
				progressText = reachCount..'/'..num
			end
			
			info = localize('achievement.desc.'..data.id, {num =  getFromatNum(num), num1 = num1, name = localize('achievement.blocker.name.'..num), n = n})
		end

		self.progressSprite:setPositionX((progress - 1) * 345)
		self.progressNum:setString(progressText)
		self.info:setString(info)
		self.num:setText(tostring(num1))

		if num1 > 99 then
			self.num:setScale(0.7)
			self.num:setPositionY(-32)
		else
			self.num:setScale(0.9)
			self.num:setPositionY(-28)
		end 
		
	end

	if data.level > 0 or data:canReceive() then
		local canShowHand = CCUserDefault:sharedUserDefault():getBoolForKey("achi.can.show.hand", false)
		if data:canReceive() and not self.mainPanel.showGuide and not canShowHand and not hasShowHand then
			local pos = self.icon:getPosition()
			self.hand = GameGuideAnims:handclickAnim(0, 0)
		    self.hand:setScale(0.55)
		    self:addChild(self.hand)
		    self.hand:setPosition(ccp(pos.x+30, pos.y-50))
		    hasShowHand = true
		    guideHand = self.hand
		end

		if data.type == AchiType.PROGRES then
			if self.numText then self.numText:removeFromParentAndCleanup(true) end
			self.numText = BitmapText:create(data.level..'级', "fnt/register2.fnt")
			self.numText:setScale(0.7)
			self.numText:setPosition(ccp(70, 30))
   			self.achi_icon:addChild(self.numText)
		end
		if data:canReceive() then 
			self.bg1:setVisible(true)
			self.bg2:setVisible(false)
	    	self:playIconAnimation(true)
	    	self:playFrameAnimation(true)

	    	if not self.star then 
			    FrameLoader:loadArmature('skeleton/achi_star', 'all_star', 'all_star')
			    self.star = ArmatureNode:create("all_star", true)
				if not self.star then return end
		   		self.star:playByIndex(0, 0)
		    	self.star:setPosition(ccp(130, 15))
		    	self:runAction(CCCallFunc:create(function ()
		    		self:addChild(self.star:wrapWithBatchNode())
		    	end))
		    end
		else
			self:playIconAnimation(false)
			self:playFrameAnimation(false)
			self.icon:setTouchEnabled(false)
			if self.star then self.star:removeFromParentAndCleanup(true) self.star = nil end
		end
	else
		self.iconBg:adjustColor(0, -1, 0, 0)
		self.iconBg:applyAdjustColorShader()
		self.achi_icon:adjustColor(0, -1, 0, 0)
		self.achi_icon:applyAdjustColorShader()
		self.num:setColor(ccc3(255, 255, 255))
		self.icon:setTouchEnabled(false)
	end

	if self.achi_icon then
		self.achi_icon:setScale(0.8)
	end
end

function AchiPanelRender:onRenderClick()
	if self.isDisposed then return end 
	if bClickReceive then return end
	bClickReceive = true
	local function onSuccess(evt)
		if self.isDisposed then return end
		bClickReceive = false
		local startPos = self.icon:getPosition()
		startPos = self.ui:convertToWorldSpace(startPos)
		if self.callback then self.callback(evt.addScore, startPos) end
		local achiNode = Achievement:getAchi(evt.id)
		self:setData(achiNode)

		if guideHand and not guideHand.isDisposed then
			guideHand:removeFromParentAndCleanup(true)
			guideHand = nil
		end
		CCUserDefault:sharedUserDefault():setBoolForKey("achi.can.show.hand", true)
	end
	local function onFail(evt)
		bClickReceive = false
		local achiNode = Achievement:getAchi(evt.id)
		self:setData(achiNode)
	end
	Achievement:receive(self.data.id, onSuccess, onFail, onFail) 
end

function AchiPanelRender:playIconAnimation(bPlay)
	if bPlay then
		local animations = CCArray:create()
		animations:addObject(CCScaleTo:create(12/24, 1.1))
		animations:addObject(CCScaleTo:create(12/24, 1))
		local action = CCRepeatForever:create(CCSequence:create(animations))
		self.icon:runAction(action)
	else
		self.icon:stopAllActions()
		self.icon:setScale(1)
	end
end

function AchiPanelRender:playFrameAnimation(bPlay)
	if bPlay then
		local animations = CCArray:create()
		animations:addObject(CCFadeIn:create(12/24))
		animations:addObject(CCFadeOut:create(12/24))
		local action = CCRepeatForever:create(CCSequence:create(animations))
		self.kuang:runAction(action)
	else
		self.kuang:stopAllActions()
		self.kuang:setVisible(false)
	end
end

function AchiPanelRender:setCallback(callback)
	self.callback = callback
end

local AchiPanel = class(LayerGradient)
function AchiPanel:create(tabIndex, showGuide)
	local winSize = CCDirector:sharedDirector():getWinSize()
    local panel = AchiPanel.new()
    panel:loadRequiredResource("ui/achi_panel.json")
    panel:initLayer()
   	panel:changeWidthAndHeight(winSize.width, winSize.height)
    panel:setStartColor(ccc3(255, 216, 119))
    panel:setEndColor(ccc3(247, 187, 129))
    panel:setStartOpacity(255)
    panel:setEndOpacity(255)
    panel:init(tabIndex, showGuide)
    panel:setData()
    return panel
end

function AchiPanel:buildInterfaceGroup(groupName)
    if self.builder then return self.builder:buildGroup(groupName)
    else return nil end
end

function AchiPanel:loadRequiredResource(panelConfigFile)
    self.panelConfigFile = panelConfigFile
    self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function AchiPanel:unloadRequiredResource()
    if self.panelConfigFile then
        InterfaceBuilder:unloadAsset(self.panelConfigFile)
    end
end

function AchiPanel:dispose()
    LayerColor.dispose(self)
    if type(self.unloadRequiredResource) == "function" then self:unloadRequiredResource() end
end

function AchiPanel:init(tabIndex, showGuide)
	self.tabIndex = tabIndex or 1
	self.newAchis = AchiUIManager:getNewAchis()
	self.showGuide = showGuide
	self.pageLights = {0, 0, 0}
	self.pageNums = {0, 0, 0}
	self.pageNews = {false, false, false}

	local winSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()
    local realSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local realOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()
	local topHeight = 120
	local bottomHeight = 40
	self:setPosition(ccp(realOrigin.x, realOrigin.y))

	self.ui = self:buildInterfaceGroup('achievement/achi_panel')
	self:addChild(self.ui)
	-- BasePanel.init(self, ui)

	self.top = self.ui:getChildByName('top')
	self.top:setPositionY(realSize.height)
	self.title = self.top:getChildByName('title')
	self.title:changeFntFile('fnt/caption.fnt')
	self.title:setText(localize('achievement.new.panel.title1'))
	local titleSize = self.title:getContentSize()
    local titleScale = 66 / titleSize.height
    self.title:setScale(titleScale)
    self.title:setPositionX((realSize.width - titleSize.width * titleScale) / 2)
    self.title:setPositionY(self.title:getPositionY() - _G.__EDGE_INSETS.top * 0.4)
	self.rank_btn = self.top:getChildByName('rank_btn')
	self.rank_btn:setPositionY(self.rank_btn:getPositionY() - _G.__EDGE_INSETS.top * 0.6)
	self.rank_btn:setTouchEnabled(true, 0, true)
    self.rank_btn:setButtonMode(true)
	self.rank_btn:addEventListener(DisplayEvents.kTouchTap, function() 
		if self.showGuide then return end
		DcUtil:UserTrack({ category='ui', sub_category='G_achievement_click_button', other='t2'})
		PaymentNetworkCheck.getInstance():check(function ()
			self:setVisible(false)
            local AchiRankPanel = require "zoo.PersonalCenter.achi.panel.AchiRankPanel"
        	local panel = AchiRankPanel:create(self)
        	panel:popout() 
        end, function ()
            CommonTip:showTip(localize('crash.resume.has.no.net'))
        end)
    end)
	self.close_btn = self.top:getChildByName('close_btn')
	self.close_btn:setPositionY(self.close_btn:getPositionY() - _G.__EDGE_INSETS.top * 0.6)
	self.close_btn:setTouchEnabled(true, 0, true)
    self.close_btn:setButtonMode(true)
	self.close_btn:addEventListener(DisplayEvents.kTouchTap, function() 
        self:onCloseBtnTapped() 
    end)

    local bg2 = self.ui:getChildByName("bg2")
    local size = bg2:getPreferredSize()
    bg2:setPreferredSize(CCSizeMake(size.width, winSize.height - bottomHeight - topHeight))
    bg2:setPositionY(bg2:getPositionY() + winSize.height + _G.__EDGE_INSETS.bottom)

    local bg3 = self.ui:getChildByName("bg3")
    local size = bg3:getPreferredSize()
    bg3:setPreferredSize(CCSizeMake(size.width, winSize.height - bottomHeight - topHeight - 310))
    bg3:setPositionY(bg3:getPositionY() + winSize.height + _G.__EDGE_INSETS.bottom)
    listHeight = winSize.height - bottomHeight - topHeight - 405
    local pagedViewY = bg3:getPositionY() - bg3:getGroupBounds().size.height + 10
    -- local pos = bg2:getGroupBounds().size
    -- printx(5, pos.height)

	self.info = self.ui:getChildByName('info')
	self.info:setPositionY(pagedViewY - 35)
	self.info1 = self.ui:getChildByName('info1')
	self.info1:setPositionY(pagedViewY - 35)
	self.info2 = self.ui:getChildByName('info2')
	self.info2:setPositionY(pagedViewY - 35)
	self.user = self.ui:getChildByName('user')
	self.user:getChildByName('user'):setOpacity(0)
	self.user:setPositionY(self.user:getPositionY() + winSize.height + _G.__EDGE_INSETS.bottom)
	self.userInfo = self.user:getChildByName('info')
	self.help_btn = self.user:getChildByName('help2')
	self.userHelp1 = self.user:getChildByName('help1')
	self.userTitle = self.user:getChildByName('title')
	self.userTitle:changeFntFile('fnt/register2.fnt')
	self.userTitle:setColor(ccc3(137, 56, 19))
	--self.userTitle:setScale(0.88)
	self.userGrade1 = self.user:getChildByName('grade1')
	local function showTip(btn, grade)
		local content = self:buildInterfaceGroup('achievement/bagItemTipContent')
		if btn == self.userGrade1 then 
			content:getChildByName('title'):setString(localize('achievement.tip.title1', {medal = localize('achievement.medal.title'..grade)}))
		else
			content:getChildByName('title'):setString(localize('achievement.tip.title2', {medal = localize('achievement.medal.title'..grade)}))
		end
		if grade == 2 then 
            local str = ""
            if UserManager.getInstance().markV2Active then
                str = localize('achievement.right.text1_1')
            else
                str = localize('achievement.right.text1')
            end

			content:getChildByName('desc'):setString(str)
		else
			content:getChildByName('desc'):setString(localize('achievement.right.detail2', {medal = localize('achievement.medal.title'..(grade - 1)), text = localize('achievement.right.text'..(grade - 1))}))
		end
		local tip = BubbleTip:create(content, 105)
		tip:show(btn:getGroupBounds())
	end
	self.userGrade1:setTouchEnabled(true, 0, true)
	self.userGrade1:addEventListener(DisplayEvents.kTouchTap, function() 
		if self.grade == 1 then return end
		showTip(self.userGrade1, self.currentGrade)
	end)
	self.userGrade2 = self.user:getChildByName('grade2')
	self.userGrade2:setTouchEnabled(true, 0, true)
	self.userGrade2:addEventListener(DisplayEvents.kTouchTap, function() 
		if self.currentGrade == self.nextGrade then return end
		showTip(self.userGrade2, self.nextGrade)
	end)
	self.userHelp2 = self.help_btn:getChildByName('info')

	self.help_btn:setTouchEnabled(true, 0, true)
    self.help_btn:setButtonMode(true)
	self.help_btn:addEventListener(DisplayEvents.kTouchTap, function() 
		if self.showGuide then return end
		DcUtil:UserTrack({ category='ui', sub_category='G_achievement_click_button', other='t4'})
		local AchiExplainPanel = require "zoo.PersonalCenter.achi.panel.AchiExplainPanel"
        local panel = AchiExplainPanel:create(self.builder)
        panel:popout() 
    end)

	local colorConfig = {
        normal = ccc3(134, 64, 1),
        focus = ccc3(243, 124, 27)
    }
    local tabTxts = {}
    for i = 1, 3 do
        table.insert(tabTxts, localize('achievement.new.panel.tab'..i))
    end
	local AchiTabBar = require "zoo.PersonalCenter.achi.panel.AchiTabBar"
	local tabbar = self.ui:getChildByName('tabbar')
	tabbar:setPositionY(tabbar:getPositionY() + winSize.height + _G.__EDGE_INSETS.bottom)
	self.tabbar = AchiTabBar:create(tabbar, tabTxts, colorConfig)

	self.pagedView = PagedView:create(listWidth, listHeight, 3, nil, true, false)
    self.pagedView:setIgnoreVerticalMove(false)
    self.tabbar:setView(self.pagedView)
    self.pagedView:setPosition(ccp(52, pagedViewY))
    local function switchCallback() self:switchPage() end
    local function switchFinishCallback() self:switchPageFinish() end
    self.pagedView:setSwitchPageCallback(switchCallback)
    self.pagedView:setSwitchPageFinishCallback(switchFinishCallback)
    self.ui:addChildAt(self.pagedView, self.tabbar.tabbar:getZOrder() - 1)
end

function AchiPanel:setData()
	local achiState = Achievement:getState()
	self.currentGrade = achiState.level
	self.nextGrade = math.min(self.currentGrade + 1, 6)
	self.currentGradeProgress = achiState.score
	self.nextGradeProgress = achiState.nextLevelScore
	self:updateUserIcon()
	self:updateProgress()
	self:updatePagedView()

	for i = 1, 3 do
		if self.pageNews[i] then
			self.tabbar:onTabClicked(i)
			return 
		end
	end
	self.tabbar:onTabClicked(self.tabIndex)

	if self.showGuide then
    	self:runAction(CCCallFunc:create(function ()
    		if self.layout1 and self.layout1.items then
    			if self.layout1.items[1].data:canReceive() then 
    				AchiUIManager:showGuide2(self, function( ... )
		    			self.layout1.items[1]:onRenderClick()
		    		end)
    			else
    				AchiUIManager:showGuide2_2(self, function( ... )
    					self.showGuide = false
		    			AchiUIManager:showGuide3(self)
		    		end)
    			end 
			end
    	end))
    end
end

function AchiPanel:updateUserIcon()
	local profile = UserManager.getInstance().profile
	if profile and profile.headUrl then
		local function onImageLoadFinishCallback(clipping)
			if self.isDisposed then return end
			local clippingSize = clipping:getContentSize()
			local scale = 120 / clippingSize.width
			
			clipping:setScale(scale)
			local pos = self.user:getChildByName('user'):getPosition()
			clipping:setPosition(ccp(pos.x + 68,  pos.y - 68))
			self.user:addChild(clipping)

		end
		local head = HeadImageLoader:createWithFrame(profile.uid, profile.headUrl)
		onImageLoadFinishCallback(head)
	end
end

function AchiPanel:updateProgress()
	local progressBg = self.user:getChildByName('progress')
	local progressMask = Sprite:createWithSpriteFrameName('achievement/prog_mask_mc0000')
	local progressClippingNode = ClippingNode.new(CCClippingNode:create(progressMask.refCocosObj))
	progressBg:addChild(progressClippingNode)
	progressMask:dispose()
	
	progressClippingNode:setPosition(ccp(210, 23))
	progressClippingNode:setInverted(false)
	progressClippingNode:setAnchorPoint(ccp(0, 0))
	progressClippingNode:ignoreAnchorPointForPosition(false)
	progressClippingNode:setAlphaThreshold(0.5)

	local progressSprite = Sprite:createWithSpriteFrameName('achievement/prog_mask_mc0000')
	progressClippingNode:addChild(progressSprite)
	progressSprite:setPositionX((math.min(self.currentGradeProgress / self.nextGradeProgress, 1) - 1) * 420)
	self.progressSprite = progressSprite

	self.userInfo:changeFntFile('fnt/register2.fnt')
	self.userInfo:setColor(ccc3(135, 53, 2))
	self.userInfo:setScale(0.8)
	self.userInfo:setText(self.currentGradeProgress .. '/' .. self.nextGradeProgress)
	self.userHelp2:setString(localize('achievement.new.panel.btn3'))

	if self.nextGrade == self.currentGrade then 
		self.userHelp1:setString(localize('achievement.new.panel.content2'))
	else
		self.userHelp1:setString(localize('achievement.new.panel.content1', {n = self.nextGradeProgress - self.currentGradeProgress}))
	end
	self.userTitle:setText(localize('achievement.medal.title'.. self.currentGrade))
	if self.currentGrade == 1 then 
		self.userTitle:setPositionX(340)
	else 
		self.userTitle:setPositionX(370)
	end

	if self.currentGrade == 1 then 
		self.medal = Sprite:createWithSpriteFrameName('achievement/achi_grade_2_mc0000')
		self.medal:setAnchorPoint(ccp(0.5, 0.5))
		local userY = self.user:getPositionY()
		local userHeight = self.user:getGroupBounds().size.height
		self.medal:setPosition(ccp(635, -255 + userY + userHeight))
		self.ui:addChild(self.medal)
		-- self:createProgress(1, 1)
		-- self:createProgress(1, 70)
		-- self:createProgress(2, 1)
		-- self:createProgress(2, 70)
		-- self:createProgress(3, 1)
		-- self:createProgress(3, 70)
		-- self:createProgress(4, 1)
		-- self:createProgress(4, 70)
		-- self:createProgress(5, 1)
		-- self:createProgress(5, 70)
	else
		self:createProgress(self.currentGrade - 1, true)
	end 
end

function AchiPanel:updatePagedView()
	for i = 1, 3 do 
		local function sort(a, b)
			if a.sortIndex == b.sortIndex then
				return a.priority < b.priority
			else
				return a.sortIndex > b.sortIndex
			end
		end
		local achis = Achievement:getAchisByCategory(i)
		for k, v in pairs(achis) do
			if table.indexOf(self.newAchis, v.id) then
				self.pageNews[i] = true
				v.sortIndex = 3
			elseif v:canReceive() then
				v.sortIndex = 2 
			elseif v.level > 0 then
				v.sortIndex = 1
			else
				v.sortIndex = 0
			end
		end
		table.sort(achis, sort)

    	local page = VerticalScrollable:create(listWidth, listHeight)
	    page.name = "AchiPanelPage"..i
	    page:setIgnoreHorizontalMove(false)
	    local layout = VerticalTileLayout:create(listWidth)
	    layout:setItemVerticalMargin(18)
	    page:setContent(layout)
	    self.pageNums[i] = table.size(achis)
	    local light = 0
	    for k, v in pairs(achis) do
	    	if v.sortIndex > 0 then light = light + 1 end
			local render = AchiPanelRender:create(self)
			render:setData(v)
			render:setCallback(function ( ... )
				self:renderCallback(...)
			end)
			render:setHeight(148)
			layout:addItem(render)
		end
		self['layout'..i] = layout
		self.pageLights[i] = light
		page:updateScrollableHeight()
		self.pagedView:addPageAt(page, i)
	end

	self.tabbar:setNews(self.pageNews)
end

function AchiPanel:playScoreAnimation(score, startPos, grade)
	local userY = self.user:getPositionY()
	local userHeight = self.user:getGroupBounds().size.height
	if score > 0 then
		local icon = Sprite:createWithSpriteFrameName('achievement/jifen10000')
		icon:setPosition(ccp(startPos.x, startPos.y))
		icon:setAnchorPoint(ccp(0, 1))
		self.ui:addChild(icon)
		local arr = CCArray:create()
		arr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(5/24, ccp(500, -300 + userY + userHeight)), CCScaleTo:create(5/24, 1.5)))
		arr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(5/24, ccp(490, -200 + userY + userHeight)), CCScaleTo:create(5/24, 0.6)))
		arr:addObject(CCCallFunc:create(function() 
			icon:removeFromParentAndCleanup(true) 
			self.userInfo:setText(self.currentGradeProgress .. '/' .. self.nextGradeProgress)
			if self.nextGrade == self.currentGrade then 
				self.userHelp1:setString(localize('achievement.new.panel.content2'))
			else
				self.userHelp1:setString(localize('achievement.new.panel.content1', {n = self.nextGradeProgress - self.currentGradeProgress}))
			end
			self.progressSprite:setPositionX((math.min(self.currentGradeProgress / self.nextGradeProgress, 1) - 1) * 420)

			local score = BitmapText:create('+'..score, 'fnt/register2.fnt', -1, kCCTextAlignmentCenter)
			score:setColor(ccc3(252, 166, 0))
			score:setScale(1.1)
			score:setPosition(ccp(510, -200 + userY + userHeight)) 
			self.ui:addChild(score)

			local arr = CCArray:create()
			arr:addObject(CCMoveTo:create(8/24, ccp(510, -140 + userY + userHeight)))
			arr:addObject(CCFadeOut:create(4/24))
			arr:addObject(CCCallFunc:create(function() 
				score:removeFromParentAndCleanup(true) 

			end))
			score:runAction(CCSequence:create(arr))
		end))
		icon:runAction(CCSequence:create(arr))
	end

	if grade then
		local endPos = ccp(0, self.progressSprite:getPositionY())
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(10/24))
	    arr:addObject(CCMoveTo:create(1/24, endPos))
	    arr:addObject(CCFadeOut:create(10/24))
	    arr:addObject(CCFadeIn:create(10/24))
	    arr:addObject(CCFadeOut:create(10/24))
	    arr:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(10/24), CCCallFunc:create(function()
	    	self:createProgress(grade)
	    	self.progressSprite:setPositionX((math.min(self.currentGradeProgress / self.nextGradeProgress, 1) - 1) * 420)
	    end)))
	    self.progressSprite:runAction(CCSequence:create(arr))
	end
end

function AchiPanel:createProgress(grade, bStop)
	-- printx(5, 'createProgress', grade, bStop)
	local userY = self.user:getPositionY()
	local userHeight = self.user:getGroupBounds().size.height
	local positions = {ccp(156, -67), ccp(150, -69), ccp(150, -69), ccp(148, -70), ccp(145, -43)}
	if self.medal then self.medal:removeFromParentAndCleanup(true) end
	self.medal = gAnimatedObject:createWithFilename('gaf/achi_upgrade/0'..grade..'.gaf')
	self.ui:addChild(self.medal)
	self.medal:setPosition(ccp(positions[grade].x, positions[grade].y + userY + userHeight))
	self.medal:playSequence("begin", false, true, ASSH_RESTART)
	if bStop then 
		self.medal:gotoAndStop('end')
	else
		self.medal:setSequenceDelegate('begin', function( ... )
			if self.showGuide then self.showShare = true return end
			local AchiSharePanel = require "zoo.PersonalCenter.achi.panel.AchiSharePanel"
		    local panel = AchiSharePanel:create(grade + 1, self.builder)
		    panel:popout()
		end)
		self.medal:start()
	end 
end

function AchiPanel:setLightInfo()
	self.info:setString('已点亮成就：')
	self.info1:setString(self.pageLights[self.tabIndex]..'')
	self.info2:setString('/'..self.pageNums[self.tabIndex])
end

function AchiPanel:shareCallback()
	self.showGuide = false
	if self.showShare then 
		local AchiSharePanel = require "zoo.PersonalCenter.achi.panel.AchiSharePanel"
	    local panel = AchiSharePanel:create(Achievement:getState().level, self.builder)
	    panel:popout()
	end
end

function AchiPanel:renderCallback(addScore, startPos)
	-- printx(5, 'renderCallback', table.tostring(Achievement:getState()))
	local achiState = Achievement:getState()
	local upgrade
	if achiState.level > self.currentGrade then
		upgrade = achiState.level - 1
	end
	self.currentGrade = achiState.level
	self.nextGrade = math.min(self.currentGrade + 1, 6)
	self.currentGradeProgress = achiState.score
	self.nextGradeProgress = achiState.nextLevelScore
	self.userTitle:setText(localize('achievement.medal.title'.. self.currentGrade))
	if self.currentGrade == 1 then 
		self.userTitle:setPositionX(340)
	else 
		self.userTitle:setPositionX(380)
	end

	startPos = self:convertToNodeSpace(startPos)
	self:playScoreAnimation(addScore, startPos, upgrade)
	if self.showGuide then 
		AchiUIManager:showGuide3(self, function( ... )
			self:shareCallback()
		end)
	end
end

function AchiPanel:switchPage()
	
end

function AchiPanel:switchPageFinish( ... )
	if self.isDisposed then return end
	self.tabIndex = self.pagedView:getPageIndex()
	self.tabbar:onTabClicked(self.pagedView:getPageIndex())
	self:setLightInfo()
end

function AchiPanel:popout()
	--PopoutManager:sharedInstance():add(self, true)
	local curScene = Director:sharedDirector():getRunningSceneLua()
	curScene:addChild(self)
end

function AchiPanel:onCloseBtnTapped()
    if self.isDisposed then return end
    --AchiUIManager:clearNewAchis()

    
	Director:sharedDirector():popScene()
	-- PopoutQueue:sharedInstance():popAgain( true , PopoutLayerPriority.Guide_Achieve )
end

function AchiPanel:onKeyBackClicked()
	self:onCloseBtnTapped()
end

return AchiPanel