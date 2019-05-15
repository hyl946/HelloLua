
local LotteryLogic = require 'zoo.panel.endGameProp.lottery.LotteryLogic'

local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local GetRewardPanel = require 'zoo.panel.endGameProp.lottery.GetRewardPanel'

local UIHelper = require 'zoo.panel.UIHelper'

local function getIconByItemId(itemId, index)
	return ResourceManager:sharedInstance():buildItemSprite(itemId)
end


local TurnCtrl = class()

function TurnCtrl:ctor( ui, lotteryMode)

	self.lotteryMode = lotteryMode

	self.observers = {}

	self.ui = ui

	local lotteryConfig = LotteryLogic:getLotteryConfig(self.lotteryMode)

	local rewardConfig = {}

	for _, v in ipairs(lotteryConfig) do
		table.insert(rewardConfig, v.rewards[1])
	end

	-- self.rewardConfig = {
	self.rewardConfig = rewardConfig or {
		{ itemId=10085,num=1},
		{ itemId=10071,num=1 },
		{ itemId=10013,num=1 },
		{ itemId=2,num=1 },
		{ itemId=10062,num=1 },
		{ itemId=10061,num=1 },
		{ itemId=10069,num=1 },
		{ itemId=14,num=3 }
	}

	if self.lotteryMode == LotteryLogic.MODE.kNEW then

		table.walk({
			'free_btn',
			'free_label',
			'icon',
			'label',
			'num',
			'btn',
		}, function (nodeName)
			self.ui:getChildByPath(nodeName):setVisible(false)
		end)

		local new_ui_group = self.ui:getChildByName('new_ui_group')

		self.lottery_btn_2 = ButtonIconNumberBase:createNewStyle(new_ui_group:getChildByPath('lottery_btn_2'), ButtonStyleType.TypeACA)
		self.lottery_btn_1 = ButtonIconNumberBase:createNewStyle(new_ui_group:getChildByPath('lottery_btn_1'), ButtonStyleType.TypeACA)

		self.lottery_btn_1:setColorMode(kGroupButtonColorMode.blue)
		self.lottery_btn_2:setColorMode(kGroupButtonColorMode.blue)

		self.lottery_btn_1:setString('抽步数')
		self.lottery_btn_2:setString('抽步数')

		local icon = new_ui_group:getChildByPath('icon')
		icon:setVisible(false)

		self.lottery_btn_1:setIconByFrameName(icon.frameName)
		self.lottery_btn_2:setIconByFrameName(icon.frameName)

		-- self.lottery_btn_1:setDelNumber(LotteryLogic:getNewCost(false), hex2ccc3('0458D7'))
		self.lottery_btn_1:setNumber(LotteryLogic:getNewCost(true))

		self.lottery_btn_2:setNumber(LotteryLogic:getNewCost(false))

		self.buyLink = new_ui_group:getChildByPath('buy')
		UIUtils:setTouchHandler(self.buyLink, function ( ... )
			self:openBuyVoucherPanel()
		end)

		self.buyLink:setVisible(false)

		self.voucherNum = new_ui_group:getChildByPath('info/num')
		self.voucherNum:setColor(hex2ccc3('66D9FF'))
		UIHelper:move(self.voucherNum, 0, -2)
		self.tip = new_ui_group:getChildByPath('tip')


		local function _start( ... )
			if self.ui.isDisposed then return end


			DcUtil:activity({
				game_type = 'stage',
				game_name = 'fs_new_lottery',
				category = 'draw',
				sub_category = 'draw',
				playId = GamePlayContext:getInstance():getIdStr(),
				t1 = LotteryLogic:getNewCost(),
				t2 = UserManager:getInstance():getUserPropNumber(ItemType.VOUCHER),
				t3 = LotteryLogic:getCurGameplayContextDrawCount() + 1,
			})


			if self.startClickCallback then
				self.startClickCallback()
			end
			self:notify('ClickStartBtn')
			self:autoStart()
			

		end

		self.lottery_btn_1:ad(DisplayEvents.kTouchTap, 	preventContinuousClick(_start))
		self.lottery_btn_2:ad(DisplayEvents.kTouchTap, 	preventContinuousClick(_start))
	else

		self.ui:getChildByName('new_ui_group'):setVisible(false)
	
		self.start = 	ButtonIconNumberBase:create( self.ui:getChildByName('btn') )
		self.start:ad(DisplayEvents.kTouchTap, function()
			if self.ui.isDisposed then return end
			if self.startClickCallback then
				self.startClickCallback()
			end
			self:notify('ClickStartBtn')
			self:autoStart()
		end)

		self.start:setColorMode(kGroupButtonColorMode.blue)
		-- local icon = ResourceManager:sharedInstance():buildItemSprite(10085)
		-- self.start:setIcon(icon ,true )
		-- icon:setAnchorPointCenterWhileStayOrigianlPosition()
		-- icon:setScale(1.05)
		self.start:setIconByFrameName("add.step.lottery/icon_lottery0000")
		self.start:setNumber( LotteryLogic:getCost() )
		self.start:setString(string.format('%s', localize('five.steps.lottery.btn2')))

		self.free_start = 	GroupButtonBase:create(self.ui:getChildByName('free_btn'))
		self.free_start:setString(localize('five.steps.lottery.free.btn'))
		self.free_start:ad(DisplayEvents.kTouchTap, function ( ... )
			if self.ui.isDisposed then return end
			if self.startClickCallback then
				self.startClickCallback()
			end
			self:notify('ClickStartBtn')
			self:autoStart()
		end)

		self.dot = getRedNumTip()
		self.ui:getChildByName('btn'):addChild(self.dot)
		self.dot:setPosition(ccp(135, 45))
		self.dot:setScale(1.2)

		self.free_dot = getRedNumTip()
		self.ui:getChildByName('free_btn'):addChild(self.free_dot)
		self.free_dot:setPosition(ccp(135, 45))
		self.free_dot:setScale(1.2)

		self.label = self.ui:getChildByName('label')
		self.label:setString(localize('five.steps.lottery.desc'))
		self.diamonds_num = self.ui:getChildByName('num')

		self.free_label = self.ui:getChildByName('free_label')

		local tag = LotteryLogic:getFreeModeStrategyTag()
		if tag then
			self.free_label:setString(localize('five.steps.lottery.free.inf.' .. tag))
		else
			self.free_label:setString(localize('five.steps.lottery.free.inf'))
		end

		if self.lotteryMode ~= LotteryLogic.MODE.kNORMAL then
			self.label:setVisible(false)
			self.diamonds_num:setVisible(false)
			self.start:setVisible(false)
			self.ui:getChildByName('icon'):setVisible(false)
		end

		if self.lotteryMode ~= LotteryLogic.MODE.kFREE then
			self.free_label:setVisible(false)
			self.free_start:setVisible(false)
		end
	end

	self.isBusy = false
	self:buildTurnTable()

	self:refresh()
end

function TurnCtrl:buildTurnTable()
	self.turntable = self.ui:getChildByName('turn')

	local bg = self.turntable:getChildByName('bg')
	local bgIndex = self.turntable:getChildIndex(bg)



	if self.lotteryMode == LotteryLogic.MODE.kNEW then
		for i = 1, 8 do
	    	local itemId = self.rewardConfig[i].itemId
	    	itemId = ItemType:getRealIdByTimePropId(itemId)

	    	local stepMap = {
	    		[ItemType.ADD_FIVE_STEP] = '+5',
	    		[ItemType.ADD_2_STEP] = '+2',
	    	}

	    	if stepMap[itemId] then

	    		local decro = UIHelper:createUI('ui/lottery.json', "add.step.lottery/decro")
		    	self.turntable:addChildAt(decro, bgIndex + 1)
		    	decro:setRotation(45 * (i-1) + 22.5 -1)
		    	for _, v in ipairs(decro:getChildrenList()) do
		    		v:setVisible(stepMap[itemId] == v.name)
		    		v:setPositionY(v:getPositionY() + 25)

		    		-- if i == 6 then
		    		-- 	v:setPositionY(v:getPositionY() - 25)
		    		-- end

		    	end

		    	if i == 6 then
	    			decro:setRotation(decro:getRotation() - 1)
	    		end
		    	
	    	end
		end
	end


	for i = 1, 8 do 
		local reward = self.rewardConfig[i]
		self:buildRewardItem(i, reward)
	end
	self:setEnabled(true)
end



local function positionNode( holder, icon, isUniformScale)

	if (not holder) or holder.isDisposed then return end
	if (not icon) or icon.isDisposed then return end


	local layoutUtils = require 'zoo.panel.happyCoinShop.utils'

	local parent = holder:getParent()

	if (not parent) or parent.isDisposed then return end



	local iconIndex = parent:getChildIndex(holder)
	parent:addChildAt(icon, iconIndex)

	local size = holder:getContentSize()
	local sx, sy = holder:getScaleX(), holder:getScaleY()

	local realSize = {
		width = sx * size.width,
		height = sy * size.height,
	}

	layoutUtils.scaleNodeToSize(icon, realSize, parent, isUniformScale)
	layoutUtils.verticalCenterAlignNodes({icon}, holder, parent)
	layoutUtils.horizontalCenterAlignNodes({icon}, holder, parent)

	holder:setVisible(false)



end


local function setRewardItem( ui, itemId, num )

	if (not ui) or ui.isDisposed then return end


	local iconHolder = ui:getChildByName('icon')
	local icon = ResourceManager:sharedInstance():buildItemSprite(itemId)
	positionNode(iconHolder, icon, true)

	local flagHolder = ui:getChildByName('flag')


	local flagSpriteFrameName

	if ItemType:isTimeProp(itemId) then
		flagSpriteFrameName = 'add.step.lottery/res/bag_time_limit_flag'
	elseif ItemType:inPreProp(itemId) then
		flagSpriteFrameName = 'add.step.lottery/res/bag_pre_prop_flag'
	elseif ItemType:inTimePreProp(itemId) then
		flagSpriteFrameName = 'add.step.lottery/res/bag_time_pre_prop_flag'
	end

	if flagSpriteFrameName then
		local flag = UIHelper:safeCreateSpriteByFrameName(flagSpriteFrameName .. '0000')
		positionNode(flagHolder, flag, true)
	end

	flagHolder:setVisible(false)
	iconHolder:setVisible(false)


	local numUI = BitmapText:create('x' .. tostring(num), 'fnt/target_amount.fnt')
	-- numUI:setColor(ccc3(0, 0, 0))
	positionNode(ui:getChildByName('num'), numUI, true)
end


function TurnCtrl:buildRewardItem(index, reward)
	local itemUI = self.turntable:getChildByName('item_'..index)
	setRewardItem(itemUI, reward.itemId, reward.num)

	local angle = (90-22.5) - 45*(index - 1)

	while angle > 360 do
		angle = angle - 360
	end

	while angle < 0 do
		angle = angle + 360
	end


	local radius = 210

	angle = angle / 180 * math.pi
	itemUI:setPosition(ccp(radius * math.cos(angle), radius * math.sin(angle)))

end

function TurnCtrl:getPoints()
	if self.lotteryMode == LotteryLogic.MODE.kNEW then
		return UserManager:getInstance():getUserPropNumber(ItemType.VOUCHER) or 0
	else
		return UserManager:getInstance():getUserPropNumber(ItemType.DIAMONDS) or 0
	end
end

function TurnCtrl:refresh()

	if self.ui.isDisposed then return end

	if LotteryLogic:canDrawLottery(self.lotteryMode) then
		self:setEnabled(true)
	else
		self:setEnabled(false)
	end

	self:refreshView()
end

function TurnCtrl:refreshView( ... )
	if self.ui.isDisposed then return end

	if self.lotteryMode == LotteryLogic.MODE.kNEW then

		UIHelper:setLeftText(self.voucherNum, tostring(math.floor(self:getPoints())), 'fnt/tutorial_white.fnt')

		local _, hasDiscount = LotteryLogic:getNewCost()
		self.lottery_btn_1:setVisible(hasDiscount)
		self.tip:setVisible(false)
		self.lottery_btn_2:setVisible(not hasDiscount)
	else
		self.diamonds_num:setString(tostring( math.floor(self:getPoints() )))

		if self.lotteryMode == LotteryLogic.MODE.kFREE then
			self.free_dot:setNum(LotteryLogic:getLeftFreeDrawCount())
			if LotteryLogic:getLeftFreeDrawCount() > 0 then
				self.free_start:setColorMode(kGroupButtonColorMode.green)
			else
				self.free_start:setColorMode(kGroupButtonColorMode.blue)
			end
		elseif self.lotteryMode == LotteryLogic.MODE.kNORMAL then
			self.dot:setNum(LotteryLogic:getLeftDrawCount())	
			if LotteryLogic:getLeftDrawCount() > 0 then
				self.start:setColorMode(kGroupButtonColorMode.green)
			else
				self.start:setColorMode(kGroupButtonColorMode.blue)
			end
		end
	end
end


function TurnCtrl:getIconByItemId(itemId, index, isBig)
	return getIconByItemId(itemId, index, isBig)
end


function TurnCtrl:setEnabled(enabled)
	if enabled == self.enabled then 
		return
	end

	self.enabled = enabled
	self.turntable:setTouchEnabled(enabled, 0, true)
	if enabled then
		self.turntable:removeEventListenerByName(DisplayEvents.kTouchBegin)
		self.turntable:addEventListener(DisplayEvents.kTouchBegin, function(evt) 
			if self.ui.isDisposed then return end
			self:onTouchBegin(evt) 
		end)
	else
		self.turntable:removeEventListenerByName(DisplayEvents.kTouchBegin)
	end

	if (not self.enabled) and (not self.isBusy) then
		self.turntable:setTouchEnabled(true, 0, true)
		self.turntable:addEventListener(DisplayEvents.kTouchBegin, function(evt) 
		end)
	end
end

function TurnCtrl:openBuyVoucherPanel( ... )
	local BuyVoucherPanel
	if __ANDROID then
		BuyVoucherPanel = require 'zoo.panel.endGameProp.lottery.BuyVoucherPanelAndroid'
	else
		BuyVoucherPanel = require 'zoo.panel.endGameProp.lottery.BuyVoucherPanelIOS'
	end

	BuyVoucherPanel:create(function ( panel )
		if self.ui.isDisposed then panel:dispose() return end


		panel:setBuyCallback(function ( ... )
			if self.ui.isDisposed then return end
		end)

		panel:popout()

		DcUtil:activity({
	        game_type = 'stage',
	        game_name = 'fs_new_lottery',
	        category = 'canyu',
	        sub_category = 'buy_ticket_click',

	        playId = GamePlayContext:getInstance():getIdStr(),
	        t1 = panel:getBuyCount(),
	        t2 = UserManager:getInstance():getUserPropNumber(ItemType.VOUCHER),
	        t3 = LotteryLogic:getNewCost(),
	    })


	end)


	

end


function TurnCtrl:autoStart()


	if self.enabled == true then
		local p1 = ccp(0, 100)
		local p2 = ccp(240, 100)
		local p3 = ccp(480, 100)

		p1 = self.turntable:convertToWorldSpace(p1)
		p2 = self.turntable:convertToWorldSpace(p2)
		p3 = self.turntable:convertToWorldSpace(p3)


		self:onTouchBegin({globalPosition = p1})
		self:onTouchMove({globalPosition = p2})
		self:onTouchEnd({globalPosition = p3}, true)
	else

		if self.isBusy then
			CommonTip:showTip('正在摇奖，请稍后~')
			return
		end
		
		if not LotteryLogic:canDrawLottery(self.lotteryMode) then

			self:notify('RewardFail')

			if self.lotteryMode == LotteryLogic.MODE.kNEW then

				self:openBuyVoucherPanel()

			else
				local BuyDiamondPanel
				if __ANDROID then
					BuyDiamondPanel = require 'zoo.panel.endGameProp.lottery.BuyGoodsAndroidPanel'
				else
					BuyDiamondPanel = require 'zoo.panel.endGameProp.lottery.BuyGoodsIOSPanel'
				end

				local panel = BuyDiamondPanel:create()

				panel:init(function ( ... )
					panel:popout()
				end)
			end
		end

	end
end



function TurnCtrl:onTouchBegin(evt)

	self.turntable:removeEventListenerByName(DisplayEvents.kTouchBegin)
	local pos = self.turntable:getParent():convertToWorldSpace(ccp(self.turntable:getPositionX(), self.turntable:getPositionY()))
	self.posX, self.posY = pos.x, pos.y
	local angle = -math.atan2(evt.globalPosition.y - self.posY, evt.globalPosition.x - self.posX)
	local rotation = self.turntable:getRotation()
	while rotation < -90 or rotation > 270 do
		if rotation > 270 then rotation = rotation - 360
		else rotation = rotation + 360 end
	end
	self.startRotation = angle * 180 / math.pi - rotation
	self.rotationRec = {}
	self.lastRotation = rotation
	self.turntable:addEventListener(DisplayEvents.kTouchMove, function(evt) 
		if self.ui.isDisposed then return end
		self:onTouchMove(evt) 
	end)
	self.turntable:addEventListener(DisplayEvents.kTouchEnd, function(evt) 
		if self.ui.isDisposed then return end
		self:onTouchEnd(evt) 
	end)
	self:onDragBegin()
end



function TurnCtrl:onTouchMove(evt)
	local angle = -math.atan2(evt.globalPosition.y - self.posY, evt.globalPosition.x - self.posX)
	self.turntable:setRotation(angle * 180 / math.pi - self.startRotation)
	if #self.rotationRec >= 10 then table.remove(self.rotationRec, 1) end
	local rotation = self.turntable:getRotation()
	while rotation < -90 or rotation > 270 do
		if rotation > 270 then rotation = rotation - 360
		else rotation = rotation + 360 end
	end
	table.insert(self.rotationRec, rotation - self.lastRotation)
	self.lastRotation = rotation
	if self.schedule then Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule) end
	local function onTimeOut()
		self.rotationRec = {} 
	end
	self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeOut, 0.1, false)
end




function TurnCtrl:onTouchEnd(evt, isAuto)
	self.turntable:removeEventListenerByName(DisplayEvents.kTouchMove)
	self.turntable:removeEventListenerByName(DisplayEvents.kTouchEnd)
	if self.schedule then Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule) end
	local angle = -math.atan2(evt.globalPosition.y - self.posY, evt.globalPosition.x - self.posX)
	self.turntable:setRotation(angle * 180 / math.pi - self.startRotation)
	local sum = 0
	for k, v in ipairs(self.rotationRec) do
		local rotation = v
		if rotation > 180 then rotation = rotation - 360
		elseif rotation < -180 then rotation = rotation + 360 end
		sum = sum + rotation
	end
	local rotation = self.turntable:getRotation()
	while rotation < -90 or rotation > 270 do
		if rotation > 270 then rotation = rotation - 360
		else rotation = rotation + 360 end
	end
	self.turntable:addEventListener(DisplayEvents.kTouchBegin, function(evt) 
		if self.ui.isDisposed then return end
		self:onTouchBegin(evt) 
	end)
	sum = sum + rotation - self.lastRotation
	sum = sum / (#self.rotationRec + 1)
	if math.abs(sum) > 7 then
		if sum > 0 then sum = 7
		elseif sum < -7 then sum = -7 end
	end
	if math.abs(sum) > 1.5 then
		local speed = sum

		if isAuto and speed < 0 then
			speed = - speed
		end

		self:onDragEnd(speed)

	else
	end
end



function TurnCtrl:setTargetAngle(target, range)
	self.target, self.range = -target, range
end


function TurnCtrl:stayRotate(sumSpeed)
	local function onUpdate(deltaTime)
		if self.ui.isDisposed then return end
		self.turntable:setRotation(self.turntable:getRotation() + sumSpeed * deltaTime * 60)
	end
	self.turntable:unscheduleUpdate()
	self.turntable:scheduleUpdateWithPriority(onUpdate, 0)
end

local function standardAngle(angle)
	if angle < 0 then
		while angle < 0 do angle = angle + 360 end
	end
	if angle > 360 then
		while angle > 360 do angle = angle - 360 end
	end
	return angle
end



function TurnCtrl:notCalcStopping(sumSpeed)
	local finalTarget = standardAngle(self.target)
	local count = math.floor(math.abs(sumSpeed) / 1.5) - 1
	local start = standardAngle(self.turntable:getRotation())
	local clockWise = sumSpeed >= 0
	if clockWise and finalTarget - start < 0 then
		count = count + 1
	elseif not clockWise and finalTarget - start > 0 then
		count = count + 1
	end
	local sum = 0
	if not clockWise then
		sum = finalTarget - start - count * 360
	else
		sum = finalTarget - start + count * 360
	end
	local time = sum * 2 / sumSpeed / 60
	local final = self.turntable:getRotation() + sum
	local sumTime = 0
	local start = self.turntable:getRotation()
	
	local function onUpdate(deltaTime)
		if self.ui.isDisposed then return end
		sumTime = sumTime + deltaTime
		local angle = start + sum * math.sin(sumTime / time * math.pi / 2)
		self.turntable:setRotation(angle)
		if sumTime >= time then
			self.turntable:setRotation(finalTarget)
			self.turntable:unscheduleUpdate()
			self.isBusy = false
			self:setEnabled(true)
			self:refresh()

			
		end
	end
	self.turntable:unscheduleUpdate()
	self.turntable:scheduleUpdateWithPriority(onUpdate, 0)
end


function TurnCtrl:calcStopping(sumSpeed)
	local finalTarget = standardAngle(self.target - 22.5) 
	local count = math.floor(math.abs(sumSpeed) / 1.5) - 1
	local start = standardAngle(self.turntable:getRotation())
	local clockWise = sumSpeed >= 0
	if clockWise and finalTarget - start < 0 then
		count = count + 1
	elseif not clockWise and finalTarget - start > 0 then
		count = count + 1
	end
	local sum = 0
	if not clockWise then
		sum = finalTarget - start - count * 360
	else
		sum = finalTarget - start + count * 360
	end
	local time = sum * 2 / sumSpeed / 60
	local final = self.turntable:getRotation() + sum
	local sumTime = 0
	local start = self.turntable:getRotation()
	
	local function onUpdate(deltaTime)
		if self.ui.isDisposed then return end
		sumTime = sumTime + deltaTime
		local angle = start + sum * math.sin(sumTime / time * math.pi / 2)
		self.turntable:setRotation(angle)
		if sumTime >= time then
			self.turntable:setRotation(finalTarget)
			self.turntable:unscheduleUpdate()
			self:onTurnFinish()
		end
	end
	self.turntable:unscheduleUpdate()
	self.turntable:scheduleUpdateWithPriority(onUpdate, 0)
end



function TurnCtrl:onDragBegin()
end

function TurnCtrl:onDragEnd(speed)
	self:playCostAnim()
	local function onSuccess(index, itemId, num)
		if self.ui.isDisposed then return end
		self:setTargetAngle(45 * (index - 1), 20)
		self.rewardItem = {
			itemId = itemId,
			num = num
		}
		self:calcStopping(speed)

		self:notify('RewardSuccess', itemId, num)

		
		
	end
	local function onFail(err)
		-- CommonTip:showTip('five.steps.lottery.lack.diamond')
		if self.ui.isDisposed then return end
		self:setTargetAngle(45, 20)
		self:notCalcStopping(speed)
		self.isBusy = false
		self:setEnabled(true)
		self:notify('RewardFail')


	end
	local function onCancel()
		if self.ui.isDisposed then return end
		self:setTargetAngle(45, 20)
		self:notCalcStopping(speed)
		self.isBusy = false
		self:setEnabled(true)
		CommonTip:showTip(Localization:getInstance():getText("数据错误，请关闭活动面板重新进入。"))
		self:notify('RewardFail')
	end
	
	self.isBusy = true
	self:setEnabled(false)

	self:stayRotate(speed)

	self:sendRewardHttp(onSuccess, onFail, onCancel)
end

function TurnCtrl:playCostAnim()
	
end


function TurnCtrl:sendRewardHttp(onSuccess, onFail, onCancel)
	LotteryLogic:getLotteryReward(self.lotteryMode, function ( rewards )
		local rewardItem = rewards[1]
		local index
		for key, value in ipairs(self.rewardConfig) do
			if value.itemId == rewardItem.itemId and value.num == rewardItem.num then
				index = key
				break
			end
		end

		if not index then
			if onCancel then
				onCancel()
			end
			return 
		end
		if onSuccess then
			onSuccess(index, rewardItem.itemId, rewardItem.num)
		end
	end, onFail, onCancel)

	self:refreshView()
	
end

function TurnCtrl:popShowAnim( callback )
	if (self.ui.isDisposed) then
		return 
	end
	-- body

	local eff = CommonEffect:buildGetPropLightAnimWithoutBg()
	local sp = ResourceManager:sharedInstance():buildItemSprite(self.rewardItem.itemId)
	sp:setAnchorPoint(ccp(0.5, 0.5))
	local layer = Layer:create()
	layer:addChild(eff)
	layer:addChild(sp)
	self.ui:addChild(layer)
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	local pos = ccp(vo.x + vs.width/2, vo.y + vs.height/2)
	pos = self.ui:convertToNodeSpace(pos)
	layer:setPosition(pos)

	layer:runAction(UIHelper:sequence{
		CCDelayTime:create(1),
		CCCallFunc:create(function ( ... )
			if callback then callback() end
		end)
	})

	UIHelper:createMaskInUI(layer)
end

function TurnCtrl:onTurnFinish()

	local LotteryServer = require 'zoo.panel.endGameProp.lottery.LotteryServer'
	if LotteryServer:isAddStep(self.rewardItem.itemId) then

		self:setEnabled(true)
		self:refresh()

		if self.lotteryMode == LotteryLogic.MODE.kNEW then
			self:popShowAnim(function ( ... )
				self.isBusy = false

				if (self.ui.isDisposed) then
					return 
				end
				if self.getRewardCallback then
					self.getRewardCallback(self.rewardItem)
				end
			end)
		else

			self.isBusy = false

			if self.getRewardCallback then
				self.getRewardCallback(self.rewardItem)
			end
		end

	else

		local panel = GetRewardPanel:create(self.rewardItem)
		panel:setCloseCallback(function ( ... )
			self.isBusy = false
			self:setEnabled(true)
			self:refresh()
			if self.getRewardCallback then
				self.getRewardCallback(self.rewardItem)
			end

			

		end)
		panel:popout()

	end

	self:refreshView()

end

function TurnCtrl:setGetRewardCallback( callback )
	self.getRewardCallback = callback
end

function TurnCtrl:addObservers( ob )
	table.insert(self.observers, ob)
end

function TurnCtrl:notify(eventName, ...)
	for _, ob in ipairs(self.observers) do
		if ob['on' .. eventName] then
			ob['on' .. eventName](ob, ...)
		end
	end
end

return TurnCtrl