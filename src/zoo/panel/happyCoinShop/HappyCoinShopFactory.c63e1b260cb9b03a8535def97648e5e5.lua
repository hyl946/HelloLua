-- 为了AbTest
-- 1. 根据情况选择:
		-- + 使用旧功能
		-- + 用空代理取代旧功能
-- 2. 根据情况选择:
		-- + 使用原有MarketPanel
		-- + 使用新的MarketPanel


--新注释 2017/5.25
--同时存在4版 风车币商店以及促销功能
--1.33 1.39 1.45_A 1.45_B

--1.33 和 1.39 1.45_A 1.45_B 的协议迥然不同
--1.39 和 1.45_A 1.45_B 的协议是极度相似的
--1.45_A 和 1.45_B 协议完全一样 ，ui不同
--1.45_A 和 1.39 ui一致

HappyCoinShopFactory = class()

-- 工厂方法
local instance = nil

function HappyCoinShopFactory:createInstance()
	if instance == nil then
		if _G.isLocalDevelopMode then printx(0, 'HappyCoinShopFactory:createInstance') end
		instance = HappyCoinShopFactory.new()
	end
end

function HappyCoinShopFactory:getInstance()
	return instance
end

function HappyCoinShopFactory:ctor()
	self.initd = false
end

function HappyCoinShopFactory:init()
	self.initd = true
	if self:shouldUseNewfeatures() then
		local nullProxy = require 'zoo.panel.happyCoinShop.NullProxy'

		self.iosPayGuide = nullProxy.iosPayGuide
		self.androidSalesManager = nullProxy.androidSalesManager
		

		if self:shouldUse_1_45() then
			if self:shouldUse_1_45_A() then
				self.iosGoldPage = require 'zoo.panel.happyCoinShop.IOSGoldPage'
				self.androidGoldPage = require 'zoo.panel.happyCoinShop.AndroidGoldPage'
				self.marketPanel = require 'zoo.panel.happyCoinShop.NewMarketPanel'
			else


				-- 已经写死 总会是这三只
				self.iosGoldPage = require 'zoo.panel.happyCoinShop.IOSGoldPage_1_45_B'
				self.androidGoldPage = require 'zoo.panel.happyCoinShop.AndroidGoldPage_1_45_B'
				self.marketPanel = require 'zoo.panel.happyCoinShop.NewMarketPanel'

			end
		else
			self.iosGoldPage = require 'zoo.panel.happyCoinShop.IOSGoldPage'
			self.androidGoldPage = require 'zoo.panel.happyCoinShop.AndroidGoldPage'
			self.marketPanel = require 'zoo.panel.happyCoinShop.NewMarketPanel'
		end

	else
		require 'zoo.gameGuide.IosPayGuide'
		require 'zoo.panel.androidSalesPromotion.AndroidSalesManager'
		require 'zoo.panel.MarketPanel'

		self.iosPayGuide = IosPayGuide
		self.androidSalesManager = AndroidSalesManager
		self.marketPanel = MarketPanel

		pcall(function ( ... )
			local platform = StartupConfig:getInstance():getPlatformName()
			if platform == 'he' then
				he_log_error(string.format(
					"HappyCoinShopFactory platform: %s __ANDROID: %s stack: %s", 
					platform,
					__ANDROID,
					debug.traceback()
				))
			end
		end)
	end

end

--false 代表 1.33版
--true 代表 >= 1.39版
function HappyCoinShopFactory:shouldUseNewfeatures()
	return self:__shouldUseNewfeatures()
end

function HappyCoinShopFactory:__shouldUseNewfeatures()
	local uid = UserManager.getInstance().user.uid or '12345'
	uid = tonumber(uid) or 0
	local percent = uid % 100
	if __IOS then
		return true
	elseif __ANDROID then
		return PaymentBase:checkPaymentForPromotion()
	elseif __WIN32 then
		return true
	end
	return false
end

function HappyCoinShopFactory:shouldUse_1_45( ... )
	if __WIN32 then return true end
	return self:shouldUseNewfeatures()
end

function HappyCoinShopFactory:shouldUse_1_45_A( ... )
	if __WIN32 then return false end
	return false
end

function HappyCoinShopFactory:shouldUse_1_45_B( ... )
	return self:shouldUse_1_45() and (not self:shouldUse_1_45_A())
end

--小心翼翼的访问旧促销的数据
function HappyCoinShopFactory:hasOldIosPromotion()
    local oldModel = require("zoo.gameGuide.IosPayGuideModel"):create()
    oldModel:deserialize()
    return oldModel:isInFCashPromotion() or oldModel:isInOneYuanShopPromotion()
end

function HappyCoinShopFactory:hasOldAndroidPromotion()
	local OldAndroidPromotionMgr = require 'zoo.panel.happyCoinShop.OldAndroidPromotionMgr'
	local oldMgr = OldAndroidPromotionMgr.getInstance()
	return oldMgr:isInItemSalesPromotion() or oldMgr:isInGoldSalesPromotion()
end


function HappyCoinShopFactory:getIosPayGuide()
	if not self.initd then
		self:init()
	end
	return self.iosPayGuide
end

function HappyCoinShopFactory:getAndroidSalesManager()
	if not self.initd then
		self:init()
	end
	return self.androidSalesManager
end

function HappyCoinShopFactory:getMarketPanel()
	if not self.initd then
		self:init()
	end
	return self.marketPanel
end

function HappyCoinShopFactory:getAndroidGoldPage( ... )
	if not self.initd then
		self:init()
	end
	return self.androidGoldPage
end

function HappyCoinShopFactory:getIosGoldPage( ... )
	if not self.initd then
		self:init()
	end
	return self.iosGoldPage
end

HappyCoinShopFactory:createInstance()