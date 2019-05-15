local FifthAnniversaryMeta = require 'zoo.localActivity.FifthAnniversary.FifthAnniversaryMeta'
local UIHelper = require 'zoo.panel.UIHelper'
local FifthAnniversaryLogic = require 'zoo.localActivity.FifthAnniversary.FifthAnniversaryLogic'

local LuckBagGroupCtrl = class()


LuckBagGroupCtrl.EventType = {
	kOpenLuckyBag = 1,
	kUnlockSlot = 2,
    kSpeedUp = 3,
	kAfterCheckData = 3,
}

function LuckBagGroupCtrl:ctor( ui, dataMgr, tipCreator)
	self.ui = ui
	self.dataMgr = dataMgr
	self.tipCreator = tipCreator
end

function LuckBagGroupCtrl:init( ... )
	self.evtDp = EventDispatcher.new()
    self.fadeLights = {}
    self.customFadeEnabled = true
end

function LuckBagGroupCtrl:create( ui, dataMgr , tipCreator)
	local c = LuckBagGroupCtrl.new(ui, dataMgr, tipCreator)
	c:init()
	return c
end

function LuckBagGroupCtrl:refresh( ... )
	if self.ui.isDisposed then return end

    -- printx(61, 'LuckBagGroupCtrl:refresh', debug.traceback())

    self.fadeLights = {}

	for i = 1, FifthAnniversaryMeta.SLOT_NUM do
		local slotIndex = i
        local slotView = self.ui:getChildByPath(tostring(i))
        local slotData = self.dataMgr:getSlotData(slotIndex)


        self:refreshSlotView(slotView, slotData, slotIndex)
	end
end

function LuckBagGroupCtrl:tryOpenSlot( slotIndex, successCallback, failCallback )
	if self.ui.isDisposed then return end

    if self._busyMode == true then return end

	PaymentNetworkCheck:getInstance():check(function ( ... )

		local function _success(  )
		     if successCallback then successCallback( ) end
		     self.evtDp:dp(Event.new(LuckBagGroupCtrl.EventType.kUnlockSlot, {slotIndex = slotIndex}, self))
		end

        local function _cancel( ... )
             self.evtDp:dp(Event.new(LuckBagGroupCtrl.EventType.kAfterCheckData, nil, self))
        end

		if self.dataMgr.buySlot then
	        self.dataMgr:buySlot(slotIndex, _success, failCallback, _cancel)
		else
	        self.dataMgr:openSlot(slotIndex, _success, failCallback, _cancel)
		end

    end, function ( ... )
        -- body
        CommonTip:showNetworkAlert()
        if failCallback then failCallback() end
    end)
end



function LuckBagGroupCtrl:delay( func )
    if self.ui.isDisposed then return end
    self.ui:runAction(CCCallFunc:create(func))
end

function LuckBagGroupCtrl:setCustomFadeEnabled( b )
    if self.ui.isDisposed then return end

    -- printx(61, 'play setCustomFadeEnabled', b, #self.fadeLights)

    self.customFadeEnabled = b
    for _, v in ipairs(self.fadeLights or {}) do
        if self.customFadeEnabled then
            v:runAction(CCRepeatForever:create(
                UIHelper:sequence{
                    CCFadeOut:create(0.6),
                    CCFadeIn:create(0.7),
                }
            ))
        else
            v:stopAllActions()
        end
    end
end

function LuckBagGroupCtrl:playUpgradeAnim( slotIndex )
    if self.ui.isDisposed then return end

    local anim = UIHelper:createArmature3('skeleton/pig-act-anim', 
                    'pig-act-pkg-anim', 'pig-act-pkg-anim', 'pig-act-pkg-anim/slot-unlock')

--    printx(61, 'playUpgradeAnim')
  --  for _, v in ipairs(self.ui:getChildrenList()) do
    --    printx(61, 'vvv', v.name)
   -- end

    local slotView = self.ui:getChildByPath('' .. slotIndex)
    slotView:addChild(anim)

    anim:setPositionXY(149/2+15, -191/2-5)

    anim:ad(ArmatureEvents.COMPLETE, function ( ... )
        if self.ui.isDisposed then return end
        if anim and (not anim.isDisposed) then
            anim:removeFromParentAndCleanup(true)
        end
    end)
    anim:playByIndex(0, 1)
    anim:setScale(0.5)
end

function LuckBagGroupCtrl:setBusyMode( _busyMode )
    self._busyMode = _busyMode
end

function LuckBagGroupCtrl:refreshSlotView( slotView, slotData, slotIndex )
	local FifthAnniversaryLogic = require 'zoo.localActivity.FifthAnniversary.FifthAnniversaryLogic'

	if self.ui.isDisposed then return end
    if slotView.isDisposed then return end

    local buyBtn = slotView.buyBtn
    local progress = slotView.progress
    if not slotView.__init then
        slotView.__init = true

        slotView.btn = slotView:getChildByPath('btn')


        -- buyBtn = ButtonIconNumberBase:create(slotView:getChildByPath('btn'))
        -- buyBtn:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")
        -- buyBtn:setString('解锁')

        buyBtn = CocosObject:create()
        local gold = slotView:getChildByPath('gold')
        gold:removeFromParentAndCleanup(false)
        buyBtn:addChild(gold)
        buyBtn.gold = gold

        local txtGold = slotView:getChildByPath('txtGold')
        txtGold:removeFromParentAndCleanup(false)
        txtGold:setPositionY(txtGold:getPositionY()-5)
        buyBtn:addChild(txtGold)
        buyBtn.txtGold = txtGold
        slotView:addChild(buyBtn)

        slotView.buyBtn = buyBtn
        local goodsId = FifthAnniversaryMeta.GoodsId[string.format('kSlot%s', slotIndex)]

        if goodsId > 0 then

	        local buyLogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kActivity, DcSourceType.kActPre .. FifthAnniversaryLogic:getActId())
	        local price = buyLogic:getPrice()

	        -- buyBtn:setNumber(price)
            buyBtn.txtGold:setString(price)
	        

	        -- printx()
            local isCanBuy = self:canBuySlot()
            buyBtn:setVisible( isCanBuy )
	    end

        progress = slotView:getChildByPath('progress')
        progress:getChildByName('bg'):setVisible(false)
        UIHelper:buildProgress(progress)
        UIHelper:move(progress, -5, -6)

        slotView.progress = progress

        slotView.onCountDown = function ( ... )
        end

        local txtTime = slotView:getChildByName("time")
        txtTime:setColor(hex2ccc3('FF8E1E'))
        UIHelper:move(txtTime, 0, -9)

        slotView.btn:setTouchEnabled(true,nil,false)
        slotView.btn:addEventListener(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
            if not self.canUnlockSlot then
                return
            end
            if goodsId > 0 then
                --解锁
                if FifthAnniversaryLogic:isActEnd() then
                    CommonTip:showTip(localize('the.activity.has.ended'))
                    return
                end

                local function doUnlock()
                    self:tryOpenSlot(slotIndex, function ( ... )
                        if self.ui.isDisposed then return end
                        self:playUpgradeAnim(slotIndex)
                    end)
                end

                if not slotData.unlocked then
                    if slotIndex==4 then
                        local saveKey = "Act.FifthAnniversary.tip.unlock"
                        local value = CCUserDefault:sharedUserDefault():getIntegerForKey(saveKey, 0)
                        if value and value == 1 then
                            doUnlock()
                        else
                            CCUserDefault:sharedUserDefault():setIntegerForKey(saveKey, 1)
                            CCUserDefault:sharedUserDefault():flush()
                            
                            local text = {
                                tip = "是否要消耗风车币解锁新烤箱？",
                                yes = "确定",
                                no = "取消",
                            }
                            local panel = CommonTipWithBtn:create(text, 2, doUnlock, nil, nil, false)
                            PopoutManager:sharedInstance():add(panel, false, false)
                        end
                    else
                        doUnlock()
                    end
                end
            else

            end
        end))
    end


    local needStopLightAction = true

    buyBtn:setVisible(false)
    slotView.btn:setVisible(false)
    slotView:getChildByPath('time'):setVisible(false)
    slotView:getChildByPath('progress'):setVisible(false)
    slotView:getChildByPath('multiIcon'):setVisible(false)
    slotView:getChildByPath('speedUpBtn'):setVisible(false)
    slotView:getChildByPath('rewardBtn'):setVisible(false)
    slotView:getChildByPath('txtLock'):setVisible(false)
    slotView:getChildByPath('bgEmpty'):setVisible(false)
    slotView:getChildByPath('bgNormal'):setVisible(false)
    slotView:getChildByPath('bgLock'):setVisible(false)
    slotView:getChildByPath('bagDone'):setVisible(false)
    slotView:getChildByPath('cake'):setVisible(false)

    local function __onClick( ... )
    	if self.ui.isDisposed then return end

            -- body

        if FifthAnniversaryLogic:isActEnd() then
            CommonTip:showTip(localize('the.activity.has.ended'))
            return
        end

        if slotData.unlocked and (not slotData.isSlotEmpty) and slotData.isCDFinished then
            self:tryOpenLuckyBag(slotIndex)
        elseif slotData.unlocked and (not slotData.isSlotEmpty) and slotData.isInCDing then
            self:showSpeedUpUI(slotIndex)
        elseif slotData.unlocked and (slotData.isSlotEmpty) then
            CommonTip:showTip("还没有蛋糕哦，去闯关获得吧~")
        elseif not slotData.unlocked then
            if not self.canUnlockSlot then return end
            if slotIndex == self.dataMgr:getUnlockedSlotNum() + 1 then
                slotView.btn:dispatchEvent(Event.new(DisplayEvents.kTouchTap))
            else
                CommonTip:showTip("请先解锁前一个烤箱~")
            end
        end
    end

    UIUtils:setTouchHandler(slotView:getChildByPath('bgEmpty'), __onClick)
    UIUtils:setTouchHandler(slotView:getChildByPath('bgNormal'), __onClick)
    UIUtils:setTouchHandler(slotView:getChildByPath('bgLock'), __onClick)

    local speedBtn = slotView:getChildByPath('speedUpBtn')
    local rewardBtn = slotView:getChildByPath('rewardBtn')
    -- UIUtils:setTouchHandler(speedBtn, nil)

    self:stopSlotCountDown(slotView, slotData, slotIndex)

    slotView:getChildByPath('bgLock'):setVisible(not slotData.unlocked)
    slotView:getChildByPath('txtLock'):setVisible(not slotData.unlocked)

    if not slotData.unlocked then
        if slotIndex == self.dataMgr:getUnlockedSlotNum() + 1 then
            local isCanBuy = self:canBuySlot() and self.canUnlockSlot
            buyBtn:setVisible( isCanBuy )
            slotView.btn:setVisible(isCanBuy)
            slotView:getChildByPath('txtLock'):setVisible(not isCanBuy)
        end

    else

        if slotData.isSlotEmpty then
            slotView:getChildByPath('bgEmpty'):setVisible(true)
            slotView:getChildByPath('bgNormal'):setVisible(false)
        else
            slotView.btn:setVisible(true)
            slotView:getChildByPath('bgNormal'):setVisible(true)
            slotView:getChildByPath('multiIcon'):setVisible(true)

            slotView:getChildByPath('multiIcon/2'):setVisible(slotData.multiple == 2)
            slotView:getChildByPath('multiIcon/3'):setVisible(slotData.multiple == 3)
            slotView:getChildByPath('multiIcon/4'):setVisible(slotData.multiple == 4)

            -- printx(61, 'isCDFinished', slotData.isCDFinished, slotData.cdStartTS - Localhost:time(), slotData.cdEndTS - Localhost:time())


            if slotData.isCDFinished then
                slotView:getChildByPath('bagDone'):setVisible(true)
            	slotView:getChildByPath('rewardBtn'):setVisible(true)
            else

                slotView:getChildByPath('time'):setVisible(true)
                slotView:getChildByPath('progress'):setVisible(true)
                speedBtn:setVisible(true)

                -- UIUtils:setTouchHandler(speedBtn, function ( ... )
                    -- self:showSpeedUpUI(slotIndex)
                -- end)

                local context = self
                function slotView:onCountDown()
                    if self.isDisposed then return end
                    if context.ui.isDisposed then return end
                    local rest = slotData.cdEndTS - Localhost:time()
                    rest = math.max(rest, 0)
                    rest = rest/1000
                    local mm = math.floor(rest / 60)
                    local ss = rest % 60
                    UIHelper:setCenterText(self:getChildByPath('time'), string.format('%02d:%02d', mm, ss))
                    local totalDuration = slotData.cdEndTS - slotData.cdStartTS
                    totalDuration = totalDuration / 1000
                    totalDuration = math.max(totalDuration, 0.001)
                    progress:setProgress(math.clamp(rest / totalDuration, 0, 1))

                    if rest <= 0 then
                        context:delay(function ( ... )
                            if self.isDisposed then return end
                            if context.ui.isDisposed then return end
                            context:refresh()
                        end)
                    end

                end
                self:startSlotCountDown(slotView, slotData, slotIndex)
            end
        end
    end

    -- if needStopLightAction then
    --     slotView:getChildByPath('bag/light'):stopAllActions()
    -- end
end



function LuckBagGroupCtrl:tryOpenLuckyBag( slotIndex, successCallback, failCallback )
    if self.ui.isDisposed then return end

    if self._busyMode == true then return end

    local slotData = self.dataMgr:getSlotData(slotIndex)

	PaymentNetworkCheck:getInstance():check(function ( ... )
        self.dataMgr:openLuckBag(slotIndex, function ( ... )
        	if successCallback then successCallback(...) end
        	local rewards = ({...})[1]
        	self.evtDp:dp(Event.new(LuckBagGroupCtrl.EventType.kOpenLuckyBag, {rewards = rewards, slotIndex = slotIndex, multiple = slotData.multiple or 1}, self))
        end, failCallback)
    end, function ( ... )
        -- body
        CommonTip:showNetworkAlert()
        if failCallback then failCallback() end
    end)
end

function LuckBagGroupCtrl:hideAllExceptBag( slotIndex )
	if self.ui.isDisposed then return end

    -- printx(61, 'hideAllExceptBag', slotIndex)

	local slotView = self.ui:getChildByPath(tostring(slotIndex))
	slotView:getChildByPath('time'):setVisible(false)
    slotView:getChildByPath('progress'):setVisible(false)
    slotView:getChildByPath('multiIcon'):setVisible(false)
    slotView:getChildByPath('speedUpBtn'):setVisible(false)
    slotView:getChildByPath('rewardBtn'):setVisible(false)
    slotView:getChildByPath('txtLock'):setVisible(false)
    slotView:getChildByPath('cake'):setVisible(false)
    local buyBtn = slotView.buyBtn
    if buyBtn then
    	buyBtn:setVisible(false)
        slotView.btn:setVisible(false)
    end
    slotView:getChildByPath('bgEmpty'):setVisible(false)
end

function LuckBagGroupCtrl:onSlotCountDown( pausedSlotIndex )
    if self.ui.isDisposed then return end
    for i = 1, FifthAnniversaryMeta.SLOT_NUM do
        local slotIndex = i
        local slotView = self.ui:getChildByPath(tostring(i))
        local slotData = self.dataMgr:getSlotData(slotIndex)
        if slotView.timerRunning then

        	if pausedSlotIndex ~= i then
	            slotView:onCountDown()
	        end
        end
    end
end


function LuckBagGroupCtrl:startSlotCountDown( slotView, slotData, slotIndex)
    if self.ui.isDisposed then return end
    slotView:onCountDown()
    slotView.timerRunning = true
end


function LuckBagGroupCtrl:stopSlotCountDown( slotView, slotData, slotIndex)
    if self.ui.isDisposed then return end
    slotView.timerRunning = false
end


function LuckBagGroupCtrl:showSpeedUpUI( slotIndex )
    if self.ui.isDisposed then return end
    -- if self.dataMgr:howManySpeedUpCardINeed(slotIndex) <= self.dataMgr:getNumOfSpeedUpCard() then
    --     self:showSpeedUpTip(slotIndex)
    -- else
        self:showMoneySpeedUpTip(slotIndex)
    -- end

	local FifthAnniversaryLogic = require 'zoo.localActivity.FifthAnniversary.FifthAnniversaryLogic'
    FifthAnniversaryLogic:dc_when_try_cd(slotIndex)
end

-- function LuckBagGroupCtrl:showSpeedUpTip( slotIndex )
--     if self.ui.isDisposed then return end
--     self:removeSpeedUpTip()
--     local speedUpTip = self:createSpeedUpTip(slotIndex)

--     local speedUpBtn = ButtonIconNumberBase:create(speedUpTip:getChildByPath('btn'))
--     speedUpBtn:setString('加速')
--     speedUpBtn:setNumber(
--     	self.dataMgr:howManySpeedUpCardINeed(slotIndex)
--     )

--     speedUpTip:getChildByPath('label'):setString("使用金币开启福袋")

--     local numLabel = speedUpTip:getChildByPath('num')
--     UIHelper:setLeftText(numLabel, tostring(self.dataMgr:getNumOfSpeedUpCard()))
--     numLabel:setColor(hex2ccc3('CC6600'))

--     speedUpBtn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
--         if self.ui.isDisposed then return end

--         if FifthAnniversaryLogic:isActEnd() then
--             CommonTip:showTip(localize('the.activity.has.ended'))
--             return
--         end

--         self:trySpeedUp(slotIndex)
--         self:removeSpeedUpTip()

--         FifthAnniversaryLogic:dc_when_cd(slotIndex, self.dataMgr:howManySpeedUpCardINeed(slotIndex), 1, self.scene or 1)

--     end))
-- end

function LuckBagGroupCtrl:showMoneySpeedUpTip( slotIndex )
    if self.ui.isDisposed then return end
    self:removeSpeedUpTip()
    local speedUpTip = self:createSpeedUpTip(slotIndex)
    speedUpTip:getChildByPath('label'):setString("使用风车币加速做蛋糕")

    local goodsId = FifthAnniversaryMeta.GoodsId.kSpeedUp
    local num = self.dataMgr:howManySpeedUpCardINeed(slotIndex)
    local buyLogic = BuyLogic:create(goodsId, MoneyType.kGold)
    local price = buyLogic:getPrice() * num
    
    local speedUpBtn = ButtonIconNumberBase:create(speedUpTip:getChildByPath('btn'))
    speedUpBtn:setNumber(price)
    speedUpBtn:setString('加速')
    speedUpBtn:setIconByFrameName'ui_images/ui_image_coin_icon_small0000'
    speedUpBtn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
        if self.ui.isDisposed then return end

        if FifthAnniversaryLogic:isActEnd() then
            CommonTip:showTip(localize('the.activity.has.ended'))
            return
        end
        -- body
        self:trySpeedUp(slotIndex)
        self:removeSpeedUpTip()

        FifthAnniversaryLogic:dc_when_cd(slotIndex, self.dataMgr:howManySpeedUpCardINeed(slotIndex), 2, self.scene or 1)

    end))
end

function LuckBagGroupCtrl:setScene( scene )
	self.scene = scene
end

function LuckBagGroupCtrl:trySpeedUp( slotIndex, successCallback, failCallback)
    if self.ui.isDisposed then return end

    PaymentNetworkCheck:getInstance():check(function ( ... )

        self.dataMgr:trySpeedUp(slotIndex, function ( ... )
        	-- body
        	if successCallback then successCallback(...) end

        	-- CommonTip:showTip('加速成功')

        	-- for i = 1, FifthAnniversaryMeta.SLOT_NUM do
        	-- 	local slotData = self.dataMgr:getSlotData(i)
        	-- 	if (not slotData.isSlotEmpty) and slotData.isInCDing then
        	-- 		self:showSpeedUpUI(i)
        	-- 		break
        	-- 	end
        	-- end

    		self.evtDp:dp(Event.new(LuckBagGroupCtrl.EventType.kSpeedUp, nil, self))

        end, failCallback)
    end, function ( ... )
        -- body
        CommonTip:showNetworkAlert()
        if failCallback then failCallback() end

    end)
end

function LuckBagGroupCtrl:removeSpeedUpTip( ... )
    if self.ui.isDisposed then return end
    -- body
    if self.speedUpTip and (not self.speedUpTip.isDisposed) then
        self.speedUpTip:removeFromParentAndCleanup(true)
    end
    self.speedUpTip = nil
end

function LuckBagGroupCtrl:createSpeedUpTip( slotIndex )
    print("LuckBagGroupCtrl:createSpeedUpTip",slotIndex,debug.traceback())
    if not self.speedUpTip then
        self.speedUpTip = self.tipCreator()
        self.ui:addChild(self.speedUpTip)

        local slotView = self.ui:getChildByPath(string.format('%d', slotIndex))
        local bounds = slotView:getGroupBounds(self.ui)
        local p = ccp(bounds:getMidX(), bounds:getMidY())
        if slotIndex%4 == 1 then
            p.x = p.x+40
            elseif slotIndex%4 == 0 then
            p.x = p.x-60
        end
        self.speedUpTip:setPosition(p)

        self.speedUpTip:setTouchEnabledWithMoveInOut(true)
        self.speedUpTip:ad(DisplayEvents.kTouchBeginOutSide, preventContinuousClick(function ( ... )
            if self.ui.isDisposed then return end
            self:removeSpeedUpTip()
        end))

        self.speedUpTip:runAction(UIHelper:sequence{
            CCDelayTime:create(7),
            CCCallFunc:create(function ( ... )
                if self.ui.isDisposed then return end
                self:removeSpeedUpTip()
            end)
        })
        return self.speedUpTip
    end
end

function LuckBagGroupCtrl:canBuySlot( ... )
	if self._canBuySlot == nil then
		return true
	end
	return self._canBuySlot
end

function LuckBagGroupCtrl:setCanBuySlot( b )
	self._canBuySlot = b
end

return LuckBagGroupCtrl