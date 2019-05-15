-- 使用说明：
-- 文件用于测试不同条件下 PaymentManager 作出的决策是否正确
-- 使用前需修改以下部分：
-- AndroidPayment.lua 的 defaultSMSPaymentDecision 改为全局变量
-- PlatformConfig.lua 添加两个函数：
-- function PlatformConfig:getAndroidPlatformConfig()
--     return AndroidPlatformConfigs
-- end

-- function PlatformConfig:getForkPlatformMap()
--     return ForkPlatformMap
-- end
-- 执行后会在 Data 目录下生成 paycheck 文本文件
-- \t作为分隔符进行格式化 可以直接导入 Excel 使用


-- 测试环境：设置支付宝为可用
PaymentManager.getInstance().checkHaveAliAPP = function()
	return true
end
-- 测试环境：直接返回短代支付方式
PaymentManager.getInstance().getDefaultSmsPayment = function()
	return AndroidPayment.getInstance():getDefaultSmsPayment()
end
-- 测试环境
AndroidPayment.getInstance().registerPayment = function(self, paymentType)
end
-- 测试环境：是否触发一元特卖条件
PaymentManager.getInstance().checkNeedOneYuanPay = function(self, goodsId)
	if not goodsId then return end
	if self:getHasFirstThirdPay() then return end
	if not self:checkThirdPartPaymentEabled() then return end
	if not self:checkHasRealThirdPay() then return end

	if self.oneYuanGoodsId and self.oneYuanGoodsId ~= goodsId then
		return
	end

	local needShow = false
	for k,v in pairs(ThirdPayPromotionConfig) do
		if k == goodsId then 
			needShow = true
			break
		end
	end
	if not needShow then return end

	return true
end
-- 测试环境：输出文件
local file;
local testCount = 0;
-- 测试环境：替换print
local oldPrint = print
print = function() end
my_print = oldPrint
function debug_print(...)
	-- oldPrint(unpack{...})
	local para = {...}
	file:write(table.concat({...}, '\t')..'\n')
	io.flush(file)
end



-- 设置平台
local function setPlatform(payment)
	PlatformConfig.paymentConfig = payment
	AndroidPayment:getInstance():initPaymentConfig(payment)
end
-- 设置Sim卡
local originalSetOperator = AndroidPayment.getInstance().getOperator
local function setOperator(value)
	AndroidPayment.getInstance().getOperator = function(self)
			return value
		end
end
-- 设置是否支持短代支付（省份支付切换）
local operatorToPayment = {
	[TelecomOperators.CHINA_MOBILE] = {Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME},
	[TelecomOperators.CHINA_UNICOM] = {Payments.CHINA_UNICOM},
	[TelecomOperators.CHINA_TELECOM] = {Payments.CHINA_TELECOM},
}
local function setSmsPayLimit(bool)
	local operator = AndroidPayment:getInstance():getOperator()
	local res = {}
	if not bool then
		if _G.isLocalDevelopMode then printx(0, table.tostring(operatorToPayment), operator) end
		res = table.clone(operatorToPayment[operator] or {})
	else
	end
	AndroidPayment.getInstance().getSmsPayments = function(self)
		return res
	end
end
-- 设置超过短代额度
local function setPaymentLimitPassed(bool)
	PaymentManager:getInstance().smspayPassLimit = bool
end
-- 设置优先支付方式
local function setPayTypeWithTopPriority(paytype)
	PaymentManager:getInstance().defaultPayment = paytype
end
-- 设置是否未支付过三方
local function setHasFirstThirPay(bool)
	PaymentManager:getInstance().hasFirstThirdPay = bool
end
-- 设置是否能使用短代支付
local originalCheckSmsPayEnabled = PaymentManager.getInstance().checkSmsPayEnabled
local function setCanPayWithSms(bool)
	PaymentManager.getInstance().checkSmsPayEnabled = function(self)
		return bool
	end
end
-- 设置是否能使用三方支付
local originalCheckThirdPartyPaymentEabled = PaymentManager.getInstance().checkThirdPartPaymentEabled
local function setCanPayWithThirdPay(bool)
	PaymentManager.getInstance().checkThirdPartPaymentEabled = function(self)
		return bool
	end
end
-- 设置是否触发转化三方支付
local originalCheckNeedOneYuanPay = PaymentManager.getInstance().checkNeedOneYuanPay
local function setIsOneYuanPay(bool)
	PaymentManager.getInstance().checkNeedOneYuanPay = function(self, goodsId)
		return bool
	end
end
local originalNetworkEnabled = PaymentNetworkCheck.getInstance().check
local function setNetworkEnabled(bool)
	PaymentNetworkCheck:getInstance().check = function(self, successCallback, failCallback)
		if bool then
			if successCallback then successCallback() end
		else
			if failCallback then failCallback() end
		end
	end
end


-- //////////////////////
-- 测试 1：
-- ××来源：
-- 短代可用额度是否足够
-- 是否省份/渠道支持短代支付（支付切换）
-- 是否有Sim卡

-- ××结果：
-- 短代支付是否可用
local function test1Sub(simName, platform, province, passLimit)
	setSmsPayLimit(province)
	setPaymentLimitPassed(passLimit)
	local res, reason = PaymentManager:getInstance():checkSmsPayEnabled()
	if res then
		debug_print("平台: "..tostring(platform).."; SIM: "..simName.."; 省份限制: "..tostring(province).."; 超限额: "..tostring(passLimit)..
			"; 支付: "..tostring(res))
	end
end
local function test1()
	debug_print("测试 1：短代是否可用")
	for k, v in pairs(TelecomOperators) do
		for k1, v1 in pairs(PlatformConfig:getAndroidPlatformConfig()) do
			local packages = PlatformConfig:getForkPlatformMap()[k1]
			local packageStr
			if type(packages) == "table" then
				packageStr = table.concat(packages, ', ')
			else
				packageStr = tostring(PlatformNameEnum[k1])
			end
			setOperator(v)
			setPlatform(v1.paymentConfig)
			test1Sub(k, packageStr, true, true)
			test1Sub(k, packageStr, true, false)
			test1Sub(k, packageStr, false, true)
			test1Sub(k, packageStr, false, false)
		end
	end
end

-- ////////////////////
-- 测试 2：
-- ××来源：
-- 是否有支持的三方支付方式
-- 是否联网

-- ××结果：
-- 是否支持三方支付
local function test2()
	debug_print("测试 2：三方是否可用")
	for k1, v1 in pairs(PlatformConfig:getAndroidPlatformConfig()) do
		local packages = PlatformConfig:getForkPlatformMap()[k1]
		debug_print("/////////////////////////////////////")
		if type(packages) == "table" then
			debug_print("平台: "..table.concat(packages, ', '))
		else
			debug_print("平台: "..tostring(PlatformNameEnum[k1]))
		end
		setPlatform(v1.paymentConfig)
		debug_print("支付: "..tostring(PaymentManager:getInstance():checkThirdPartPaymentEabled()))
	end
end

-- ////////////////////
-- 测试 3：
-- ××来源：
-- 支付来源
-- 支持三方支付
-- 支持短代支付
-- 未支付过三方
-- 当前优先短代支付

-- ××结果：
-- 是否触发转化三方支付
local test3Goods = {2, 24, 33, 150}
local test3ExceptPayments = {Payments.MDO, Payments.IOS_RMB}
local function test3Sub(simName, payName, thirdPaymentPaid, canPayWithSms, canPayWithThirdPay)
	setHasFirstThirPay(thirdPaymentPaid)
	setCanPayWithSms(canPayWithSms)
	setCanPayWithThirdPay(canPayWithThirdPay)
	for i, v in ipairs(test3Goods) do
		if PaymentManager:getInstance():checkNeedOneYuanPay(v) or false then
			debug_print("SIM: "..tostring(simName).."; 三方支持: "..tostring(PaymentManager:getInstance():checkThirdPartPaymentEabled()).."; 短代支持: "..
				tostring(PaymentManager:getInstance():checkSmsPayEnabled()).."; 优先支付: "..tostring(payName).."; 商品ID: "..tostring(v)..
				"; 支付过三方: "..tostring(thirdPaymentPaid).."; 触发转化三方支付: "..tostring(PaymentManager:getInstance():checkNeedOneYuanPay(v) or false))
		end
	end
end
local function test3()
	debug_print("测试 3：是否触发转化三方支付")
	for k, v in pairs(TelecomOperators) do
		setOperator(v)
		for k1, v1 in pairs(PlatformConfig:getAndroidPlatformConfig()) do
			local packages = PlatformConfig:getForkPlatformMap()[k1]
			debug_print("/////////////////////////////////////")
			if type(packages) == "table" then
				debug_print("平台: "..table.concat(packages, ', '))
			else
				debug_print("平台: "..tostring(PlatformNameEnum[k1]))
			end
			setPlatform(v1.paymentConfig)
			for k2, v2 in pairs(Payments) do
				if not table.indexOf(test3ExceptPayments, v) then
					setPayTypeWithTopPriority(v2)
					test3Sub(k, k2, true, true, true)
					test3Sub(k, k2, true, true, false)
					test3Sub(k, k2, true, false, true)
					test3Sub(k, k2, true, false, false)
					test3Sub(k, k2, false, true, true)
					test3Sub(k, k2, false, true, false)
					test3Sub(k, k2, false, false, true)
					test3Sub(k, k2, false, false, false)
				end
			end
		end
	end
end

-- ////////////////////
-- 测试 4：

-- ××来源：
-- 支付来源
-- 是否触发转化三方支付
-- 三方支付是否可用（是否联网）
-- 短代是否可用
-- 优先支付方式：短代、三方支付

-- ××结果：
-- 确定的当前支付方式，确定的支付价格（原GoodsId和折价GoodsId），确定的备选支付方式
local decisionToStr = {
	[IngamePaymentDecisionType.kPayFailed] = "支付失败",
	[IngamePaymentDecisionType.kPayWithType] = "指定支付方式",
	[IngamePaymentDecisionType.kSmsPayOnly] = "仅短代支付",
	[IngamePaymentDecisionType.kThirdPayOnly] = "仅三方支付",
	[IngamePaymentDecisionType.kSmsWithOneYuanPay] = "都可用时同时转化三方",
	[IngamePaymentDecisionType.kThirdOneYuanPay] = "仅三方可用时一元限购",
	[IngamePaymentDecisionType.kGoldOneYuanPay] = "一元购买风车币",
}
local function test4Sub(operator, payName, thirdPaymentPaid, canPayWithSms, canPayWithThirdPay)
	setHasFirstThirPay(thirdPaymentPaid)
	setCanPayWithSms(canPayWithSms)
	setCanPayWithThirdPay(canPayWithThirdPay)
	for i, v in ipairs(test3Goods) do
		PaymentManager:getInstance():getRMBBuyItemDecision(function(decision, firstPayment, payTable)
				local tab = {}
				table.foreach(payTable or {}, function(v)
						table.insert(tab, tostring(table.keyOf(Payments, v)))
					end)
				debug_print("运营商: "..tostring(operator).."; 三方支持: "..tostring(canPayWithThirdPay).."; 短代支持: "..
					tostring(canPayWithSms).."; 优先支付: "..tostring(payName).."; 商品ID: "..tostring(v)..
					"; 触发转化三方支付: "..tostring(thirdPaymentPaid).."; 支付方式: "..tostring(decisionToStr[decision]).."; 首选支付方式: "..
					tostring(table.keyOf(Payments, firstPayment)).."; 其他支付: "..table.concat(tab, ','))
			end, v)
	end
end
local function test4()
	debug_print("测试 4：获取支付策略（测试排除有道具和有足够风车币的状况）")
	for k, v in pairs(TelecomOperators) do
		setOperator(v)
		for k1, v1 in pairs(PlatformConfig:getAndroidPlatformConfig()) do
			local packages = PlatformConfig:getForkPlatformMap()[k1]
			debug_print("/////////////////////////////////////")
			if type(packages) == "table" then
				debug_print("平台: "..table.concat(packages, ', '))
			else
				debug_print("平台: "..tostring(PlatformNameEnum[k1]))
			end
			setPlatform(v1.paymentConfig)
			for k2, v2 in pairs(Payments) do
				if not table.indexOf(test3ExceptPayments, v) then
					setPayTypeWithTopPriority(v2)
					test4Sub(k, k2, true, true, true)
					test4Sub(k, k2, true, true, false)
					test4Sub(k, k2, true, false, true)
					test4Sub(k, k2, true, false, false)
					test4Sub(k, k2, false, true, true)
					test4Sub(k, k2, false, true, false)
					test4Sub(k, k2, false, false, true)
					test4Sub(k, k2, false, false, false)
				end
			end
		end
	end
end

-- ///////////////////
-- 测试：

-- ××来源：
-- 短代可用额度是否足够
-- 是否省份/渠道支持短代支付（支付切换）
-- 未支付过三方
-- 支付来源
-- 是否联网

-- Sim卡
-- 三方支付方式
-- 优先支付方式

-- ××结果：
-- 确定的当前支付方式，确定的支付价格（原GoodsId和折价GoodsId），确定的备选支付方式
local failReason2Str = {
	[AndroidRmbPayResult.kSuccess] = "支付成功",
	[AndroidRmbPayResult.kNoPaymentAvailable] = "没有可用的支付方式",
	[AndroidRmbPayResult.kNoNet] = "未联网",
}
local function totalTestSub(platform, sim, payName, network, thirdPaymentPaid)
	setHasFirstThirPay(thirdPaymentPaid)
	setNetworkEnabled(network)

	for i, v in ipairs(test3Goods) do
		PaymentManager:getInstance():getRMBBuyItemDecision(function(decision, firstPayment, _, payTable, repayTable)
				local tab1, tab2 = {}, {}
				table.foreach(payTable or {}, function(k, v)
						table.insert(tab1, tostring(table.keyOf(Payments, v)))
					end)
				table.foreach(repayTable or {}, function(k, v)
						table.insert(tab2, tostring(table.keyOf(Payments, v)))
					end)
				-- if decision == IngamePaymentDecisionType.kPayFailed then
				-- 	debug_print(.."; 平台: "..tostring(platform).."; SIM: "..tostring(sim)..
				-- 		"; 三方支持: "..tostring(PaymentManager:getInstance():checkThirdPartPaymentEabled())..
				-- 		"; 短代支持: "..tostring(PaymentManager:getInstance():checkSmsPayEnabled()).."; 优先支付: "..tostring(payName).."; 商品ID: "..tostring(v)..
				-- 		"; 联网: "..tostring(network).."; 支付过三方: "..tostring(thirdPaymentPaid).."; 支付方式: "..tostring(decisionToStr[decision])..
				-- 		"; 首选支付方式: "..tostring(failReason2Str[firstPayment]).."; 其他支付: "..table.concat(tab1, ',').."; 失败后支付: "..table.concat(tab2, ','))
				-- else
				-- 	debug_print(.."; 平台: "..tostring(platform).."; SIM: "..tostring(sim)..
				-- 		"; 三方支持: "..tostring(PaymentManager:getInstance():checkThirdPartPaymentEabled())..
				-- 		"; 短代支持: "..tostring(PaymentManager:getInstance():checkSmsPayEnabled()).."; 优先支付: "..tostring(payName).."; 商品ID: "..tostring(v)..
				-- 		"; 联网: "..tostring(network).."; 支付过三方: "..tostring(thirdPaymentPaid).."; 支付方式: "..tostring(decisionToStr[decision])..
				-- 		"; 首选支付方式: "..tostring(table.keyOf(Payments, firstPayment)).."; 其他支付: "..table.concat(tab1, ',').."; 失败后支付: "..table.concat(tab2, ','))
				-- end
				if decision == IngamePaymentDecisionType.kPayFailed then
					debug_print(tostring(platform), tostring(sim),
						tostring(PaymentManager:getInstance():checkThirdPartPaymentEabled()), 
						tostring(PaymentManager:getInstance():checkSmsPayEnabled()), tostring(payName), tostring(v),
						tostring(network), tostring(thirdPaymentPaid), tostring(decisionToStr[decision]), 
						tostring(failReason2Str[firstPayment]), table.concat(tab1, ','), table.concat(tab2, ','))
				else
					debug_print(tostring(platform), tostring(sim),
						tostring(PaymentManager:getInstance():checkThirdPartPaymentEabled()), 
						tostring(PaymentManager:getInstance():checkSmsPayEnabled()), tostring(payName), tostring(v),
						tostring(network), tostring(thirdPaymentPaid), tostring(decisionToStr[decision]), 
						tostring(table.keyOf(Payments, firstPayment)), table.concat(tab1, ','), table.concat(tab2, ','))
				end
			end, v)
	end
end
local function totalTest()
	for k1, v1 in pairs(TelecomOperators) do
		setOperator(v1)
		for k2, v2 in pairs(PlatformConfig:getAndroidPlatformConfig()) do
			local packages, platformStr = PlatformConfig:getForkPlatformMap()[k2]
			if type(packages) == "table" then
				packages = table.clone(packages)
				if PlatformNameEnum[k2] then
					table.insert(packages, 1, tostring(PlatformNameEnum[k2]))
					table.unique(packages, true)
				end
				platformStr = table.concat(packages, ', ')
			else
				platformStr = tostring(PlatformNameEnum[k2])
			end
			-- my_print("input", table.tostring(v2.paymentConfig))
			setPlatform(v2.paymentConfig)
			-- my_print("output", table.tostring(PlatformConfig.paymentConfig))
			local isSmsPaymentTested = false
			for k3, v3 in pairs(Payments) do
				if not table.indexOf(test3ExceptPayments, v) and (table.indexOf(v2.paymentConfig.thirdPartyPayment, v3) or
					table.indexOf(v2.paymentConfig.chinaMobilePayment, v3) or v2.paymentConfig.chinaUnicomPayment == v3 or
					v2.paymentConfig.chinaTelecomPayment == v3) and not isSmsPaymentTested then
					local finalK3 = k3
					if (table.indexOf(v2.paymentConfig.chinaMobilePayment, v3) or v2.paymentConfig.chinaUnicomPayment == v3 or
						v2.paymentConfig.chinaTelecomPayment == v3) then
						if AndroidPayment.getInstance():getDefaultSmsPayment() and AndroidPayment.getInstance():getDefaultSmsPayment() ~= 0 then
							setPayTypeWithTopPriority(AndroidPayment.getInstance():getDefaultSmsPayment())
							finalK3 = tostring(table.keyOf(Payments, AndroidPayment.getInstance():getDefaultSmsPayment()))
						else
							setPayTypeWithTopPriority(v3)
						end
						isSmsPaymentTested = true
					else
						setPayTypeWithTopPriority(v3)
					end
					totalTestSub(platformStr, k1, finalK3, true, true)
					totalTestSub(platformStr, k1, finalK3, false, true)
					totalTestSub(platformStr, k1, finalK3, true, false)
					totalTestSub(platformStr, k1, finalK3, false, false)
				end
			end
		end
	end
end

return function()
	local path = HeResPathUtils:getUserDataPath() .. "/paycheck"
	file = io.open(path, "w")
	-- test1()
	-- test2()
	-- test3()
	-- test4()
	-- PaymentManager.getInstance().checkSmsPayEnabled = originalCheckSmsPayEnabled
	-- PaymentManager.getInstance().checkThirdPartPaymentEabled = originalCheckThirdPartyPaymentEabled
	-- PaymentManager.getInstance().checkNeedOneYuanPay = originalCheckNeedOneYuanPay
	totalTest()

	setTimeOut(function() io.close(file) end, 10)
end