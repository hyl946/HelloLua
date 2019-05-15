
GoodsIdInfoObject = class()

--一元特价相关道具id偏移量
local ID_DELTA_ALPHA = 5000
--7天以上未付费用户五折道具id偏移量
local ID_DELTA_BETA = 6000
--获取风车币名字或者paycode的id偏移量
local ID_DELTA_GAMMA = 10000

GoodsIdChangeType = table.const{
	kNormal = "kNormal",
	kOneYuanChange = "kOneYuanChange",
	kAwakenPayChange = "kAwakenPayChange",
}

function GoodsIdInfoObject:ctor()
	--原始id
	self.oriGoodsId = nil
	--一元特价道具id
	self.alphaGoodsId = nil
	--7天以上未付费用户五折道具id
	self.betaGoodsId = nil
end

function GoodsIdInfoObject:init(goodsId, goodsType)
	self.goodsType = goodsType or GoodsType.kItem
	self.currentGoodsId = goodsId
	if self.goodsType ~= GoodsType.kCurrency then 
		if goodsId <= ID_DELTA_ALPHA then 
		self.oriGoodsId = goodsId
		elseif goodsId > ID_DELTA_ALPHA and goodsId <= ID_DELTA_BETA then   
			self.oriGoodsId = goodsId - ID_DELTA_ALPHA
		elseif goodsId > ID_DELTA_BETA then 
			self.oriGoodsId = goodsId - ID_DELTA_BETA
		end

		self.alphaGoodsId = self.oriGoodsId
		self.betaGoodsId = self.oriGoodsId
		local hasDiscount = false
		for k,v in pairs(ThirdPayPromotionConfig) do
			if k == self.oriGoodsId then 
				hasDiscount = true
				break
			end
		end

		if hasDiscount then 
			self.alphaGoodsId = self.oriGoodsId + ID_DELTA_ALPHA
			self.betaGoodsId = self.oriGoodsId + ID_DELTA_BETA
		end
	else
		self.oriGoodsId = goodsId
		self.alphaGoodsId = goodsId
		self.betaGoodsId = goodsId
	end
end

function GoodsIdInfoObject:setGoodsIdChange(changeType)
	if changeType then 
		if changeType == GoodsIdChangeType.kOneYuanChange then 
			self.currentGoodsId = self.alphaGoodsId
			return
		elseif changeType == GoodsIdChangeType.kAwakenPayChange then 
			self.currentGoodsId = self.betaGoodsId
			return 
		end
	end
	self.currentGoodsId = self.oriGoodsId
end

function GoodsIdInfoObject:getCurrentChangeType()
	if self.currentGoodsId == self.alphaGoodsId then 
		return  GoodsIdChangeType.kOneYuanChange
	elseif self.currentGoodsId == self.betaGoodsId then 
		return  GoodsIdChangeType.kAwakenPayChange
	else
		return  GoodsIdChangeType.kNormal
	end
end

function GoodsIdInfoObject:getOriginalGoodsId()
	return self.oriGoodsId
end

function GoodsIdInfoObject:getOneYuanGoodsId()
	return self.alphaGoodsId
end

function GoodsIdInfoObject:getAwakenPayGoodsId()
	return self.betaGoodsId
end

function GoodsIdInfoObject:getGoodsId()
	return self.currentGoodsId
end

function GoodsIdInfoObject:getGoodsNameId()
	if self.goodsType == GoodsType.kCurrency then 
		return self.currentGoodsId + ID_DELTA_GAMMA
	else
		return self.currentGoodsId
	end
end	

function GoodsIdInfoObject:getGoodsPayCodeId(paymentType)
	if self.goodsType == GoodsType.kCurrency then 
		return self.currentGoodsId + ID_DELTA_GAMMA
	else
		if paymentType and paymentType == Payments.MI then -- 小米打折1元购买特殊处理
			if self.currentGoodsId > ID_DELTA_ALPHA and self.currentGoodsId <= ID_DELTA_BETA then
				if self.currentGoodsId == 5018 then 	
					return 214		--高级精力瓶 2块
				else
					return 213		--高级精力瓶 1块
				end
			else
				return self.currentGoodsId
			end
		else
			return self.currentGoodsId
		end
	end
end

function GoodsIdInfoObject:getGoodsType()
	return self.goodsType
end

function GoodsIdInfoObject:getDiscountNum()
	local discountNum = 10
	if self.currentGoodsId == self.alphaGoodsId then
		local discountInfo = ThirdPayPromotionConfig[self.oriGoodsId]
		if discountInfo then 
			discountNum = discountInfo.discount
		end 
	end
	return discountNum
end

function GoodsIdInfoObject:create(goodsId, goodsType)
	local obj = GoodsIdInfoObject.new()
	obj:init(goodsId, goodsType)
	return obj
end