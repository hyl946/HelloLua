--[[
 * GiftPackEndgamePanel
 * @date    2019-01-07 14:11:18
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local GiftPackEndgamePanel = class(BasePanel)

function GiftPackEndgamePanel:create( goodsId, closeCallBack)
	local panel = GiftPackEndgamePanel.new()
	panel:loadRequiredResource("ui/GiftPackEndGamePanel.json")
	panel:init(goodsId, closeCallBack)
	return panel
end

function GiftPackEndgamePanel:hideTip( ... )
    if self.ui.isDisposed then return end
    if self.energeTip then
        self.energeTip:setVisible(false)
    end

    if self.tipId then
        cancelTimeOut(self.tipId)
        self.tipId = nil
    end
end

function GiftPackEndgamePanel:showTip( icon )
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

function GiftPackEndgamePanel:init( goodsId, closeCallBack)
	self.goodsId = goodsId
	self.closeCallBackFunc = closeCallBack

	self.infos = GiftPack:getGoodsInfo(goodsId)

	local config = self.infos.config
	local info = self.infos.info

	local mgr = PromotionManager:getInstance()

	if mgr:isInPromotion() and mgr:getGoodsId() == goodsId then
		self:createPromotion()
	elseif not config then
		self:createWindmill()
	elseif config.reward then
		self:createNewerOne(goodsId, config.reward)
	else
		self:createNormal(goodsId)
	end

	BasePanel.init(self, self.ui)

	if config then
		local function GetTime()
			return info.expTime or 0
		end
    	self:initCountDown(GetTime)
    end
end

function GiftPackEndgamePanel:getPromotionConfig()
	local promotionMgr = PromotionManager:getInstance()
	local promotion = promotionMgr:getPromotionInfo()
	local config = {
			time = promotionMgr:getRestTime(),
			goodsId = promotionMgr:getGoodsId(),
			productId = promotionMgr:getProductId(),
			id = promotionMgr:getPromotionId()
	}

	if __IOS then
		local metaMgr = MetaManager:getInstance()
		local productMeta = metaMgr:getProductMetaByID(config.id)
		config.iapPrice = promotionMgr:getLocalePriceByProductId(productMeta.productId)
		config.priceLocale = promotionMgr:getLocaleByProductId(productMeta.productId)
	end
	return config
end

function GiftPackEndgamePanel:createPromotion()
	local goodsId = self.goodsId
	self.ui = self:buildInterfaceGroup("GiftPack.EndGame/endgame_promotion")
	self.isPromotion = true
	self:setDiscount(goodsId)

	local function GetTime()
		if __WIN32 then return Localhost:time() + 10000000 end
		return PromotionManager:getInstance():getDeadline() * 1000
	end
	self:initCountDown(GetTime)

	self.icons = {}

	self.goldicon = self.ui:getChildByName('gold')
	self.goldicon:setVisible(false)
	self.goldicon.goodsId = goodsId

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local price = meta.thirdRmb / 100
	local ori_price = meta.rmb / 100

	self.goldicon.itemInfo = meta.items[1]

	local btnui = self.ui:getChildByName('btn')
	local btn = GroupButtonBase:createNewStyle( btnui )
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:buy(btn)
    	btn:setEnabled(false)
    end)
    btn:setString(string.format('￥%0.2f', price))
    btn:setColorMode(kGroupButtonColorMode.blue)

    self.ui:getChildByName('jiazhi'):setString('价值:')
    self.ui:getChildByName('ori'):setString(string.format('￥%0.2f', ori_price))
end

function GiftPackEndgamePanel:buyWindmill( config )
	local index = config.id
	self.goodsId = index
	local function onSuccess()
		local user = UserManager:getInstance().user
		local serv = UserService:getInstance().user
		local oldCash = user:getCash()
		local newCash = oldCash + config.cash;
		user:setCash(newCash)
		serv:setCash(newCash)

		local userExtend = UserManager:getInstance().userExtend
		if type(userExtend) == "table" then userExtend.payUser = true end
		if __IOS or __WIN32 then
			UserManager:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())
			UserService:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())
		end

		local priceInFen = 0
		if __WP8 or __ANDROID then
			priceInFen = config.rmb
		else
			priceInFen = config.price and config.price  * 100 or 0
		end		

		local level = nil
		if GameBoardLogic:getInstance() then
			level = GameBoardLogic:getInstance().level
		end

		if not __ANDROID then -- android consumeCurrency点在IngamePaymentLogic:deliverItems()里面打点了
			GainAndConsumeMgr.getInstance():consumeCurrency(DcFeatureType.kStore, DcDataCurrencyType.kRmb, priceInFen, 
											10000 + index, 1, level, nil, DcSourceType.kStoreBuyGold)
		end
		GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStore, ItemType.GOLD, config.cash, DcSourceType.kStoreBuyGold, level, nil, DcPayType.kRmb, priceInFen, index)

		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
		if successCallback then
			successCallback()
		end

		if __IOS or __WIN32 then 
			GlobalEventDispatcher:getInstance():dispatchEvent(
				Event.new(kGlobalEvents.kConsumeComplete,{
					price=config.price,
					props=Localization:getInstance():getText("consume.history.panel.gold.text",{n=config.cash}),
					goodsId=index,
					goodsType=2,
				})
			)
		end

		self:onBuySuccess()
	end
	local function onFail(errCode, errMsg, noTip)
		if failCallback then
			failCallback(errCode, errMsg, noTip)
		end
	end
	local function onCancel(ignoreTip)
		if not ignoreTip then 
			CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative", nil, 2)
		end
		if cancelCallback then
			cancelCallback()
		end
	end
	if __IOS then -- IOS
		local dcIosInfo = DCIosRmbObject:create()
	    dcIosInfo:setGoodsId(config.productIdentifier)
	    dcIosInfo:setGoodsType(2)
	    dcIosInfo:setGoodsNum(1)
	    dcIosInfo:setRmbPrice(config.iapPrice)
	    PaymentIosDCUtil.getInstance():setIosRmbPayStart(dcIosInfo)

		local peDispatcher = PaymentEventDispatcher.new()
		local function successDcFunc(evt)
			dcIosInfo:setResult(IosRmbPayResult.kSuccess)
        	PaymentIosDCUtil.getInstance():sendIosRmbPayEnd(dcIosInfo)
		end
		local function failedDcFunc(evt)
			local data = evt.data
			local errCode = data.errCode
			local errMsg = data.errMsg
			dcIosInfo:setResult(IosRmbPayResult.kSdkFail, errCode, errMsg)
        	PaymentIosDCUtil.getInstance():sendIosRmbPayEnd(dcIosInfo)
		end
		local function productIdChangeDcFunc(evt)
			PaymentIosDCUtil.getInstance():sendIosProductIdChange(dcIosInfo, evt.data.newProductId)
		end
		peDispatcher:addEventListener(PaymentEvents.kIosBuySuccess, successDcFunc)
		peDispatcher:addEventListener(PaymentEvents.kIosBuyFailed, failedDcFunc)
		peDispatcher:addEventListener(PaymentEvents.kIosProductIdChange, productIdChangeDcFunc)
		IosPayment:buy(config.productIdentifier, config.iapPrice, config.priceLocale, config.id, onSuccess, onFail, peDispatcher)
	elseif __ANDROID then -- ANDROID
		local logic = IngamePaymentLogic:create(index, GoodsType.kCurrency, 'payment_Pack', 'payment_Pack'..index)
		PlatformConfig:setCurrentPayType(PaymentManager.getInstance():getDefaultThirdPartPayment(true))
		local decesion, payType = PaymentManager.getInstance():getThirdPartPaymentDecision()
		logic:ignoreSecondConfirm(true)
		logic:specialBuy(decesion, payType, onSuccess, onFail, onCancel)
	elseif __WP8 then
		local logic = Wp8Payment:create(index)
		logic:buy(onSuccess, onFail, onCancel)
	else -- on PC, there is no payment, u should not have come here!
		local http = IngameHttp.new(false)
		http:ad(Events.kComplete, onSuccess)
		http:ad(Events.kError, onFail)
		local tradeId = Localhost:time()
		http:load(index, tradeId, "chinaMobile", 2, nil, tradeId)
	end
end

function GiftPackEndgamePanel:createWindmill()
	self.ui = self:buildInterfaceGroup("GiftPack.EndGame/endgame_windmill")

	self.isWindmill = true

	local productItems = MarketManager:sharedInstance().productItems
	local paynames = {'wechat_2', 'alipay_2', 'qihoo_2','wandoujia_2','msdk', 'mi', 'huawei', 'qqwallet', 'mialipay',
						'miwxpay', 'qihoo_wx', 'qihoo_ali'}

	local payinfo

	for _,name in ipairs(paynames) do
		payinfo = table.find(productItems or {}, function ( item )
			return item.name == name
		end)
	end

	if not payinfo then payinfo = {} end

	local t1 = table.find(payinfo, function ( item )
		return item.iapPrice == 28
	end)

	local t2 = table.find(payinfo, function ( item )
		return item.iapPrice == 6
	end)

	if not t1 then
		t1 = {
			sort = 11,id = 37,cash = 340,
    		discount = 10,tag = "wechat_2",iapPrice = 28,
    		newSort = 11,payType = 11,extraCash = 60,
    		rmb = 2800,grade = "30",}
	end

	if not t2 then
		t2 = {
			sort = 11,id = 35,cash = 66,
    		discount = 10,tag = "wechat_2",iapPrice = 6,
    		newSort = 11,payType = 11,extraCash = 6,
    		rmb = 600,grade = "10",
		}
	end

	local btn1ui = self.ui:getChildByName('btn1')
	local btn2ui = self.ui:getChildByName('btn2')

	local btn1 = GroupButtonBase:createNewStyle( btn1ui )
	btn1:ad(DisplayEvents.kTouchTap, function ( ... )
		local gold1 = self.ui:getChildByName('gold1')
		gold1.itemInfo = {itemId = 14, num = t1.cash}
		self.icons = {gold1}

    	self:buyWindmill(t1)
    	btn1:setEnabled(false)
    	setTimeOut(function ( ... )
    		if not btn1.isDisposed then
    			btn1:setEnabled(true)
    		end
    	end, 5)
    end)
    btn1:setString(string.format('￥%0.2f', t1.iapPrice))
    btn1:setColorMode(kGroupButtonColorMode.blue)

    local function set( c, i )
    	local numl = self.ui:getChildByName('num' .. i..'l')
	    local numr = self.ui:getChildByName('num' .. i..'r')
	    local song = self.ui:getChildByName('song'..i)

	    local pos = song:getPosition()
	    local size = song:getContentSize()

	    numl:setAnchorPoint(ccp(1, 0.5))
	    numl:setPosition(ccp(pos.x - size.width / 2 + 20, pos.y - size.height / 2))

	    numr:setAnchorPoint(ccp(0, 0.5))
	    numr:setPosition(ccp(pos.x + size.width / 2 + 23, pos.y - size.height / 2))

	    numl:setScale(0.65)
	    numr:setScale(0.65)
	    numl:setText(c.cash - c.extraCash)
	    numr:setText(c.extraCash)
    end
    
    set(t1, 1)
    set(t2, 2)

    local btn2 = GroupButtonBase:createNewStyle( btn2ui )
	btn2:ad(DisplayEvents.kTouchTap, function ( ... )
		local gold2 = self.ui:getChildByName('gold2')
		gold2.itemInfo = {itemId = 14, num = t2.cash}
		self.icons = {gold2}

    	self:buyWindmill(t2)
    	btn2:setEnabled(false)
    	setTimeOut(function ( ... )
    		if not btn2.isDisposed then
    			btn2:setEnabled(true)
    		end
    	end, 5)
    end)
    btn2:setString(string.format('￥%0.2f', t2.iapPrice))
    btn2:setColorMode(kGroupButtonColorMode.blue)
	
	local more = self.ui:getChildByName('more')
	more:setTouchEnabled(true, 0, true)
	more:ad(DisplayEvents.kTouchTap, function ( ... )
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			local panel =  createMarketPanel(index, nil)
			if panel then 
				panel:popout()
			end
		end
	end)
end

function GiftPackEndgamePanel:createNormal( goodsId )
	self.ui = self:buildInterfaceGroup('GiftPack.EndGame/endgame_normal')

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local price = meta.thirdRmb / 100
	local ori_price = meta.rmb / 100
	local bg = self.ui:getChildByName('bg2')
	local bgsize = bg:getPreferredSize()
	local marge = 10

	local items = table.filter(meta.items, function ( itemInfo )
		return itemInfo.itemId ~= 14
	end)

	local gold = table.find(meta.items, function ( itemInfo )
		return itemInfo.itemId == 14
	end)

	local count = #items
	local ww,hh = 1,1
	if count > 4 then
		ww = 2
		hh = 3
	elseif count > 2 then
		ww = 2
		hh = 2
	elseif count > 1 then
		ww = 2
	end

	local w = (bgsize.width - 2*marge)/ww
	local h = (bgsize.height - 2*marge)/hh

	self.icons = {}

	table.sort(items, function ( a, b )
		return a.itemId < b.itemId
	end)

	local total = #items
	for index,itemInfo in ipairs(items) do
		local icon = GiftPack:createIcon(itemInfo)
        bg:addChild(icon)

        if total == 1 then
        	icon:setScale(0.7)
        elseif total == 2 then
        	icon:setScale(0.55)
        else
        	icon:setScale(0.55)
        	if total == 4 then
        		w = w - 2
        	end
        end

        if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
        	icon.unit:setPositionX(icon.unit:getPositionX() - 6)
        end

        local size = icon:getGroupBounds().size
        icon:setPosition(ccp(
        	w / 2 + marge + (index-1)%2*w - 8,
        	bgsize.height - marge - h/2 - math.floor((index-1)/2)*h))

        self.icons[index] = icon
	end

	self.ui:getChildByName('goldnumph'):setVisible(false)
	local goldicon = self.ui:getChildByName('gold_icon')
	local size = goldicon:getContentSize()
	local num = BitmapText:create(gold.num, 'fnt/zhifuyouhua1.fnt')
	num:setAnchorPoint(ccp(0, 0.5))
	num:setPosition(ccp(size.width, size.height/2))
	goldicon:addChild(num)

	self.goldicon = goldicon
	goldicon.itemInfo = gold

	local line = self.ui:getChildByName('line')
	local pos = line:getPosition()
	local size = line:getContentSize()
	local ori = BitmapText:create(string.format('价值￥%0.0f', ori_price), 'fnt/mark_tip.fnt')
	ori:setScale(0.7)
	ori:setPosition(ccp(pos.x + size.width/2, pos.y - size.height/2))
	self.ui:addChildAt(ori, 2)

	local btnui = self.ui:getChildByName('btn')
	local btn = GroupButtonBase:createNewStyle( btnui )
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:buy(btn)
    	btn:setEnabled(false)
    end)
    btn:setString(string.format('￥%0.2f', price))
    btn:setColorMode(kGroupButtonColorMode.blue)

    self:setDiscount(goodsId)
end

function GiftPackEndgamePanel:getDiscountNum( goodsId )
	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local price = meta.thirdRmb / 100
	local ori_price = meta.rmb / 100

	local discountNum = price * 10 / ori_price
	local num = math.ceil(discountNum)
	local distance = num - discountNum
	return distance > 0.5 and math.floor(discountNum) or num
end

function GiftPackEndgamePanel:setDiscount(goodsId)
	local discountNum = self:getDiscountNum(goodsId)

	if not self.discountUI then
		local discountContainerUI = self.ui:getChildByName('zhe')
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
		if not self.dx then
			self.dx = discountNumUI:getPositionX()
			self.dy = discountNumUI:getPositionY()
		end
		discountNumUI:setRotation(35)
		discountNumUI:setPositionX(self.dx +15)
		discountNumUI:setPositionY(self.dy -8)

		if discountNum == 1 then
			discountNumUI:setPositionX(self.dx +18)
			discountNumUI:setPositionY(self.dy -10)
		end

		discountNumUI:setScale(2)
		local discountTextUI = self.discountUI:getChildByName("text")
		if not self.dxx then
			self.dxx = discountTextUI:getPositionX()
			self.dyy = discountTextUI:getPositionY()
		end
		discountTextUI:setPosition(ccp(self.dxx + 5, self.dyy - 5))
		
		discountTextUI:setRotation(35)
		discountTextUI:setScale(1.7)
		discountTextUI:setText(Localization:getInstance():getText("buy.gold.panel.discount"))
	end
end

function GiftPackEndgamePanel:createNewerOne(goodsId, rewardGoodsId)
	self.ui = self:buildInterfaceGroup('GiftPack.EndGame/endgame_newer')

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local price = meta.thirdRmb / 100
	local ori_price = meta.rmb / 100
	local bg = self.ui:getChildByName('bg1')
	local bgsize = bg:getPreferredSize()
	local marge = 10
	local w = (bgsize.width - 2*marge)/2 + 4
	local h = (bgsize.height - 2*marge)/2

	self.icons = {}
	for index,itemInfo in ipairs(meta.items) do
		local icon = GiftPack:createIcon(itemInfo)
		icon:setScale(0.55)
        bg:addChild(icon)

        local size = icon:getGroupBounds().size
        icon:setPosition(ccp(
        	w / 2 + marge + math.floor((index-1)/2)*w - 20, 
        	bgsize.height - marge - h/2 - (index-1)%2*h))

        self.icons[index] = icon
	end

	--btn
	local btnui = self.ui:getChildByName('btn')
	local btn = ButtonIconNumberBase:createNewStyle( btnui )
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:buy(btn)
    	btn:setEnabled(false)
    end)
    btn:setDelNumber(string.format('￥%0.2f', ori_price))
    btn:setNumber(string.format('￥%0.2f', price))
    btn:setColorMode(kGroupButtonColorMode.blue)

	--saving
	local savingph = self.ui:getChildByName('saving')
	savingph:setVisible(false)
	local snum = ori_price - price
	local saving = BitmapText:create('￥'..snum, 'fnt/zhifuyouhua4.fnt')
    saving:setColor(ccc3(255,255,0))
    saving:setScale(1.2)
    saving:setRotation(35)
    local savingsize = savingph:getGroupBounds().size
    local savingpos = savingph:getPosition()
    saving:setPosition(ccp(savingpos.x + savingsize.width/2 - 5, savingpos.y - savingsize.height/2 + 5))
    self.ui:addChild(saving)

	local infos = GiftPack:getGoodsInfo( rewardGoodsId )
    local day = infos.config.duration / 3600 / 24 / 1000
	local tip2 = self.ui:getChildByName('tip2')
	tip2:setString(string.format('购买后%d天内，每日登录可领', day))
	tip2:setPositionY(tip2:getPositionY() - 5)

	local tip1 = self.ui:getChildByName('tip1')
	tip1:setPositionY(tip1:getPositionY() - 10)
	tip1:setString('购买立刻获得')

	bg = self.ui:getChildByName('bg2')
	bgsize = bg:getPreferredSize()
	marge = 10
	w = (bgsize.width - 2*marge)/2 + 4
	h = (bgsize.height - 2*marge)/2

	meta = MetaManager.getInstance():getGoodMeta(rewardGoodsId)
	if meta then
		for index,itemInfo in ipairs(meta.items) do
			local icon = GiftPack:createIcon(itemInfo)
	        bg:addChild(icon)

	        local size = icon:getGroupBounds().size
	        icon:setPosition(ccp(
	        	w / 2 + marge + (index-1)%2*w - 20,
	        	bgsize.height - 13 - marge - h/2 - math.floor((index-1)/2)*h))
		
	        if #meta.items == 1 then
	        	icon:setScale(0.6)
	        	icon:setPosition(ccp(bgsize.width/2 - 20, bgsize.height/2))
			end
		end
	end
end

function GiftPackEndgamePanel:buy(btn)
	local function dc( dcInfo )
        dcInfo = dcInfo or {}
        dcInfo.list_id = self.goodsId
        GiftPack:dc('buy', 'pay_stage_5steps', dcInfo)
    end


    local function onSuccess(dcInfo)
        self:onBuySuccess()
        dc( dcInfo )
        if btn and not btn.isDisposed then
       		btn:setEnabled(false)
       	end
    end

    local function onFail(dcInfo)
       dc( dcInfo )
       if btn and not btn.isDisposed then
       		btn:setEnabled(true)
       	end
    end

    local function onCancel(dcInfo)
        dc( dcInfo )
        if btn and not btn.isDisposed then
       		btn:setEnabled(true)
       	end
    end

    GiftPack:buy( self.goodsId, onSuccess, onFail, onCancel )
end

function GiftPackEndgamePanel:onBuyFinished( ... )
	local meta = MetaManager.getInstance():getGoodMeta(self.goodsId)

	local has5step = false
	if meta then
		for _,item in ipairs(meta.items) do
			if item.itemId == ItemType.ADD_FIVE_STEP or item.itemId == ItemType.TIMELIMIT_ADD_FIVE_STEP then
				has5step = true break
			end
		end
	end

    GiftPack:onCloseEndgamePanel()

	if self.closeCallBackFunc then
        if __IOS then
            has5step = true
        end
		self.closeCallBackFunc(has5step)
	end
end

function GiftPackEndgamePanel:onBuySuccess()
    local goodsId = self.goodsId

    if self.isPromotion then
    	PromotionManager:getInstance():onBuySuccess()
    end

    if self.isDisposed then return end
    
    local meta = MetaManager.getInstance():getGoodMeta(goodsId)

    if not self.isWindmill then
	    local bottle = table.find(meta.items, function (item)
	        return item.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
	    end)
	end

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

    if self.goldicon then
    	flymax = flymax + 1
    end

    local function fly( icon )
        local itemInfo = icon.itemInfo
        if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
            itemInfo = {itemId = itemInfo.itemId, num = 1}
        end
        local anim = FlyItemsAnimation:create({itemInfo})
        local pos = icon:getPosition()
        pos = icon:getParent():convertToWorldSpace(pos)
        local size = icon:getGroupBounds().size
        anim:setWorldPosition(ccp(pos.x + size.width/2, pos.y - size.height/2))
        anim:setScaleX(icon:getScaleX())
        anim:setScaleY(icon:getScaleY())
        anim:setFinishCallback(finished)
        anim:play()
    end

    for k, icon in ipairs(self.icons) do
        fly(icon)
    end

    if self.goldicon then
    	fly(self.goldicon)
    end
end

function GiftPackEndgamePanel:initCountDown(GetTime)
    local cdph = self.ui:getChildByName('cdph')
    cdph:setVisible(false)
    local pos = cdph:getPosition()
    local size  = cdph:getGroupBounds().size

    if not GetTime then return end

    local function closeCd()
        if self.cdId then
            Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.cdId)
            self.cdId = nil
        end
        if self.isDisposed then return end
        if self.lightCd then
            -- self.lightCd:removeFromParentAndCleanup(true)
            -- self.lightCd = nil
            self.lightCd:setText('00:00:00')
        end
        if self.cd then
            -- self.cd:removeFromParentAndCleanup(true)
            -- self.cd = nil
            self.cd:setText('00:00:00')
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
        local endTime = math.floor(GetTime() / 1000)

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
    local cd = BitmapText:create('1', 'fnt/zhifuyouhua3.fnt')
    cd:setAnchorPoint(ccp(0, 0.5))
    cd:setPosition(ccp(pos.x, pos.y - size.height / 2 - 4))
    self.cd = cd

    -- self.lightCd = BitmapText:create('1', 'tempFunctionRes/Double11/fnt/2018db11_a5s_time2.fnt')
    -- self.lightCd:setPosition(ccp(pos.x + size.width/2, pos.y - size.height / 2 - 5))
    -- self.lightCd:setVisible(false)
    update()
    self.ui:addChild(cd)
    -- self.ui:addChild(self.lightCd)
end

-- function GiftPackEndgamePanel:popout()
-- 	PopoutManager:sharedInstance():add(self, false, true)

-- 	local size = self:getGroupBounds().size
-- 	self:setContentSize(CCSizeMake(size.width, size.height))
-- 	self:setAnchorPoint(ccp(0.5, -0.5))
-- 	self:ignoreAnchorPointForPosition(false)

-- 	local winSize = CCDirector:sharedDirector():getVisibleSize()

-- 	local offset = 0
-- 	if winSize.height > 1330 then
-- 		offset = 45
-- 	end

-- 	self:setPosition(ccp(winSize.width / 2, -winSize.height + size.height/2 + offset))
-- 	self:setScale(0.2)
	
--     self:runAction(CCScaleTo:create(0.2, 1))

--     if winSize.height < 1280 and self.addFivePanel then
--     	local esize = self.addFivePanel:getGroupBounds().size
-- 		local posy = self.addFivePanel:getPositionY()
-- 		local miny = posy - esize.height
-- 		local ddy = self:getPositionY()
-- 		local topy = ddy + size.height/2

-- 		if miny < topy then
-- 			local offset = topy - miny + 5
-- 			self.addFivePanel:setPositionY(self.addFivePanel:getPositionY() + offset)
-- 		end
-- 	end
-- end

-- function GiftPackEndgamePanel:remove()
-- 	PopoutManager:sharedInstance():remove(self)
-- end

return GiftPackEndgamePanel