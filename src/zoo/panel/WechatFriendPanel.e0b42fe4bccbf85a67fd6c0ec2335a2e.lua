require "zoo.payment.paymentDC.PaymentDCUtil"
require "zoo.panel.broadcast.WechatFriendPayTip"

local function setNodeOriginX(node, originX)
	local x = node:getPositionX(node:getParent())
	local oldOriginX = node:getGroupBounds().origin.x
	node:setPositionX(x + originX - oldOriginX)
end

local function getRightX(node)
	local bounds = node:getGroupBounds(node:getParent())
	return bounds.origin.x + node:getContentSize().width * node:getScaleX()
end

WechatFriendPanel = class(BasePanel)

local reBuyCount = 1 -- 第几次尝试购买

local dcInfos = {} -- 这个值在IngamePaymenLogic里边设置

function WechatFriendPanel.setDcInfo(p_dcInfos)
	dcInfos = p_dcInfos
end

function WechatFriendPanel:create(itemData, lastFailedItem, errCode)
	local instance = WechatFriendPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.wechat_friend_panel)
	FrameLoader:loadImageWithPlist('ui/BuyConfirmPanel.plist')
	instance:init(itemData, lastFailedItem, errCode)
	return instance
end

function WechatFriendPanel:init(itemData, lastFailedItem, errCode)
	self.name = 'WechatFriendPanel'
	self.lastFailedItem = lastFailedItem
	self.itemData = itemData
	self.errCode = errCode

	local ui = self:buildInterfaceGroup('onFailPanel')
	
	BasePanel.init(self, ui)

	self.closeBtn = self.ui:getChildByName('closeBtn')
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:ad(
		DisplayEvents.kTouchTap, 
		function ()
			if #(dcInfos) >= 4 then
				local androidDcInfos = dcInfos[1]
				local reBuyGoldCount = dcInfos[2]
				local orderId = dcInfos[3]
				local paymentType = dcInfos[4]
				androidDcInfos.result = AndroidRmbPayResult.kCloseRepayPanel
				PaymentDCUtil.getInstance():sendAndroidBuyGold(
					androidDcInfos, 
					reBuyGoldCount, 
					orderId, 
					paymentType
				)
			end

			dcInfos = {}
			self:close(true) 
		end
	)

	self.title = self.ui:getChildByName('title')
	local titleSize = self.ui:getChildByName('titleSize')
	self.title = TextField:createWithUIAdjustment(titleSize, self.title)
	self.ui:addChild(self.title)
	self.title:setString(localize('wechatfri.panel.title'))


	self.text = self.ui:getChildByName('text')
	self.text:setString(localize('wechatfri.panel.pop'))

	-- 问号图标
	self.qIcon = self.ui:getChildByName('qIcon')
	self.qIcon:removeFromParentAndCleanup(false)
	local inputLayer = Layer:create()
	self.qIcon.name = kHitAreaObjectName
	inputLayer:addChild(self.qIcon)
	self.qIcon = inputLayer
	self.ui:addChild(self.qIcon)

	self.qIcon:setTouchEnabled(true)
	self.qIcon:ad(
		DisplayEvents.kTouchTap, 
		function() 
			self:setVisible(false)
			local explainPanel = WXFriExplainPanel:create(function () self:setVisible(true) end)
			explainPanel:popout()
		end
	)

	self.footer = self.ui:getChildByName('footer')
	self.footer:setString(localize('panel.choosepayment.wechatfri'))

	self.coinIcon = self.ui:getChildByName('coinIcon')

	self.cashText = self.ui:getChildByName('cashText')
	local cashTextSize = self.ui:getChildByName('cashTextSize')
	self.cashText = TextField:createWithUIAdjustment(cashTextSize, self.cashText)
	self.ui:addChild(self.cashText)
	self.cashText:setString('123')

	self.sendIcon = self.ui:getChildByName('sendIcon')

	self.extraCashText = self.ui:getChildByName('extraCashText')
	local extraCashTextSize = self.ui:getChildByName('extraCashTextSize')
	self.extraCashText = TextField:createWithUIAdjustment(extraCashTextSize, self.extraCashText)
	self.ui:addChild(self.extraCashText)
	self.extraCashText:setString('4')

	self.reBuyBtn = self.ui:getChildByName('buy')
	self.reBuyBtn = ButtonIconsetBase:create(self.reBuyBtn)

	self.friendBuyBtn = self.ui:getChildByName('friendBuy')
	self.friendBuyBtn = ButtonIconsetBase:create(self.friendBuyBtn)
	self.friendBuyBtn:setColorMode(kGroupButtonColorMode.blue)
	self.friendBuyBtn:setIconByFrameName('pay_icon/icon_wechat_small0000')
	self.friendBuyBtn:setString(localize('wechatfri.panel.btn'))
	self.friendBuyBtn:ad(DisplayEvents.kTouchTap, function() self:askFriendToPay() end)

	self:buildFromData()

	self:adjustCashTextPosition() --按产品需求 强行调整元素位置
	self:adjustBtnPosition()
end

function WechatFriendPanel:buildFromData()
	self:buildReBuyBtn()
	self:buildCashText()
end

function WechatFriendPanel:buildReBuyBtn()
	local payType = self.itemData.payType
	local price = nil

	if __IOS then
		price = self.itemData.iapPrice
	else
		price = self.itemData.price or self.itemData.iapPrice
	end

	local priceLocale = self.itemData.priceLocale

	local payShowConfig = PaymentManager.getInstance():getPaymentShowConfig(payType, price)
	self.reBuyBtn:setIconByFrameName(payShowConfig.smallIcon)

	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(priceLocale)	-- 货币符号

	local btnText = ''

	if isLongSymbol then 
		btnText = string.format("%s%0.0f", currencySymbol, price)
	else
		btnText = string.format("%s%0.2f", currencySymbol, price)
	end

	self.reBuyBtn:setString(btnText)

	-- self.reBuyBtn:setTouchEnabled(true)
	self.reBuyBtn:ad(
		DisplayEvents.kTouchTap, 
		function()
			self:close()

			reBuyCount = reBuyCount + 1

			local data = table.clone(self.itemData, true)
			data.reBuyCount = reBuyCount

			self.lastFailedItem:buyGold({
				index = self.itemData.id, 
				data = data,
			})
		end
	)
end

function WechatFriendPanel:buildCashText()
	local cash = self.itemData.cash
	local extraCash = self.itemData.extraCash
	if extraCash <= 0 then
		self.extraCashText:setVisible(false)
		self.sendIcon:setVisible(false)
	else
		self.extraCashText:setString(tostring(extraCash))
	end

	self.cashText:setString(tostring(cash - extraCash))
end

function WechatFriendPanel:adjustCashTextPosition()
	local container = Sprite:createEmpty()
	self.coinIcon:removeFromParentAndCleanup(false)
	self.cashText:removeFromParentAndCleanup(false)

	container:addChild(self.coinIcon)
	container:addChild(self.cashText)
	if self.sendIcon:isVisible() then
		self.sendIcon:removeFromParentAndCleanup(false)
		self.extraCashText:removeFromParentAndCleanup(false)
		container:addChild(self.sendIcon)
		container:addChild(self.extraCashText)
	end

	setNodeOriginX(self.cashText, getRightX(self.coinIcon))
	setNodeOriginX(self.sendIcon, getRightX(self.cashText) + 5)
	setNodeOriginX(self.extraCashText, getRightX(self.sendIcon))

	local x, y = self.coinIcon:getPositionX(), self.coinIcon:getPositionY()
	self.coinIcon:setPosition(ccp(self.coinIcon:getPositionX() - x, self.coinIcon:getPositionY() - y))
	self.cashText:setPosition(ccp(self.cashText:getPositionX() - x, self.cashText:getPositionY() - y))
	self.sendIcon:setPosition(ccp(self.sendIcon:getPositionX() - x, self.sendIcon:getPositionY() - y))
	self.extraCashText:setPosition(ccp(self.extraCashText:getPositionX() - x, self.extraCashText:getPositionY() - y))

	container:setPosition(ccp(x, y))

	self.ui:addChild(container)

	local containerSize = container:getGroupBounds(self.ui).size

	local btnBounds = self.reBuyBtn:getGroupBounds(self.ui)
	local rightX = btnBounds.origin.x + btnBounds.size.width
	local centerX = btnBounds.origin.x + btnBounds.size.width/2.0


	if tonumber(self.itemData.cash) >= 100 then  --align = right
		container:setPositionX(rightX - containerSize.width)
	else -- align = center
		container:setPositionX(centerX - containerSize.width/2)
	end
end

function WechatFriendPanel:adjustBtnPosition()
	local reBuyBtnBounds = self.reBuyBtn:getGroupBounds(self.ui)
	local friendBuyBtnBounds = self.friendBuyBtn:getGroupBounds(self.ui)
	local centerX = reBuyBtnBounds.origin.x + reBuyBtnBounds.size.width / 2 - 0.5
	local targetOriginX = centerX - friendBuyBtnBounds.size.width/2
	local targetX = targetOriginX + self.friendBuyBtn:getPositionX() - friendBuyBtnBounds.origin.x
	self.friendBuyBtn:setPositionX(targetX)
end

function WechatFriendPanel:popout()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local panelSize = self:getGroupBounds().size
    self:setPositionY( - (visibleSize.height - panelSize.height) /2 )
    self:setPositionX((visibleSize.width - panelSize.width) /2 )
    PopoutManager:sharedInstance():add(self, true, false)

    if self.errCode ~= nil then
    	if self.errCode == -2 or self.errCode == -6 or self.errCode == -7 then
    		CommonTip:showTip(localize('wechat.kf.off.fail.text'))
    	end
    end
end

function WechatFriendPanel:close(isClearCount)
	if not self.isDisposed then
		if isClearCount then
			self:clearCount()
		end
		PopoutManager:sharedInstance():remove(self, true)
	end
end

function WechatFriendPanel:dispose()
	FrameLoader:unloadImageWithPlists({'ui/BuyConfirmPanel.plist'})
end

function WechatFriendPanel:clearCount()
	reBuyCount = 1
end

function WechatFriendPanel:askFriendToPay()
	local function sendWechatMsg(tradeId, nonce, sign)
		local title = '帮我实现买买买的愿望吧~'
		local text = '我在开心消消乐忙过关~帮我付钱买袋风车币吧，闯关全靠你啦！'
		local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_friend_pay_share.png")

		local username = nameDecode(UserManager:getInstance().profile.name)
		local headUrl = UserManager:getInstance().profile.headUrl
		
		-- 不是 网址形式 的头像，是一个 0-n的序号
		if string.find(headUrl, 'http') == nil then
			headUrl = 'http://static.manimal.happyelements.cn/hd/activity/businessCard/'..headUrl..'.png'
		end
		local redirect_uri = 'http://animalmobile.happyelements.cn/wxpfa.jsp?head='..headUrl..'&nickname='..username..'&platform='..PlatformConfig.name..'&nonce='..nonce..'&tradeId='..tradeId
		local link = 'https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx6c266c7e402c1e24&redirect_uri='..HeDisplayUtil:urlEncode(redirect_uri)..'&response_type=code&scope=snsapi_base&state='..sign..'#wechat_redirect'

		local shareCallback = {
	        onSuccess = function(result)
    			CommonTip:showTip(localize('wechatfri.detail.panel.tip1'), "positive", nil, 3)
    			self:sendWechatFriendDC(tradeId, WechatFriendResult.kSuccess)
    			self:close()
	        end,
	        onError = function(errCode, msg)
	        	CommonTip:showTip(localize('wechat.kf.sign.fail.1'), "negative")
	        	self:sendWechatFriendDC(tradeId, WechatFriendResult.kFail)
	        end,
	        onCancel = function()
	        	CommonTip:showTip(localize('wechatfri.detail.panel.tip2'), "negative")
	        	self:sendWechatFriendDC(tradeId, WechatFriendResult.kCancel)
	    	end
	    }

	    local shareType, delayResume = SnsUtil.getShareType()
	    if shareType == PlatformShareEnum.kJPWX or shareType == PlatformShareEnum.kWechat then 
	    	SnsUtil.sendLinkMessage( shareType, title, text, thumb, link, false, shareCallback)
	    end
	end
	local function __sendHttpOrder()
		self:sendHttpOrder(
			function(tradeId, nonce, sign)
				sendWechatMsg(tradeId, nonce, sign)
			end, 
			nil
		)
	end

	PaymentNetworkCheck.getInstance():check(function()
			RequireNetworkAlert:callFuncWithLogged(__sendHttpOrder)
		end, function() 
			CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips")) 
		end
	)
end

function WechatFriendPanel:sendWechatFriendDC(tradeId, result)
	local goodsIdInfo = GoodsIdInfoObject:create(self.itemData.id, 2)
	PaymentDCUtil.getInstance():sendWechatFriend({
		tradeId = tradeId,
		typeChoose = self.itemData.payType,
		goodsId = goodsIdInfo:getGoodsId(),
		goodsNum = 1,
		price = self.itemData.iapPrice,
		result = result
	})
end	        			

function WechatFriendPanel:sendHttpOrder(successCallback, failCallback)
    
    local goodsIdInfo = GoodsIdInfoObject:create(self.itemData.id, 2)
    local tradeId = luajava.bindClass('com.happyelements.android.operatorpayment.OrderIdGenerator'):genOrderId(goodsIdInfo:getGoodsId())
    
	local function onRequestFinish(evt)
		local nonce = ''
    	local sign = ''
		if evt.data then
			if evt.data.nonce then
				nonce = evt.data.nonce
			end
			if evt.data.checkSign then
				sign = evt.data.checkSign
			end
		end
		if successCallback then
        	successCallback(tradeId, nonce, sign)
        end
    end 

	local function onRequestError(evt)
		if failCallback then
        	failCallback()
        end
    end

    local function onRequestCancel(evt)
        if failCallback then
        	failCallback()
        end
    end

	local http = DoWXFriendPayHttp.new(true)
    
    http:addEventListener(Events.kComplete, onRequestFinish)
    http:addEventListener(Events.kError, onRequestError)
    http:addEventListener(Events.kCancel, onRequestCancel)


    local sign = PaymentManager.getInstance():getSignForThirdPay(goodsIdInfo)

    local finalPrice = PaymentManager.getInstance():getPriceByPaymentType(
    	goodsIdInfo:getGoodsId(), 
    	goodsIdInfo:getGoodsType(), 
    	self.itemData.payType
    )

    local goodsName = localize("goods.name.text"..tostring(goodsIdInfo:getGoodsNameId()))
    local num = 1

    local ip = MetaInfo:getInstance():getIpAddress()

    local username = nameDecode(UserManager:getInstance().profile.name)
	local headUrl = UserManager:getInstance().profile.headUrl
	if string.find(headUrl, 'http') == nil then
		headUrl = 'http://static.manimal.happyelements.cn/hd/activity/businessCard/'..headUrl..'.png'
	end
	local platformName = PlatformConfig.name

    http:syncLoad(
    	PlatformConfig.name,
    	sign,
    	tradeId,
    	goodsIdInfo:getGoodsPayCodeId(),
    	goodsIdInfo:getGoodsType(),
    	num,
    	goodsName,
    	finalPrice * 100,
    	ip,
    	{
    		{key = 'head', value = headUrl},
    		{key = 'nickname', value = username},
    		{key = 'platform', value = platformName},
    	}
	)
end






WXFriExplainPanel = class(BasePanel)

function WXFriExplainPanel:create(closeCallback)
	local instance = WXFriExplainPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.wechat_friend_panel)
	instance:init(closeCallback)
	return instance
end

function WXFriExplainPanel:init(closeCallback)
	self.name = 'WXFriExplainPanel'
	self.closeCallback = closeCallback

	local ui = self:buildInterfaceGroup('detail')
	
	BasePanel.init(self, ui)

	self.closeBtn = self.ui:getChildByName('closeBtn')
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:close() end)

	self.title = self.ui:getChildByName('title')
	local titleSize = self.ui:getChildByName('titleSize')
	self.title = TextField:createWithUIAdjustment(titleSize, self.title)
	self.ui:addChild(self.title)
	self.title:setString(localize('wechatfri.detail.panel.title'))


	self.text = self.ui:getChildByName('text')
	self.text:setString(localize('wechatfri.detail.panel.pop'))

	self.tip = self.ui:getChildByName('tip')

	local tipText1 = localize('wechatfri.detail.panel.desc1')..'\n'
	local tipText2 = localize('wechatfri.detail.panel.desc2')..'\n'
	local tipText3 = localize('wechatfri.detail.panel.desc3')

	self.tip:setString(tipText1..tipText2..tipText3)
end

function WXFriExplainPanel:popout()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local panelSize = self:getGroupBounds().size
    self:setPositionY( - (visibleSize.height - panelSize.height) /2 )
    self:setPositionX((visibleSize.width - panelSize.width) /2 )
    PopoutManager:sharedInstance():add(self, true, false)
end

function WXFriExplainPanel:close()
	if not self.isDisposed then
		PopoutManager:sharedInstance():remove(self, true)
		if self.closeCallback then
			self.closeCallback()
		end
	end
end

local wechatFriendLogic = nil

WechatFriendLogic = class()

function WechatFriendLogic:sharedInstance()
	if wechatFriendLogic == nil then
		wechatFriendLogic = WechatFriendLogic.new()
	end
	return wechatFriendLogic
end

function WechatFriendLogic:ctor()
	self.data = {
		successPFALogs = {},
		overduePFALogs = {},
		serverCoin = nil              -- 后端所记录的金币数目, nil 表示金币数目和前端一样
	}
	self.dcLogs = {} -- 成功记录的备份，为了打点
	self.isBusy = false
end

function WechatFriendLogic:firstCheckResult()
	if not self.havecheckedOnce then
		self.havecheckedOnce = true
		self:checkNewResult()
		local homeScene = HomeScene:sharedInstance()
		homeScene:ad(
			SceneEvents.kEnterForeground, 
			function()
				if _G.isLocalDevelopMode then printx(0, 'niu2x WechatFriendLogic call back') end
				self:checkNewResult()
			end
		)
	end
end

function WechatFriendLogic:checkNewResult()
	if not self.isBusy then
		self.isBusy = true
		self:pullData(
			function ()
				self:handleData(function()
					self.isBusy = false
				end)
			end,
			function ()
				self.isBusy = false
			end
		)
	end
end

function WechatFriendLogic:pullData(successCallback, failCallback)

	local function onRequestFinish(evt)
		if _G.isLocalDevelopMode then printx(0, 'wechatFriendLogic pullData ', table.tostring(evt.data)) end
		self:mergeData(evt.data)
		if successCallback then
        	successCallback()
        end
    end 

	local function onRequestError(evt)
		failCallback()
    end

    local function onRequestCancel(evt)
    	failCallback()
    end

	local http = GetWxFriendResult.new(true)
    
    http:addEventListener(Events.kComplete, onRequestFinish)
    http:addEventListener(Events.kError, onRequestError)
    http:addEventListener(Events.kCancel, onRequestCancel)

    http:load()

    -- onRequestFinish({data={
    -- 	successPFALogs = {
    -- 		{goodsId = 10008, num = 1}

    -- 	},
    -- 	overduePFALogs = {
    -- 		{goodsId = 10004, num = 1},
    -- 		{goodsId = 10001, num = 1}
    -- 	},
    -- 	coin = 1
    -- }})
end

function WechatFriendLogic:mergeData(data)
	if data and data.successPFALogs then
		self.data.successPFALogs = table.union(self.data.successPFALogs, data.successPFALogs)
		if data.coin then
			self.data.serverCoin = tonumber(data.coin)
		end
	end
	if data and data.overduePFALogs then
		self.data.overduePFALogs = table.union(self.data.overduePFALogs, data.overduePFALogs)
	end
end

-- function WechatFriendLogic:handleData(onFinish)
-- 	self:handleSuccessData(function() 
-- 		self:handleFailData(onFinish)
-- 	end)
-- end

function WechatFriendLogic:handleData(onFinish)
	self:handleSuccessData()
	self:handleFailData()
	if onFinish then
		onFinish()
	end
end

function WechatFriendLogic:handleSuccessData(onFinish)
	if __ANDROID then
		self.dcLogs = self.data.successPFALogs
		self:androidHandleSuccessData(onFinish)
	else
		self:notAndroidHandleSuccessData(onFinish)
	end
end

function WechatFriendLogic:dcBuyCurrency()
	if self.dcLogs then
		for k, data in pairs(self.dcLogs) do
			local num = tonumber(data.num)
			local count = 1
			while count <= num do
				local goodsId = data.goodsId
				local cash = self:getCashByGoodsId(goodsId)
				local rmb = self:getRmbByGoodsId(goodsId)
				GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, ItemType.GOLD, cash, DcSourceType.kWechatFriPay, nil, nil, DcPayType.kRmb, rmb, goodsId)
				count = count + 1
			end
		end
	end
end

-- function WechatFriendLogic:androidHandleSuccessData(onFinish)
-- 	local successDataNumber = self:getSuccessDataNumber()
-- 	if successDataNumber <= 0 then
-- 		if onFinish then
-- 			onFinish()
-- 		end
-- 	elseif successDataNumber == 1 then
-- 		self:showOneSuccessMsg(onFinish)
-- 	else
-- 		self:showManySuccessMsg(onFinish)
-- 	end
-- end

function WechatFriendLogic:androidHandleSuccessData()
	local successDataNumber = self:getSuccessDataNumber()
	if successDataNumber <= 0 then
	elseif successDataNumber == 1 then
		self:showOneSuccessMsg()
	else
		self:showManySuccessMsg()
	end
end

function WechatFriendLogic:notAndroidHandleSuccessData()
	local successDataNumber = self:getSuccessDataNumber()
	if successDataNumber <= 0 then
	else
		self.data.successPFALogs = {}
		local text = localize('consume.tip.panel.text.3.5', {num = successDataNumber}) 
		local panel = WechatFriendPayTip:create(text, false, function()
			BroadcastManager:getInstance():onCurClose()
		end)
		BroadcastManager:getInstance():add(panel)
	end
end


function WechatFriendLogic:getSuccessDataNumber()
	if self.data and self.data.successPFALogs then
		local successResultNumber = 0
		for k, data in pairs(self.data.successPFALogs) do
			successResultNumber = successResultNumber + tonumber(data.num)
		end
		return successResultNumber
	end
	return 0
end

function WechatFriendLogic:showOneSuccessMsg()
	local data = self.data.successPFALogs[1]
	local goodsId = data.goodsId
	local cash = self:getCashByGoodsId(goodsId)

 	self.data.successPFALogs = {}

	local text = localize('consume.tip.panel.text.3', {num = cash})
	local panel
	panel = WechatFriendPayTip:create(text, true, function()
		if not panel.isDisposed then
			local anim = FlyItemsAnimation:create({{itemId = ItemType.GOLD, num = cash}})
		 	local startX, startY = panel:getGoldIconWorldPosXY()
			anim:setWorldPosition(ccp(startX, startY))
			anim:setFinishCallback(
				function()
					self:addCash()
					BroadcastManager:getInstance():onCurClose()
				end
			)
			anim:play()
		else
			self:addCash()
			BroadcastManager:getInstance():onCurClose()
		end
	end)
	BroadcastManager:getInstance():add(panel)

end

function WechatFriendLogic:showManySuccessMsg()
	local datas = self.data.successPFALogs
	local logsNumber = self:getSuccessDataNumber()
	local totalCash = 0
	
	for k, data in pairs(datas) do
		local goodsId = data.goodsId
		local cash = self:getCashByGoodsId(goodsId)
		local num = data.num
		totalCash = tonumber(cash)*tonumber(num) + totalCash
	end

 	self.data.successPFALogs = {}

	local text = localize('consume.tip.panel.text.3.2', {num = logsNumber, num1 = totalCash})
	local panel
	panel = WechatFriendPayTip:create(text, true, function()
		if not panel.isDisposed then
			local anim = FlyItemsAnimation:create({{itemId = ItemType.GOLD, num = totalCash}})
		 	local startX, startY = panel:getGoldIconWorldPosXY()
			anim:setWorldPosition(ccp(startX, startY))
			anim:setFinishCallback(
				function()
					self:addCash()
					BroadcastManager:getInstance():onCurClose()
				end
			)
			anim:play()
		else
			self:addCash()
			BroadcastManager:getInstance():onCurClose()
		end
	end)
	BroadcastManager:getInstance():add(panel)
end

function WechatFriendLogic:handleFailData(onFinish)
	local failDataNumber = self:getFailDataNumber()
	if failDataNumber <= 0 then
		if onFinish then
			onFinish()
		end
	elseif failDataNumber == 1 then
		self:showOneFailMsg(onFinish)
	else
		self:showManyFailMsg(onFinish)
	end
end

function WechatFriendLogic:getFailDataNumber()
	if self.data and self.data.overduePFALogs then
		return #(self.data.overduePFALogs)
	end
	return 0 
end


function WechatFriendLogic:showOneFailMsg()
	-- 在HomeScene中 先处理成功消息，然后回调，延时，之后来处理失败消息
	-- 此时，因为有延时，所以，此时可能已经进入别的页面
	-- 如果已经进入别的页面，则 数据不清空。直接返回，期待下一次再处理
	if self:isHomeScene() then 
		local data = self.data.overduePFALogs[1]
		local goodsId = data.goodsId
		local cash = self:getCashByGoodsId(goodsId)
		local text = localize('consume.tip.panel.text.3.1', {num = cash})
	 	self.data.overduePFALogs = {}

	 	local panel = WechatFriendPayTip:create(text, false, function()
			BroadcastManager:getInstance():onCurClose()
	 	end)
		BroadcastManager:getInstance():add(panel)
	 else
	 end
end

function WechatFriendLogic:showManyFailMsg()
	if self:isHomeScene() then
		local datas = self.data.overduePFALogs
		local logsNumber = #datas
		local text = localize('consume.tip.panel.text.3.3', {num = logsNumber})
	 	self.data.overduePFALogs = {}
		local panel = WechatFriendPayTip:create(text, false, function()
			BroadcastManager:getInstance():onCurClose()
	 	end)
		BroadcastManager:getInstance():add(panel)
	else
	end
end

function WechatFriendLogic:isHomeScene()
	local curScene = Director:sharedDirector():getRunningScene()
	return curScene:is(HomeScene)
end

function WechatFriendLogic:addCash()
	local curCoin = UserManager:getInstance().user:getCash()
	local serverCoin = self.data.serverCoin
	if serverCoin ~= nil and serverCoin > curCoin then 
		UserManager:getInstance().user:setCash(serverCoin)
	    UserService:getInstance().user:setCash(serverCoin)
	    local scene = HomeScene:sharedInstance()
		if scene then
			scene:checkDataChange()
			if scene.goldButton then scene.goldButton:updateView() end
		end
	end
	self:dcBuyCurrency()
end

function WechatFriendLogic:getCashByGoodsId(goodsId)
	local goldItemIndex = tonumber(goodsId) - 10000  --10000 goodsID 减去 10000 得到 这一项 在配置中的 id 和 index
	local metaConfig = MetaManager:getInstance().product_android
	local cash = 0
	if metaConfig and metaConfig[goldItemIndex] then
		cash = metaConfig[goldItemIndex].cash
	end
	return cash
end

function WechatFriendLogic:getRmbByGoodsId(goodsId)
	local goldItemIndex = tonumber(goodsId) - 10000  --10000 goodsID 减去 10000 得到 这一项 在配置中的 id 和 index
	local metaConfig = MetaManager:getInstance().product_android
	local rmb = 0
	if metaConfig and metaConfig[goldItemIndex] then
		rmb = metaConfig[goldItemIndex].rmb
	end
	return rmb
end