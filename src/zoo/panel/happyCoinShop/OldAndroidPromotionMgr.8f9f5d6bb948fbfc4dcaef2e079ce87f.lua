--用于访问旧版安卓促销的本地数据
local OldAndroidPromotionMgr = class()
local instance = nil

local AndroidSalesPromotionType = {
    ItemSales = 1,
    GoldSales = 2,   
}

local AndroidSalesPromotionLocation = {
	kNormal = 1,
	kSpecial = 2,	
}

local configPath = HeResPathUtils:getUserDataPath() .. '/android_pay_guide_config_'..(UserManager:getInstance().uid or '0')
local forcePopKey = "android.sales.promotion.pop"


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

function OldAndroidPromotionMgr.getInstance()
	if not instance then
		instance = OldAndroidPromotionMgr.new()
		instance:init()
	end
	return instance
end

function OldAndroidPromotionMgr:init()
	self.itemSalesInfo = {}
	self.goldSalesInfo = {}
	self.itemSalesPanel = nil 
	self.showOneYuanItemAni = true

	self:deserialize()
end


--初始化
function OldAndroidPromotionMgr:initSalesPromotion(salesPromotionInfo)
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

function OldAndroidPromotionMgr:deserialize()
	local info = readConfig()
	self:initSalesPromotion(info)
end

function OldAndroidPromotionMgr:isInItemSalesPromotion()
	local lastOccurTime = tonumber(self.itemSalesInfo.occurTime) or 0
	local now = Localhost:time()/1000
	return now >= lastOccurTime and now < self:getItemSalesEndTime() and self:getItemSalesBuyCount() < 1
end


function OldAndroidPromotionMgr:getItemSalesEndTime()
	return tonumber(self.itemSalesInfo.endTime) or 0
end

function OldAndroidPromotionMgr:getItemSalesBuyCount()
	return tonumber(self.itemSalesInfo.boughtCount) or 0
end

function OldAndroidPromotionMgr:isInGoldSalesPromotion()
	local lastOccurTime = tonumber(self.goldSalesInfo.occurTime) or 0
	local now = Localhost:time()/1000
	return now >= lastOccurTime and now < self:getGoldSalesEndTime() and self:getGoldSalesBuyCount() < 1
end

function OldAndroidPromotionMgr:getGoldSalesEndTime()
	return tonumber(self.goldSalesInfo.endTime) or 0
end

function OldAndroidPromotionMgr:getGoldSalesBuyCount()
	return tonumber(self.goldSalesInfo.boughtCount) or 0
end

return OldAndroidPromotionMgr