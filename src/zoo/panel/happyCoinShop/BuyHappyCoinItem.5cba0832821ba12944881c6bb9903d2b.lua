local function wrapText(textUI)
	local label = textUI:getChildByName('label')
	local size = textUI:getChildByName('size')
	local text = TextField:createWithUIAdjustment(size, label)
	textUI:addChild(text)
	textUI.getGroupBounds = function(node, ancestor)
		return text:getGroupBounds(addChild)
	end
	return text
end

local GoldIcon = class()

function GoldIcon:ctor(iconUI)
	self.ui = iconUI
	self.isOutSide = false
	self:setIconType(nil)
end

function GoldIcon:setIconType(iconType)
	for i = 1, 7 do
		self.ui:getChildByName(string.format('type%d', i)):setVisible(false)
	end
	if type(iconType) == 'number' then
		local icon = self.ui:getChildByName(string.format('type%d', iconType))
		if icon then
			icon:setVisible(true)
		end
	end
end

function GoldIcon:getUI()
	return self.ui
end

local GoldNumber = class()

function GoldNumber:ctor(ui)
	self.ui = ui
	self.originCash = wrapText(self.ui:getChildByName('originCash'))
	self.extraCash = wrapText(self.ui:getChildByName('extraCash'))
	self.songIcon = self.ui:getChildByName('song')

	self.originCash:setWidth(-1)
	self.extraCash:setWidth(-1)

	self.originCash.oldPosX = self.originCash:getPositionX()
	self.extraCash.oldPosX = self.extraCash:getPositionX()
	self.songIcon.oldPosX = self.songIcon:getPositionX()
	self.ui.oldPosX = self.ui:getPositionX()
end

function GoldNumber:setNumber(cash, extraCash)
	local originCash = cash - extraCash

	if originCash == 3600 then
		self.ui:setScale(0.92)
	elseif originCash > 1000 then
		self.ui:setScale(0.95)
	end
	self.originCash:setString(tostring(originCash))
	if extraCash > 0 then
		self.extraCash:setString(tostring(extraCash))
		self.extraCash:setVisible(true)
		self.songIcon:setVisible(true)
	else
		self.extraCash:setVisible(false)
		self.songIcon:setVisible(false)
		self.originCash:setPositionX(self.originCash.oldPosX + 100)
	end

	local layoutItems = {
		{node = self.ui:getChildByName('originCash')}
	}
	local items = {
		self.ui:getChildByName('originCash')
	}

	if self.songIcon:isVisible() then
		local leftMargin = 0
		if originCash > 1000 then
			leftMargin = 7
		end
		table.insert(layoutItems, {node = self.songIcon, margin = {right = 10, left = leftMargin}})
		table.insert(items, self.songIcon)
	end
	if self.extraCash:isVisible() then
		table.insert(layoutItems, {node = self.ui:getChildByName('extraCash')})
		table.insert(items, self.ui:getChildByName('extraCash'))
	end

	local utils = require 'zoo.panel.happyCoinShop.utils'
	utils.horizontalLayoutItems(layoutItems)
	
	local itemsGroupBounds = utils.getNodesGroupBounds(items, self.ui)
	local itemsWidth = itemsGroupBounds.size.width
	local parentWidth = 315
	self.ui:setPositionX((parentWidth - itemsWidth)/2 + 4)

	--即使我费劲对齐了 仍然需要强行调整
	if self.originCash == 2580 then
		self.ui:setPositionX(self.ui:getPositionX() + 4)
	end
	if self.originCash == 280 then
		self.ui:setPositionX(self.ui:getPositionX() + 12)
	end
end

BuyHappyCoinItem = class(BaseUI)

function BuyHappyCoinItem:ctor()
end

function BuyHappyCoinItem:create(data, ui, isNeedWechatFriendPay)
	local instance = BuyHappyCoinItem.new()
	instance.isNeedWechatFriendPay = isNeedWechatFriendPay
	if isNeedWechatFriendPay == nil then
		instance.isNeedWechatFriendPay = false
	end
	instance:init(data, ui)
	instance.id = data.id
	return instance
end

function BuyHappyCoinItem:init(data, ui)
	self.data = data
	BaseUI.init(self, self:__buildUI(data, ui))
	self:__initBuyLogic()
end

function BuyHappyCoinItem:__buildUI(data, ui)
	self.buyBtn	= GroupButtonBase:create(ui:getChildByName('button'))

	self.buyBtn:setPositionY(self.buyBtn:getPositionY() + 5)
	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(data.priceLocale)
	if isLongSymbol then 
		if __IOS then
			self.buyBtn:setString(string.format("%s%.0f", currencySymbol, data.iapPrice))
		else
			self.buyBtn:setString(string.format("%s%.0f", currencySymbol, data.priceInCent/100.0))
		end
	else
		if __IOS then
			self.buyBtn:setString(string.format("%s%.2f", currencySymbol, data.iapPrice))
		else
			self.buyBtn:setString(string.format("%s%.2f", currencySymbol, data.priceInCent/100.0))
		end
	end
	self.buyBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:buyGold()
	end)


	self.flag_1 = ui:getChildByName('flag_1') 
	self.flag_2 = ui:getChildByName('flag_2')

	if type(data.flag) == 'string' then
		if data.flag == '最热门' then
			self.flag_1:setVisible(true)
			self.flag_2:setVisible(false)
		elseif data.flag == '送最多' then
			self.flag_2:setVisible(true)
			self.flag_1:setVisible(false)
		end
	else
		self.flag_1:setVisible(false)
		self.flag_2:setVisible(false)
	end


	self.icon = GoldIcon.new(ui:getChildByName('goldType'))
	self.icon:setIconType(data.iconType)


	self.goldNum = GoldNumber.new(ui:getChildByName('goldNum'))
	self.goldNum:setNumber(data.cash, data.extraCash)

	self.hole = ui:getChildByName('hole')
	self.hole:setOpacity(255*0.9)

	self.hole2 = ui:getChildByName('hole2')

	if data.iconType >= 1 and data.iconType <= 4 then
		self.hole:setVisible(false)
	else
		self.hole2:setVisible(false)
	end

	return ui
end

function BuyHappyCoinItem:__initBuyLogic()
	self.buyLogic = BuyGoldLogic:create()
	self.buyLogic:getMeta()

end


function BuyHappyCoinItem:buyGold()
	local bounds = self.icon:getUI():getGroupBounds()
	local posX = bounds:getMidX()
	local posY = bounds:getMidY()

	local function onOver()
		if self.isDisposed then return end
		self:enableAllBuyBtn()
		PlatformConfig:setCurrentPayType()
	end
	local function onCancel()

		DcUtil:logBuyGoldItem(self.data.id, 'cancel', false)
		if self.isDisposed then return end
		self:enableAllBuyBtn()
		PlatformConfig:setCurrentPayType()

		-- 取消的时候 和 失败的时候 统一弹出 重买面板
		if self.onBuyFail and type(self.onBuyFail) == 'function' then
			self.onBuyFail(self.data, self)
		end

		--refresh the panel after sign successfully
		local mp = MarketPanel:getCurrentPanel()
		if not mp.isDisposed then
			mp:refresh()
		end

		if self.quickSignCallback then
			self.quickSignCallback()
		end
	end
	local function onFail(errCode, errMsg, noTip)
		if _G.isLocalDevelopMode then printx(0, "BuyGoldItem:onFail:"..tostring(errCode)..","..tostring(errMsg)) end
		DcUtil:logBuyGoldItem(self.data.id, 'fail', false)
		if self.isDisposed then return end
		self:enableAllBuyBtn()
		if not noTip then 
			if errCode == 730241 or errCode == 730247 or errCode == 731307 then
				if not self.isNeedWechatFriendPay then
					self:runAction(CCCallFunc:create(function () CommonTip:showTipWithErrCode(errMsg, errCode, "negative") end ))
				end
				--refresh the panel after sign successfully
				local mp = MarketPanel:getCurrentPanel()
				if not mp.isDisposed then
					mp:refresh()
				end

				if self.quickSignCallback then
					self.quickSignCallback()
				end
			elseif type(errCode)=='number' and errCode == -1000061 then
				if not self.isNeedWechatFriendPay then
					self:runAction(CCCallFunc:create(function () CommonTip:showTipWithErrCode(localize("error.tip.-1000061"), errCode, "negative", nil, 3) end))		
				end
			else
				if not self.isNeedWechatFriendPay then
					local tipStrKey = "buy.gold.panel.err.undefined"
					if errCode == -6 then 
						--短代支付 支付前联网校验 特殊错误码提示联网
						tipStrKey = "dis.connect.warning.tips"
					end
					self:runAction(CCCallFunc:create(function () CommonTip:showTipWithErrCode(localize(tipStrKey), errCode, "negative", nil, 3) end))		
				end
			end
		end

		PlatformConfig:setCurrentPayType()

		if self.onBuyFail and type(self.onBuyFail) == 'function' then
			self.onBuyFail(self.data, self, errCode)
		end
		
	end

	local function onSuccess()
		DcUtil:logBuyGoldItem(self.data.id, 'success', false)
		if self.isDisposed then return end
		local scene = HomeScene:sharedInstance()
		local button
		if scene then button = scene.goldButton end
		if button then button:updateView() end
		
		CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.success"), "positive", onOver)


		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local num = self.data.cash
		local toWorldPosX = 190 + visibleOrigin.x
		local toWorldPosY = 40 + visibleOrigin.y

		local anim = FlyGoldToAnimation:create(num, ccp(toWorldPosX - 150, toWorldPosY))
		anim:setWorldPosition(ccp(posX, posY))
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
			if self.onBuySuccess then self.onBuySuccess(self.data.payType) end
		end)
		anim:play()
	end

	if __IOS then -- IOS
		self:disableAllBuyBtn()
		local function startBuyLogic()
			self:disableAllBuyBtn()
			self.buyLogic:buy(self.data.id, self.data, onSuccess, onFail, onCancel)
		end
		local function onFailLogin()
			self:enableAllBuyBtn()
		end
		RequireNetworkAlert:callFuncWithLogged(startBuyLogic, onFailLogin)
		
	else -- on ANDROID and PC we don't need to check for network
		if _G.isLocalDevelopMode then printx(0, table.tostring(self.data)) end
		PlatformConfig:setCurrentPayType(self.data.payType)
		if self.data.payType == Payments.WECHAT then
			
			local function enableButton()
				if self.isDisposed then return end
				self:enableAllBuyBtn()
			end
			setTimeOut(enableButton, 5)

			if PaymentManager.getInstance():checkCanWechatQuickPay(self.data.iapPrice) then
				if UserManager.getInstance():isWechatSigned() then
					local function onConfirm()
						DcUtil:logBuyGoldItem(self.data.id, 'money', true)
						self.buyLogic:buy(self.data.id, self.data, onSuccess, onFail, onCancel)
					end

					local WechatQuickPayConfirmPanel = require "zoo.panel.wechatPay.WechatQuickPayConfirmPanel"
					local cp = WechatQuickPayConfirmPanel:create(self.data.cash, self.data.iapPrice)
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

								if self.quickSignCallback then
									self.quickSignCallback()
								end
							end
							local resultPanel = require("zoo.panel.alipay.PanelSignResult"):create(true)
							resultPanel:popout(function ()  end)
							self.buyLogic:buy(self.data.id, self.data, localSuccess, onFail, onCancel)
							
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

							if self.quickSignCallback then
								self.quickSignCallback()
							end
						end
						self:disableAllBuyBtn()
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
		elseif self.data.payType == Payments.ALIPAY then
			-- nothing
			if PaymentManager.getInstance():checkCanAliQuickPay(self.data.iapPrice) then 
				if UserManager.getInstance():isAliSigned() then
					--todo: to popout a confirm panel

					local function onConfirm()
						DcUtil:logBuyGoldItem(self.data.id, 'money', true)
						self:disableAllBuyBtn()
						self.buyLogic:buy(self.data.id, self.data, onSuccess, onFail, onCancel)
					end

					local AliQuickPayConfirmPanel = require "zoo.panel.alipay.AliQuickPayConfirmPanel"
					local cp = AliQuickPayConfirmPanel:create(self.data.cash, self.data.iapPrice)
					cp:popout(onConfirm)

					return
				else
					if _G.use_ali_quick_pay then
						if PaymentBase:getPayment(Payments.ALI_SIGN_PAY):isEnabled() then
							if _G.isLocalDevelopMode then printx(0, 'PaymentBase:getPayment(Payments.ALI_SIGN_PAY):isEnabled()') end
							self:disableAllBuyBtn()
							local function localSuccess()
								-- 刷新签约状态
								_G.use_ali_quick_pay = false
								local mp = MarketPanel:getCurrentPanel()
								if mp and not mp.isDisposed then
									mp:refresh()
								end

								if self.quickSignCallback then
									self.quickSignCallback()
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

								if self.quickSignCallback then
									self.quickSignCallback()
								end

								if onFail then
									onFail(errCode, errMsg, noTip)
								end
							end
							self.buyLogic:buy(self.data.id, self.data, localSuccess, localFail, onCancel)
							return
						else
							local function onSignSuccess()
								--refresh the panel after sign successfully
								_G.use_ali_quick_pay = false
								local mp = MarketPanel:getCurrentPanel()
								if mp and not mp.isDisposed then
									mp:refresh()
								end
								if self.quickSignCallback then
									self.quickSignCallback()
								end

								DcUtil:logBuyGoldItem(self.data.id, 'money', true)
								self:disableAllBuyBtn()
								self.buyLogic:buy(self.data.id, self.data, onSuccess, onFail, onCancel)
							end

							local function onSignCancel()
								_G.use_ali_quick_pay = false
								local mp = MarketPanel:getCurrentPanel()
								if mp and not mp.isDisposed then
									mp:refresh()
								end
								if self.quickSignCallback then
									self.quickSignCallback()
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
		elseif self.data.payType == Payments.QQ or self.data.payType == Payments.QQ_WALLET then
			--目前QQ相关平台三方支付用MSDK 直接会调起其中的微信支付 这里是解决微信未登录无回调的问题
			local function enableButton()
				if not self.isDisposed then
					self:enableAllBuyBtn()
				end
			end
			setTimeOut(enableButton, 5)
		end
		DcUtil:logBuyGoldItem(self.data.id, 'money', true)
		self:disableAllBuyBtn()

		self.buyLogic:buy(self.data.id, self.data, onSuccess, onFail, onCancel)
	end
end

function BuyHappyCoinItem:enableAllBuyBtn()
	if self.onEnableAllBuyBtn then
		self.onEnableAllBuyBtn()
	end
end

function BuyHappyCoinItem:disableAllBuyBtn()
	if self.onDisableAllBuyBtn then
		self.onDisableAllBuyBtn()
	end
end

function BuyHappyCoinItem:setBuyBtnEnabled(bEnabled)
	if self.isOutSide then
		bEnabled = false
	end
	self.buyBtn:setEnabled(bEnabled)
end

function BuyHappyCoinItem:setBuyCallback(onEnableAllBuyBtn, onDisableAllBuyBtn, onBuySuccess, onBuyFail)
	self.onEnableAllBuyBtn = onEnableAllBuyBtn
	self.onDisableAllBuyBtn = onDisableAllBuyBtn 
	self.onBuySuccess = onBuySuccess
	self.onBuyFail = onBuyFail
end

function BuyHappyCoinItem:setQuickSignCallback(callback)
	self.quickSignCallback = callback
end

function BuyHappyCoinItem:setOutSideView(isOutSide)
	if isOutSide ~= self.isOutSide then
		self.isOutSide = isOutSide
		if self.isOutSide then
			self:setBuyBtnEnabled(false)
		else
			self:setBuyBtnEnabled(true)
		end
	end
end

return BuyHappyCoinItem