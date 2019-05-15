local CompPay = class()

function CompPay:create(parentPanel, ui, androidRmbBuy)
	local comp = CompPay.new()
	comp:init(parentPanel, ui, androidRmbBuy)
	return comp
end

function CompPay:init(parentPanel, ui, androidRmbBuy)
	self.parentPanel = parentPanel
	self.ui = ui
	self.androidRmbBuy = androidRmbBuy

	--------------------------风车币解锁-------------------------------------------
	self.useWindmillBtnRes = self.ui:getChildByName("btn_cash")
	self.useWindmillBtn	= ButtonIconNumberBase:create(self.useWindmillBtnRes)
	self.useWindmillBtn:setColorMode(kGroupButtonColorMode.blue)
	local goodsMeta = MetaManager.getInstance():getGoodMetaByItemID(self.parentPanel.lockedCloudId)
    self.useWindmillBtn:setIconByFrameName('ui_images/ui_image_coin_icon_small0000')
    if not self.androidRmbBuy then
		self.useWindmillBtn:setNumber(goodsMeta.qCash)
    end
	local useWindmillBtnLabelKey	= "unlock.cloud.panel.rmb.button"
	local useWindmillBtnLabelValue	= Localization:getInstance():getText(useWindmillBtnLabelKey, {})
	self.useWindmillBtn:setString(useWindmillBtnLabelValue)
	local function onUseWindmillBtnTapped()
		self:onUseWindmillBtnTapped()
	end
	self.useWindmillBtn:addEventListener(DisplayEvents.kTouchTap, onUseWindmillBtnTapped)

	--------------------------一元解锁-------------------------------------------
	self.oneyuanBtn = ButtonIconNumberBase:create(self.ui:getChildByName('btn_oneyuan'))
	self.oneyuanBtn:setString(localize('unlock.cloud.panel.use.friend.unlock'))
	self.oneyuanBtn:setColorMode(kGroupButtonColorMode.blue)
	local rmbIcon = Sprite:createWithSpriteFrameName('area_unlock/rmbIcon0000')
	rmbIcon:setAnchorPoint(ccp(0, 1.05))
	self.oneyuanBtn:setIcon(rmbIcon)
	self.oneyuanBtn:setNumber(1)
	self.oneyuanBtn:ad(DisplayEvents.kTouchTap, function () self:onUseWindmillBtnTapped() end )

	if self.androidRmbBuy then
		self.useWindmillBtn:setVisible(false)
	else
		self.oneyuanBtn:setVisible(false)
	end
end

function CompPay:onUseWindmillBtnTapped()
	local price = nil
	local function onSendUnlockMsgSuccess()
		if self.ui.isDisposed then return end
		self.parentPanel.oldOnEnterForeGroundCallback = self.parentPanel.onEnterForeGroundCallback
		self.parentPanel.onEnterForeGroundCallback  = function()
			self.parentPanel.oldOnEnterForeGroundCallback(self.parentPanel)
		end

		local function animateFinish()
			local function onRemoveSelfFinish()
				self.parentPanel.unlockCloudSucessCallBack()
			end
			if self.ui.isDisposed then return end
			self.parentPanel:remove(onRemoveSelfFinish)
		end
		local array = CCArray:create()
		if price ~= nil then
			array:addObject(CCDelayTime:create(0.8))
			self.useWindmillBtn:playFloatAnimation('-'..price)
		end
		array:addObject(CCCallFunc:create(animateFinish))
		self.ui:runAction(CCSequence:create(array))
	end

	local function onSendUnlockMsgFailed(errorCode)
		if self.ui.isDisposed then return end
		self.parentPanel.onEnterForeGroundCallback  = self.parentPanel.oldOnEnterForeGroundCallback
		local failTxtKey
		if type(errorCode)=='number' and table.exist({RealNameManager.errCode, RealNameManager.errWaitCode}, errorCode) then
			failTxtKey = 'error.tip.'..tostring(errorCode)
		elseif self.androidRmbBuy then 
			failTxtKey = "unlock.cloud.panel.use.rmb.unlock.failed"  
		else 
			failTxtKey = "unlock.cloud.panel.use.gold.unlock.failed" 
		end 
		local failTxtValue	= Localization:getInstance():getText(failTxtKey, {})
		CommonTip:showTip(failTxtValue)
		self.useWindmillBtn:setEnabled(true)
	end

	local function onSendUnlockMsgCanceled()
		if self.ui.isDisposed then return end
		self.parentPanel.onEnterForeGroundCallback = self.parentPanel.oldOnEnterForeGroundCallback
		self.parentPanel:setVisible(true)
		self.useWindmillBtn:setEnabled(true)
	end

	self.useWindmillBtn:setEnabled(false)

	local androidPayParamTable = nil
 	if self.androidRmbBuy then -- ANDROID
		self.parentPanel.onEnterForeGroundCallback = function()
			self.parentPanel.oldOnEnterForeGroundCallback(self.parentPanel)
			onSendUnlockMsgCanceled()
		end
		
		androidPayParamTable = {}
		androidPayParamTable.isRmbPay = true
		androidPayParamTable.adDecision = self.parentPanel.adDecision
		androidPayParamTable.adPaymentType = self.parentPanel.adPaymentType
		androidPayParamTable.adRepayChooseTable = self.parentPanel.adRepayChooseTable
		androidPayParamTable.sourePanel = self.parentPanel
	else
		local goodMeta	= MetaManager.getInstance():getGoodMetaByItemID(self.parentPanel.lockedCloudId)
		price = goodMeta.qCash
	end
 	local logic = UnlockLevelAreaLogic:create(self.parentPanel.lockedCloudId)
	logic:setOnSuccessCallback(onSendUnlockMsgSuccess)
	logic:setOnFailCallback(onSendUnlockMsgFailed)
	logic:setOnCancelCallback(onSendUnlockMsgCanceled)
	logic:start(UnlockLevelAreaLogicUnlockType.USE_WINDMILL_COIN, {}, androidPayParamTable)
end

function CompPay:hide()
	self.oneyuanBtn:setVisible(false)
	self.useWindmillBtn:setVisible(false)
end

return CompPay