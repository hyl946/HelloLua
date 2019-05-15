require 'zoo.util.OpenUrlUtil'
require 'zoo.panel.buygold.BuyHappyCoinManager'

BuyGoldItem = class(ItemInClippingNode)

function BuyGoldItem:create(itemData, successCallback, failCallback)
	local instance = BuyGoldItem.new()
	instance:loadRequiredResource(PanelConfigFiles.buy_gold_items) 
	instance:init(itemData, successCallback, failCallback)
	return instance
end

function BuyGoldItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function BuyGoldItem:getItemResPre()
	return "goldItemLevel"
end

function BuyGoldItem:init(itemData, successCallback, failCallback)
	ItemInClippingNode.init(self)

	self.goldLevel = BuyHappyCoinManager:getShowConfig(itemData.grade, itemData.cash) or 1

	local ui = self.builder:buildGroup(self:getItemResPre()..self.goldLevel)
	self:setContent(ui)
	self.ui = ui

	self.itemData = itemData
	self.buyLogic = BuyGoldLogic:create()
	self.buyLogic:getMeta()
	self.successCallback = successCallback
	self.failCallback = failCallback

	local goldNumUI = self.ui:getChildByName("goldNum")
	local goldNumSizeUI = self.ui:getChildByName("goldNum_size")
	local extraPartUI = self.ui:getChildByName("extraPart")
	local extraCash = itemData.extraCash or 0
	if extraCash > 0 then 
		goldNumUI:setVisible(false)
		goldNumSizeUI:setVisible(false)

		local label, size = extraPartUI:getChildByName("goldNum"), extraPartUI:getChildByName("goldNum_size")
		local extraLabel, extraSize = extraPartUI:getChildByName("extraGoldNum"), extraPartUI:getChildByName("extraGoldNumSize")
		label = TextField:createWithUIAdjustment(size, label)
		label:setString(itemData.cash - extraCash)
		extraPartUI:addChild(label)

		extraLabel = TextField:createWithUIAdjustment(extraSize, extraLabel)
		extraLabel:setString(extraCash)
		extraPartUI:addChild(extraLabel)
	else
		extraPartUI:setVisible(false)

		local label, size = ui:getChildByName("goldNum"), ui:getChildByName("goldNum_size")
		label = TextField:createWithUIAdjustment(size, label)
		label:setString(itemData.cash - extraCash)
		ui:addChild(label)
	end

	local btn = ui:getChildByName("buyBtn");
	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(itemData.priceLocale)	-- 货币符号
	btn = GroupButtonBase:create(btn)
	btn:setColorMode(kGroupButtonColorMode.blue);
	self.procClick = true
	if isLongSymbol then 
		btn:setString(string.format("%s%0.0f", currencySymbol, itemData.iapPrice))
	else
		btn:setString(string.format("%s%0.2f", currencySymbol, itemData.iapPrice))
	end
	self.btnBuy = btn;
	self.icon = self.ui:getChildByName("icon")

	local function onBuyTapped(evt) 
		self:buyGold(evt.context) 
	end
	btn:addEventListener(DisplayEvents.kTouchTap, onBuyTapped, {index = itemData.id, data = itemData})
end

function BuyGoldItem:setButtonEnable(isEnable)
	if self.btnBuy and not self.btnBuy.isDisposed then 
		if __ANDROID then 
			local scene = Director:sharedDirector():getRunningScene()
			if isEnable == true then 
				if scene and scene.goldItemMaskLayer and not scene.goldItemMaskLayer.isDisposed then 
					scene.goldItemMaskLayer:setTouchEnabled(false)
				end
			else
				if scene and scene.goldItemMaskLayer and not scene.goldItemMaskLayer.isDisposed then 
					scene.goldItemMaskLayer:setTouchEnabled(true, 0 ,true)
				end
			end
		end
		self.btnBuy:setEnabled(isEnable)
	end
end

function BuyGoldItem:disableClick()
	self.procClick = false
	self:setButtonEnable(false)
end

function BuyGoldItem:enableClick()
	self.procClick = true
	self:setButtonEnable(true)
end

function BuyGoldItem:buyGold(context)
	local function onOver()
		if self.isDisposed then return end
		PlatformConfig:setCurrentPayType()
		if self.procClick then self:setButtonEnable(true) end
	end

	local function onCancel()
		DcUtil:logBuyGoldItem(context.index, 'cancel', false)
		if self.isDisposed then return end
		if self.procClick  then self:setButtonEnable(true) end
		PlatformConfig:setCurrentPayType()

		-- 取消的时候 和 失败的时候 统一弹出 重买面板
		if self.failCallback and type(self.failCallback) == 'function' then
			self.failCallback(self.itemData, self)
		end

		--refresh the panel after sign successfully
		local mp = MarketPanel:getCurrentPanel()
		if not mp.isDisposed then
			mp:refresh()
		end
	end
	local function onFail(errCode, errMsg, noTip)
		if _G.isLocalDevelopMode then printx(0, "BuyGoldItem:onFail:"..tostring(errCode)..","..tostring(errMsg)) end
		DcUtil:logBuyGoldItem(context.index, 'fail', false)
		if self.isDisposed then return end
		if self.procClick then self:setButtonEnable(true) end
		if not noTip then 
			if errCode == 730241 or errCode == 730247 or errCode == 731307 then
				if not self.failCallback then
					self:runAction(CCCallFunc:create(function () CommonTip:showTipWithErrCode(errMsg, errCode, "negative") end ))
				end
				--refresh the panel after sign successfully
				local mp = MarketPanel:getCurrentPanel()
				if not mp.isDisposed then
					mp:refresh()
				end
			else
				if not self.failCallback then
					self:runAction(CCCallFunc:create(function () CommonTip:showTipWithErrCode(localize("buy.gold.panel.err.undefined"), errCode, "negative", nil, 3) end))		
				end
			end
		end

		PlatformConfig:setCurrentPayType()

		if self.failCallback and type(self.failCallback) == 'function' then
			self.failCallback(self.itemData, self, errCode)
		end
		
	end

	local bounds = self.icon:getGroupBounds()
	local posX = bounds:getMidX()
	local posY = bounds:getMidY()
	local function onSuccess()
		DcUtil:logBuyGoldItem(context.index, 'success', false)

		local scene = HomeScene:sharedInstance()
		local button
		if scene then button = scene.goldButton end
		if button then button:updateView() end
		
		CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.success"), "positive", onOver)


		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local num = context.data.cash
		local toWorldPosX = 190 + visibleOrigin.x
		local toWorldPosY = 40 + visibleOrigin.y

		local anim = FlyGoldToAnimation:create(num,ccp(toWorldPosX - 150,toWorldPosY))
		anim:setWorldPosition(ccp(posX,posY))
		anim:setFinishCallback(function( ... )
			local scene = Director.sharedDirector():getRunningScene()

			if scene then
				local animLabel = TextField:create("+" .. num,"",30)
				animLabel:setAnchorPoint(ccp(0.5,0.5))
				animLabel:setPositionXY(toWorldPosX - 30 ,toWorldPosY)
				animLabel:setColor(ccc3(0x35,0x11,0x19))
				scene:addChild(animLabel, SceneLayerShowKey.TOP_LAYER)

				local actions = CCArray:create()
				actions:addObject(CCMoveBy:create(0.8,ccp(0,42)))
				actions:addObject(CCCallFunc:create(function( ... )
					animLabel:removeFromParentAndCleanup(true)
				end))
				animLabel:runAction(CCSequence:create(actions))

				actions = CCArray:create()
				actions:addObject(CCDelayTime:create(0.4))
				actions:addObject(CCFadeOut:create(0.4))
				animLabel:runAction(CCSequence:create(actions))
			end


			if self.successCallback then self.successCallback(self.itemData.payType) end
		end)
		anim:play()
	end

	if __IOS then -- IOS
		self:setButtonEnable(false)
		local function startBuyLogic()
			self:setButtonEnable(false)
			self.buyLogic:buy(context.index, context.data, onSuccess, onFail, onCancel)
		end
		local function onFailLogin()
			self:setButtonEnable(true)
		end
		RequireNetworkAlert:callFuncWithLogged(startBuyLogic, onFailLogin)
	else -- on ANDROID and PC we don't need to check for network
		PlatformConfig:setCurrentPayType(self.itemData.payType)
		if self.itemData.payType == Payments.WECHAT then
			
			local function enableButton()
				if not self.isDisposed then
					if self.procClick then self:setButtonEnable(true) end
				end
			end
			setTimeOut(enableButton, 5)
			if PaymentManager.getInstance():checkCanWechatQuickPay(context.data.iapPrice) then
				if UserManager.getInstance():isWechatSigned() then
					local function onConfirm()
						DcUtil:logBuyGoldItem(context.index, 'money', true)
						self:setButtonEnable(false)
						self.buyLogic:buy(context.index, context.data, onSuccess, onFail, onCancel)
					end

					local WechatQuickPayConfirmPanel = require "zoo.panel.wechatPay.WechatQuickPayConfirmPanel"
					local cp = WechatQuickPayConfirmPanel:create(context.data.cash,context.data.iapPrice)
					cp:popout(onConfirm)

					return
				else
					if _G.use_wechat_quick_pay then
						local function signSuccess()
							local function localSuccess()
								-- 刷新签约状态
								_G.use_wechat_quick_pay = false
								local mp = MarketPanel:getCurrentPanel()
								if mp and not mp.isDisposed then
									mp:refresh()
								end
								if onSuccess then
									onSuccess()
								end
							end
							local resultPanel = require("zoo.panel.alipay.PanelSignResult"):create(true)
							resultPanel:popout(function ()  end)
							self.buyLogic:buy(context.index, context.data, localSuccess, onFail, onCancel)
							
						end
						local function signFail(error_code)
							if error_code == -1002 then
				                CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('wechat.kf.sign.fail.1'), 'negative', nil, 3)
				            elseif error_code then
				            	CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('error.tip.'..error_code), 'negative', nil, 3)
				            else
				            	CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('wechat.kf.sign.fail.2'), 'negative', nil, 3)
				            end
				            _G.use_wechat_quick_pay = false
				            local mp = MarketPanel:getCurrentPanel()
							if mp and not mp.isDisposed then
								mp:refresh()
							end
						end
						self:setButtonEnable(false)
						local WechatQuickPayGuide = require "zoo.panel.wechatPay.WechatQuickPayGuide"
						WechatQuickPayLogic:getInstance():sign(signSuccess, signFail, 1, WechatQuickPayGuide.isGuideTime())
						return 
					else
						local WechatQuickPayGuide = require "zoo.panel.wechatPay.WechatQuickPayGuide"
						if WechatQuickPayGuide.isGuideTime() then
							WechatQuickPayGuide.updateGuideTimeAndPopCount()
						else
							WechatQuickPayGuide.updateOnlyGuideTime()
						end
					end
				end
			end 
		elseif self.itemData.payType == Payments.ALIPAY then
			-- nothing
			if PaymentManager.getInstance():checkCanAliQuickPay(context.data.iapPrice) then 
				if UserManager.getInstance():isAliSigned() then
					--todo: to popout a confirm panel

					local function onConfirm()
						DcUtil:logBuyGoldItem(context.index, 'money', true)
						self:setButtonEnable(false)
						self.buyLogic:buy(context.index, context.data, onSuccess, onFail, onCancel)
					end

					local AliQuickPayConfirmPanel = require "zoo.panel.alipay.AliQuickPayConfirmPanel"
					local cp = AliQuickPayConfirmPanel:create(context.data.cash,context.data.iapPrice)
					cp:popout(onConfirm)

					return
				else
					if _G.use_ali_quick_pay then
						if PaymentBase:getPayment(Payments.ALI_SIGN_PAY):isEnabled() then
							if _G.isLocalDevelopMode then printx(0, 'PaymentBase:getPayment(Payments.ALI_SIGN_PAY):isEnabled()') end
							-- DcUtil:logBuyGoldItem(context.index, 'money', true)
							self:setButtonEnable(false)
							local function localSuccess()
								-- 刷新签约状态
								_G.use_ali_quick_pay = false
								local mp = MarketPanel:getCurrentPanel()
								if mp and not mp.isDisposed then
									mp:refresh()
								end
								if onSuccess then
									onSuccess()
								end
							end
							local function localFail(errCode, errMsg, noTip)
								_G.use_ali_quick_pay = false
								local mp = MarketPanel:getCurrentPanel()
								if mp and not mp.isDisposed then
									mp:refresh()
								end
								if onFail then
									onFail(errCode, errMsg, noTip)
								end
							end
							self.buyLogic:buy(context.index, context.data, localSuccess, localFail, onCancel)
							return
						else
							local function onSignSuccess()
								--refresh the panel after sign successfully
								_G.use_ali_quick_pay = false
								local mp = MarketPanel:getCurrentPanel()
								if mp and not mp.isDisposed then
									mp:refresh()
								end

								DcUtil:logBuyGoldItem(context.index, 'money', true)
								self:setButtonEnable(false)
								self.buyLogic:buy(context.index, context.data, onSuccess, onFail, onCancel)
							end

							local function onSignCancel()
								_G.use_ali_quick_pay = false
								local mp = MarketPanel:getCurrentPanel()
								if mp and not mp.isDisposed then
									mp:refresh()
								end
							end

							-- local AliSignPanel = require "zoo.panel.alipay.AliPaymentSignAccountPanel"
							-- local ap = AliSignPanel:create(AliQuickSignEntranceEnum.MARKET_PANEL)
				   --          if AliQuickPayPromoLogic:isEntryEnabled() then
				   --              ap:setReduceShowOption(AliSignPanel.showNormalReduce)
				   --          end
							-- ap:popout(onSignCancel, onSignSuccess)

				            local function onSignCallback(ret, data)
				                if ret == AlipaySignRet.Success then
				                    if self.isDisposed then return end
				                    onSignSuccess()
			                    elseif ret == AlipaySignRet.Cancel then
			                    	onSignCancel()
		                    	elseif ret == AlipaySignRet.Fail then
				                end
				            end
				            AlipaySignLogic.getInstance():startSign(AliQuickSignEntranceEnum.MARKET_PANEL, onSignCallback)
							return
						end
					else
						local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"
						if AliQuickPayGuide.isGuideTime() then
							AliQuickPayGuide.updateGuideTimeAndPopCount()
						else
							AliQuickPayGuide.updateOnlyGuideTime()
						end
					end
				end
			end
		elseif self.itemData.payType == Payments.QQ or self.itemData.payType == Payments.QQ_WALLET or 
			   self.itemData.payType == Payments.QIHOO or self.itemData.payType == Payments.QIHOO_WX or self.itemData.payType == Payments.QIHOO_ALI then
			--目前QQ相关平台三方支付用MSDK 直接会调起其中的微信支付 这里是解决微信未登录无回调的问题
			local function enableButton()
				if not self.isDisposed then
					if self.procClick then self:setButtonEnable(true) end
				end
			end
			setTimeOut(enableButton, 5)
		end
		DcUtil:logBuyGoldItem(context.index, 'money', true)
		self:setButtonEnable(false)
		self.buyLogic:buy(context.index, context.data, onSuccess, onFail, onCancel)
	end
end

function BuyGoldItem:update()

end

ThirdPayLinkItem = class(ItemInClippingNode)
function ThirdPayLinkItem:create(txt, linkAddr, clickCallback)
	local instance = ThirdPayLinkItem.new()
	instance:loadRequiredResource(PanelConfigFiles.buy_gold_items)
	instance:init(txt, linkAddr, clickCallback)
	return instance
end

function ThirdPayLinkItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function ThirdPayLinkItem:init(txt, linkAddr, clickCallback)
	ItemInClippingNode.init(self)
	local ui = self.builder:buildGroup("thirdPartyLinkItem")
	self:setContent(ui)

	self.btn = ui:getChildByName('btn')
	self.btn:setButtonMode(true)
	self.btnTxt = self.btn:getChildByName('txt')

	ui:getChildByName('bg'):setVisible(false)

	local function onBtnTapped(evt) 
		OpenUrlUtil:openUrl(linkAddr)
		if clickCallback then
			clickCallback()
		end
	end
	self.btn:addEventListener(DisplayEvents.kTouchTap, onBtnTapped)
end

function ThirdPayLinkItem:disableClick()
	self.procClick = false
	if not self.btn.isDisposed then self.btn:setTouchEnabled(false) end
end

function ThirdPayLinkItem:enableClick()
	self.procClick = true
	if not self.btn.isDisposed then self.btn:setTouchEnabled(true) end
end


