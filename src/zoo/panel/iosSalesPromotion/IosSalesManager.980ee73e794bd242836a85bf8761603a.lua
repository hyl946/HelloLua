IosSalesManager = {}

--for IosOneYuanPromotionType.OneYuanAlphaProp 
local promotionConfigAlpha = table.const{
	[29] = {oriPrice = 20, 	pLevel = 1},
	[30] = {oriPrice = 20, 	pLevel = 1},
	[31] = {oriPrice = 12, 	pLevel = 2},
	[32] = {oriPrice = 12, 	pLevel = 2},
	[33] = {oriPrice = 8.5, pLevel = 3},
	[34] = {oriPrice = 9, 	pLevel = 3},
	[35] = {oriPrice = 5.5, pLevel = 4},
	[36] = {oriPrice = 6, 	pLevel = 4},
	[37] = {oriPrice = 10, 	pLevel = 5},
	[38] = {oriPrice = 10, 	pLevel = 5},
	[39] = {oriPrice = 10, 	pLevel = 5},
}

function IosSalesManager:seperateItemTable(rewardsTable)
	local coinTable = {}
	local itemTable = {}
	if rewardsTable then
		for k,v in pairs(rewardsTable) do
			if v.itemId == ItemType.GOLD then 
				table.insert(coinTable, v)
			else
				table.insert(itemTable, v)
			end
		end
	end
	return coinTable, itemTable 
end

function IosSalesManager:getPromitonConfigById(productId)
	for k,v in pairs(promotionConfigAlpha) do
		if k == productId then 
			return v 
		end
	end
end