
GoodsLocalLogic = class()
local kITEM_TYPE_BAG = 10
local kITEM_TYPE_RANGE = 10000

local INGAME_TYPE_GOODS = 1
local INGAME_TYPE_CASH = 2

function GoodsLocalLogic:getItemId( goodsMeta )
	if not goodsMeta then return nil end
	return goodsMeta.items[1].itemId
end

function GoodsLocalLogic:getCash( uid, goodsMeta )
	if GoodsMetaRef:isSupplyEnergyGoods( goodsMeta.id ) then
		UserLocalLogic:refreshEnergy()
		local buyer = UserService.getInstance().user
		local buyEnergyCount = UserLocalLogic:getUserEnergyMaxCount() - buyer:getEnergy()
		return goodsMeta:getCash() * buyEnergyCount
	elseif ItemConstans.ITEM_MARK == GoodsLocalLogic:getItemId(goodsMeta) then
		local addNum = UserService.getInstance().mark.addNum or 0
		local addMarkPrice = MetaManager.getInstance().global:getAddMarkPirce(addNum + 1)
		return addMarkPrice
	else 
		return goodsMeta:getCash()
	end
end

function GoodsLocalLogic:deliverGoods( uid, goodsMeta, cartNum, targetId )
	cartNum = cartNum or 0
	--dailyDataService.recordLimitGoodsBuyLog(uid, goodsMeta, cartNum)
	if GoodsMetaRef:isSupplyEnergyGoods( goodsMeta.id ) then
		UserLocalLogic:addEnergy(uid, UserLocalLogic:getUserEnergyMaxCount())
	else
		local items = goodsMeta.items
		for i, item in ipairs(items) do
			if item.itemId == ItemConstans.ITEM_FURIT_ACCELERATE then --online module
			elseif item.itemId == ItemConstans.ITEM_LADY_BUG_RESTART then --online module
			elseif item.itemId == ItemConstans.ITEM_ENERGY_PROP then
				local propMeta = MetaManager:getInstance():getPropMeta(item.num)
				UserExtendsLocalLogic:extraEenrgy(uid, propMeta)
				UserLocalLogic:addEnergy( uid, UserLocalLogic:getUserEnergyMaxCount(uid) )
			else
				GoodsLocalLogic:deliverItem( uid, item.itemId, item.num * cartNum )
			end
		end
	end
end

function GoodsLocalLogic:deliverItem( uid, itemId, num )
	local itemType = itemId / kITEM_TYPE_RANGE
	if itemType < kITEM_TYPE_BAG then --normal item		
		return ItemLocalLogic:add( uid, itemId, num )
	else
		return GoodsLocalLogic:addBuyCount( uid )
	end
end

function GoodsLocalLogic:addBuyCount( uid )
	if _G.isLocalDevelopMode then printx(0, "ERROR! not implement bag") end
end

function GoodsLocalLogic:ingame( id, orderId, channel, ingameType, detail )
	local user = UserService.getInstance().user
	local uid = user.uid
	if ingameType == INGAME_TYPE_CASH then
		local productMeta = MetaManager.getInstance():getProductMetaByID(id)
		if productMeta then ItemLocalLogic:add( uid, ItemConstans.ITEM_CASH, productMeta.cash ) end
	elseif ingameType == INGAME_TYPE_GOODS then
		local goodsId = id
		local num = 1
		local goodsMeta = MetaManager.getInstance():getGoodMeta(goodsId)
		local rmb = goodsMeta.rmb or 0
		if rmb <= 0 then return false, ZooErrorCode.BUY_WRONG_MONEY_TYPE end 
		local cash = goodsMeta:getCash() or 0
		GoodsLocalLogic:deliverGoods( uid, goodsMeta, num, 0 )
	end
	return true
end