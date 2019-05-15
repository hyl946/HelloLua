local SuperCls = require("zoo/localActivity/UserCallBackTest/src/view/ActBasePanel.lua")
local MainPanel = class(SuperCls)

local config = require("zoo/localActivity/UserCallBackTest/Config.lua")
local model = require("zoo/localActivity/UserCallBackTest/src/model/Model.lua"):getInstance()
local LastDayRender = require("zoo/localActivity/UserCallBackTest/src/component/LastDayRender.lua")
local DayRender = require("zoo/localActivity/UserCallBackTest/src/component/DayRender.lua")
local OK_BTN_LOGIC = { NONE = 0, 
					   OK = 1 }

function MainPanel:create()

	if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction MainPanel:create" ) end

	local mainPanel = MainPanel.new()
    mainPanel:loadRequiredResource("ui/UserCallBackTest/res/new_panel.json")
	model:setMainPanel(mainPanel)
	mainPanel:init()
	return mainPanel
end

function MainPanel:init()
	if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction MainPanel:init" ) end
	SuperCls.init(self, config, model, constants)
end

function MainPanel:initUI()
	if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction MainPanel:initUI" ) end
    SpriteUtil:addSpriteFramesWithFile('ui/UserCallBackTest/frames/arrow.plist', 'ui/UserCallBackTest/frames/arrow.png')
	FrameLoader:loadArmature('ui/UserCallBackTest/skeleton/anim', 'UserCallBackVer2', 'UserCallBackVer2')
	self.ui = self:buildInterfaceGroup("UserCallBackVer2/MainPanel")

	self.okBtn = GroupButtonBase:create(self.ui:getChildByName("okBtn"))
	self.timeTf = self.ui:getChildByName("timeTf")
	local date = os.date('*t', (model.endTime - 100)/1000)

	local stringText = localize("activity.3009.UserCallBack.time", {month = date.month, day = date.day})
	if _G.isLocalDevelopMode then printx(101, "MainPanel initUI = "  , stringText ) end
	

	self.timeTf:setString( stringText )
	-- self.timeTf:setPositionX(self.timeTf:getPositionX() + 22)
	self.descTf = self.ui:getChildByName("descTf")
	-- self.descTf:setPositionX(self.descTf:getPositionX() + 10)

	self.btnClose = self.ui:getChildByName("closeBtn")
	self.btnClose:setTouchEnabled(true, 0, true)
	self.btnClose:setButtonMode(true)
	self.btnClose:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnClicked() end)

	self.dayRenders = {}
	for i=1, 6 do self.dayRenders[i] = DayRender:create(self.ui:getChildByName("item" .. i), i, false) end
	self.dayRenders[7] = LastDayRender:create(self.ui:getChildByName("item7"), 7, model:showPriceTag())

	SuperCls.initUI(self)

	self:resetOkBtn()

    if model:isActEnd() then 
        self:playActEnd()
    end
end

function MainPanel:dispose()
	for i=1, #self.dayRenders do
		self.dayRenders[i]:dispose()
	end
    SpriteUtil:removeLoadedPlist('ui/UserCallBackTest/frames/arrow.plist')
    if FrameLoader.unloadArmature then --版本兼容
		FrameLoader:unloadArmature('ui/UserCallBackTest/skeleton/anim', true)
    end
	SuperCls.dispose(self)
end

function MainPanel:onPassDay()
    model.received = false
	if model:isActEnd() then 
		self:onClkCloseBtn()
	else
		if model.received then 
			-- model.received = false
			-- model:updateRewardTipView()
		end
		SuperCls.onPassDay(self)
		self:resetOkBtn()
	end
end

function MainPanel:resetOkBtn()
    self.forceGainReward = not model.received and model:getTodayID() < 4 					--前三天强制领奖闯关
    self.btnClose.clkToGainAward = self.forceGainReward

	if not model.received then
		self.okBtnLogic = OK_BTN_LOGIC.OK
		self.okBtn:useBubbleAnimation(0.02)
		self.okBtn:setEnabled(true)--setColorMode(kGroupButtonColorMode.green)
	else
		self.okBtnLogic = OK_BTN_LOGIC.NONE
		self.okBtn.groupNode:stopAllActions()
		self.okBtn:setEnabled(false)--:setColorMode(kGroupButtonColorMode.grey)
	end
	if self.forceGainReward then
	 	self.okBtn:setString("领取并闯关")
	else
		self.okBtn:setString("领取礼包")
	end
end

function MainPanel:refresh()
	if self.ui.isDisposed then return end
	SuperCls.refresh(self)

	for i=1, #self.dayRenders do print(i, i, i, i)  self.dayRenders[i]:refresh() end
	if model.received then
		self:playDescTfAnim()
	else
		self.descTf:stopAllActions()
		self.descTf:setVisible(false)
	end
end

function MainPanel:playDescTfAnim()
	self.descTf:stopAllActions()
	local timeA = Localhost:getDayStartTimeByTS(Localhost:timeInSec() + 86400)

	if model:getTodayID() >= 7 and (timeA + 2) > model.endTime / 1000 or model:isActEnd() then
		return
	end
	
	self.descTf:setVisible(true)
	self.descTf:runAction(CCRepeatForever:create(
								CCSequence:createWithTwoActions(
									CCDelayTime:create(1), 
									CCCallFunc:create(function()
										if self.ui.isDisposed then return end
										local timeNow = Localhost:timeInSec()
										local gapTime = timeA - timeNow
										if gapTime <= 0 then self.descTf:stopAllActions()
										else
											local hour = math.floor(gapTime / 3600)
											local minute = math.floor(( gapTime % 3600 ) / 60)
											local second = ( gapTime % 3600 ) % 60
											if hour < 10 then hour = "0" .. hour end
											if minute < 10 then minute = "0" .. minute end
											if second < 10 then second = "0" .. second end
											local timeStr = hour .. ":" .. minute .. ":" .. second
											self.descTf:setString(localize("activity.3009.UserCallBack.mainPanel.nextAwardTime", {time=timeStr}))
										end
									end))))
end

function MainPanel:popout(closeCallBack)
	self.closeCallBack = closeCallBack
	SuperCls.popout(self)
end

function MainPanel:clkToOK()
	if not model.received then--领奖
		self:gainAward()
	else--打最高关卡
		self:playTopLevel()
		self:onClkCloseBtn(true)
	end
end

function MainPanel:playTopLevel()
	local levelId = UserManager.getInstance().user:getTopLevelId()
	local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
	startGamePanel:popout(false)
end

function MainPanel:playActEnd()
    local function playArmature()
        local playGameAnim = ArmatureNode:create('UserCallBackVer2/PlayGameAnim')
        playGameAnim:playByIndex(0, 1)
        playGameAnim:update(0.001)
        playGameAnim:stop()
        playGameAnim:playByIndex(0, 1)
        playGameAnim:setPosition(ccp(300, -820))
        self.ui:addChild(playGameAnim)
        playGameAnim:addEventListener(ArmatureEvents.COMPLETE, function()
            if self.ui.isDisposed then return end
            playGameAnim:setVisible(false)
            self.ui:removeChild(playGameAnim)
        end)
    end

    self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(playArmature)))
    self.okBtnLogic = OK_BTN_LOGIC.OK
    -- self.okBtn.groupNode:getChildByName("awardTf"):setVisible(false)
    -- self.okBtn.groupNode:getChildByName("playGameTf"):setVisible(true)


    
    self.okBtn:setEnabled(true)
    self.okBtn:setString("去闯关")
end

function MainPanel:getActIcon()
    local actBtns = HomeScene:sharedInstance().activityIconButtons
    if actBtns then
        for k, v in pairs(actBtns) do
            if v.source == 'UserCallBack/Config.lua' then
                return v
            end
        end
    end
    return nil
end

function MainPanel:hideActIcon()
    -----------------
    -- 取消了
    -----------------
    -- if HomeScene.onIconBtnFinishJob then
    --     local icon = self:getActIcon()
    --     if icon then
    --         HomeScene:sharedInstance():onIconBtnFinishJob(icon)
    --     end
    -- end
end

function MainPanel:gainAward()
	if not model.received then
		local todayID = model:getTodayID()
		local function onSucess(rewardItems)
			local item = self.dayRenders[todayID]
			if self.forceGainReward and item and item.rewardCells then 
				local endCount = 0
				self:flyItem(todayID, function ()
					endCount = endCount + 1
					if endCount >= #item.rewardCells then
						self:__close()
						UserCallbackManager.getInstance():openStartLevelPanel()
					end
				end)
			else
				self:flyItem(todayID)
			end

			if self.ui.isDisposed then return end
			
			self.dayRenders[todayID]:playGainAwardAnim()
			
			if todayID == 7 then
				self.okBtn:setEnabled(false)
				self.okBtn.groupNode:setVisible(false)
                self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(4), CCCallFunc:create(function() self:onClkCloseBtn() end)))
			elseif (model.endTime / 1000) < (Localhost:getDayStartTimeByTS(Localhost:timeInSec() + 86400) + 2) then
                self:playActEnd()
    		elseif todayID + 1 <= 7 then
    			self.dayRenders[todayID+1]:toAvailableState()
                self.dayRenders[todayID+1]:playTomorrowAnim()
    			self:playDescTfAnim()
    			self:resetOkBtn()
    		end
		end
		local function onFail()
			self.btnClose:setTouchEnabled(true)
			self.okBtnLogic = OK_BTN_LOGIC.OK

			if self.forceGainReward then
				self.btnClose.clkToGainAward = false
			end
		end
		local function onCancel()
			self.btnClose:setTouchEnabled(true)
			if self.forceGainReward then
				self.btnClose.clkToGainAward = false
			end
		end
		if UserCallbackManager.getInstance():getUserGroup() == UserCallbackManager.UserGroup.kGroupNewB then
			extra = "zhou"
		end
		model:reward(model:getTodayRewardID(), extra, onSucess, onFail, onCancel)
	else
		if self.forceGainReward then
			self.btnClose.clkToGainAward = false
		end
	end
end

function MainPanel:flyItem(itemIndex,finishCallbak)

	local item = self.dayRenders[itemIndex]

	if item and item.rewardCells then 
		for i=1, #item.rewardCells do
			local rewardCell = item.rewardCells[i]
			local bBuffItem = rewardCell.reward.Buff

			if bBuffItem then
				local BuffLevel = rewardCell.reward.BuffLevel
				local levelId = UserManager:getInstance().user:getTopLevelId()
			    local topLevelNode = HomeScene:sharedInstance().worldScene.levelToNode[levelId]
			    if topLevelNode then 
			    	local function scrollCB()
				    	require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"
				        local pos = topLevelNode:getPosition()
				        local worldPos = topLevelNode:getParent():convertToWorldSpace(ccp(pos.x + 10, pos.y - 75))

						local anim = FlySpecialItemAnimation:create({itemId=0, num=1}, "UserCallBackVer2/prebuff_icon/res/buff"..BuffLevel.."0000", worldPos)
						anim:setWorldPosition(rewardCell:convertToWorldSpace(ccp(-45, -46)))
						anim:setFinishCallback(finishCallbak)
						anim:play()
			    	end

					HomeScene:sharedInstance().worldScene:moveTopLevelNodeToCenter(scrollCB)
				end
			else
				local anim = FlyItemsAnimation:create({rewardCell.reward})
				anim:setWorldPosition(rewardCell:convertToWorldSpace(ccp(-47, -50)))
				anim:setFinishCallback(finishCallbak)
				anim:play()
			end
		end
	end
end

-- function MainPanel:flyToFlowerNode(itemIndex, finishCallbak)
-- 	local item = self.dayRenders[itemIndex]
-- 	if item and item.rewardCells then 
-- 		local levelId = UserManager:getInstance().user:getTopLevelId()
-- 	    local topLevelNode = HomeScene:sharedInstance().worldScene.levelToNode[levelId]
-- 	    if topLevelNode then 
-- 	    	local function scrollCB()
-- 		    	require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"
-- 		        local pos = topLevelNode:getPosition()
-- 		        local worldPos = topLevelNode:getParent():convertToWorldSpace(ccp(pos.x + 10, pos.y - 25))

-- 				for i=1, #item.rewardCells do
-- 					local rewardCell = item.rewardCells[i]
-- 					local anim = FlySpecialItemAnimation:create({itemId=0, num=1}, "UserCallBackVer2/prebuff_icon/"..rewardCell.reward.."_inner0000", worldPos)
-- 					anim:setWorldPosition(rewardCell:convertToWorldSpace(ccp(0, -15)))
-- 					anim:setFinishCallback(finishCallbak)
-- 					anim:play()
-- 				end
-- 	    	end

-- 			HomeScene:sharedInstance().worldScene:moveTopLevelNodeToCenter(scrollCB)
-- 		end
-- 	end
-- end

function MainPanel:popoutShowTransition()
	local backCount = 0
	for i = 1, #self.dayRenders do
		self.dayRenders[i]:playShowAnim(function() 
			if self.ui.isDisposed then return end
			backCount = backCount + 1
			-- if backCount >= 7 then self:playShowAnim2() end --去掉抖动一下
			if backCount >= 7 then self:onPanelAnimEnd() end
		end)
	end
	SuperCls.popoutShowTransition(self)
end

function MainPanel:playShowAnim2()
	if self.ui.isDisposed then return end
	local backCount = 0
	for i = 1, #self.dayRenders do
		self.dayRenders[i]:playShowAnim2(function() 
			if self.ui.isDisposed then return end
			backCount = backCount + 1
			if backCount >= 7 then self:onPanelAnimEnd() end
		end)
	end
end

function MainPanel:onPanelAnimEnd()
	if self.ui.isDisposed then return end
	if not model:getLocalDataByKey("hasGuideVer2", false) and not model:isActEnd() then
		self:palyGuideAnim()
		model:writeLocalDataByKey("hasGuideVer2", true)
	end
end

function MainPanel:palyGuideAnim()
	if self.ui.isDisposed then return end

	local guideAnim1 = ArmatureNode:create('UserCallBackVer2/GuideAnim1')

	if guideAnim1 == nil then
		return
	end
	
	local size = CCDirector:sharedDirector():getVisibleSize()
	self.guideBg = LayerColor:createWithColor(ccc3(0, 0, 0), size.width*2, size.height*2)
    self.guideBg:setOpacity(150)
    local guideMask = LayerColor:createWithColor(ccc3(0, 0, 0), 656, 140)
    guideMask:setPositionXY(35, -945)
    self.guideClippingNode =  ClippingNode.new(CCClippingNode:create(guideMask.refCocosObj))
    guideMask:dispose()
    self.guideClippingNode:setInverted(true)
    self.guideClippingNode:addChild(self.guideBg)
    -- self.guideClippingNode:setContentSize(CCSizeMake(960, 1280))
    self.ui:addChild(self.guideClippingNode)
    self.guideBg:setPosition(self.guideClippingNode:convertToNodeSpace(ccp(0, 0)))
    
    guideAnim1:playByIndex(0, 1)
    guideAnim1:update(0.001)
    guideAnim1:stop()
    guideAnim1:playByIndex(0, 1)
    guideAnim1:setPosition(ccp(300, -500))
    self.ui:addChild(guideAnim1)

    self.rightBg = LayerColor:createWithColor(ccc3(0, 0, 0), 620, 1960)
    self.rightBg:setOpacity(150)
    self.rightBg:setPositionXY(720, -1280)
    self.ui:addChild(self.rightBg)

    local s = CCDirector:sharedDirector():getWinSize()
    guideAnim1:addEventListener(ArmatureEvents.COMPLETE, function()
    	if self.ui.isDisposed then return end
    	guideAnim1:setVisible(false)
    	self.ui:removeChild(guideAnim1)
    	local stencil = self.guideClippingNode:getStencil()
    	stencil:setPosition(ccp(35, -305))
    	stencil:setScaleX(1.0)
    	stencil:setScaleY(1.2)

    	local guideAnim2 = ArmatureNode:create('UserCallBackVer2/GuideAnim2')
    	guideAnim2:playByIndex(0, 1)
    	guideAnim2:update(0.001)
    	guideAnim2:stop()
    	guideAnim2:playByIndex(0, 1)
    	guideAnim2:setPosition(ccp(300, -273))
    	self.ui:addChild(guideAnim2)
    	guideAnim2:addEventListener(ArmatureEvents.COMPLETE, function()
    		if self.ui.isDisposed then return end
    		guideAnim2:setVisible(false)
    		self.ui:removeChild(guideAnim2)
    		self.guideClippingNode:removeFromParentAndCleanup(true)
    		self.guideClippingNode = nil
    		self.guideBg = nil
    		self.rightBg:removeFromParentAndCleanup(true)
    		self.rightBg = nil
    	end)
    end)
end

function MainPanel:__close()
	if model.received and config.isCompatibleVersion(52) and model:hasNextBoxToAchive() then
		NotificationGuideManager.getInstance():popoutIfNecessary(NotiGuideTriggerType.kUserCallBack)
	end
	SuperCls.onClkCloseBtn(self)
end

function MainPanel:onClkCloseBtn(ignoreCallBack)
    if model.received then self:hideActIcon() end
	if model:isActEnd() then model:onActEnd() end

	if self.btnClose.clkToGainAward then
		self:gainAward()
	else
		self:__close()
		if not ignoreCallBack and self.closeCallBack ~= nil then 
			self.closeCallBack() 
		end
	end
end

function MainPanel:onCloseBtnClicked(evt)
	self.btnClose:setTouchEnabled(false)
	self:onClkCloseBtn()
end

return MainPanel