
MarkPrisePanelModel = {}

function MarkPrisePanelModel:getMarkPriseInfo(index)
	local goodsId = MarkPrisePanelModel:getGoodsId(index)
	if type(goodsId) ~= "number" then return {} end
	local meta = MetaManager:getInstance():getGoodMeta(goodsId)
	if type(meta) ~= "table" then return {} end
	local res = {}
	for k, v in ipairs(meta.items) do
		table.insert(res, {itemId = v.itemId, num = v.num})
	end
	return res
end

function MarkPrisePanelModel:getGoodsId(index)
	local markMeta = MetaManager:getInstance().mark
	if type(markMeta) ~= "table" then return end
	if type(markMeta[index]) ~= "table" then return end
	return markMeta[index].goodsId
end

local function mathRound(num)
	if (num * 100) % 10 > 5 then 
		return math.ceil(num * 10)
	else 
		return math.floor(num * 10) 
	end
end

function MarkPrisePanelModel:getRmbPriceAndDiscount(index)
	local discount = 10
	local goodsId = MarkPrisePanelModel:getGoodsId(index)
	local meta = MetaManager:getInstance():getGoodMeta(goodsId)
	local oriPrice = meta.rmb / 100
	local nowPrice = meta.discountRmb / 100
	discount = mathRound(nowPrice / oriPrice)
	return oriPrice, nowPrice, discount
end

function MarkPrisePanelModel:getWindMillPriceAndDiscount(index)
	local discount = 10
	local goodsId = MarkPrisePanelModel:getGoodsId(index)
	local meta = MetaManager:getInstance():getGoodMeta(goodsId)
	local oriPrice = meta.qCash
	local nowPrice = meta.discountQCash
	discount = mathRound(nowPrice / oriPrice)
	return oriPrice, nowPrice, discount
end