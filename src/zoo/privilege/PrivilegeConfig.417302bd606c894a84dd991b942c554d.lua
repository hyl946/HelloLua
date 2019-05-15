PrivilegeType = table.const{
	kPreProp = 1,
	kRankRace = 2,
	kDiscountBuy = 3,
}

local PrePropVO = class()
function PrePropVO:ctor()
	self.level = level
	self.preItemIDs = nil
	self.endTime = nil
end

function PrePropVO:decode(src)
	if src.level and type(src.level) == "number" 
		and src.preItemIDs and type(src.preItemIDs) == "table"
		and src.endTime and type(src.endTime) == "number" then
		self.level = src.level
		self.preItemIDs = src.preItemIDs
		self.endTime = src.endTime
		return true
	end
	return false
end

function PrePropVO:toObject()
	return {level = self.level, preItemIDs = self.preItemIDs, endTime = self.endTime}
end


local RankRaceVO = class()
function RankRaceVO:ctor()
	self.level = nil
	self.extraNumRed = nil
	self.extraNumYellow = nil
	self.endTime = nil
end

function RankRaceVO:decode(src)
	if src.level and type(src.level) == "number" 
		and src.extraNumRed and type(src.extraNumRed) == "number" 
		and src.extraNumYellow and type(src.extraNumYellow) == "number" 
		and src.endTime and type(src.endTime) == "number" then
		self.level = src.level
		self.extraNumRed = src.extraNumRed
		self.extraNumYellow = src.extraNumYellow
		self.endTime = src.endTime
		return true
	end
	return false
end

function RankRaceVO:toObject()
	return {level = self.level, extraNumRed = self.extraNumRed, extraNumYellow = self.extraNumYellow, endTime = self.endTime}
end

local DiscountBuyVO = class()
function DiscountBuyVO:ctor()
	self.level = nil
	self.extraItemId = nil
	self.discountGoodsIDs = nil
	self.endTime = nil
end

function DiscountBuyVO:decode(src)
	if src.level and type(src.level) == "number" 
		and src.extraItemId and type(src.extraItemId) == "number" 
		and src.discountGoodsIDs and type(src.discountGoodsIDs) == "table" 
		and src.endTime and type(src.endTime) == "number" then
		self.level = src.level
		self.extraItemId = src.extraItemId
		self.discountGoodsIDs = src.discountGoodsIDs
		self.endTime = src.endTime
		return true
	end
	return false
end

function DiscountBuyVO:toObject()
	return {level = self.level, extraItemId = self.extraItemId, discountGoodsIDs = self.discountGoodsIDs, endTime = self.endTime}
end

local PrivilegeConfig = {}
function PrivilegeConfig:getVOClass(privilegeType)
	if privilegeType == PrivilegeType.kPreProp then 
		return PrePropVO
	elseif privilegeType == PrivilegeType.kRankRace then 
		return RankRaceVO
	elseif privilegeType == PrivilegeType.kDiscountBuy then 
		return DiscountBuyVO
	end
end

return PrivilegeConfig