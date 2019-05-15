require "hecore.class"

WMBBuyItemLogic = class()
function WMBBuyItemLogic:ctor()
	
end

function WMBBuyItemLogic:init()
	
end

function WMBBuyItemLogic:buy(goodsId, goodsNum, dcWindmillInfo, buyLogic, successCallback, failCallback, cancelCallback, updateFunc)
	self.goodsId = goodsId
	self.goodsNum = goodsNum
	self.dcWindmillInfo = dcWindmillInfo
	self.buyLogic = buyLogic
	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
	self.updateFunc = updateFunc

	self:buyWithWindmill(false)
end

function WMBBuyItemLogic:onlineBuy(goodsId, goodsNum, dcWindmillInfo, buyLogic, successCallback, failCallback, cancelCallback, updateFunc)
	self.goodsId = goodsId
	self.goodsNum = goodsNum
	self.dcWindmillInfo = dcWindmillInfo
	self.buyLogic = buyLogic
	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
	self.updateFunc = updateFunc

	self:buyWithWindmill(true)
end

function WMBBuyItemLogic:buyWithWindmill(online)
	local singlePrice = self.buyLogic:getPrice()
	self.dcWindmillInfo:setGoodsNum(self.goodsNum)
	self.dcWindmillInfo:setWindMillPrice(self.goodsNum * singlePrice)

	local function onSuccess(data)
		local scene = HomeScene:sharedInstance()
		local button = scene.goldButton
		if button then button:updateView() end

		self.dcWindmillInfo:setResult(DCWindmillPayResult.kSuccess)
		if __ANDROID then 
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcWindmillInfo)
		elseif __IOS then 
			PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcWindmillInfo)
		end

		if self.successCallback then 
			self.successCallback(self.goodsNum)
		end
	end
	local function onFail(errorCode)
		if errorCode and errorCode == 730330 then
			self.dcWindmillInfo:setResult(DCWindmillPayResult.kNoWindmill)
			self:goldNotEnough()
		else
			self.dcWindmillInfo:setResult(DCWindmillPayResult.kFail, errorCode)
			-- if errorCode then 
			-- 	CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errorCode)), "negative")
			-- end
			if self.failCallback then 
				self.failCallback(errorCode)
			end
		end
		if __ANDROID then 
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcWindmillInfo)
		elseif __IOS then 
			PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcWindmillInfo)
		end
	end

   	self.buyLogic:start(self.goodsNum, onSuccess, onFail, nil, nil, online)
end

function WMBBuyItemLogic:setStoreEnterFlag( flag )
	self.storeEnterFlag = flag
end

function WMBBuyItemLogic:goldNotEnough()
	local function updateGold()
		if __ANDROID then 
			PaymentDCUtil.getInstance():setSrcPayId(nil)
		elseif __IOS then
			PaymentIosDCUtil.getInstance():setSrcPayId(nil)
		end
		if self.updateFunc then 
			self.updateFunc()
		end
	end
	local function createGoldPanel()
		if _G.isLocalDevelopMode then printx(0, "createGoldPanel") end
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			if __ANDROID then 
				PaymentDCUtil.getInstance():setSrcPayId(self.dcWindmillInfo and self.dcWindmillInfo.payId)
			elseif __IOS then
				PaymentIosDCUtil.getInstance():setSrcPayId(self.dcWindmillInfo and self.dcWindmillInfo.payId)
			end
			-- local config = {TabsIdConst.kHappyeCoin}
			local panel = createMarketPanel(index)
			panel:addEventListener(kPanelEvents.kClose, updateGold)


        	if self.storeEnterFlag and panel.addEnterFlag then
        		panel:addEnterFlag(self.storeEnterFlag)
        	end

			panel:popout()
		else 
			updateGold() 
		end
	end

	local function cancelCallback()
		if self.cancelCallback then 
			self.cancelCallback()
		end
	end
	GoldlNotEnoughPanel:createWithTipOnly(createGoldPanel)
end

function WMBBuyItemLogic:create()
	local logic = WMBBuyItemLogic.new()
	logic:init()
	return logic
end