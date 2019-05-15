local TradeUtils = {}

function TradeUtils:getCashPrice( goodsId )
	local goodsData = MarketManager:getGoodsById(goodsId)
	if goodsData and goodsData.currentPrice then
		return goodsData.currentPrice
	else
		return 0
	end
end

function TradeUtils:getCashOriPrice( goodsId )
	local goodsMeta = MetaManager.getInstance():getGoodMeta(goodsId)
	return goodsMeta.qCash or 0
end


function TradeUtils:getRmbPrice( goodsId )
	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	if goodsMeta and goodsMeta.discountRmb and goodsMeta.discountRmb > 0 then
		return goodsMeta.discountRmb / 100
	elseif goodsMeta and goodsMeta.rmb then
		return goodsMeta.rmb / 100
	else
		return 0
	end
end

function TradeUtils:getRmbOriPrice( goodsId )
	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	if goodsMeta and goodsMeta.rmb then
		return goodsMeta.rmb / 100
	else
		return 0
	end
end

function TradeUtils:formatPriceShow(price)
	price = tonumber( price )
	return string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
end

function TradeUtils:getItems( goodsId )
	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	if goodsMeta and goodsMeta.items then
		local ret = {}
		for _, v in ipairs(goodsMeta.items) do
			table.insert(ret, {itemId = v.itemId, num = v.num})
		end
		return ret
	else
		return {}
	end
end

function TradeUtils:isGoldEnough( goodsId )
	local user = UserManager:getInstance().user
	local meta = MetaManager:getInstance():getGoodMeta(goodsId)
	if user and meta then
		local finalCash = TradeUtils:getCashPrice(goodsId)
		if finalCash == 0 then
			return false
		elseif user:getCash() >= finalCash then
			return true
		end
	end
	return false
end

return TradeUtils