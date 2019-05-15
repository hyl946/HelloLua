if __IOS then
	require "zoo.util.IosPayment"
	require 'zoo.gameGuide.IosPayGuide'
	require 'zoo.panel.iosSalesPromotion.IosSalesManager'
end

IapBuyPropLogic = class()

--@param productInfo 传goodsId或者外面构建好的productInfo(目前是为了兼容原来的调用 以后不要自己构建)
function IapBuyPropLogic:create(productInfo, feature, source, dcIosInfo)
	local logic = IapBuyPropLogic.new()
	logic.feature = feature
	logic.source = source
	local initSuc = false 
	if type(productInfo) == "number" then 
		initSuc = logic:init(productInfo, dcIosInfo)
	elseif type(productInfo) == "table" then 
		if _G.isLocalDevelopMode then he_log_warning("Warning:This is not the recommended invocation") end
		initSuc = logic:initWithInfo(productInfo, dcIosInfo)
	end

	if initSuc then 
		return logic
	else
		return nil
	end
end

function IapBuyPropLogic:init(goodsId, dcIosInfo)
	local product = MetaManager:getInstance():getProductMetaByGoodsId(goodsId)
	if product then 
		local meta = MetaManager:getInstance():getGoodMeta(product.goodsId)
		if not meta then 
			he_log_error("IapBuyPropLogic::init==error: no meta of goodsId "..goodsId)
			return false 
		end 
		self.data = {
			id = product.id, 
			price = product.price, 
			items = table.clone(meta.items), 
			goodsId = product.goodsId,
			productIdentifier = product.productId,
			-- discount = product.discount, 		--这个打折信息不应该配在product里 应该跟goods表统一
			priceLocale = 'CNY',
		}

		self:initDcInfo(dcIosInfo)

		return true
	else
		he_log_error("IapBuyPropLogic::init==error: no product meta of goodsId "..goodsId)
		return false 
	end
end

function IapBuyPropLogic:setActivityId(activityId)
	self.activityId = activityId
end

--如果面板有这方面处理 这里和面板保持一致
function IapBuyPropLogic:setPriceLocale(priceLocale)
	if self.data then 
		self.data.priceLocale = priceLocale
	end
end

function IapBuyPropLogic:initWithInfo(productInfo, dcIosInfo)
	self.data = productInfo
	self:initDcInfo(dcIosInfo)
	return true
end

function IapBuyPropLogic:initDcInfo(dcInfo)
	local _dcIosInfo = dcInfo
	if not _dcIosInfo then
		_dcIosInfo = DCIosRmbObject:create()
	    _dcIosInfo:setGoodsId(self.data.productIdentifier)
	    _dcIosInfo:setGoodsType(1)
	    _dcIosInfo:setGoodsNum(1)
	    _dcIosInfo:setRmbPrice(self.data.price)
	end
	self.dcIosInfo = _dcIosInfo
end

function IapBuyPropLogic:buy(successCallback, failCallback)
	local function onSuccess()
		local stageInfo = StageInfoLocalLogic:getStageInfo(UserManager:getInstance().user.uid)
		local levelId = 0
		if stageInfo then levelId = stageInfo.levelId end

		local valueCalculator = GainAndConsumeMgr.getInstance():getPayValueCalculator(self.data.items, self.data.price * 100, DcPayType.kRmb)
		for __, v in pairs(self.data.items) do
			UserManager:getInstance():addReward(v, true)
			UserService:getInstance():addReward(v)
			local value = valueCalculator:getItemSellPrice(v.itemId)
			GainAndConsumeMgr.getInstance():gainItem(self.feature, v.itemId, v.num, self.source, levelId, self.activityId, DcPayType.kRmb, value, self.data.goodsId)
		end

		local userExtend = UserManager:getInstance().userExtend
		if userExtend then userExtend.payUser = true end

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end

		self.dcIosInfo:setResult(IosRmbPayResult.kSuccess)
    	PaymentIosDCUtil.getInstance():sendIosRmbPayEnd(self.dcIosInfo)

		if successCallback then successCallback() end

		GainAndConsumeMgr.getInstance():consumeCurrency(self.feature, DcDataCurrencyType.kRmb, self.data.price * 100, 
													self.data.goodsId, 1, levelId, self.activityId, self.source)

		GlobalEventDispatcher:getInstance():dispatchEvent(
			Event.new(kGlobalEvents.kConsumeComplete, {
				price = self.data.price,
				props = Localization:getInstance():getText("goods.name.text"..tostring(self.data.goodsId)),
				goodsId = self.data.goodsId,
				goodsType = 1
		}))
	end

	local function onFail(errCode, errMsg, noTip)
		if failCallback then failCallback(errCode, errMsg, noTip) end
	end

	local peDispatcher = PaymentEventDispatcher.new()
	local function failedDcFunc(evt)
		local data = evt.data
		local errCode = data.errCode
		local errMsg = data.errMsg
		self.dcIosInfo:setResult(IosRmbPayResult.kSdkFail, errCode, errMsg)
    	PaymentIosDCUtil.getInstance():sendIosRmbPayEnd(self.dcIosInfo)
	end
	peDispatcher:addEventListener(PaymentEvents.kIosBuyFailed, failedDcFunc)

	if __IOS then
		IosPayment:buy(self.data.productIdentifier, self.data.price, self.data.priceLocale, self.data.id, onSuccess, onFail, peDispatcher)
	elseif __WIN32 then
		onSuccess()
	else
		onFail()
	end
end