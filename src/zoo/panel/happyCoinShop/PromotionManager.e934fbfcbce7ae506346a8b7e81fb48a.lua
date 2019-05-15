--我期待的促销信息
-- local promotion = {
--	
-- 	id = xxx,
-- 	boughtCount = 0,
-- 	occurTime = 0,
-- 	endTime = 0
-- }


require 'zoo.panel.happyCoinShop.PromotionIcon'
require "zoo.panel.happyCoinShop.PennyPayIcon"

local configPath = HeResPathUtils:getUserDataPath() .. '/union_promotion_data_'..(UserManager:getInstance().uid or '0')

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



local PromotionManager = class()

local instance = nil

function PromotionManager:createInstance()
	if instance == nil then
		instance = PromotionManager.new()
		instance:cancelAllNotification()
	end
end

function PromotionManager:getInstance()
	return instance
end

function PromotionManager:writeConfig( ... )
	return writeConfig(...)
end

function PromotionManager:readConfig( ... )
	return readConfig(...)
end


function PromotionManager:ctor()
	--缓存促销信息
	local data = readConfig()
	self.promotion = self:checkData(data)
	self.pennyData = self:checkPennyData(data)
	self.pulled = false
end

--联网查询促销信息 这个信息应该被缓存 后续调用不必网络通信
function PromotionManager:pullPromotionInfo(callback)
	if self.pulled == true then
		callback()
	else
		local complete = function(evt)
	    	self.pulled = true
	    	--检查是不是有效数据
	    	--如果格式不对 则返回nil
			self:writeConfig(evt.data)
	    	self.promotion = self:checkData(evt.data)
	    	self.pennyData = self:checkPennyData(evt.data)

	    	callback()
	    end
		local http = GetUnionPromotionInfo.new(true)
	    http:addEventListener(Events.kComplete, complete)
	    http:addEventListener(Events.kError, function(evt)
	    	callback()
	    end)
	    http:addEventListener(Events.kCancel, function(evt)
	    	callback()
	    end)
	    http:syncLoad(2)
	end
end

function PromotionManager:checkPennyData( data )
	if not data then return nil end
	if not data.pennyData then return nil end

	local pennyData = data.pennyData
	if type(pennyData) ~= 'table' then return nil end
	if type(pennyData.id) ~= 'number' then return nil end
	if type(pennyData.boughtCount) ~= 'number' then return nil end
	if type(pennyData.occurTime) ~= 'number' then return nil end
	if type(pennyData.endTime) ~= 'number' then return nil end
	return pennyData
end

function PromotionManager:checkData(data)
	if not data then return nil end
	if not data.promotion then return nil end

	local promotion = data.promotion
	if type(promotion) ~= 'table' then return nil end
	if type(promotion.id) ~= 'number' then return nil end
	if type(promotion.boughtCount) ~= 'number' then return nil end
	if type(promotion.occurTime) ~= 'number' then return nil end
	if type(promotion.endTime) ~= 'number' then return nil end
	return promotion
end

function PromotionManager:hasValidInfo()
	return self.promotion ~= nil
end

function PromotionManager:hasBought()
	return self.promotion and self.promotion.boughtCount > 0
end

function PromotionManager:getPennyPayRestTime( ... )
	if self.pennyData == nil then return 0 end
	local nowTime = Localhost:timeInSec()
	local endTime = self.pennyData.endTime
	return endTime - nowTime
end

function PromotionManager:getPennyPayGoodsId( ... )
	return 478
end

function PromotionManager:getRestTime()
	if not self:hasValidInfo() then
		return 0
	end

	local nowTime = Localhost:timeInSec()
	local endTime = self.promotion.endTime
	return endTime - nowTime
end

function PromotionManager:getDeadline()
	if not self:hasValidInfo() then
		return 0
	end

	return self.promotion.endTime
end

function PromotionManager:getGoodsId()
	if __ANDROID then
		return self.promotion.id
	elseif __IOS then
		local metaMgr = MetaManager.getInstance()
		local productMeta = metaMgr:getProductMetaByID(self.promotion.id)
		return productMeta.goodsId
	end
end


function PromotionManager:getPromotionId()
	return self.promotion.id
end

function PromotionManager:isTimeOut()
	return self:getRestTime() <= 0
end

function PromotionManager:isInPromotion()
	return not self:isPennyPayEnabled() and self:hasValidInfo() and (not self:hasBought()) and (not self:isTimeOut())
end

function PromotionManager:getLastTriggerTime()
	if self:hasValidInfo() then
		return self.promotion.occurTime
	else
		return 0
	end
end

--触发一次促销
--如果当前已经有促销信息，不应该调用这个
function PromotionManager:triggerPromotion(callback)

	local http = TriggerUnionPromotionInfo.new(true)
    http:addEventListener(Events.kComplete, function(evt)
    	--检查是不是有效数据
    	--如果格式不对 则返回nil
    	self:writeConfig(evt.data)
    	self.promotion = self:checkData(evt.data)
    	self.pennyData = self:checkPennyData(evt.data)

    	if self:isInPromotion() then
    		if not self.dcWmPromotion then
    			self.dcWmPromotion = true
	    		DcUtil:UserTrack({
					category = "shop",
					sub_category = "wm_promotion",
					goods_id = self:getGoodsId()
				})
			end
    	end
    	callback()
    end)
    http:addEventListener(Events.kError, function(evt)
    	callback()
    end)
    http:addEventListener(Events.kCancel, function(evt)
    	callback()
    end)
    http:syncLoad(2)
end

function PromotionManager:processNotification()
	if not self:isInPromotion() then 
		return 
	end

	local goodsId = self:getGoodsId()
	local restTime = self:getRestTime()

	if restTime <= 3600 then 
		return 
	end

	if __IOS then
    	local promotionType 
    	if goodsId == 362 or goodsId == 493 then
    		promotionType = IosOneYuanPromotionType.OneYuanFCash
    	else
    		promotionType = IosOneYuanPromotionType.OneYuanProp
    	end
    	LocalNotificationManager.getInstance():setIosSalesPromotionNoti(
    		promotionType, 
    		restTime - 3600 + os.time()
    	)
    end
    if __ANDROID then
    	local promotionType 
    	if goodsId == 366 or goodsId == 494 then
    		promotionType = AndroidSalesPromotionType.GoldSales
    	else
    		promotionType = AndroidSalesPromotionType.ItemSales
    	end
    	LocalNotificationManager.getInstance():setAndroidSalesPromotionNoti(
    		promotionType, 
    		restTime - 3600 + os.time()
    	)
    end
end

--进入游戏时 被调用一次  pullData
--如果有促销信息未过期 则显示
function PromotionManager:onEnterGame(retCb)
	--只运行一次
	if not self.runed then 
		self.runed = true

		if self:isPennyPayEnabled() then
			self:addPennyPayIconInHomeScene()
		elseif self:isInPromotion() then
			self:addPromotionIconInHomeScene()
		end

		self:pullPromotionInfo(function()

			if self:isPennyPayEnabled() then
				self:removePennyPayIconInHomeScene()
				self:addPennyPayIconInHomeScene()
			elseif self:isInPromotion() then
				self:removePromotionIconInHomeScene()
				self:addPromotionIconInHomeScene()
				self:removePennyPayIconInHomeScene()
			else
				self:removePromotionIconInHomeScene()
				self:removePennyPayIconInHomeScene()
			end
			if retCb then retCb() end
		end)

		GlobalEventDispatcher:getInstance():addEventListener(
			kGlobalEvents.kReturnFromGamePlay, 
			function()
				self:onPlayedLeveL()
			end
		)
	else
		if retCb then retCb() end
	end
end

--打完一关时调用
--如果不是正在促销信息 则尝试触发一次  如果触发成功  则显示
function PromotionManager:onPlayedLeveL()
	if not self:isInPromotion() or not self:isPennyPayEnabled() then
		if self:canTryTrigger() then
			self:triggerPromotion(function()
				if self:isInPromotion() then
					self:addPromotionIconInHomeScene()
				elseif self:isPennyPayEnabled() then
					self:addPennyPayIconInHomeScene()
				end
			end)
		end 
	end
end

function PromotionManager:tryTriggerFormGiftPack(cb)
	if self:isInPromotion() then
		return false
	end

	if self:hasBought() then
		return false
	end

	if __ANDROID and not self:isNeverPayInLastNDay(60) then
		return false
	end

	if __IOS and not self:isNeverApplePayInLastNDay(60) then
		return false
	end

	self:triggerPromotion(function()
		if self:isInPromotion() then
			self:addPromotionIconInHomeScene()
			if cb then cb(true) end
		end
	end)
end

function PromotionManager:canTryTrigger()
	if _G.isLocalDevelopMode then printx(0, '前端判断能不能去尝试一次触发') end
	local lastTriggerToNow = Localhost:timeInSec() - self:getLastTriggerTime()
	if lastTriggerToNow < 30*24*3600 then

		if _G.isLocalDevelopMode then
			-- RemoteDebug:uploadLog('二十天内 触发过 因此不触发')
		end

		return false
	end

	if GiftPack:isEnabled() then
		return false
	end

	if self:hasBought() then
		return false
	end

	if __ANDROID then
		return self:canAndroidTryTrigger()
	elseif __IOS then
		return self:canIOSTryTrigger()
	else
		if _G.isLocalDevelopMode then
			-- RemoteDebug:uploadLog('不是Android或ios 因此不触发')
		end

		return false
	end
end

function PromotionManager:canAndroidTryTrigger()
	if not self:isLevelMoreThan(40) then
		if _G.isLocalDevelopMode then
			-- RemoteDebug:uploadLog('等级不是40以下 因此不触发')
		end
		return false 
	end

	if self:isNeverPayInLastNDay(60) then
		if _G.isLocalDevelopMode then
			-- RemoteDebug:uploadLog('20天内未付费 因此触发')
		end

		return true 
	end
	
	return false
end

function PromotionManager:canIOSTryTrigger()
	if not self:isLevelMoreThan(40) then 
		-- if _G.isLocalDevelopMode then RemoteDebug:uploadLog('级别不够40') end 
		return false 
	end
	if not self:isNeverApplePayInLastNDay(60) then 
		-- if _G.isLocalDevelopMode then RemoteDebug:uploadLog('20天内花过钱') end 
		return false 
	end
	-- if _G.isLocalDevelopMode then RemoteDebug:uploadLog('苹果 触发') end
	return true
end

function PromotionManager:isNeverApplePayInLastNDay( n )
	local lastPayToNow = Localhost:time() - UserManager:getInstance():getUserExtendRef():getLastApplePayTime()
    return lastPayToNow >= n * 24 * 3600 * 1000, UserManager:getInstance():getUserExtendRef():getLastApplePayTime()
end

function PromotionManager:isNeverThirdPayInLastNDay( n )
	local lastPayToNow = Localhost:time() - UserManager:getInstance():getUserExtendRef():getLastThirdPayTime()
    return lastPayToNow >= n * 24 * 3600 * 1000, UserManager:getInstance():getUserExtendRef():getLastThirdPayTime()
end

function PromotionManager:isNeverPayInLastNDay(n)
	local lastPayToNow = Localhost:time() - UserManager:getInstance():getUserExtendRef():getLastPayTime()
    return lastPayToNow >= n * 24 * 3600 * 1000
end

function PromotionManager:isNeverPay()
	return not UserManager:getInstance():getUserExtendRef().payUser
end

function PromotionManager:isLevelMoreThan(n)
	return UserManager:getInstance().user:getTopLevelId() >= n
end

--在HomeScene展示促销Icon
function PromotionManager:addPromotionIconInHomeScene()
	if self.hadPromotionIcon then return end
	self.hadPromotionIcon = true

	local function onTap()
		if self.pulled == true then
        	self:enterHappyCoinShop()
        else
        	CommonTip:showNetworkAlert()
        end
    end
    local function callback()
    	if self:isInPromotion() then
	        local homeScene = HomeScene:sharedInstance()
	        if not homeScene.promotionIcon then
		        local icon = PromotionIcon:create()
		        homeScene:addIcon(icon)
		        homeScene.promotionIcon = icon
		        icon.wrapper:ad(DisplayEvents.kTouchTap, onTap)
	        end
	    end
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))
	--notification
	self:processNotification()
end

function PromotionManager:isPennyPayEnabled()
	local payment = PaymentBase:getPayment(Payments.ALIPAY)
	local data = self.pennyData
	local isEnabled = data and self:getPennyPayRestTime() > 0 and data.boughtCount <= 0
	return isEnabled and payment:isEnabled()
end

--在HomeScene展示1分购Icon
function PromotionManager:addPennyPayIconInHomeScene()
	if self.hadPennyPayIcon then return end
	self.hadPennyPayIcon = true

	local function onTap()
    	local panel =  createMarketPanel(MarketManager:sharedInstance():getHappyCoinPageIndex() or 3, nil, nil, Payments.ALIPAY)
		if panel then
			panel:setSource(1)
			panel:popout()
		end
    end
    local function callback()
    	if self:isPennyPayEnabled() then
	        local homeScene = HomeScene:sharedInstance()
	        if not homeScene.pennyPayIcon then
		        local icon = PennyPayIcon:create()
		        homeScene:addIcon(icon)
		        homeScene.pennyPayIcon = icon
		        icon.wrapper:ad(DisplayEvents.kTouchTap, onTap)
	        end
	    end
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))
end

function PromotionManager:removePennyPayIconInHomeScene()
	if not self.hadPennyPayIcon then return end
	self.hadPennyPayIcon = false

	--TODO:
	-- self:cancelAllNotification()

	local homeScene = HomeScene:sharedInstance()
    if homeScene.pennyPayIcon and not homeScene.pennyPayIcon.isDisposed then
        homeScene:removeIcon(homeScene.pennyPayIcon, true)
        homeScene.pennyPayIcon = nil
    end
end

function PromotionManager:cancelAllNotification()
	if __IOS then
    	LocalNotificationManager.getInstance():cancelAllIosSalesPromotion()
    end
    if __ANDROID then
    	LocalNotificationManager.getInstance():cancelAllAndroidSalesPromotion()
    end
end


local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

function PromotionManager:enterHappyCoinShop()
	local panel =  createMarketPanel(MarketManager:sharedInstance():getHappyCoinPageIndex() or 3)
	if panel then
		panel:setSource(1)
		panel:popout()
	end
end

function PromotionManager:removePromotionIconInHomeScene()
	if not self.hadPromotionIcon then return end
	self.hadPromotionIcon = false

	self:cancelAllNotification()

	local homeScene = HomeScene:sharedInstance()
    if homeScene.promotionIcon and not homeScene.promotionIcon.isDisposed then
        homeScene:removeIcon(homeScene.promotionIcon, true)
        homeScene.promotionIcon = nil
    end
end

function PromotionManager:onTimeOut()
	self.dcWmPromotion = false
	self:removePromotionIconInHomeScene()
	self:removePennyPayIconInHomeScene()

	if self.promotionEndCallback then
		self.promotionEndCallback()
	end
end

function PromotionManager:setPromotionEndCallback(callback)
	self.promotionEndCallback = callback
end

function PromotionManager:onBuySuccess()
	self.dcWmPromotion = false
	self.promotion.boughtCount = self.promotion.boughtCount + 1

	local data = readConfig()
	if data and data.promotion and data.promotion.boughtCount then
		data.promotion.boughtCount = data.promotion.boughtCount + 1
	end
	writeConfig(data)

	self:removePromotionIconInHomeScene()
end

function PromotionManager:onBuyPennySuccess()
	self.pennyData.boughtCount = self.pennyData.boughtCount + 1

	local data = readConfig()
	if data and data.pennyData and data.pennyData.boughtCount then
		data.pennyData.boughtCount = data.pennyData.boughtCount + 1
	end
	writeConfig(data)

	self:removePennyPayIconInHomeScene()
end

--如果有促销信息未过期则显示
--没有则尝试触发，触发成功则显示在商店，显示在藤蔓
function PromotionManager:onEnterHappyCoinShop(callback)
	if not self:isInPromotion() and not self:isPennyPayEnabled() then
		if self:canTryTrigger() then
			self:triggerPromotion(function()
				if self:isInPromotion() then
					self:addPromotionIconInHomeScene()
					callback(true)
				else
					callback()
				end
			end)
		else
			callback()
		end
	else
		callback()
	end
end

function PromotionManager:getPromotionInfo()
	return self.promotion
end

function PromotionManager:getProductId()
	if __IOS then
		local metaMgr = MetaManager.getInstance()
		local productMeta = metaMgr:getProductMetaByID(self.promotion.id)
		return productMeta.productId
	end
end

function PromotionManager:getFailTopShowKey( src )
	local key = 'promotion.show.fail.top'
	if src then
		key = key .. "src"
	end

	local uid = '12345'

    if UserManager and UserManager:getInstance().user then
    	uid = UserManager:getInstance().user.uid or '12345'
    end

    key = key .. '.' .. uid


    return key

end

function PromotionManager:hadShowPennyFailTop( ... )
	local key = self:getFailTopShowKey(".penny")
	return CCUserDefault:sharedUserDefault():getStringForKey(key) == tostring(self:getLastTriggerTime())
end

function PromotionManager:setShowPennyFailTop( ... )
	local key = self:getFailTopShowKey(".penny")
	CCUserDefault:sharedUserDefault():setStringForKey(key, tostring(self:getLastTriggerTime()))
end

function PromotionManager:hadShowFailTop( ... )
	local key = self:getFailTopShowKey()
	return CCUserDefault:sharedUserDefault():getStringForKey(key) == tostring(self:getLastTriggerTime())
end

function PromotionManager:setShowFailTop( ... )
	local key = self:getFailTopShowKey()
	CCUserDefault:sharedUserDefault():setStringForKey(key, tostring(self:getLastTriggerTime()))
end

function PromotionManager:setIapConfig( iapConfig )
	self.iapConfig = iapConfig
end

function PromotionManager:getLocaleByProductId( productId )
	for key, value in pairs(self.iapConfig or {}) do
		if value.productIdentifier == productId then
			return value.priceLocale or 'cny'
		end
	end
	return 'cny'
end

function PromotionManager:getLocalePriceByProductId( productId )
	for key, value in pairs(self.iapConfig or {}) do
		if value.productIdentifier == productId then
			return value.iapPrice
		end
	end
end

return PromotionManager