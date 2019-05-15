local BuyAddTwoStepLogic = {}

BuyAddTwoStepLogic.MODE = {
	kGoldCash = 1,    -- 风车币 买 610
	kRMB = 2,         -- 人民币 买 610

	kRMB_WITH_FIRST_DISCOUNT = 3, -- 每日首次 人民币 买 643 ，后续 人民币 买 644

	kRMB_ONCE_PER_DAY = 4, -- 每日只有一次 买643
}

local GoodsId = 610

local GoodsIds_kRMB_WITH_FIRST_DISCOUNT = {
	643, 
	644
}

local GoodsId_kRMB_ONCE_PER_DAY = 643


function BuyAddTwoStepLogic:isEnabled( ... )

	if __WIN32 then
		return true, BuyAddTwoStepLogic.MODE.kGoldCash
	end

	-- hard code android yyb
	if __ANDROID then
		local key = 'BuyTwoSteps'
		local uid = UserManager:getInstance():getUID()
		if MaintenanceManager:getInstance():isEnabledInGroup(key, 'A1', uid) then
			return true, BuyAddTwoStepLogic.MODE.kGoldCash
		end

		if MaintenanceManager:getInstance():isEnabledInGroup(key, 'A2', uid) then
			return true, BuyAddTwoStepLogic.MODE.kRMB
		end

		if MaintenanceManager:getInstance():isEnabledInGroup(key, 'B2', uid) then
			return true, BuyAddTwoStepLogic.MODE.kRMB_WITH_FIRST_DISCOUNT
		end

		if MaintenanceManager:getInstance():isEnabledInGroup(key, 'B3', uid) then
			return true, BuyAddTwoStepLogic.MODE.kRMB_ONCE_PER_DAY
		end
	end

	if __IOS then
		local key = 'BuyTwoSteps'
		local uid = UserManager:getInstance():getUID()
		if MaintenanceManager:getInstance():isEnabledInGroup(key, 'A1', uid) then
			return true, BuyAddTwoStepLogic.MODE.kGoldCash
		end
	end

	return false
end

function BuyAddTwoStepLogic:shouldDisableNewLottery( ... )
	local key = 'BuyTwoSteps'
	local uid = UserManager:getInstance():getUID()
	if MaintenanceManager:getInstance():isEnabledInGroup(key, 'A1', uid) then
		return true
	end

	if MaintenanceManager:getInstance():isEnabledInGroup(key, 'A2', uid) then
		return true
	end

	if MaintenanceManager:getInstance():isEnabledInGroup(key, 'B1', uid) then
		return true
	end

	if MaintenanceManager:getInstance():isEnabledInGroup(key, 'B2', uid) then
		return true
	end

	if MaintenanceManager:getInstance():isEnabledInGroup(key, 'B3', uid) then
		return true
	end

	if MaintenanceManager:getInstance():isEnabledInGroup(key, 'B4', uid) then
		return true
	end

	return false
end

function BuyAddTwoStepLogic:canBuyInMode( mode )
	if mode == BuyAddTwoStepLogic.MODE.kRMB_ONCE_PER_DAY then
		if UserManager:getInstance():getDailyBoughtGoodsNumById( GoodsId_kRMB_ONCE_PER_DAY ) >= 1 then
			return false
		end
	end
	return true
end

function BuyAddTwoStepLogic:canBuy( ... )
	local hadUsedAddFiveSteps = false
	for _, v in ipairs({
		ItemType.ADD_FIVE_STEP,
		ItemType.TIMELIMIT_ADD_FIVE_STEP,
		ItemType.ADD_1_STEP,
		ItemType.ADD_2_STEP,
		ItemType.ADD_15_STEP,
	}) do
		if GamePlayContext:getInstance():hadUsedProp(v) then
			hadUsedAddFiveSteps = true
			break
		end
	end

	if (not hadUsedAddFiveSteps) then
		return true
	else
		return false, GamePlayContext:getInstance():hadUsedProp(ItemType.ADD_2_STEP)
	end
end

function BuyAddTwoStepLogic:getGoodsId( mode )

	if mode == BuyAddTwoStepLogic.MODE.kRMB_WITH_FIRST_DISCOUNT then
		if UserManager:getInstance():getDailyBoughtGoodsNumById(GoodsIds_kRMB_WITH_FIRST_DISCOUNT[1]) >= 1 then
			return GoodsIds_kRMB_WITH_FIRST_DISCOUNT[2]
		else
			return GoodsIds_kRMB_WITH_FIRST_DISCOUNT[1]
		end
	elseif mode == BuyAddTwoStepLogic.MODE.kRMB_ONCE_PER_DAY then
		return GoodsId_kRMB_ONCE_PER_DAY
	else
		return GoodsId
	end
end

function BuyAddTwoStepLogic:buy( mode, successCallback, failCallback, cancelCallback, updateGoldCallback )
	-- body
	if mode == BuyAddTwoStepLogic.MODE.kGoldCash then
		self:buyWithGoldCash( successCallback, failCallback, cancelCallback, updateGoldCallback )
	else

		if __ANDROID then
			self:buyWithRMB( successCallback, failCallback, cancelCallback, mode )
		end

	end
end

function BuyAddTwoStepLogic:buyWithRMB( successCallback, failCallback, cancelCallback , mode)

	local goodsId = self:getGoodsId(mode)


	if not self.dcObj then

		PaymentManager.getInstance():getRMBBuyItemDecision(function ( decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable )

			self.decisionObj = {
	    		decision = decision,
	    		paymentType = paymentType,
	    		dcAndroidStatus = dcAndroidStatus,
	    		otherPaymentTable = otherPaymentTable,
	    		repayChooseTable = repayChooseTable,
	    	}


	    	local goodsIdInfo = GoodsIdInfoObject:create(goodsId)
			self.dcObj = DCAndroidRmbObject:create()
			self.dcObj:setGoodsId(goodsIdInfo:getGoodsId(mode))
			self.dcObj:setGoodsType(goodsIdInfo:getGoodsType())
			self.dcObj:setGoodsNum(1)
			self.dcObj:setTypeStatus(dcAndroidStatus)
			if dcAndroidStatus == IngamePaymentDecisionType.kPayFailed then 	
				if paymentType == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec then 
					self.dcObj:setInitialTypeList(PaymentManager.getInstance():getDefaultThirdPartPayment())
				end
			else
				self.dcObj:setInitialTypeList(paymentType)
			end
			self:buyWithRMB(successCallback, failCallback, cancelCallback, mode)
	    end, goodsId)
		return
	end

	local decision = self.decisionObj

	local function onBuySuccess( ... )
		local TradeUtils = require 'zoo.panel.endGameProp.lottery.TradeUtils'
		local itemId = TradeUtils:getItems(self:getGoodsId(mode))[1].itemId
		if successCallback then successCallback(itemId) end
	end

	local function onBuyFail( errCode )
		if errCode then
			CommonTip:showTip(localize('error.tip.'..errCode))
		else
			CommonTip:showTip(localize('buy.gold.panel.err.undefined'))
		end
		if failCallback then failCallback() end
	end

	local function onBuyCancel( ... )
		if cancelCallback then cancelCallback() end
	end

	if decision.decision == IngamePaymentDecisionType.kPayWithWindMill then
	else
		PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self.dcObj)
		local logic = IngamePaymentLogic:createWithGoodsInfo(GoodsIdInfoObject:create(goodsId), self.dcObj, DcFeatureType.kAddFiveSteps, DcSourceType.kAdd2Step)
		logic:endGameBuy(decision.decision, decision.paymentType, onBuySuccess, onBuyFail, onBuyCancel, nil, decision.repayChooseTable)
	end

end



function BuyAddTwoStepLogic:reset( ... )
	self.dcObj = nil
	self.decisionObj = nil
end

function BuyAddTwoStepLogic:buyWithGoldCash( successCallback, failCallback, cancelCallback, updateGoldCallback)

	if not self.dcObj then
		local dcWindmillInfo = DCWindmillObject:create()
		dcWindmillInfo:setGoodsId(self:getGoodsId())
		self.dcObj = dcWindmillInfo
	end

	if __ANDROID then 
		PaymentDCUtil.getInstance():sendAndroidWindMillPayStart(self.dcObj)
	end

	local function onSuccess()

		local TradeUtils = require 'zoo.panel.endGameProp.lottery.TradeUtils'
		local itemId = TradeUtils:getItems(self:getGoodsId())[1].itemId
		if successCallback then successCallback(itemId) end
	end

	local function onFail(errorCode)
		if errorCode then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errorCode)), "negative")
		end
		if failCallback then failCallback(errorCode) end
	end

	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	local function onGoldChange()
		if updateGoldCallback then updateGoldCallback() end
	end

	local buyLogic = BuyLogic:create(self:getGoodsId(), MoneyType.kGold, DcFeatureType.kAddFiveSteps, DcSourceType.kAdd2Step)
	buyLogic:getPrice()
	local logic = WMBBuyItemLogic:create()
	logic:setStoreEnterFlag(_G.StoreManager.EnterFlag.kEndGamePanel2Step)
	logic:buy(self:getGoodsId(), 1, self.dcObj, buyLogic, onSuccess, onFail, onCancel, onGoldChange)
end

return BuyAddTwoStepLogic