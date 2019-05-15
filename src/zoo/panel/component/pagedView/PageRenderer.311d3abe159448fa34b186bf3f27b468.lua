require 'zoo.panel.component.bubbleTip.BubbleTip'
require 'zoo.panelBusLogic.UsePropsLogic'
require 'zoo.panelBusLogic.SellLogic'
require 'zoo.panel.CommonTip'
require 'zoo.panel.UpdateNewVersionPanel'
require 'zoo.panel.PrePackageUpdatePanel'
require 'zoo.panel.jumpLevel.MoreIngredientPanel'


-------------------- LOCAL FUNCTIONS --------------------
local function buildBtnLabel(ui, labelName, fontSizeName, labelString)
	local label = ui:getChildByName(labelName)
	local labelRect = ui:getChildByName(fontSizeName)

	local newLabel = TextField:createWithUIAdjustment(labelRect, label)
	newLabel.name = labelName
	newLabel:setString(labelString)
	ui:addChild(newLabel)
end




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
	tipInstance:show(rect)
end







---------------- PAGE RENDERER CLASS -----------------

PageRenderer = class(BaseUI)

function PageRenderer:create(groupName, pageSize, drawUnlockButton)
	local instance = PageRenderer.new()
	instance:loadRequiredResource(PanelConfigFiles.bag_panel_ui)
	instance:init(groupName, pageSize, drawUnlockButton)
	return instance
end

function PageRenderer:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

function PageRenderer:init(groupName, pageSize, drawUnlockButton)


	self.ui = self.builder:buildGroup(groupName)--ResourceManager:sharedInstance():buildGroup(groupName)

	assert(self.ui)

	BaseUI.init(self, self.ui)
	self.ui:getChildByName('bg'):setOpacity(0)


	local maxSize = 20


	-- self.pageSize = 18 -- every page is simply 18 boxes plus a unlock button!
	self.pageSize = pageSize
	self.showUnlockBtn = drawUnlockButton -- show unlock on every page

	self.itemBoxes = {}
	-- set visible according to the page size
	for i=1, self.pageSize do 
		local ib = self.ui:getChildByName('item'..i)
		ib:setVisible(true)
		table.insert(self.itemBoxes, ib)
		-- ib:getChildByName('icon'):setVisible(false)
		ib:getChildByName('txt'):setVisible(false)
		ib:getChildByName('txt_fontSize'):setVisible(false)
	end 

	-- set the rest invisible
	for i=self.pageSize+1, maxSize do
		local ib = self.ui:getChildByName('item'..i)
		ib:setVisible(false)
	end

	if self.showUnlockBtn then
		local btn = self.ui:getChildByName('unlockButton')
		btn:getChildByName('txt'):setString(Localization:getInstance():getText('bag.panel.unlock', {}))
		btn:setVisible(true)
		btn:setTouchEnabled(true, 0, false)
		btn:addEventListener(DisplayEvents.kTouchTap, 
		                     function (event)
		                     	self:onUnlockButtonTap(event)
		                     end,
		                     self)
	else 
		local btn = self.ui:getChildByName('unlockButton')
		btn:setVisible(false)
		btn:removeEventListenerByName(DisplayEvents.kTouchTap)
	end


	return true
end

function PageRenderer:setItems(items)
-- items = {{id = xxx, quantity = xxx}, ...}

	assert(items)
	assert(#items <= self.pageSize)

	for i=1, #items do
		self:showBoxIcon(i, nil)
		self:showBoxIcon(i, items[i])
	end
	for j=#items + 1, self.pageSize do 
		self:showBoxIcon(j, nil)
	end
end

function PageRenderer:setItemAt(index, item)
	assert(item)
	assert(item.itemId)
	assert(item.num >= 0)
	assert(index <= self.pageSize)

	self:showBoxIcon(index, item)
end


function PageRenderer:showBoxIcon(index, item)
	assert(index > 0)
	assert(index <= self.pageSize)

	local propsId = item and item.itemId or 0
	local quantity = item and item.num or 0

	local ib = self.itemBoxes[index]
	local txt = ib:getChildByName('txt')
	local fontSize = ib:getChildByName('txt_fontSize')
	local newLabel = TextField:createWithUIAdjustment(fontSize, txt)
	-- createWithUIAdjustment will remove txt from parent
	-- SO use newLabel to replace txt
	txt = newLabel
	newLabel.name = 'txt'
	ib:addChild(newLabel)

	if quantity == 0 then 
		ib:setTouchEnabled(false)
		ib:removeEventListenerByName(DisplayEvents.kTouchTap)
		txt:setVisible(false)
		if ib.ui then ib.ui:removeFromParentAndCleanup(true) end
		return 
	end

	-------------------------------------
	-- ignore bad IDs
	-- if  propsId <= 10000 
	-- 	or (propsId >=10016 and propsId <= 10017)
	-- 	or (propsId >= 10020 and propsId <= 10024) 
	-- 	or propsId == 10028
	-- 	or (propsId >= 10030 and propsId ~= 10039)
	-- then
	-- 	-- no good...
	-- 	return

	-- end 
	-- if not BagManager:isValideItemId(propsId) then return end

	local isWenHao = not BagManager:isValideItemId(propsId)
	
	local ui = nil
	if isWenHao then
		ui = ResourceManager:sharedInstance():buildGroup('Prop_wenhao')
	else
		ui = ResourceManager:sharedInstance():buildItemGroupWithDecorate(propsId, quantity)
	end
	txt:setVisible(true)

	local nNumForDisplay = quantity

	if ItemType:isMergableItem(propsId) then
		nNumForDisplay = 1
	end

	txt:setString(nNumForDisplay)
	-- make the icon to fit into the box
	ui:setScale(0.8)
	local outSize = ib:getGroupBounds().size
	local innerSize = ui:getGroupBounds().size
	-- center the icon in the box
	ui:setPosition(ccp((outSize.width - innerSize.width) / 2, 0 - (outSize.height - innerSize.height) / 2))

	if ib.ui ~= nil then ib.ui:removeFromParentAndCleanup(true) end

	ib:addChild(ui)
	ib.ui = ui

	ib:setTouchEnabled(true, 0, false)
	ib:addEventListener(DisplayEvents.kTouchTap, 
	                      function(event)
	                      		self:onItemTap(event)
	                      end, 
	                      {index = index, isWenHao = isWenHao, item = item })
	-- make sure that txt is above the icon
	txt:removeFromParentAndCleanup(false)
	ib:addChild(txt)


	local function updateFlag(cdInSec, isTimePreProp ,expireTime )
			if not ib or ib.isDisposed then return end
			if expireTime then
				cdInSec = math.floor((expireTime - Localhost:time()) / 1000)
			end
			if cdInSec <= 0 then
				if ib.timeFlagUp then
					ib.timeFlagUp:removeFromParentAndCleanup(true) 
					ib.timeFlagUp = nil
				end
				if ib.timeFlag then 
					ib.timeFlag:removeFromParentAndCleanup(true) 
					ib.timeFlag = nil
					ib.timeFlaglabel = nil 
					ib.timeFlgaIsLabel = nil
				end
				if ib.weekMatchOnlyFlag then
					ib.weekMatchOnlyFlag:removeFromParentAndCleanup(true) 
					ib.weekMatchOnlyFlag = nil
				end

				local expireFlag = Sprite:createWithSpriteFrameName("bag_expire_flag0000")
				assert(expireFlag)
				expireFlag:setAnchorPoint(ccp(0.5, 0))
				expireFlag:setPosition(ccp(55, -120))
				ib:addChild(expireFlag)
			else

				local showLabelTime24 = 24 * 60 * 60
				local showLabelTime48 = 48 * 60 * 60

				local isShowLabel = false

				--这里判断一下 如果是限时道具的话 那么显示出具体的剩余时间
				if cdInSec < showLabelTime48 then
					--显示的是label
					isShowLabel = true 
					if  ib.timeFlgaIsLabel == false then
						if ib.timeFlag then
							ib.timeFlag:removeFromParentAndCleanup(true) 
						end
						ib.timeFlag = nil
						ib.timeFlaglabel = nil 
						ib.timeFlgaIsLabel = nil
					else
						if ib.timeFlag then
							local cIdx = 100
							if cdInSec < showLabelTime24  then
								cIdx = 101
								ib.timeFlaglabel:setColor((ccc3(255,255,0)))	--黄色的字
							else
								cIdx = 100
								ib.timeFlaglabel:setColor((ccc3(255,255,255)))	--白色的字
							end
							ib.timeFlag:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
							ib.timeFlag:applyAdjustColorShader()
						end
					end

					if  ib.timeFlgaIsLabel == nil  then
						--create
						local timeFlag =  nil
						local cIdx = 100

						timeFlag = SpriteColorAdjust:createWithSpriteFrameName("timeLabelbg0000")
						
						-- timeFlag:setOpacity(100)
						-- timeFlag:setColor((ccc3(255,0,0)))
						timeFlag:setContentSize(CCSizeMake( 90, 49 ))
						timeFlag:setAnchorPoint(ccp(0, 0))
						timeFlag:setPosition(ccp(15, -130))
						ib:addChild(timeFlag)
						ib.timeFlag = timeFlag

						local label = TextField:create("", nil, 18 , CCSizeMake( 88 , 32), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
						if cdInSec < showLabelTime24  then
							cIdx = 101
							label:setColor((ccc3(255,255,0)))	--黄色的字
						else
							cIdx = 100
							label:setColor((ccc3(255,255,255)))	--白色的字
						end
						timeFlag:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
						timeFlag:applyAdjustColorShader()

						
						label:setAnchorPoint(ccp(0, 0))
						label:setPosition(ccp(-1, 7))
						timeFlag:addChild(label)
						ib.timeFlaglabel = label
						ib.timeFlgaIsLabel = true
					end


					local strTime = getTimeFormatString(cdInSec, 1)
					if ib.timeFlaglabel then
						ib.timeFlaglabel :setString( strTime )
					end
					ib:getChildByName('txt'):setVisible(false)

					--如果是前置道具 那么在上方显示 前置
					if isTimePreProp and ib.timeFlagUp == nil then
						local spriteName = 'bag_pre_prop_flag0000'
						local timeFlagUp = Sprite:createWithSpriteFrameName(spriteName)
						assert(timeFlagUp)
						timeFlagUp:setAnchorPoint(ccp(0, 1))
						timeFlagUp:setPosition(ccp(24, 10))
						ib:addChild(timeFlagUp)
						ib.timeFlagUp = timeFlagUp
					end



				else
					--显示的是精灵 
					--限时
					local spriteName = 'bag_time_limit_flag0000'
					local x = 15
					if isTimePreProp then
						--前置限时
						spriteName = 'bag_time_pre_prop_flag0000'
					--	x = 15
					end
					local timeFlag = Sprite:createWithSpriteFrameName(spriteName)
					assert(timeFlag)
					timeFlag:setAnchorPoint(ccp(0, 0))
					timeFlag:setPosition(ccp(x, -135))
					ib:addChild(timeFlag)
					ib.timeFlag = timeFlag
					ib.timeFlgaIsLabel = false


					-- local spriteName = 'ingame_time_limit_flag0000'
					-- local timeFlag = Sprite:createWithSpriteFrameName(spriteName)
					-- assert(timeFlag)
					-- timeFlag:setAnchorPoint(ccp(0.5, 0))
					-- timeFlag:setPosition(ccp(60, 0))
					-- ib:addChild(timeFlag)
					-- ib.timeFlag = timeFlag
					-- ib.timeFlgaIsLabel = false
					
				end

				if isShowLabel then
					local function onDelayTimeFinished()
						updateFlag(cdInSec-1 , isTimePreProp , expireTime)
					end
					local replaceFlagAction = CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(onDelayTimeFinished))
					ib:runAction(replaceFlagAction)
				else
					local function onDelayTimeFinished()
						updateFlag(0)
					end
					local replaceFlagAction = CCSequence:createWithTwoActions(CCDelayTime:create(cdInSec), CCCallFunc:create(onDelayTimeFinished))
					ib:runAction(replaceFlagAction)
				end

				if ib:getChildByName('txt') then
					ib:getChildByName('txt'):setVisible(false)
				end
							
			end
		end
	if item.expireTime and item.expireTime > 0 then -- 限时道具		
		local isTimePreProp = ItemType:inPreProp(tonumber(item.itemId))
		local cdInSec = math.floor((item.expireTime - Localhost:time()) / 1000)
		updateFlag(cdInSec, isTimePreProp ,item.expireTime)

	elseif ItemType:inPreProp(item.itemId) then
		local prePropFlag = Sprite:createWithSpriteFrameName("bag_pre_prop_flag0000")
		prePropFlag:setAnchorPoint(ccp(0, 1))
		prePropFlag:setPosition(ccp(24, 10))
		ib:addChild(prePropFlag)
	end

	if ItemType:getRealIdByTimePropId(item.itemId) == ItemType.RANDOM_BIRD then

		if ib.timeFlagUp then
			ib.timeFlagUp:removeFromParentAndCleanup(true) 
			ib.timeFlagUp = nil
		end

		local weekMatchOnlyFlag = Sprite:createWithSpriteFrameName("weekmatch_only_flag0000")
		weekMatchOnlyFlag:setAnchorPoint(ccp(0, 1))

		-- if ib.timeFlag then
		-- 	weekMatchOnlyFlag:setPosition(ccp(-12, 10))
		-- 	ib.timeFlag:setPositionX(62)
		-- else
		-- 	weekMatchOnlyFlag:setPosition(ccp(16, 10))
		-- end

		weekMatchOnlyFlag:setAnchorPoint(ccp(0.5, 1))
		weekMatchOnlyFlag:setPosition(ccp(57, 10))

		ib.weekMatchOnlyFlag = weekMatchOnlyFlag
		ib:addChild(weekMatchOnlyFlag)
	end

end


function PageRenderer:onItemTap(event)
	-- show tips
	assert(event.context)
	local index = event.context.index
	local isWenHao = event.context.isWenHao
	local ib = self.itemBoxes[index]

	local originSize = ib.ui:getGroupBounds().size
	local enlargeRestoreAction = EnlargeRestore:create(ib.ui, originSize, 1.25, 0.1, 0.1)
	if ib.ui:numberOfRunningActions() == 0 then
		ib.ui:runAction(enlargeRestoreAction)
	end

	if isWenHao then
		if UpdatePackageManager:enabled() then
			UpdatePackageManager:getInstance():startDownload()
			
		elseif NewVersionUtil:hasPackageUpdate() then
			local panel = nil
			if (_G.isPrePackage ) then
				panel = PrePackageUpdatePanel:create(
					ib:getPositionInWorldSpace(),
					Localization:getInstance():getText("new.version.tip.bag")
				) 

				if (panel) then
					panel:popout()
				end
			else

				local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'
				AsyncSkinLoader:create(UpdatePageagePanel, {
					ib:getPositionInWorldSpace(),
					Localization:getInstance():getText("new.version.tip.bag")
				}, UpdatePageagePanel.getSkin, function ( panel )
					if (panel) then
						panel:popout()
					end
				end)
			end 
		else
			CommonTip:showTip(Localization:getInstance():getText("new.version.tip.bag.1"))
		end
	elseif event.context.item.itemId == ItemType.INGREDIENT and UserManager:getInstance().user:getTopLevelId() >= JumpLevelManager:getLowestJumpableLevel() then
		local jumpedLevels = JumpLevelManager:getInstance():getJumpedLevels()
		local moreIngredientLevels = JumpLevelManager:getMoreIngredientLevels()
		if #jumpedLevels == 0 and #moreIngredientLevels == 0 then
			self:showTip(ib, event.context.item)
		else
			self:showIngredientTip(ib, event.context.item)
		end			
	else 
		self:showTip(ib, event.context.item)
	end
end

function PageRenderer:showIngredientTip(ib, item)
	local propsId = item.itemId

	local content = self.builder:buildGroup('ingredientTipContent')--ResourceManager:sharedInstance():buildGroup('bagItemTipContent')
	local desc = content:getChildByName('desc')
	local title = content:getChildByName('title')
	local btn = GroupButtonBase:create(content:getChildByName('btn'))
	local function onIngredientBtnTapped()

		local bagPanel = PopoutManager:sharedInstance():getLastPopoutPanel()
		if bagPanel and type(bagPanel.onCloseBtnTapped) == "function" then
			bagPanel:onCloseBtnTapped()
		end
	    DcUtil:UserTrack({category = 'skipLevel', sub_category = 'open_get_pod', t1 = UserManager:getInstance().user:getTopLevelId(), t2 = JumpLevelManager:getInstance():getOwndIngredientNum(), t3 = 1})

		local panel = MoreIngredientPanel:create()
		panel:popout()
	end

	btn:setString(localize('skipLevel.Button6'))
	btn:ad(DisplayEvents.kTouchTap, onIngredientBtnTapped)

	title:setString(Localization:getInstance():getText("prop.name."..propsId))
	local originSize = desc:getDimensions()
	originSize = {width = originSize.width, height = originSize.height}
	desc:setDimensions(CCSizeMake(originSize.width, 0))
	desc:setString(Localization:getInstance():getText("skipLevel.tips.ingredient", {n = '\n', s = ' '}))
	showTip(ib:getGroupBounds(), content, propsId)
end

function PageRenderer:showTip(ib, item)
	assert(item)
	local propsId = item.itemId
	local realPropId = item.timePropId or item.itemId

	local content = self.builder:buildGroup('bagItemTipContent')--ResourceManager:sharedInstance():buildGroup('bagItemTipContent')
	local desc = content:getChildByName('desc')
	local title = content:getChildByName('title')
	local sellBtn = GroupButtonBase:create(content:getChildByName('sellButton'))
	local useBtn = GroupButtonBase:create(content:getChildByName('useButton'))

	local function canUseItem(itemId)
		if itemId == 10012 or itemId == 10013 or itemId == 10014 or itemId == 10039
		then 
			return true
		else 
			return false
		end
	end

	local canUse = canUseItem(propsId)
	local canSell = false -- CURRENTLY: not supported


	title:setString(Localization:getInstance():getText("prop.name."..propsId, {num = item.num}))
	local originSize = desc:getDimensions()
	originSize = {width = originSize.width, height = originSize.height}
	desc:setDimensions(CCSizeMake(originSize.width, 0))
		
	if item.itemId == ItemType.INGREDIENT and 
		UserManager:getInstance().user:getTopLevelId() >= JumpLevelManager:getLowestJumpableLevel() then
		desc:setString(Localization:getInstance():getText("skipLevel.tips.ingredient", {n = '\n', s = ' '}))
	else
		desc:setString(Localization:getInstance():getText("level.prop.tip."..propsId, {n = "\n", replace1 = 1}))
	end

	local descSize = desc:getContentSize()
	descSize = {width = descSize.width, height = descSize.height}
	-- descSize.height = math.max(descSize.height, originSize.height)
	-- time prop
	if item.timePropId then
		local function getCDTime()
			local cdTimeInSec = math.floor((item.expireTime - Localhost:time()) / 1000)
			local h = 0
			local m = 0
			local s = 0
			if cdTimeInSec > 0 then 
				local cdMin = cdTimeInSec / 60 -- 倒计时的分钟数
				if cdMin >= 1 then
					cdMin = math.floor(cdMin) -- 向下取整
					h = math.floor(cdMin / 60)
					m = cdMin % 60
				else -- 剩余时间少于1分钟时使用秒数倒计时
					s = math.floor(cdTimeInSec % 60)
				end
			end
			return {h=h,m=m,s=s}
		end

		local expireDesc = TextField:create("", desc:getFontName(), desc:getFontSize())
		local function updateCDTime()
			if expireDesc and not expireDesc.isDisposed then
				local cdTime = getCDTime()
				if cdTime.h==0 and cdTime.m==0 and cdTime.s==0 then -- 已过期
					expireDesc:setString(Localization:getInstance():getText("level.expire.prop.tip2"))
				else
					if cdTime.h > 0 or cdTime.m > 0 then
						local expireDescText = Localization:getInstance():getText("level.expire.prop.tip", {h=cdTime.h, m=cdTime.m})
						expireDesc:setString(expireDescText)
					else -- 秒数倒计时
						local expireDescText = Localization:getInstance():getText("level.expire.prop.tip1", {s=cdTime.s})
						expireDesc:setString(expireDescText)
						setTimeOut(updateCDTime, 1)		
					end
				end
			end
		end
		updateCDTime()

		expireDesc:setDimensions(CCSizeMake(originSize.width, 0))
		expireDesc:setColor(ccc3(255,0,0))
		expireDesc:setAnchorPoint(ccp(0,1))
		local descPos = desc:getPosition()
		expireDesc:setPosition(ccp(descPos.x, descPos.y - descSize.height - 5))

		content:addChild(expireDesc)

		local expireDescSize = expireDesc:getContentSize()
		descSize.height = descSize.height + expireDescSize.height + 5
	end

	sellBtn:setVisible(false)
	sellBtn:setEnabled(false)
	sellBtn:setColorMode(kGroupButtonColorMode.orange)

	useBtn:setVisible(false)
	useBtn:setEnabled(false)
	useBtn:setColorMode(kGroupButtonColorMode.green)

	if canSell then 
		sellBtn:setVisible(true)
		-- sellBtn:setButtonMode(true)
		sellBtn:setEnabled(true)
		sellBtn:addEventListener(DisplayEvents.kTouchTap, function(event) self:onSellBtnTapped(event) end, realPropId )
		sellBtn:setString(Localization:getInstance():getText('bag.panel.button.sell', {}))
	end

	if canUse then
		local bounds = ib:getGroupBounds()
		local boxPosition = ccp(bounds:getMidX(),bounds:getMidY())  
		
		useBtn:setVisible(true) 
		-- useBtn:setButtonMode(true)
		useBtn:setEnabled(true)
		useBtn:addEventListener(DisplayEvents.kTouchTap, function(event) self:onUseBtnTapped(event) end, {propsId = realPropId, pos = boxPosition} )
		-- buildBtnLabel(useBtn, 'txt', 'txt_fontSize', Localization:getInstance():getText('bag.panel.button.use', {}))
		useBtn:setString(Localization:getInstance():getText('bag.panel.button.use', {}))
	end

	local btnPosY = desc:getPositionY() - descSize.height - 40
	sellBtn:setPositionY(btnPosY)
	useBtn:setPositionY(btnPosY)

	if canSell and not canUse then 
		local contSize = content:getGroupBounds().size
		sellBtn:setPositionX(contSize.width / 2)
	elseif not canSell and canUse then
		local contSize = content:getGroupBounds().size
		useBtn:setPositionX(contSize.width / 2)
	elseif not canSell and not canUse then
		useBtn:removeFromParentAndCleanup(true)
		sellBtn:removeFromParentAndCleanup(true)
	end	


	showTip(ib:getGroupBounds(), content, propsId)
end

function PageRenderer:onUnlockButtonTap(event)
	-- if _G.isLocalDevelopMode then printx(0, 'unlock button clicked') end

	local function callback(success)
		if self.buyUnlockCallbackFunc then
			self.buyUnlockCallbackFunc(success)
		end
	end

	BagManager:getInstance():buyUnlock(callback)
end

function PageRenderer:dispose()
	CocosObject.dispose(self)
	disposeTip()
end

function PageRenderer:setBuyUnlockCallbackFunc(callbackFunc)
	self.buyUnlockCallbackFunc = callbackFunc
end

function PageRenderer:setSellCallbackFunc(callbackFunc)
	self.sellCallbackFunc = callbackFunc
end

function PageRenderer:setUseCallbackFunc(callbackFunc)
	self.useCallbackFunc = callbackFunc
end

function PageRenderer:onSellBtnTapped(event)
	local propsId = event.context

	local amount = 1
	local sellLogic = SellLogic:create(propsId, amount)

	local function onSuccess()
		-- print 'sell success'
		disposeTip()
		self.sellCallbackFunc(true)
	end

	local function onFail()
		-- print 'sell failed'
		disposeTip()
		self.sellCallbackFunc(false)
	end

	local showLoading = true
	sellLogic:start(onSuccess, onFail, showLoading)

end

function PageRenderer:onUseBtnTapped(event)
	local propsId = event.context.propsId
	local position = event.context.pos
	local isTempProps = false
	local levelId = 0
	local param = nil 
	local itemLIst = {propsId}

	local type = ItemType.SMALL_ENERGY_BOTTLE
	local toAdd = 0

	local function onSuccess()
		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local visibleSize = Director:sharedDirector():getVisibleSize()

		local anim = FlyTopEnergyBottleAni:create(type, toAdd)
		anim:setWorldPosition(position)
		anim:play()

		disposeTip()
		self.useCallbackFunc(true)
	end 
	local function onFail()
		disposeTip()
		self.useCallbackFunc(false)
	end


	if UserEnergyRecoverManager:isEnergyFull() and propsId ~= 10039 then
		disposeTip()
		CommonTip:showTip(Localization:getInstance():getText('energy.panel.energy.is.full', {}), 1, nil)
	else
		local curEnergy = UserEnergyRecoverManager:sharedInstance():getEnergy()
		local maxEnergy	= UserEnergyRecoverManager:sharedInstance():getMaxEnergy()
		local maxToAdd = maxEnergy - curEnergy 

		if propsId == 10012 then
			type = ItemType.SMALL_ENERGY_BOTTLE
			toAdd = math.min(1, maxToAdd)
		elseif propsId == 10013 then
			type = ItemType.MIDDLE_ENERGY_BOTTLE
			toAdd = math.min(5, maxToAdd)
		elseif propsId == 10014 then
			type = ItemType.LARGE_ENERGY_BOTTLE
			toAdd = math.min(30, maxToAdd)
		elseif propsId == 10039 then
			type = ItemType.INFINITE_ENERGY_BOTTLE
		end

		local logic = UseEnergyBottleLogic:create(type, DcFeatureType.kBag, DcSourceType.kBagUse)
		logic:setSuccessCallback(onSuccess)
		logic:start(true)
		local scene = HomeScene:sharedInstance()
		local button = scene.energyButton
		scene:checkUserEnergyDataChange()
		button:updateView()
	end


end






