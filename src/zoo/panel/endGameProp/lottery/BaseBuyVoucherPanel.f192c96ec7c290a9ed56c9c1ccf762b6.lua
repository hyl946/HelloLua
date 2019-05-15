local NodeGroupControl = require('zoo.panel.endGameProp.lottery.NodeGroupControl')
local HShrinkCon = require('zoo.panel.endGameProp.lottery.HShrinkCon')
local CenterCon = require('zoo.panel.endGameProp.lottery.CenterCon')

local UIHelper = require 'zoo.panel.UIHelper'

local BaseBuyVoucherPanel = class(BasePanel)

function BaseBuyVoucherPanel:create()
    local panel = BaseBuyVoucherPanel.new()
    panel:init()
    return panel
end

function BaseBuyVoucherPanel:getGoodsId( ... )
	return 600
end

function BaseBuyVoucherPanel:init()

	self.countLimits = 2

    local ui = UIHelper:createUI("ui/lottery.json", "add.step.lottery/buy_voucher")
	BasePanel.init(self, ui)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    local goodsId = self:getGoodsId()
    local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
    local price = self:getCashPrice(goodsId)
    local goodsItems = goodsMeta.items
    self.goodsMeta = goodsMeta

    local coinItem = table.find(goodsItems, function ( v )
    	return v.itemId == ItemType.COIN
    end)

    local voucherItem = table.find(goodsItems, function ( v )
    	return v.itemId == ItemType.VOUCHER
    end)

    self.voucherItem = voucherItem
    self.coinItem = coinItem

    UIHelper:setCenterText(self.ui:getChildByPath('content/num_1'), tostring(coinItem.num), 'fnt/discount_limited_time.fnt')
    UIHelper:setCenterText(self.ui:getChildByPath('content/num_2'), tostring(voucherItem.num), 'fnt/discount_limited_time.fnt')

    local voucherIcon = ResourceManager:sharedInstance():buildItemSprite(ItemType.VOUCHER)
    local bubble_2 = self.ui:getChildByPath('content/bubble_2')
    bubble_2:addChild(voucherIcon)
    voucherIcon:setPositionXY(bubble_2:getContentSize().width/2 - 9, bubble_2:getContentSize().height/2+7)
    voucherIcon:setAnchorPoint(ccp(0.5, 0.5))
    voucherIcon:setScale(1.2)

    self.minusBtn = self.ui:getChildByPath('content/minus')
    self.plusBtn = self.ui:getChildByPath('content/plus')
    self.buyCountLabel = self.ui:getChildByPath('content/buy_count')
    self.buyCount = 1

    UIUtils:setTouchHandler(self.minusBtn, function ( ... )
    	if self.isDisposed then return end
    	if self.buyCount > 1 then
	    	self.buyCount = math.clamp(self.buyCount - 1, 1, self.countLimits)
	    	self:refreshBuyCount()
    		self:onBuyCountChange(self.buyCount)
	    end
    end, nil, 0.1)

    UIUtils:setTouchHandler(self.plusBtn, function ( ... )
    	if self.isDisposed then return end
    	if self.buyCount < self.countLimits then
	    	self.buyCount = math.clamp(self.buyCount + 1, 1, self.countLimits)
	    	self:refreshBuyCount()
    		self:onBuyCountChange(self.buyCount)

	    end
    end, nil, 0.1)

    local sum_icon_1 = self.ui:getChildByPath('content/sum_icon_1')
    local sum_icon_2 = self.ui:getChildByPath('content/sum_icon_2')

    local function _set_sum_icon( holder, sp )
    	holder:setVisible(false)
    	local parent = holder:getParent()
    	local index = parent:getChildIndex(holder)
    	parent:addChildAt(sp, index)
    	sp:setAnchorPoint(ccp(0.5, 0.5))
    	local bounds = holder:getGroupBounds(parent)
    	local pos = ccp(bounds:getMidX(), bounds:getMidY())
    	sp:setPosition(pos)

    	local sx = bounds.size.width / sp:getContentSize().width
    	sp:setScale(sx)
    end

    local tmp = ResourceManager:sharedInstance():buildGroup("itemIcon2")
    local sp = tmp:getChildByPath('sprite')
    sp:removeFromParentAndCleanup(false)
    tmp:dispose()
    tmp = nil


    _set_sum_icon(sum_icon_1, sp)
    _set_sum_icon(sum_icon_2, ResourceManager:sharedInstance():buildItemSprite(ItemType.VOUCHER))

    self.sum_1 = self.ui:getChildByPath('content/sum_1')
    self.sum_2 = self.ui:getChildByPath('content/sum_2')


    self:refreshBuyCount()



    --
    local money_bar_icon = self.ui:getChildByPath('content/money_bar/icon')
    local money_bar_num = self.ui:getChildByPath('content/money_bar/num')
    local money_bar_desc = self.ui:getChildByPath('content/money_bar/desc')
    money_bar_num:setDimensions(CCSizeMake(0, 0))
    money_bar_desc:setDimensions(CCSizeMake(0, 0))

    money_bar_icon:removeFromParentAndCleanup(false)
    money_bar_num:removeFromParentAndCleanup(false)
    money_bar_desc:removeFromParentAndCleanup(false)

    money_bar_icon = NodeGroupControl:create(money_bar_icon)
    money_bar_num = NodeGroupControl:create(money_bar_num)
    money_bar_desc = NodeGroupControl:create(money_bar_desc)


    local money_bar_holder = self.ui:getChildByPath('content/money_bar_holder')
    money_bar_holder:setVisible(false)
    local centerCon = CenterCon:create(money_bar_holder)


    local hshrinkCon = HShrinkCon:create()
    hshrinkCon:addChild(money_bar_desc)
    hshrinkCon:addChild(money_bar_icon)
    hshrinkCon:addChild(money_bar_num)

    money_bar_desc:getNode():setString('您拥有: ')
    money_bar_desc:_notify_content_change()

    centerCon:addChild(hshrinkCon)
    self.ui:getChildByPath('content'):addChild(centerCon)
    self.money_bar = centerCon
    self.money_bar_num = money_bar_num

    self:refreshGoldCash()
    --

    
end

function BaseBuyVoucherPanel:refreshGoldCash( ... )
	if self.isDisposed then return end
	local cash = UserManager:getInstance().user:getCash()
	self.money_bar_num:getNode():setString(' ' .. tostring(cash))
	self.money_bar_num:_notify_content_change()
end

function BaseBuyVoucherPanel:refreshBuyCount( ... )
	if self.isDisposed then return end
    UIHelper:setCenterText(self.buyCountLabel, tostring(self.buyCount), 'fnt/discount_limited_time.fnt')
    if self.buyCount <= 1 then
    	self.minusBtn:applyAdjustColorShader()
		self.minusBtn:adjustColor(0,-1, 0, 0)
    else
    	self.minusBtn:clearAdjustColorShader()
    end

    if self.buyCount >= self.countLimits then
    	self.plusBtn:applyAdjustColorShader()
		self.plusBtn:adjustColor(0,-1, 0, 0)
    else
    	self.plusBtn:clearAdjustColorShader()
    end

    UIHelper:setLeftText(self.sum_1, tostring(self.coinItem.num * self.buyCount), 'fnt/addfriend4.fnt')
    UIHelper:setLeftText(self.sum_2, tostring(self.voucherItem.num * self.buyCount), 'fnt/addfriend4.fnt')

end

function BaseBuyVoucherPanel:onBuyCountChange( ... )
	-- body
end

function BaseBuyVoucherPanel:getCashPrice( goodsId )
	-- body
	local goodsData = MarketManager:getGoodsById(goodsId)
	if goodsData and goodsData.currentPrice then
		return goodsData.currentPrice
	else
		return 0
	end
end

function BaseBuyVoucherPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function BaseBuyVoucherPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)
	self.allowBackKeyTap = true
	self:popoutShowTransition()
end

function BaseBuyVoucherPanel:popoutShowTransition( ... )
	if self.isDisposed then return end
	local LotteryLogic = require 'zoo.panel.endGameProp.lottery.LotteryLogic'
    local neededVoucherNum = LotteryLogic:getNeededVoucherNum()
    local singleGoodsVoucherNum = self.voucherItem.num
    local neededBuyCount = math.ceil(neededVoucherNum / singleGoodsVoucherNum)
    self.buyCount = math.clamp(neededBuyCount, 1, self.countLimits)
	self:refreshBuyCount()
	self:onBuyCountChange(self.buyCount)
end

function BaseBuyVoucherPanel:getBuyCount( ... )
	return self.buyCount
end

function BaseBuyVoucherPanel:onCloseBtnTapped( ... )
    self:_close()
end

function BaseBuyVoucherPanel:onBuySuccess( ... )
	if self.onBuySuccessCallback then
		self.onBuySuccessCallback()
	end
	-- 名字虽然是diamonds 但含义是 转盘的消耗物, voucher 也适用
	require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):update()
end

function BaseBuyVoucherPanel:setBuyCallback( callback )
	self.onBuySuccessCallback = callback
end

return BaseBuyVoucherPanel
