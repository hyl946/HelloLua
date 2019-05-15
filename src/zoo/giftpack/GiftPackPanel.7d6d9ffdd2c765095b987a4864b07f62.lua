--[[
 * GiftPackPanel
 * @date    2019-01-07 19:39:04
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local GiftPackPanel = class(BasePanel)

local UIHelper = require 'zoo.panel.UIHelper'

function GiftPackPanel:create(goodsId)
	local panel = GiftPackPanel.new()
	panel:loadRequiredResource("ui/GiftPackPanel.json")
    panel:init(goodsId)
    return panel
end

function GiftPackPanel:init(goodsId)
    self.goodsId = goodsId
    self.ui = self:buildInterfaceGroup('GiftPack.Panel/Panel')
    BasePanel.init(self, self.ui)

    self:initView()
end

function GiftPackPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function GiftPackPanel:initView( ... )
    self:initItem()
    self:initCountDown()
    self:showDiscountAction()

    self.closeBtn = self.ui:getChildByPath('close')
    self.closeBtn:setTouchEnabled(true, 0, true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() 
		self:onCloseBtnTapped()
	end)

    local animNode = UIHelper:createArmature3('skeleton/giftpacksun', 
                    'tks/sun', 'tks/sun', 'tks/sun')

    animNode:setPosition(ccp(200, -390))
    animNode:playByIndex(0)
    self.ui:addChild(animNode)

    self.animNode:unscheduleUpdate()
    local scheduleObj = CocosObject:create()
    
    scheduleObj:scheduleUpdateWithPriority(
        function()
            if self.animNode.isDisposed then return end
            self.animNode.refCocosObj:advanceTime(1/58)
        end
        ,1)
    self.animNode:addChild(scheduleObj)
end

function GiftPackPanel:showDiscountAction()
    if self.animNode then
        self.animNode:playByIndex(0)
        return
    end

    local animNode = UIHelper:createArmature3('skeleton/discount', 
                    'tks/discount', 'tks/discount', 'tks/discount')

    animNode:setPosition(ccp(20, -150))
    animNode:playByIndex(0)

    local goodsId = self.goodsId
    local numSlot = animNode:getSlot("num")

    local numnode = Sprite:createEmpty()
    local num = self:getDiscountNum(goodsId)

    local numlabel = BitmapText:create(num, "fnt/18dbsale_disc.fnt", -1, kCCTextAlignmentCenter)
    numlabel:setPosition(ccp(18, -28))
    numlabel:setScaleY(1.2)
    numnode:addChild(numlabel)
    numSlot:setDisplayImage(numnode.refCocosObj, true)

    self.ui:addChildAt(animNode, 2)
    self.animNode = animNode
end

function GiftPackPanel:createIcon( itemInfo )
    local icon
    if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
        icon = ResourceManager:sharedInstance():buildItemSprite(ItemType.INFINITE_ENERGY_BOTTLE)
    else
        icon = ResourceManager:sharedInstance():buildItemSprite(itemInfo.itemId)
    end
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon.itemInfo = itemInfo

    local size = icon:getContentSize()

    local num_str = 'x'..itemInfo.num
    if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
        num_str = itemInfo.num / 60
        if num_str < 1 then
            num_str = itemInfo.num
        end
    end

    local offset = 0
    if itemInfo.itemId == 10087 then
        offset = 10
    end

    local num = BitmapText:create(num_str, 'fnt/18dlsale_item_time.fnt')
    num:setAnchorPoint(ccp(0, 0.5))
    num:setScale(1.3)
    local tx = 65 + offset
    num:setPosition(ccp(tx, size.height/2 - 25))
    icon:addChild(num)

    if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
        local u = '小时'
        if itemInfo.num / 60 < 1 then
            u = '分钟'
        end
        local unit = BitmapText:create(u, 'fnt/18dlsale_item_time.fnt')
        unit:setAnchorPoint(ccp(0, 0.5))
        unit:setScale(0.8)
        local nsize = num:getGroupBounds().size
        unit:setPosition(ccp(tx + nsize.width - 2, size.height/2 - 25))
        icon:addChild(unit)
    end

    if ItemType:isTimeProp(itemInfo.itemId )  then
        local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(itemInfo.itemId)
        icon:addChild(time_prop_flag)
        time_prop_flag:setAnchorPoint(ccp(0.5,0.5))
        local size = icon:getContentSize()
        time_prop_flag:setPosition( ccp( size.width/2, 20 ) )
    end

    icon:setScale(0.6)

    return icon
end

function GiftPackPanel:initItem()
    local goodsId = self.goodsId
    local meta = MetaManager.getInstance():getGoodMeta(goodsId)
    local price = meta.thirdRmb / 100

    local items = {}
    for _,it in ipairs(meta.items) do
       items[_] = {num=it.num, itemId=it.itemId}
    end
    
    table.sort(items, function ( a, b )
        return a.itemId < b.itemId
    end)

    if not self.buyBtn then
        local btn = self.ui:getChildByName('btn')
        self.buyBtn = GroupButtonBase:create(btn)
        self.buyBtn:ad(DisplayEvents.kTouchTap, function ()
            if self.isDisposed then return end
            self.buyBtn:setEnabled(false)
            self:buy()
        end)
        local line = btn:getChildByName('line')
        line:setAnchorPointCenterWhileStayOrigianlPosition()
        line:setPositionY(line:getPositionY() - 5)
        line:setPositionX(line:getPositionX() + 5)
        -- ph:setVisible(false)

        local ph = self.ui:getChildByName('oriph')
        ph:setVisible(false)

        local pos = ph:getPosition()
        local size = btn:getGroupBounds().size
        local op = self:getOriPrice(goodsId)
        local oriPrice = BitmapText:create(string.format("价值￥%.0f", op), 'fnt/2018db_yjz.fnt')
        oriPrice:setPosition(ccp(pos.x+size.width/2-8, pos.y - 20 ))
        oriPrice:setColor(ccc3(255, 204, 153))
        self.ui:addChildAt(oriPrice, line:getZOrder())
        oriPrice:setScale(0.6)

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
            local icon = self:createIcon(itemInfo)
            self.ui:addChildAt(icon, 2)
            icon.itemInfo = itemInfo
            table.insert(icons, icon)
        elseif not self.goldNum then
            local goldnumph = self.ui:getChildByName('goldnumph')
            goldnumph:setVisible(false)
            local size = goldnumph:getGroupBounds().size
            local pos = goldnumph:getPosition()

            local gold_icon = self.ui:getChildByName('gold_icon')
            gold_icon:setAnchorPoint(ccp(0,1))
            local num = BitmapText:create(itemInfo.num, 'fnt/2018db11_small_panel_1.fnt')
            gold_icon:addChild(num)
            num:setAnchorPoint(ccp(0, 0.5))
            num:setScale(0.8)
            num:setPosition(ccp(56 , 26))
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
end

function GiftPackPanel:hideTip( ... )
    if self.ui.isDisposed then return end
    if self.energeTip then
        self.energeTip:setVisible(false)
    end
end

function GiftPackPanel:showTip( icon )
    if not self.energeTip then
        self.energeTip = Sprite:create('tips.png')
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

function GiftPackPanel:layoutIcons(icons )
    local itemsph = self.ui:getChildByName("itemsph")
    itemsph:setVisible(false)
    local itemspos = itemsph:getPosition()
    local itemssize = {width = 177, height = 155}

    local w = 100
    if #icons == 1 then
        icons[1]:setScale(1.2)
        icons[1]:setPosition(ccp(itemspos.x + itemssize.width/2 , itemspos.y - itemssize.height/2 + 5))
    elseif #icons == 2 then
        local y = itemspos.y - itemssize.height/2
        for index,icon in ipairs(icons) do
            icon:setScale(0.7)
        end
        icons[1]:setPosition(ccp((1-1) * w + itemspos.x + 35, y + 14 ))
        icons[2]:setPosition(ccp((2-1) * w + itemspos.x + 20, y + 14 ))
    elseif #icons == 3 then
        local y = itemspos.y - itemssize.height/3
        for count=1,2 do
            local icon = icons[count]
            icon:setScale(0.7)
            icon:setPosition(ccp((count-1) * w + itemspos.x + 30, y + 15))
        end
        icons[1]:setPositionX(icons[1]:getPositionX()+ 8)
        local icon = icons[3]
        icon:setScale(0.7)
        icon:setPosition(ccp(itemspos.x + itemssize.width/2 - 5, y - itemssize.height/3 - 5 ))
    elseif #icons == 4 then
        local y = itemspos.y - itemssize.height/3
        for count,icon in ipairs(icons) do
            icon:setScale(0.7)
            if count <= 2 then
                icon:setPosition(ccp((count-1) * w + itemspos.x + 35, y + 20 ))
            else
                icon:setPosition(ccp((count-3) * w + itemspos.x + 35, y - itemssize.height/3 - 5 ))
            end
        end
        icons[2]:setPositionX(icons[2]:getPositionX() - 5)
        icons[4]:setPositionX(icons[4]:getPositionX() - 5)
    end
end

function GiftPackPanel:initCountDown()
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
            self.lightCd:setText('00:00:00')
        end
        if self.cd then
            self.cd:setText('00:00:00')
        end
    end

    local function runLastAction()
        if self.isDisposed then return end
        if self.cd:numberOfRunningActions() > 0 then return end
        local array = CCArray:create()
        array:addObject(CCCallFunc:create(function ()
        end))
        array:addObject(CCDelayTime:create(0.6))
        array:addObject(CCScaleTo:create(0.2, 1.05))
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
        array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2, 1.05), CCFadeIn:create(0.1))  )
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
        local endTime = math.floor(GiftPack:getPackDeadline(self.goodsId) / 1000)

        local last = endTime - now

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
    local cd = BitmapText:create('1', 'fnt/2018db11_small_panel_2.fnt')
    -- cd:setAnchorPoint(ccp(0, 0.5))
    cd:setPosition(ccp(pos.x + size.width/2 -8, pos.y - size.height / 2 - 8))
    self.cd = cd

    self.lightCd = BitmapText:create('1', 'fnt/2018db11_small_panel_3.fnt')
    -- self.lightCd:setAnchorPoint(ccp(0, 0.5))
    self.lightCd:setPosition(ccp(pos.x + size.width/2 - 8, pos.y - size.height / 2 - 8))
    self.lightCd:setVisible(false)
    update()
    self.ui:addChild(cd)
    self.ui:addChild(self.lightCd)
end

function GiftPackPanel:getDiscountNum( goodsId )
    local discountNum = self:getPrice(goodsId) * 10 / self:getOriPrice(goodsId)
    local num = math.ceil(discountNum)
    local distance = num - discountNum
    return distance > 0.5 and math.floor(discountNum) or num
end

function GiftPackPanel:getPrice(goodsId)
    return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb / 100
end

function GiftPackPanel:getOriPrice(goodsId)
    return MetaManager.getInstance():getGoodMeta(goodsId).rmb / 100
end

function GiftPackPanel:buy()
    local goodsId = self.goodsId

    local function dc( dcInfo )
        dcInfo = dcInfo or {}
        dcInfo.list_id = goodsId
        GiftPack:dc('buy', 'pay_stage_mainpanel', dcInfo)
    end

    local function onSuccess(dcInfo)
        self:onBuySuccess()
        dc( dcInfo )
        if self.isDisposed then return end
        self.buyBtn:setEnabled(false)
    end

    local function onFail(dcInfo)
        dc( dcInfo )
        if self.isDisposed then return end
        self.buyBtn:setEnabled(true)
    end

    local function onCancel(dcInfo)
        dc( dcInfo )
        if self.isDisposed then return end
        self.buyBtn:setEnabled(true)
    end

    GiftPack:buy( goodsId, onSuccess, onFail, onCancel )
end

function GiftPackPanel:onBuyFinished()
    if not self.isDisposed then
        self:onCloseBtnTapped()
    end

    GiftPack:removeHomeIcon( self.goodsId )
end

function GiftPackPanel:onBuySuccess()
    local goodsId = self.goodsId

    if self.isDisposed then return end

    local meta = MetaManager.getInstance():getGoodMeta(goodsId)

    local bottle = table.find(meta.items, function (item)
        return item.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
    end)

    local flyCount = 0
    local flymax = #self.icons
    local function finished()
        flyCount = flyCount + 1

        if flyCount >= flymax then
            if bottle then
                GiftPack:showEnergyAlert(bottle.num, function ()
                    self:onBuyFinished()
                end)
            else
                self:onBuyFinished()
            end
        end
    end

    local function fly( icon )
        local itemInfo = icon.itemInfo
        if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
            itemInfo = {itemId = itemInfo.itemId, num = 1}
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

function GiftPackPanel:refreshItems()
    if self.isDisposed then return end

    for index=1,3 do
        self:createItem(index)
    end
end

function GiftPackPanel:popoutShowTransition( ... )
    self.allowBackKeyTap = true
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
end

function GiftPackPanel:popout()
    self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)
    self:popoutShowTransition()
end

return GiftPackPanel
