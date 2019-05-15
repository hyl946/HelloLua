local win32_debug_android = false

if __ANDROID or win32_debug_android then
	require 'zoo.panel.store.views.StorePayPanel'
end



_G.BuyGoodsLogic = class()



function BuyGoodsLogic:ctor( ... )
	self:reset()
end

function BuyGoodsLogic:start( onSuccess, onFail, onCancel, paymentFilter )



	local function AfterSuccess( ... )
		self._busy = false

		if onSuccess then onSuccess() end
	end

	local function AfterFail( errCode, errMsg, noTip )
		self._busy = false
		if not noTip then
			if errCode == 730241 or errCode == 730247 or errCode == 731307 then
				CommonTip:showTipWithErrCode(errMsg, errCode, "negative")
			elseif type(errCode)=='number' and errCode == -1000061 then
				CommonTip:showTipWithErrCode(localize("error.tip.-1000061"), errCode, "negative", nil, 3)
			else
				local tipStrKey = "buy.gold.panel.err.undefined"
				if errCode == -6 then 
					tipStrKey = "dis.connect.warning.tips"
				end
				CommonTip:showTipWithErrCode(localize(tipStrKey), errCode, "negative", nil, 3)	
			end
		end
		if onFail then onFail( errCode, errMsg ) end
	end

	local function AfterCancel( ... )
		self._busy = false
		if onCancel then onCancel(...) end
	end



	self._busy = true

	if __WIN32 and (not win32_debug_android) then
		if self.goodsIdInfo:getGoodsType() == GoodsType.kCurrency then
			local goodsId = self.goodsIdInfo:getGoodsId()
			local buyLogic = BuyGoldLogic:create()
			buyLogic:getMeta()
			buyLogic:setDcParams(DcFeatureType.kNewStore, DcSourceType.kNewStore)

			buyLogic:buy(goodsId, {
				id = goodsId,
			}, AfterSuccess, AfterFail, AfterCancel)
		else
			local goodsId = self.goodsIdInfo:getGoodsId()
			local http = IngameHttp.new(false)
			http:ad(Events.kComplete, AfterSuccess)
			http:ad(Events.kError, AfterFail)
			local tradeId = tostring(Localhost:time())
			http:load(goodsId, tradeId, "chinaMobile", 1, nil, tradeId)
		end
	end

	if __IOS then
		local goodsId = self.goodsIdInfo:getGoodsId()
		if self.goodsIdInfo:getGoodsType() == GoodsType.kItem then
			local buyLogic = IapBuyPropLogic:create(goodsId, DcFeatureType.kNewStore, DcSourceType.kNewStore)
        	if buyLogic then 
        		self.dcObj = buyLogic.dcIosInfo
            	buyLogic:buy(AfterSuccess, AfterFail)
        	end
		elseif self.goodsIdInfo:getGoodsType() == GoodsType.kCurrency then
			local buyLogic = BuyGoldLogic:create()
			buyLogic:getMeta()
			buyLogic:setDcParams(DcFeatureType.kNewStore, DcSourceType.kNewStore)
			buyLogic:buy(goodsId, {
				productIdentifier = self.iapConfig.productIdentifier,
				iapPrice = self.iapConfig.iapPrice,
				priceLocale = self.iapConfig.priceLocale,
				id = goodsId,
			}, AfterSuccess, AfterFail, AfterCancel)
		end
		return
	end

	if __ANDROID or win32_debug_android then
		self.dcObj = StorePayPanel:buyGoods(self.goodsIdInfo, AfterSuccess, AfterFail, AfterCancel, paymentFilter)
	end
end

function BuyGoodsLogic:reset( ... )
	self._busy = false
end

function BuyGoodsLogic:isBusy( ... )
	return self._busy
end

function BuyGoodsLogic:set( goodsId, goodsType, iapConfig )
	self.goodsIdInfo = GoodsIdInfoObject:create(goodsId, goodsType)
	self.iapConfig = iapConfig
end

function BuyGoodsLogic:buy( goodsId, goodsType, iapConfig, onSuccess, onFail, onCancel, paymentFilter)
	if not self:isBusy() then
		self:set(goodsId, goodsType, iapConfig)
		self:start(onSuccess, onFail, onCancel, paymentFilter)
	end
end

function BuyGoodsLogic:getDcObj( ... )
	return self.dcObj
end


local instance

function BuyGoodsLogic:getInstance( ... )
	if not instance then
		instance = BuyGoodsLogic.new()
	end
	return instance
end

return BuyGoodsLogic