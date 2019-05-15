--=====================================================
-- DTBuyGoldItem
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  DTBuyGoldItem.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/11/21
-- descrip:   2016双十二活动 商店风车币促销ui组件
--=====================================================
require "zoo.localActivity.doubleTwelve.DTPromotionBar"

DTBuyGoldItem = class(BuyGoldItem)

function DTBuyGoldItem:create(itemData, successCallback, failCallback)
	local instance = DTBuyGoldItem.new()
	instance:loadRequiredResource(PanelConfigFiles.buy_gold_items) 
	instance:init(itemData, successCallback, failCallback)
	return instance
end

function DTBuyGoldItem:getItemResPre()
	return "2016_double_twelve/goldItemLevel"
end

function DTBuyGoldItem:init(itemData, successCallback, failCallback)
	BuyGoldItem.init(self, itemData, successCallback, failCallback)
	local size = self.ui:getGroupBounds().size
	self.bg = self.ui:getChildByName("bg")
	self.moveDelta = size.height - self.bg:getContentSize().height

	local barUI = self.ui:getChildByName("promotionBar")
	local barPos = barUI:getPosition()
	self.promotionBarPos = barPos
	self.promotionBar = DTPromotionBar:create(barUI, self)
	self.promotionBar:setVisible(false)

	self.promotionBarShow = false
	self:update(true)
end

function DTBuyGoldItem:afterBuySuccess()
	local context = self

	local function serverSuc()
		if context.isDisposed then return end
		context:update()
		if context.procClick then context:setButtonEnable(true) end
	end

	local function serverFail()
		if context.isDisposed then return end
		context:cleanPromotionBarAndData()
		if context.procClick then context:setButtonEnable(true) end
	end

	local function sendServerRefresh()
		DTPromotionManager.getInstance():loadIosData(serverSuc, serverFail)
	end

	local function addRewardCallback()
		sendServerRefresh()
	end

	local function endCallback()
		local data = DTPromotionManager.getInstance():getIosPromotionDataByPrice(context.itemData.iapPrice)
		if data and context.promotionBarShow then 
			context.promotionBar:addReward(addRewardCallback)
		else
			sendServerRefresh()
		end
	end

	DTPromotionManager.getInstance():sendServerCashBuy(self.itemData.iapPrice, endCallback)
end

function DTBuyGoldItem:getHeight()
	local barVisible = self.promotionBar:isVisible()
	if barVisible then 
		return self:getGroupBounds().size.height
	else
		return self.bg:getGroupBounds().size.height
	end
end

function DTBuyGoldItem:setAllGoldItemTable(allGoldItemTable)
	self.allGoldItemTable = allGoldItemTable
end

function DTBuyGoldItem:showPromotionBar(noMove)
	local data = DTPromotionManager.getInstance():getIosPromotionDataByPrice(self.itemData.iapPrice)
	if data then 
		self.promotionBarShow = true

		if noMove then 
			self.promotionBar:showLight()
		else
			local moveTime = 0.2
			self.promotionBar:showAnimation(moveTime, self.moveDelta)
			if self.allGoldItemTable and #self.allGoldItemTable > 0 then 
				for k,v in pairs(self.allGoldItemTable) do
					if v.goldLevel > self.goldLevel then 
						v:runAction(CCEaseSineOut:create(CCMoveBy:create(moveTime, ccp(0, -self.moveDelta))))
					end
				end
			end
			self.parentView:updateScrollableHeight()
		end
	end
end

function DTBuyGoldItem:hidePromotionBar()
	self.promotionBarShow = false

	local moveTime = 0.2
	self.promotionBar:hideAnimation(moveTime, self.moveDelta)
	if self.allGoldItemTable and #self.allGoldItemTable > 0 then 
		for k,v in pairs(self.allGoldItemTable) do
			if v.goldLevel > self.goldLevel then 
				v:runAction(CCEaseSineOut:create(CCMoveBy:create(moveTime, ccp(0, self.moveDelta))))
			end
		end
	end
	self.parentView:updateScrollableHeight()
end

function DTBuyGoldItem:cleanPromotionBarAndData()
	DTPromotionManager.getInstance():removeIosPromotionDataByPrice(self.itemData.iapPrice)
	if self.parentView then 
		self:hidePromotionBar()
	end
end

function DTBuyGoldItem:update(isFirstTime)
	local data = DTPromotionManager.getInstance():getIosPromotionDataByPrice(self.itemData.iapPrice)
	if self.promotionBarShow then 
		if data then 
			self.promotionBar:updateData(data)
			self:showPromotionBar(true)
		else
			self:hidePromotionBar()
		end
	else
		if data then 
			self.promotionBar:updateData(data)
			if isFirstTime then 
				self:showPromotionBar(true)
			else
				self:showPromotionBar(false)
			end
		end
	end
end
