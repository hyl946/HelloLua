
local CommonViewLogic = {}
local UIHelper = require 'zoo.panel.UIHelper'

function CommonViewLogic:setDiscount( discountUI, discount )
	if discount ~= math.ceil(discount) then
		discount = math.floor(discount * 10 + 0.5) / 10
	end

	if discount > 0 and discount < 10 then
		discountUI:getChildByPath('num'):changeFntFile('fnt/hud.fnt')
		discountUI:getChildByPath('num'):setText(discount)
		local discountHolder = discountUI:getChildByPath('holder')
		local pos = discountHolder:getPosition()
		discountHolder:setVisible(false)
		discountUI:getChildByPath('num'):setPositionXY(pos.x, pos.y)
		discountUI:getChildByPath('num'):setScale(2.4)
		discountUI:getChildByPath('num'):setAnchorPoint(ccp(0.5, 0.5))

		if math.ceil(discount) ~= discount then
			discountUI:getChildByPath('num'):setAnchorPointCenterWhileStayOrigianlPosition()
			discountUI:getChildByPath('num'):setScale(2.4 * 0.6)
			discountUI:getChildByPath('text'):setAnchorPointCenterWhileStayOrigianlPosition()
			discountUI:getChildByPath('text'):setScale(0.8)

			if not discountUI._offseted then
				discountUI._offsetX = true
				UIHelper:move(discountUI:getChildByPath('text'), 4)
			end
		end



		if not discountUI._anim then
			discountUI._anim = true
			discountUI:runAction(CCRepeatForever:create(UIHelper:sequence{
				CCRotateTo:create(2/30, -9.2),
				CCRotateTo:create(3/30, 14.7016),
				CCRotateTo:create(2/30, -11.1895),
				CCRotateTo:create(2/30, -5.5248),
				CCRotateTo:create(1/30, 0),
				CCDelayTime:create(3)
			}))
		end
	else
		discountUI:setVisible(false)
	end
end

function CommonViewLogic:setDiscountRmbAndRmb( discountUI, discountRmb, rmb )
	if discountRmb and discountRmb > 0 then 
		local discount = discountRmb / rmb * 10
		CommonViewLogic:setDiscount(discountUI, discount)
	else
		discountUI:setVisible(false)
	end
end


function CommonViewLogic:setTitle( titleLabel, goodsId, fnt, scale)
	UIHelper:setCenterText(titleLabel, localize('goods.name.text' .. goodsId), fnt or 'fnt/libao1.fnt')
	titleLabel:setAnchorPointCenterWhileStayOrigianlPosition()
	titleLabel:setScale( (scale or 0.9) * titleLabel:getScaleX())
	UIHelper:move(titleLabel, 0, -2)
end

local TickTaskMgr = require 'zoo.areaTask.TickTaskMgr'


function CommonViewLogic:setTimeAndBuyLimit( flag, endTime, buyLimit, buyCount, timeoutCallback, noShowEndTime)

	local self = flag
	if self.isDisposed then return end

	if (not endTime) and (not buyLimit) then
		self:setVisible(false) 
		return
	end


	local endTimeRes 
	local buyLimitRes

	local hideEndTime


	if endTime and (not buyLimit) then
		self:getChildByPath('fag-bg'):setVisible(false)
		endTimeRes = 'thin-bg/text'

		if noShowEndTime then
			self:getChildByPath('thin-bg'):setVisible(false)
			hideEndTime = true
		end
	end


	if buyLimit and (not endTime) then
		self:getChildByPath('fag-bg'):setVisible(false)
		buyLimitRes = 'thin-bg/text'
	end



	local endTimeResScale
	local buyLimitResScale


	if buyLimit and endTime then
		self:getChildByPath('thin-bg'):setVisible(false)
		endTimeRes = 'fag-bg/text1'
		buyLimitRes = 'fag-bg/text2'
		buyLimitResScale = 0.55
		endTimeResScale = 0.7
		-- UIHelper:move(self:getChildByPath(endTimeRes), 0, 6)

		if endTimeRes and noShowEndTime then
			endTimeRes = 'thin-bg/text'
			buyLimitRes = 'thin-bg/text'
			buyLimitResScale = nil
			endTimeResScale = nil
			hideEndTime = true
			self:getChildByPath('thin-bg'):setVisible(true)
			self:getChildByPath('fag-bg'):setVisible(false)
		end
	end

	if endTimeRes then

		if not hideEndTime then
			UIHelper:move(self:getChildByPath(endTimeRes), 0, -3)
		end

		self.tickMgr = TickTaskMgr.new()
		self.tickMgr:setTickTask(1, function ( ... )
     		if self.isDisposed then return end
     		local rest = endTime - Localhost:timeInSec()

     		-- printx(61,  rest, getTimeFormatString(math.max(0, rest)) , ' getTimeFormatString(math.max(0, rest))')
     		if not hideEndTime then
				UIHelper:setCenterText(self:getChildByPath(endTimeRes), getTimeFormatString(math.max(0, rest)), 'fnt/libao6.fnt')
				if rest > 24 * 3600 then
					UIHelper:setCenterText(self:getChildByPath(endTimeRes), '仅限' .. math.ceil(rest/(24*3600)) .. '天', 'fnt/libao6.fnt')
				end

				self:getChildByPath(endTimeRes):setAnchorPointCenterWhileStayOrigianlPosition()
				self:getChildByPath(endTimeRes):setScale(endTimeResScale or 0.8)
			end

			
			if rest < 0 and timeoutCallback then
				self.tickMgr:stop()
				if timeoutCallback then timeoutCallback() end
				return
			end
    	end)

    	local old_dispose = self.dispose
    	self.dispose = function ( ... )
    		old_dispose(...)
    		self.tickMgr:stop()
    		self.tickMgr = nil
    	end
    	self.tickMgr:step()
    	self.tickMgr:start()
	end

	if buyLimitRes then
		UIHelper:move(self:getChildByPath(buyLimitRes), 0, -3)
		self.onBuyCountChange = function ( _, buyCount )
    		if self.isDisposed then return end
			UIHelper:setCenterText(self:getChildByPath(buyLimitRes), '限购' .. tostring(buyLimit - buyCount) .. '次', 'fnt/libao6.fnt')
    		self:getChildByPath(buyLimitRes):setAnchorPointCenterWhileStayOrigianlPosition()
			self:getChildByPath(buyLimitRes):setScale(buyLimitResScale or 0.8)
    	end
    	self:onBuyCountChange(buyCount)
	end

end

return CommonViewLogic