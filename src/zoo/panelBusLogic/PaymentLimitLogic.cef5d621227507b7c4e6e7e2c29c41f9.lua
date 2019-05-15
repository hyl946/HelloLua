require "zoo.payment.PaymentManager"

-- 需要限额的支付方式
-- local PaymentsMaxLimitMap = {
--     [Payments.CHINA_MOBILE] = { 
--     	daily=200,monthly=1000 
-- 	},
--     [Payments.CHINA_MOBILE_GAME] = { 
--     	daily=300,monthly=1000 
-- 	},
--     [Payments.CHINA_UNICOM] = { 
--     	daily=300,monthly=500 
-- 	},
--     [Payments.CHINA_TELECOM] = { 
--     	daily=100,monthly=300 
-- 	},
-- }

PaymentLimitLogic = {}

local IngameLimitCache = {}
local function getLimitConfig()
	local ingameLimit = UserManager.getInstance().ingameLimit

	if type(ingameLimit) == "string" then
		if not IngameLimitCache[ingameLimit] then
			IngameLimitCache[ingameLimit] = parseIngameLimitDict(ingameLimit)
		end
		return IngameLimitCache[ingameLimit]
	else
		local limitConfig = MetaManager:getInstance().global.ingame_limit
		-- if PaymentManager.getInstance():checkThirdPartPaymentEabled() then 
		-- 	--支持三方支付时 短代限额大幅下调 鼓励三方支付
		-- 	limitConfig = MetaManager:getInstance().global.ingame_limit_low
		-- end
		return limitConfig
	end
end

-- 当前支付方式是不是需要限额
function PaymentLimitLogic:isNeedLimit(paymentType)
	local limitConfig = getLimitConfig()
	if _G.isLocalDevelopMode then printx(0, table.tostring(limitConfig)) end

	return limitConfig[paymentType] ~= nil
end

-- 当前支付方式是不是超过限额
local function getPaymentInfosPath( ... )
	return HeResPathUtils:getUserDataPath() .. "/" .. "PaymentLimit_" .. MetaInfo:getInstance():getImsi()
end

local caches = {}
local function read( ... )
	if caches[getPaymentInfosPath()] then 
		return caches[getPaymentInfosPath()]
	end

	local ret = {}
	local file = io.open(getPaymentInfosPath(), "r")
	if file then
		local data = file:read("*a") 
		file:close()
		if data then
			ret = table.deserialize(data) or {}
		end
	end
	
	caches[getPaymentInfosPath()] = ret
	return ret
end

local function write( d )
	local file = io.open(getPaymentInfosPath(),"w")
	if file then 
		file:write(table.serialize(d or {}))
		file:close()
	end
end

local function getPaymentInfo( paymentType )

	-- local paymentInfo = UserManager:getInstance().paymentInfos[paymentType] 
	local paymentInfos = read()
	local paymentInfo = paymentInfos[paymentType]

	if paymentInfo then 
		local last = os.date("*t",(paymentInfo.lastModify or 0)/1000)
		local now = os.date("*t",Localhost:time()/1000)
		if now.year > last.year or now.month > last.month or now.day > last.day then 
			paymentInfo.daily = 0
		end
		if now.year > last.year or now.month > last.month then 
			paymentInfo.monthly = 0
		end
	else
		paymentInfo = { daily=0,monthly=0,lastModify=Localhost:time() }
		-- UserManager:getInstance().paymentInfos[paymentType] = paymentInfo
		paymentInfos[paymentType] = paymentInfo
	end
	-- smsDayRmb 和 smsMonthRmb 如果有值 那么直接用 
	if UserManager:getInstance().smsDayRmb then
		paymentInfo.daily = UserManager:getInstance().smsDayRmb / 100
	end
	if UserManager:getInstance().smsMonthRmb then
		paymentInfo.monthly = UserManager:getInstance().smsMonthRmb / 100
	end


	if _G.isLocalDevelopMode then printx(0, "paymentInfos",table.tostring(paymentInfos)) end

	return paymentInfo,paymentInfos
end

function PaymentLimitLogic:getPaymentLimitInfo( paymentType )
	local limitConfig = getLimitConfig()
	if limitConfig[paymentType] then 
		local paymentInfo = getPaymentInfo(paymentType)
		local daily = {
			used = paymentInfo.daily,
			limit = limitConfig[paymentType].daily
		}

		local monthly = {
			used = paymentInfo.monthly,
			limit = limitConfig[paymentType].monthly
		}
		return { daily = daily,monthly = monthly}
	else
		return false
	end
end

function PaymentLimitLogic:isExceedDailyLimit(paymentType)
	local limitConfig = getLimitConfig()
	if limitConfig[paymentType] then 
		local paymentInfo = getPaymentInfo(paymentType)
		return paymentInfo.daily >= limitConfig[paymentType].daily
	else
		return false
	end
end
function PaymentLimitLogic:isExceedMonthlyLimit(paymentType)
	local limitConfig = getLimitConfig()
	if limitConfig[paymentType] then 
		local paymentInfo = getPaymentInfo(paymentType)
		return paymentInfo.monthly >= limitConfig[paymentType].monthly
	else
		return false
	end
end

-- 
function PaymentLimitLogic:buyComplete(paymentType,price)
	local limitConfig = getLimitConfig()
	if limitConfig[paymentType] then 
		local paymentInfo,paymentInfos = getPaymentInfo(paymentType)

		local daily_Max = limitConfig[paymentType].daily
		local monthly_Max = limitConfig[paymentType].monthly

		--支付限额相关 支付完成后 客户端的  当前日限额 当前月限额数据 当前购买的数量 读取到的最大日限额 读取到的最大月限额 
		DcUtil:paymentLimitBuyComplete( paymentType , paymentInfo.daily , paymentInfo.monthly , price, daily_Max, monthly_Max )

		paymentInfo.daily = paymentInfo.daily + price
		paymentInfo.monthly = paymentInfo.monthly + price
		paymentInfo.lastModify = Localhost:time()

		-- UserManager 和 UserService 也修改
		UserManager:getInstance().smsDayRmb = paymentInfo.daily * 100
		UserManager:getInstance().smsMonthRmb = paymentInfo.monthly * 100
		UserService:getInstance().smsDayRmb = paymentInfo.daily * 100
		UserService:getInstance().smsMonthRmb = paymentInfo.monthly * 100
		Localhost:getInstance():flushCurrentUserData()

		if _G.isLocalDevelopMode then printx(0, table.tostring(paymentInfos)) end

		write(paymentInfos)
	end
end

