require "zoo.panel.androidSalesPromotion.AndroidSalesPromotionHttp"
require "zoo.panel.androidSalesPromotion.AndroidGoldSalesIconButton"
require "zoo.panel.androidSalesPromotion.AndroidNormalSalesPanel"
require "zoo.panel.androidSalesPromotion.AndroidSpecialSalesPanel"
require 'zoo.scenes.component.HomeScene.OneYuanShopButton'

AndroidSalesManager = class()
local instance = nil

AndroidSalesPromotionType = {
    ItemSales = 1,
    GoldSales = 2,   
}

AndroidSalesPromotionLocation = {
	kNormal = 1,
	kSpecial = 2,	
}

local MIN_INTERVAL = 21 * 24 * 3600 
local ENERGY_THRESHOLD = 5

local configPath = HeResPathUtils:getUserDataPath() .. '/android_pay_guide_config_'..(UserManager:getInstance().uid or '0')
local forcePopKey = "android.sales.promotion.pop"

local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

local function now()
	return os.time() + (__g_utcDiffSeconds or 0)
end

local function readConfig()
	local _config = {}

    local file = io.open(configPath, "r")
    if file then
        local data = file:read("*a") 
        file:close()
        if data then
            _config = table.deserialize(data) or {}
        end
    end
    return _config
end

local function writeConfig(data)
    local file = io.open(configPath,"w")
    if file then 
        file:write(table.serialize(data or {}))
        file:close()
    end
end

function AndroidSalesManager.getInstance()
	if not instance then
		instance = AndroidSalesManager.new()
		instance:init()
	end
	return instance
end

function AndroidSalesManager:init()
	self.itemSalesInfo = {}
	self.goldSalesInfo = {}
	self.itemSalesPanel = nil 
	self.showOneYuanItemAni = true

	local function onComplete()
		if not PaymentManager.getInstance():checkHasRealThirdPay() then 
			--处理已触发破冰的玩家从有三方支付的包换到没三方支付的包的情况
			return 
		end
		self:showAndroidSalesPromotion(true)
   	end
    
    self:loadSalesInfo(onComplete)

    --notification
    LocalNotificationManager.getInstance():cancelAllAndroidSalesPromotion()
end

function AndroidSalesManager:pocessNotification(promotionType)
    local endTime 
    if promotionType == AndroidSalesPromotionType.GoldSales then 
        endTime = self:getGoldSalesEndTime()
    else
        endTime = self:getItemSalesEndTime()
    end
    if endTime and endTime > 0 then 
        local notiTime = endTime - 3600
        if now() < notiTime then 
            LocalNotificationManager.getInstance():setAndroidSalesPromotionNoti(promotionType, notiTime)
        end
    end
end

--向后端请求促销信息
function AndroidSalesManager:loadSalesInfo(completeCallback, errorCallback, needLoading)
	local function onRequestFinish(evt)
		local salesPromotionInfo = evt.data and evt.data.promotions or {}
		local promotionLevel = evt.data and evt.data.grade
		for i,v in ipairs(salesPromotionInfo) do
			v.level = promotionLevel
		end
		self:initSalesPromotion(salesPromotionInfo)
		self:serialize()

		if completeCallback then completeCallback() end
	end

	local function onRequestError(evt)
		self:deserialize()

		if errorCallback then
			errorCallback()
		else
			if completeCallback then completeCallback() end
		end
	end

	local http = GetAndroidSalesPromotionInitInfo.new(needLoading)
    http:addEventListener(Events.kComplete, onRequestFinish)
	http:addEventListener(Events.kError, onRequestError)
    http:syncLoad()
end

--初始化
function AndroidSalesManager:initSalesPromotion(salesPromotionInfo)
	local function getPromotionInfoByType(type, rawData)
		for __,v in ipairs(rawData) do
			if tonumber(v.type) == type then
				return v
			end
		end
	end
	local itemSalesPromotionInfo = nil
	local tempPromotionType = nil
	for k,v in pairs(AndroidSalesPromotionType) do
		if v == AndroidSalesPromotionType.GoldSales then 
			self.goldSalesInfo = getPromotionInfoByType(AndroidSalesPromotionType.GoldSales, salesPromotionInfo) or {}
		else
			--道具购买促销 因为版本兼容问题 要特殊处理:如果同时收到多条道具促销信息 只取type最大的来处理
			local tempPromotionInfo = getPromotionInfoByType(v, salesPromotionInfo)
			if tempPromotionInfo then 
				if not itemSalesPromotionInfo then 
					itemSalesPromotionInfo = tempPromotionInfo
					tempPromotionType = v
				elseif tempPromotionType and v > tempPromotionType then
					itemSalesPromotionInfo = tempPromotionInfo
					tempPromotionType = v
				end
			end
		end
	end
	self.itemSalesInfo = itemSalesPromotionInfo or {}
end

function AndroidSalesManager:dcForTriggerSuccess(promotionType, grade, goodsId)
	local dcType = 1
	if promotionType == AndroidSalesPromotionType.GoldSales then
		dcType = 2
	end

	DcUtil:androidSalesPromotion(dcType, grade, goodsId)
end

function AndroidSalesManager:triggerSalesPromotion(place, completeCallback, errorCallback)
	local function onRequestFinish(evt)
		local promotion = evt.data and evt.data.promotion or {}
		promotion.level = evt.data and evt.data.grade
		local promotionType = promotion and promotion.type
		if promotionType == AndroidSalesPromotionType.GoldSales then
			self.goldSalesInfo = promotion or {}
		else
			self.itemSalesInfo = promotion or {}
		end
		self:serialize()
		self:dcForTriggerSuccess(promotionType, promotion.level, promotion.goodsId)
		if completeCallback then completeCallback() end
	end

	local function onRequestError(evt)
		if errorCallback then
			errorCallback()
		end
	end
	--请求新的道具促销时 重置强弹的本地标识
	self:cleanSecondDayPop()

	local http = TriggerAndroidSalesPromotion.new()
    http:addEventListener(Events.kComplete, onRequestFinish)
	http:addEventListener(Events.kError, onRequestError)
    http:syncLoad(place)
end

function AndroidSalesManager:serialize()
	local salesPromotionInfo = {self.itemSalesInfo, self.goldSalesInfo}
	writeConfig(salesPromotionInfo)
end

function AndroidSalesManager:deserialize()
	local info = readConfig()
	self:initSalesPromotion(info)
end

function AndroidSalesManager:getItemSalesDataByGoodsId(goodsId)
	local goodsData = MetaManager:getInstance():getGoodMeta(goodsId)
	local dataTable = {}
	dataTable.goodsId = goodsId
	dataTable.oriPrice = goodsData.rmb / 100
	dataTable.nowPrice = goodsData.discountRmb / 100
	local discount = math.ceil(dataTable.nowPrice / dataTable.oriPrice * 10)
	dataTable.discount = discount
	dataTable.items = goodsData.items

	return dataTable
end

function AndroidSalesManager:seperateItemTable(rewardsTable)
	local coinTable = {}
	local itemTable = {}
	if rewardsTable then
		for k,v in pairs(rewardsTable) do
			if v.itemId == ItemType.GOLD then 
				table.insert(coinTable, v)
			else
				table.insert(itemTable, v)
			end
		end
	end
	return coinTable, itemTable 
end

function AndroidSalesManager:shouldTriggerAndroidSales()
	if not __ANDROID then return false end

    if UserManager:getInstance().user.topLevelId < 40 then
        if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step0") end
        return false
    end

    if self:maintenanceDisable() then
        if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step1") end
        return false
    end
    
	if self:isInItemSalesPromotion() then 
		if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step2") end
		return false
	end

	if self:isInGoldSalesPromotion() then 
		if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step3") end
		return false
	end

	if PaymentManager:getInstance():getHasFirstThirdPay() then
		if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step4") end
		return false 
	end

	if not PaymentManager.getInstance():checkHasRealThirdPay() then 
		if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step5") end
		return false
	end

	if self:hasTriggeredItemSalesPromotion() then 
		if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step6") end
		return false
	end

	if self:hasTriggeredGoldSalesPromotion() then 
		if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step7") end
		return false
	end

    local energyCount = UserManager:getInstance().user:getEnergy()
    if energyCount < ENERGY_THRESHOLD then
    	if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step8") end
        return true
    else
    	local smsEnable, reason = PaymentManager:getInstance():checkSmsPayEnabled()
    	if smsEnable then 
    		if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step9") end
    		return false
    	else
    		if reason ~= SmsDisableReason.kSmsLimit and reason ~= SmsDisableReason.kSmsClose then 
    			if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step10") end
    			return false
    		end
    	end
    end
    if _G.isLocalDevelopMode then printx(0, "shouldTriggerAndroidSales()=========================step11") end
    return true
end

function AndroidSalesManager:showAndroidSalesPromotion(notFirstTime)
    if self:isInItemSalesPromotion() then
    	self:startItemSalesPromotion(notFirstTime)
    end
    if self:isInGoldSalesPromotion() then
      	self:startGoldSalesPromotion()
    end
end

--------------------------------------------------------
------------------处理道具礼包破冰相关------------------
--------------------------------------------------------

function AndroidSalesManager:buildItemSalesIcon()
    local button
    local function onTap()
        if not button._clicked then
            HomeScene:sharedInstance():onIconBtnFinishJob(button)
            button._clicked = true
        end
        self:popoutItemSalesPanel()
    end
    local function callback()
        local homeScene = HomeScene:sharedInstance()
        if homeScene.itemSalesButton and not homeScene.itemSalesButton.isDisposed then 
            return 
        end
        local itemSalesType = self:getItemSalesType()
        button = OneYuanShopButton:create(self:getItemSalesLeftSeconds(), itemSalesType)
        button._clicked = false
        homeScene:addIcon(button)
        homeScene.itemSalesButton = button
        button.wrapper:ad(DisplayEvents.kTouchTap, onTap)
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))
end

function AndroidSalesManager:isInItemSalesPromotion()
	local lastOccurTime = tonumber(self.itemSalesInfo.occurTime) or 0
	local now = Localhost:time()/1000
	return now >= lastOccurTime and now < self:getItemSalesEndTime() and self:getItemSalesBuyCount() < 1
end

function AndroidSalesManager:getNeedSecondDayPop()
	local hasForcePop = CCUserDefault:sharedUserDefault():getBoolForKey(forcePopKey)
	if not hasForcePop then 
		local popEndTime = self:getItemSalesEndTime()
		if popEndTime and popEndTime > 0 then 
			local nowDay = getDayStartTimeByTS(now())
			local endDay = getDayStartTimeByTS(popEndTime)
			if nowDay == endDay then 
				CCUserDefault:sharedUserDefault():setBoolForKey(forcePopKey, true)
				CCUserDefault:sharedUserDefault():flush()
				return true
			end
		end
	end
	return false
end

function AndroidSalesManager:cleanSecondDayPop()
	CCUserDefault:sharedUserDefault():setBoolForKey(forcePopKey, false)
	CCUserDefault:sharedUserDefault():flush()
end

function AndroidSalesManager:getItemSalesEndTime()
	return tonumber(self.itemSalesInfo.endTime) or 0
end

function AndroidSalesManager:getItemSalesLeftSeconds()
	local seconds = self:getItemSalesEndTime() - Localhost:time()/1000
	return seconds < 0 and 0 or seconds
end

function AndroidSalesManager:getItemSalesType()
	return tonumber(self.itemSalesInfo.type) or 0
end

function AndroidSalesManager:getItemSalesGoodsId()
	return tonumber(self.itemSalesInfo.goodsId) or 0
end

function AndroidSalesManager:getItemSalesLevel()
	return tonumber(self.itemSalesInfo.level) or 0
end

function AndroidSalesManager:getItemSalesBuyCount()
	return tonumber(self.itemSalesInfo.boughtCount) or 0
end

function AndroidSalesManager:hasTriggeredItemSalesPromotion()
    local now = Localhost:time()/1000
    local lastOccurTime = self.itemSalesInfo.occurTime or 0

    return now - lastOccurTime < MIN_INTERVAL
end

function AndroidSalesManager:startItemSalesPromotion(notFirstTime)
    self:itemSalesStart()
    self:buildItemSalesIcon()
    --加推送
    self:pocessNotification(AndroidSalesPromotionType.ItemSales)
    --加强弹
    if not notFirstTime or self:getNeedSecondDayPop() then
	    local function callback() -- 防止出现点击击穿
	        self:popoutItemSalesPanel()
	    end
	    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))   
	end
end

function AndroidSalesManager:popoutItemSalesPanel()
    local function promoEndCallback()
        self:itemSalesEnd()
    end
    
    local itemSalesData = self:getItemSalesDataByGoodsId(self:getItemSalesGoodsId())
    if itemSalesData then 
        local itemSalesType = self:getItemSalesType()
   		if itemSalesType == AndroidSalesPromotionType.ItemSales then 
   			if _G.isLocalDevelopMode then printx(0, "self:getItemSalesLevel()=============",self:getItemSalesLevel()) end
            if self:getItemSalesLevel() == 5 then 
                self.itemSalesPanel = AndroidSpecialSalesPanel:create(itemSalesData, self:getItemSalesLeftSeconds(), promoEndCallback)
            else
                self.itemSalesPanel = AndroidNormalSalesPanel:create(itemSalesData, self:getItemSalesLeftSeconds(), promoEndCallback)
            end
        end
        if self.itemSalesPanel then self.itemSalesPanel:popout() end
    else
        self.itemSalesPanel = nil
    end
end

function AndroidSalesManager:itemSalesStart()
    -- DcUtil:UserTrack({ category='activity', sub_category='ios_promotion', num = 1})
    if self.itemSalesSchedId then 
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.itemSalesSchedId)
        self.itemSalesSchedId = nil	
    end

    local itemSalesLeftSeconds = self:getItemSalesLeftSeconds()
    local function endPromotion()
        if self.itemSalesSchedId then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.itemSalesSchedId)
            self.itemSalesSchedId = nil
        end
        self:itemSalesEnd()
    end
    self.itemSalesSchedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(endPromotion, itemSalesLeftSeconds, false)
end

function AndroidSalesManager:itemSalesEnd()
	if self.itemSalesSchedId then 
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.itemSalesSchedId)
        self.itemSalesSchedId = nil	
    end

    local homeScene = HomeScene:sharedInstance()
    if homeScene.itemSalesButton and not homeScene.itemSalesButton.isDisposed then
        homeScene.leftRegionLayoutBar:removeItem(homeScene.itemSalesButton)
        homeScene.itemSalesButton = nil
    end
    if self.itemSalesPanel and not self.itemSalesPanel.isDisposed and self.itemSalesPanel:getParent() then 
        self.itemSalesPanel:removePopout()
    end
    self:itemSalesBought()
end

function AndroidSalesManager:setSalesPanel(panelRef)
    self.itemSalesPanel = panelRef
end

function AndroidSalesManager:itemSalesBought()
	self.itemSalesInfo.boughtCount = 1
	self:serialize()
end


----------------------------------------------------------
------------------处理风车币商店破冰相关------------------
----------------------------------------------------------
function AndroidSalesManager:buildGoldSalesIcon()
	local button
	local function onTap()
		if button and not button.isDisposed then 
			button:stopIconAni()
		end
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			DcUtil:UserTrack({category = "activity",
                        sub_category = "1yuan100_push_icon"
                        })
			HomeScene:sharedInstance():popoutMarketPanelByIndex(index)
			GamePlayMusicPlayer:playEffect(GameMusicType.kClickBubble)
		end
    end
    local function callback()
        local homeScene = HomeScene:sharedInstance()
        if homeScene.goldSalesButton and not homeScene.goldSalesButton.isDisposed then -- 防止添加多个按钮
            return
        end

        button = AndroidGoldSalesIconButton:create(self:getGoldSalesLeftSeconds())
        button.manager = self
        homeScene.leftRegionLayoutBar:addItem(button)
        homeScene.goldSalesButton = button
        button.wrapper:ad(DisplayEvents.kTouchTap, onTap)
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))
end

function AndroidSalesManager:showGoldButtonFlag()
	if SupperAppManager:checkEntry() then return end
	
    local function localCallback()
        local button = HomeScene:sharedInstance().goldButton
        if button then
            button:setOneYuanCashFlagVisible(true)
        end   
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(localCallback))
end

--
function AndroidSalesManager:removeGoldButtonFlag()
    local function localCallback()
        local button = HomeScene:sharedInstance().goldButton
        if button then
            button:setOneYuanCashFlagVisible(false)
        end   
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(localCallback))
end

function AndroidSalesManager:isInGoldSalesPromotion()
	local lastOccurTime = tonumber(self.goldSalesInfo.occurTime) or 0
	local now = Localhost:time()/1000
	return now >= lastOccurTime and now < self:getGoldSalesEndTime() and self:getGoldSalesBuyCount() < 1
end

function AndroidSalesManager:getGoldSalesEndTime()
	return tonumber(self.goldSalesInfo.endTime) or 0
end

function AndroidSalesManager:getGoldSalesLeftSeconds()
	local seconds = self:getGoldSalesEndTime() - Localhost:time()/1000
	return seconds < 0 and 0 or seconds
end

function AndroidSalesManager:getGoldSalesGoodsId()
	return tonumber(self.goldSalesInfo.goodsId) or 0
end

function AndroidSalesManager:getGoldSalesBuyCount()
	return tonumber(self.goldSalesInfo.boughtCount) or 0
end

function AndroidSalesManager:hasTriggeredGoldSalesPromotion()
    local now = Localhost:time()/1000
    local lastOccurTime = self.goldSalesInfo.occurTime or 0

    return now - lastOccurTime < MIN_INTERVAL
end

function AndroidSalesManager:startGoldSalesPromotion()
	self:goldSalesStart()
    self:showGoldButtonFlag()
    self:buildGoldSalesIcon()
    --加推送
    self:pocessNotification(AndroidSalesPromotionType.GoldSales)
end

function AndroidSalesManager:goldSalesStart()
    -- DcUtil:UserTrack({ category='activity', sub_category='ios_promotion', num = 1})
    if self.goldSalesSchedId then 
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.goldSalesSchedId)
        self.goldSalesSchedId = nil	
    end

    local goldSalesLeftSeconds = self:getGoldSalesLeftSeconds()
    local function endPromotion()
        if self.goldSalesSchedId then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.goldSalesSchedId)
            self.goldSalesSchedId = nil
        end
        self:goldSalesEnd()
    end
    self.goldSalesSchedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(endPromotion, goldSalesLeftSeconds, false)
end

function AndroidSalesManager:goldSalesEnd()
	if self.goldSalesSchedId then 
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.goldSalesSchedId)
        self.goldSalesSchedId = nil	
    end
    local homeScene = HomeScene:sharedInstance()
    if homeScene.goldSalesButton and not homeScene.goldSalesButton.isDisposed then
        homeScene.leftRegionLayoutBar:removeItem(homeScene.goldSalesButton)
        homeScene.goldSalesButton = nil
    end
    self:removeGoldButtonFlag()
    self:goldSalesBought()
end

function AndroidSalesManager:goldSalesBought()
	self.goldSalesInfo.boughtCount = 1
	self:serialize()
end

--通知服务端一元风车币促销已买。
function AndroidSalesManager:sendSeverGoldSalesBuyed()
    -- local function opSuccess()
    -- 	-- CommonTip:showTip(Localization:getInstance():getText("通知服务端一元风车币促销购买成功。"))
    -- end
    -- local function opFail()
    --     -- CommonTip:showTip(Localization:getInstance():getText("通知服务端一元风车币促销购买失败。"))
    -- end

    -- local http = OpNotifyHttp.new()
    -- http:ad(Events.kComplete, opSuccess)
    -- http:ad(Events.kError, opFail)
    -- http:load(OpNotifyType.kAndroidSalesPromotion)
end

function AndroidSalesManager:setShowOneYuanItemAni(shouldShow)
	self.showOneYuanItemAni = shouldShow
end

function AndroidSalesManager:getShowOneYuanItemAni()
	return self.showOneYuanItemAni
end

function AndroidSalesManager:maintenanceDisable()
	--maintenance开关为true 代表功能失效。 因为需求离线玩家默认功能开放
    return MaintenanceManager:getInstance():isEnabled("AndroidSalesPromotion") 
end
