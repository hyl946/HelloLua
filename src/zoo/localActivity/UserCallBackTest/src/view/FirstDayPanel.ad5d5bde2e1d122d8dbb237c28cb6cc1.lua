local SuperCls = require("zoo/localActivity/UserCallBackTest/src/view/ActBasePanel.lua")
local FirstDayPanel = class(SuperCls)

local config = require("zoo/localActivity/UserCallBackTest/Config.lua")
local model = require("zoo/localActivity/UserCallBackTest/src/model/Model.lua"):getInstance()

local OK_BTN_LOGIC = { NONE = 0, 
					   OK = 1 }

function FirstDayPanel:create()
	local firstDayPanel = FirstDayPanel.new()
	model:setMainPanel(firstDayPanel)
	firstDayPanel:loadRequiredResource("ui/UserCallBackTest/res/new_panel.json")
	firstDayPanel:init()
	return firstDayPanel
end

function FirstDayPanel:init()
	SuperCls.init(self, config, model, constants)
end

function FirstDayPanel:initUI()
	self.ui = self:buildInterfaceGroup("UserCallBackVer2/FirstDayPanel")
	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn.clkToGainAward = true

	local okBtnUI = self.ui:getChildByName("okBtn")
	self.okBtn = GroupButtonBase:create(okBtnUI)
	local okBtnLabel1 = okBtnUI:getChildByName("awardTf")
	local okBtnLabel2 = okBtnUI:getChildByName("awardTf1")
	okBtnLabel1:setVisible(false)

	self.okBtn.groupNode:setPositionXY(self.okBtn.groupNode:getPositionX() - 31, self.okBtn.groupNode:getPositionY() - 170)
	self.okBtn:useBubbleAnimation()
	SuperCls.initUI(self)

	local anim = nil
	FrameLoader:loadArmature('ui/UserCallBackTest/skeleton/anim', 'UserCallBack', 'UserCallBack')
	-- if UserCallbackManager.getInstance():getUserGroup() == UserCallbackManager.UserGroup.kGroupNewB then
		anim = ArmatureNode:create('UserCallBackVer2/FirstDayGiftShowAnim', true)
		self:buildBubble()
	-- else
	-- 	anim = ArmatureNode:create('UserCallBackVer2/FirstDayGiftShowAnim', true)
	-- 	self:buildBubble()
	-- end

    anim:playByIndex(0, 1)
    anim:update(0.001)
    anim:stop()
    anim:playByIndex(0, 1)
    anim:setPosition(ccp(300, -670))
    anim:setScale(0.75)
	self.ui:addChildAt(anim, 0)

    self.okBtnLogic = OK_BTN_LOGIC.NONE

    local delayTime = 1.8
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(delayTime))
	arr:addObject(CCCallFunc:create(function ()
		self:playBubbleAnim()
	end))
	arr:addObject(CCDelayTime:create(0.1))
	arr:addObject(CCCallFunc:create(function ()
		self.okBtnLogic = OK_BTN_LOGIC.OK
	end))
	self.ui:runAction(CCSequence:create(arr))
end

function FirstDayPanel:buildBubble()
	self.rewardCells = {}
	local builder = model.mainPanel.builder
	local rewards = model.boxRewardCfg[1].rewards
	local gapAngle = math.pi * 4 / 5 / (#rewards - 1)
	local centerX, centerY = 376, -450
	local angle = -math.pi / 2
	local radius = 285
	local rewardIconPos = ccp(-47, 50)
	local function normalizeNum(num)
		if num >= 10000 then
			return tostring(num/10000)..'万'
		else
			return tostring(num)
		end
	end
	for i = 1, #rewards do
		local reward = rewards[i]
		local rewardCell = builder:buildGroup("UserCallBackVer2/FirstDayAwardCell")
		local iconC = rewardCell:getChildByName("award"):getChildByName("iconC")


		local bBuffItem = reward.Buff

		local icon = nil 
		if bBuffItem then
			local BuffLevel = reward.BuffLevel
			reward.num = 1
			icon = builder:buildGroup("UserCallBackVer2/prebuff_icon/buff_icon_"..BuffLevel)
		else
			local itemId = reward.itemId
			if ItemType:isTimeProp(itemId) then
				itemId = ItemType:getRealIdByTimePropId(itemId)
			end 
			icon = ResourceManager:sharedInstance():buildItemSprite(itemId)
		end

		local pos = iconC:getPosition()
		icon:setAnchorPoint(ccp(0.5, 0.5))
		icon:setPositionXY(pos.x, pos.y)
		iconC:getParent():addChildAt(icon, 0)
		iconC:removeFromParentAndCleanup(true)

		-- local fntFile = "fnt/target_amount.fnt"
		local fntFile = "ui/UserCallBackTest/fnt/user_callback_numbers.fnt"
		self.rewardNumTf = BitmapText:create('', fntFile)
		self.rewardNumTf:setAnchorPoint(ccp(0.5, 0.5))
		self.rewardNumTf:setPreferredSize(200, 55)
		if reward.itemId and reward.itemId == 2 then
			self.rewardNumTf:setPosition(ccp(rewardIconPos.x + 58, rewardIconPos.y - 90))
		else
			self.rewardNumTf:setPosition(ccp(rewardIconPos.x + 90, rewardIconPos.y - 90))
		end
		self.rewardNumTf:setString("x" .. normalizeNum(reward.num))
		rewardCell:addChild(self.rewardNumTf)
		rewardCell:setPositionXY(334, -734)
		rewardCell.toPosX = centerX + radius * math.sin(angle)
		rewardCell.toPosY = centerY + radius * math.cos(angle)
		rewardCell.reward = reward
		angle = angle + gapAngle
		self.ui:addChildAt(rewardCell, 0)
		rewardCell:setVisible(false)
		self.rewardCells[i] = rewardCell
	end
end

function FirstDayPanel:playBubbleAnim()
	for i = 1, #self.rewardCells do
		local rewardCell = self.rewardCells[i]
		rewardCell:setVisible(true)
		rewardCell:runAction(CCMoveTo:create(0.25, ccp(rewardCell.toPosX, rewardCell.toPosY)))
	end
end

function FirstDayPanel:dispose()
	SuperCls.dispose(self)
end

function FirstDayPanel:popout(closeCallBack)
	self.closeCallBack = closeCallBack
	SuperCls.popout(self)
end

function FirstDayPanel:clkToOK()
	self:gainAward()
end

function FirstDayPanel:gainAward()
	if not model.received then
		local function onSucess(rewardItems)
			if self.ui.isDisposed then return end
			
			local endCount = 0
			local function finishCallbak()
				endCount = endCount + 1
				if endCount >= #self.rewardCells then
					self:__close()
					UserCallbackManager.getInstance():openStartLevelPanel()
				end
			end

			self:flyItem( finishCallbak )

			self.ui:setVisible(false)
		end
		local function onFail(evt)
			local errcode = evt and evt.data or nil
			-- if errcode then
			-- 	CommonTip:showTip(localize("error.tip."..tostring(errcode)), "negative")
			-- else
				CommonTip:showTip(localize("奖励领取失败~"), "negative")
			-- end
			self.okBtnLogic = OK_BTN_LOGIC.OK
			self.closeBtn.clkToGainAward = false
			self.closeBtn.inCloseLogic = true
			self.closeBtn.inClk = false
		end
		local function onCancel( ... )
			self:__close()
			if self.closeCallBack ~= nil then self.closeCallBack() end
		end
		local extra = nil
		if UserCallbackManager.getInstance():getUserGroup() == UserCallbackManager.UserGroup.kGroupNewB then
			extra = "zhou"
		end
		model:reward(model:getTodayRewardID(), extra, onSucess, onFail, onCancel)
	end
end


function FirstDayPanel:flyItem(finishCallbak)
	if #self.rewardCells>0 then 
		for i=1, #self.rewardCells do
			local rewardCell = self.rewardCells[i]
			local bBuffItem = rewardCell.reward.Buff

			print("==============index [[ " .. i .. " ]]")
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
						rewardCell:setVisible(false)
						anim:play()
			    	end

					HomeScene:sharedInstance().worldScene:moveTopLevelNodeToCenter(scrollCB)
				end
			else
				local anim = FlyItemsAnimation:create({rewardCell.reward})
				anim:setWorldPosition(rewardCell:convertToWorldSpace(ccp(-47, -50)))
				anim:setFinishCallback(finishCallbak)
				rewardCell:setVisible(false)
				anim:play()
			end
		end
	else
		if finishCallbak then finishCallbak() end
	end
end

-- function FirstDayPanel:flyToBag(finishCallbak)
-- 	for i=1, #self.rewardCells do
-- 		local rewardCell = self.rewardCells[i]
-- 		local anim = FlyItemsAnimation:create({rewardCell.reward})
-- 		anim:setWorldPosition(rewardCell:convertToWorldSpace(ccp(-47, -50)))
-- 		anim:setFinishCallback(finishCallbak)
-- 		rewardCell:setVisible(false)
-- 		anim:play()
-- 	end
-- end

-- function FirstDayPanel:flyToFlowerNode(finishCallbak)
-- 	local levelId = UserManager:getInstance().user:getTopLevelId()
--     local topLevelNode = HomeScene:sharedInstance().worldScene.levelToNode[levelId]
--     if topLevelNode then 
--     	local function scrollCB()
-- 	    	require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"
-- 	        local pos = topLevelNode:getPosition()
-- 	        local worldPos = topLevelNode:getParent():convertToWorldSpace(ccp(pos.x + 10, pos.y - 75))

-- 			for i=1, #self.rewardCells do
-- 				local rewardCell = self.rewardCells[i]
-- 				local anim = FlySpecialItemAnimation:create({itemId=0, num=1}, "UserCallBackVer2/prebuff_icon/"..rewardCell.reward.."_inner0000", worldPos)
-- 				anim:setWorldPosition(rewardCell:convertToWorldSpace(ccp(-45, -46)))
-- 				anim:setFinishCallback(finishCallbak)
-- 				rewardCell:setVisible(false)
-- 				anim:play()
-- 			end
--     	end

-- 		HomeScene:sharedInstance().worldScene:moveTopLevelNodeToCenter(scrollCB)
-- 	end
-- end

function FirstDayPanel:__close()
	SuperCls.onClkCloseBtn(self)
end

function FirstDayPanel:onClkCloseBtn()
	if self.closeBtn.inCloseLogic then
		self:__close()
		if self.closeCallBack ~= nil then self.closeCallBack() end
		return
	end

	if self.closeBtn.clkToGainAward then
		self:gainAward()
	else
		self.closeBtn.inClk = false
	end
end

return FirstDayPanel