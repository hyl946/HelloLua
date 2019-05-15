--[[
 * DoubleEEndgamePanel
 * @date    2018-10-25 17:51:53
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local DoubleEEndgamePanel = class(BasePanel)

function DoubleEEndgamePanel:create( goodsId, isDouble11, closeCallBack)
	local panel = DoubleEEndgamePanel.new()
	panel:loadRequiredResource("tempFunctionRes/Double11/EndgamePanel.json")
	panel:init(goodsId, isDouble11, closeCallBack)
	return panel
end

function DoubleEEndgamePanel:hideTip( ... )
    if self.ui.isDisposed then return end
    if self.energeTip then
        self.energeTip:setVisible(false)
    end

    if self.tipId then
        cancelTimeOut(self.tipId)
        self.tipId = nil
    end
end

function DoubleEEndgamePanel:showTip( icon )
    if not self.energeTip then
        self.energeTip = Sprite:create("tempFunctionRes/Double11/tips.png")
        self.ui:addChild(self.energeTip)
    end

    local pos = icon:getPosition()
    pos = icon:getParent():convertToWorldSpace(pos)
    pos = self.ui:convertToNodeSpace(pos)
    self.energeTip:setPosition(ccp(pos.x + 70, pos.y + 70))

    if self.tipId then
        cancelTimeOut(self.tipId)
        self.tipId = nil
    end

    self.tipId = setTimeOut(function ( ... )
        self:hideTip()
    end, 3)
    self.energeTip:setVisible(true)
end

function DoubleEEndgamePanel:init( goodsId, isDouble11, closeCallBack)
	self.goodsId = goodsId
	self.closeCallBackFunc = closeCallBack
    self.isDouble11 = isDouble11

	self.ui = self:buildInterfaceGroup("Double112018/endgame")
	BasePanel.init(self, self.ui)

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
    local price = meta.thirdRmb / 100

    local items = {}
    for _,it in ipairs(meta.items) do
       items[_] = {num=it.num, itemId=it.itemId}
    end
    
    table.sort(items, function ( a, b )
        return a.itemId < b.itemId
    end)

    self:setDiscount()
    self.ui:getChildByName('xiangou'):setVisible(meta.limit > 0)

    if not self.buyBtn then
        local btn = self.ui:getChildByName('btn')
        self.buyBtn = GroupButtonBase:create(btn)
        self.buyBtn:ad(DisplayEvents.kTouchTap, function ()
            if self.isDisposed then return end
            self.buyBtn:setEnabled(false)

            self:buy()

            setTimeOut(function ( ... )
                if self.isDisposed then return end
                self.buyBtn:setEnabled(true)
            end, 3)
        end)
        local ph = btn:getChildByName('line')
        ph:setAnchorPointCenterWhileStayOrigianlPosition()
        ph:setPositionY(ph:getPositionY() - 10)
        ph:setScale(0.7)
        ph:setVisible(false)
        local pos = ph:getPosition()
        local size = ph:getGroupBounds().size
        local op = self:getOriPrice(goodsId)
        local oriPrice = BitmapText:create(string.format("价值￥%.0f", op), 'tempFunctionRes/Double11/fnt/2018db_yjz.fnt')
        oriPrice:setPosition(ccp(pos.x, pos.y))
        oriPrice:setColor(ccc3(188, 219, 252))
        btn:addChildAt(oriPrice, 1)
        oriPrice:setScale(0.4)

        btn.oriPrice = oriPrice
    end

    local buyConfig = {}

    local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(buyConfig.priceLocale or 'cny')
    local showPrice = buyConfig.iapPrice or price

    if isLongSymbol then 
        self.buyBtn:setString(string.format("%s%.0f", currencySymbol, showPrice))
    else
        self.buyBtn:setString(string.format("%s%.2f", currencySymbol, showPrice))
    end

    if self.icons then
        for _,icon in ipairs(self.icons) do
            icon:removeFromParentAndCleanup(true)
        end
    end

    local icons = {}
    self.icons = icons

    local goldNumS = 0
    for _,itemInfo in ipairs(items) do
        if itemInfo.itemId == 14 then
            goldNumS = itemInfo.num
        end
        if itemInfo.itemId ~= 14 then
            local icon = self:getItemSprite( itemInfo.itemId, true , false )
            icon:setAnchorPoint(ccp(0.5, 0.5))
            self.ui:addChildAt(icon, 3)

            local size = icon:getGroupBounds().size

            local numstr = 'x'..itemInfo.num
            if itemInfo.itemId == 10098 then
                local hours = itemInfo.num / 60
                numstr = hours
            end
            local num = BitmapText:create(numstr, 'fnt/register2.fnt')
            num:setColor((ccc3(188, 219, 252)))
            num:setAnchorPoint(ccp(0, 0.5))
            num:setScale(1.3)
            num:setPosition(ccp(size.width, size.height/2))
            icon:addChild(num)

            local size = icon:getGroupBounds().size

            if itemInfo.itemId == 10098 then
                local hours = itemInfo.num / 60
                if hours - math.floor(hours) > 0 then
                    icon.extra = true
                end

                local offset = -10
                if hours>9 then offset = -6 end

                num:setPositionX(num:getPositionX() - 8)
                local unit = BitmapText:create('小时', 'fnt/register2.fnt')
                unit:setColor((ccc3(188, 219, 252)))
                unit:setAnchorPoint(ccp(0, 0.5))
                unit:setScale(0.9)
                unit:setPosition(ccp(size.width + offset, 50))
                icon:addChild(unit)

                local w = unit:getContentSize().width
                local touchLayer = LayerColor:createWithColor(ccc3(255,0,0), size.width + w, size.height)
                touchLayer:setPosition(ccp(0, 0))
                touchLayer:setTouchEnabled(true)
                local function onTap() 
                    self:showTip(icon)
                end
                touchLayer:addEventListener(DisplayEvents.kTouchTap, onTap)
                touchLayer:setOpacity(0)
                icon:addChild(touchLayer)
            end

            icon.itemInfo = itemInfo
            table.insert(icons, icon)
        elseif not self.goldNum then
            local goldnumph = self.ui:getChildByName('goldnumph')
            goldnumph:setVisible(false)
            local size = goldnumph:getGroupBounds().size
            local pos = goldnumph:getPosition()

            local gold_icon = self.ui:getChildByName('gold_icon')
            gold_icon:setAnchorPoint(ccp(0,1))
            local num = BitmapText:create(itemInfo.num, 'tempFunctionRes/Double11/fnt/2018db11_5s_coin.fnt')
            gold_icon:addChild(num)
            num:setAnchorPoint(ccp(0, 0.5))
            num:setScale(0.8)
            num:setPosition(ccp(40 , 20))
            local insize = gold_icon:getGroupBounds().size

            num.itemInfo = itemInfo
            gold_icon:setPositionX(pos.x + size.width/2 - insize.width/2)
            self.goldNum = num
        end
    end
    local goldCat = {0,100,500,1000}
    for level=1,4 do
        local target = goldCat[level] or 100000000
        self.ui:getChildByPath('gold/gold'..level):setVisible(goldNumS >= target)
    end

    self:layoutIcons(icons)
    self:initCountDown()
end

function DoubleEEndgamePanel:buy()
    local function onSuccess()
        self:onBuySuccess()
    end

    local function onFail()
        -- body
    end

    local function onCancel()
        -- body
    end

    DoubleOneOneModel:buy( self.goodsId, onSuccess, onFail, onCancel )
end

function DoubleEEndgamePanel:onBuyFinished( ... )
	local meta = MetaManager.getInstance():getGoodMeta(self.goodsId)

	local has5step = false
	for _,item in ipairs(meta.items) do
		if item.itemId == ItemType.ADD_FIVE_STEP or item.itemId == ItemType.TIMELIMIT_ADD_FIVE_STEP then
			has5step = true break
		end
	end

    Notify:dispatch('CloseDouble112018EndgamePanelEvent')

	if self.closeCallBackFunc then
        if __IOS then
            has5step = true
        end
		self.closeCallBackFunc(has5step)
	end
end

function DoubleEEndgamePanel:onBuySuccess()
    local goodsId = self.goodsId
    DoubleOneOneModel:onBuySuccess( goodsId )

    if self.isDisposed then return end

    local flyCount = 0
    local flymax = #self.icons
    local function finished()
        flyCount = flyCount + 1

        if flyCount >= flymax then
            self:onBuyFinished()
        end
    end

    local meta = MetaManager.getInstance():getGoodMeta(goodsId)
    local function fly( icon )
        local itemInfo = icon.itemInfo
        if itemInfo.itemId == 10098 then
            itemInfo.num = 1
        end
        local anim = FlyItemsAnimation:create({itemInfo})
        local pos = icon:getPosition()
        pos = icon:getParent():convertToWorldSpace(pos)
        local bounds = icon:getGroupBounds()
        anim:setWorldPosition(ccp(pos.x, pos.y))
        anim:setScaleX(icon:getScaleX())
        anim:setScaleY(icon:getScaleY())
        anim:setFinishCallback(finished)
        anim:play()
    end

    for k, icon in ipairs(self.icons) do
        if icon.itemInfo.itemId ~= 10098 then
            fly(icon)
        else
            flymax = flymax - 1
        end
    end

    for _,info in ipairs(meta.items) do
        if info.itemId == 14 then
            flymax = flymax + 1
            fly(self.goldNum)
            break
        end
    end

    BuyObserver:sharedInstance():onBuySuccess()
end

function DoubleEEndgamePanel:initCountDown()
    local cdph = self.ui:getChildByName('cdph')
    cdph:setVisible(false)
    local pos = cdph:getPosition()
    local size  = cdph:getGroupBounds().size

    local function closeCd()
        if self.cdId then
            Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.cdId)
            self.cdId = nil
        end
        if self.isDisposed then return end
        if self.lightCd then
            self.lightCd:removeFromParentAndCleanup(true)
            self.lightCd = nil
        end
        if self.cd then
            self.cd:removeFromParentAndCleanup(true)
            self.cd = nil
        end
    end

    local function runLastAction()
        if self.isDisposed then return end
        if not self.cd or not self.lightCd or self.cd:numberOfRunningActions() > 0 then return end
        local array = CCArray:create()
        array:addObject(CCCallFunc:create(function ()
        end))
        array:addObject(CCDelayTime:create(0.6))
        array:addObject(CCScaleTo:create(0.2, 1))
        array:addObject(CCDelayTime:create(0.1))
        array:addObject(CCScaleTo:create(0.2, 1))

        local action = CCSequence:create(array)

        self.cd:runAction(CCRepeatForever:create(action))

        local array = CCArray:create()
        array:addObject(CCCallFunc:create(function ()
            self.lightCd:setVisible(false)
        end))
        array:addObject(CCDelayTime:create(0.6))
        array:addObject(CCCallFunc:create(function ()
            self.lightCd:setVisible(true)
            self.lightCd:setOpacity(0)
        end))
        array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2, 1), CCFadeIn:create(0.1))  )
        array:addObject(CCDelayTime:create(0.1))
        array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2, 1), CCFadeOut:create(0.1)))

        local action = CCSequence:create(array)

        self.lightCd:runAction(CCRepeatForever:create(action))
    end

    local function update()
        if self.isDisposed then
            closeCd()
            return
        end
        local now = Localhost:timeInSec()
        local endTime = math.floor(DoubleOneOneModel:getEndTime(self.isDouble11 and 3014 or 3015) / 1000)

        local last = endTime - now
        self.ui:getChildByName('last'):setVisible(last <= 0)
        self.ui:getChildByName('title'):setVisible(last > 0)
        if last <= 0 then
            last = 0
            closeCd()
        elseif last < 60*5 then
            runLastAction()
        end
        local time = convertSecondToHHMMSSFormat(last)
        if self.cd then self.cd:setText(time) end
        if self.lightCd then self.lightCd:setText(time) end
    end

    self.cdId = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)
    local cd = BitmapText:create('1', 'tempFunctionRes/Double11/fnt/2018db11_a5s_time.fnt')
    cd:setPosition(ccp(pos.x + size.width/2, pos.y - size.height / 2 - 5))
    self.cd = cd

    self.lightCd = BitmapText:create('1', 'tempFunctionRes/Double11/fnt/2018db11_a5s_time2.fnt')
    self.lightCd:setPosition(ccp(pos.x + size.width/2, pos.y - size.height / 2 - 5))
    self.lightCd:setVisible(false)
    update()
    self.ui:addChild(cd)
    self.ui:addChild(self.lightCd)
end

function DoubleEEndgamePanel:layoutIcons(icons )
    local itemsph = self.ui:getChildByName("itemsph")
    itemsph:setVisible(false)
    local itemspos = itemsph:getPosition()
    local itemssize = {width = 159.75, height = 103.5}

    local w = 100
    if #icons == 1 then
        icons[1]:setScale(0.6)
        icons[1]:setPosition(ccp(itemspos.x + itemssize.width/2 , itemspos.y - itemssize.height/2 - 5))
    elseif #icons == 2 then
        local y = itemspos.y - itemssize.height/2
        local has = false
        for index,icon in ipairs(icons) do
            icon:setScale(0.5)
            if icon.extra then
                has = true
            end
        end

        local ox = 0
        if has then
            ox = - 10
        end
        icons[1]:setPosition(ccp((1-1) * w + itemspos.x + 40 + ox, y  ))
        icons[2]:setPosition(ccp((2-1) * w + itemspos.x + 20 + ox, y  ))
    elseif #icons == 3 then
        local y = itemspos.y - itemssize.height/3
        w = w -5
        for count=1,2 do
            local icon = icons[count]
            icon:setScale(0.5)
            icon:setPosition(ccp((count-1) * w + itemspos.x + 35, y))
        end
        icons[1]:setPositionX(icons[1]:getPositionX()+ 8)
        local icon = icons[3]
        icon:setScale(0.5)
        icon:setPosition(ccp(itemspos.x + itemssize.width/2 - 10, y - itemssize.height/3 -10 ))
    elseif #icons == 4 then
        local y = itemspos.y - itemssize.height/3
        for count,icon in ipairs(icons) do
            icon:setScale(0.47)
            if count <= 2 then
                icon:setPosition(ccp((count-1) * w + itemspos.x + 35 + 5, y + 5 ))
            else
                icon:setPosition(ccp((count-3) * w + itemspos.x + 30 + 5, y - itemssize.height/3 - 10 ))
            end
        end
        icons[2]:setPositionX(icons[2]:getPositionX() - 15)
        icons[4]:setPositionX(icons[4]:getPositionX() - 15)
    end
end

function DoubleEEndgamePanel:getItemSprite( itemId, isSmallIcon , addTimelimitIcon )

    local ret = nil

    if itemId == 50016 then
        itemId = 10066
    end

    if ItemType:isTimeProp(itemId) then
        itemId = ItemType:getRealIdByTimePropId(itemId)
    end

    if itemId == 10098 then
        itemId = 10039
    end

    local ret = ResourceManager:sharedInstance():buildItemSprite(itemId)

    if not ret then
        ret = Sprite:createEmpty()
        ret:addChild(TextField:create('没有素材shit', nil, 48))
    end
    if _G.isLocalDevelopMode  then printx(100 , "Misc getItemSprite done itemId = ",itemId ) end
    return ret
end

function DoubleEEndgamePanel:getDiscountNum( goodsId )
    local discountNum = self:getPrice(goodsId) * 10 / self:getOriPrice(goodsId)
    local num = math.ceil(discountNum)
    local distance = num - discountNum
    return distance > 0.5 and math.floor(discountNum) or num
end

function DoubleEEndgamePanel:getPrice(goodsId)
    return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb / 100
end

function DoubleEEndgamePanel:getOriPrice(goodsId)
    return MetaManager.getInstance():getGoodMeta(goodsId).rmb / 100
end

function DoubleEEndgamePanel:setDiscount()
    local goodsId = self.goodsId
    local discountNum = self:getDiscountNum(goodsId)

    if not self.discountUI then
        local discountContainerUI = self.ui:getChildByName('btn'):getChildByName('discount')
        local discountUI = discountContainerUI:getChildByName('discount')

        self.discountUI = discountUI
        self.discountContainerUI = discountContainerUI

        self.playDiscountAnim = function ()
            if self.isDisposed then return end
            local array = CCArray:create()
            array:addObject(CCRotateTo:create(2/24.0, -9.2))
            array:addObject(CCRotateTo:create(3/24.0, 14.7))
            array:addObject(CCRotateTo:create(2/24.0, -11.2))
            array:addObject(CCRotateTo:create(2/24.0, 0))
            array:addObject(CCDelayTime:create(65/24.0))
            local scaleAction = CCSequence:create(array)
            self.discountContainerUI:runAction(CCRepeatForever:create(scaleAction))
        end

        self:playDiscountAnim()
    end

    if discountNum == 10 then
        self.discountUI:setVisible(false)
    else
        local discountNumUI = self.discountUI:getChildByName("num")
        discountNumUI:setText(discountNum)
        discountNumUI:setScale(2.5)
        local discountTextUI = self.discountUI:getChildByName("text")
        discountTextUI:setScale(1.7)
        discountTextUI:setText(Localization:getInstance():getText("buy.gold.panel.discount"))

        if discountNum == 1 then
            discountNumUI:setPositionX(discountNumUI:getPositionX() + 10)
        end
    end
end

function DoubleEEndgamePanel:popout()
	PopoutManager:sharedInstance():add(self, false, true)

	local size = self:getGroupBounds().size
	self:setContentSize(CCSizeMake(size.width, size.height))
	self:setAnchorPoint(ccp(0.5, -0.5))
	self:ignoreAnchorPointForPosition(false)

	local winSize = CCDirector:sharedDirector():getVisibleSize()

	local offset = 0
	if winSize.height > 1330 then
		offset = 45
	end

	self:setPosition(ccp(winSize.width / 2, -winSize.height + size.height/2 + offset))
	self:setScale(0.2)
	
    self:runAction(CCScaleTo:create(0.2, 1))
end

function DoubleEEndgamePanel:remove()
    if self.isBottomAD then
        self:removeFromParentAndCleanup(true)
    else
    	PopoutManager:sharedInstance():remove(self)
    end
end

return DoubleEEndgamePanel