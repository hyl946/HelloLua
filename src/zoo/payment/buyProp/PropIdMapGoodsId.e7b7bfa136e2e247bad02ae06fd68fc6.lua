
-- 新表 一个道具过个选项
require "zoo.common.ItemType"

local newMap =  {
	[ItemType.INGAME_REFRESH] = {1, 648, 649},
	[ItemType.INGAME_BACK] = {2, 651, 652},
	[ItemType.INGAME_SWAP] = {3, 654, 655},
	[ItemType.INGAME_ROW_EFFECT] = {557, 657, 658},
	[ItemType.INGAME_COLUMN_EFFECT] = {558, 660, 661},

	[ItemType.INGAME_HAMMER] = {7, 663, 664},
	[ItemType.INGAME_BRUSH] = {5, 666, 667},
}

-- 旧表
local oldMap = {
  [10001] = 1, [10002] = 2, [10003] = 3,
  [10004] = 4, [10005] = 5, [10010] = 7,
  [10052] = 148,
  [10055] = 151,
  [10056] = 153,
  [10103] = 553,
  [10105] = 557,
  [10109] = 558,
}

local PropIdMapGoodsId = {}

function PropIdMapGoodsId:getOldMap( ... )
	return oldMap
end

function PropIdMapGoodsId:getNewMap( ... )
	return newMap
end

function PropIdMapGoodsId:getGoodsIdList( propId, multi )
	local ret
	if newMap[propId] then
		ret = newMap[propId]
	elseif oldMap[propId] then
		ret = {oldMap[propId]}
	else
		ret = {}
	end

	if not multi then
		ret = table.headn(ret, 1)
	end


	if UserManager:getInstance():getDailyBoughtGoodsNumById(148) > 0 then
		ret = table.map(function ( v )
			if v == 148 then
				return 147
			else
				return v
			end
		end, ret)
	end

	return ret
end

return PropIdMapGoodsId