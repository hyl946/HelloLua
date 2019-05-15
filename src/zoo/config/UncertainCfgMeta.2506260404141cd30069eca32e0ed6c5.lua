UncertainCfgMeta = class()

function UncertainCfgMeta:ctor()
	
end

function UncertainCfgMeta:create( config )
	-- body
	local meta = UncertainCfgMeta.new()
	meta:init(config)
	return meta
end

function UncertainCfgMeta:init( config )
	-- body
	self.allItemList = {}
	self.canfallingItemList = {}
	self.dropPropList = {}
	self.dropPropTotalWeight = 0
	local allItemPer = 0
	for k, v in pairs(config) do 
		-- if _G.isLocalDevelopMode then printx(0, v.k, v.v) end debug.debug()
		local item = {}
		local value = v.k:split("_")
		item.changeType = tonumber(value[1])    --可以变的item的类型
		item.changeItem = tonumber(value[2])    --可以变得item 在tile中的值
		item.changePer = tonumber(v.v)          --权重
		
		allItemPer = allItemPer + item.changePer
		
		if item.changeType == UncertainCfgConst.kProps then -- 道具独立记录，因为需要做限制
			table.insert(self.dropPropList, item)
		else
			table.insert(self.allItemList, item)
			if item.changeType ~= UncertainCfgConst.kCannotFalling then
				table.insert(self.canfallingItemList, item)
			end
		end
	end

	local perlimit = 0
	local str = "allItemPer:"
	for k = 1, #self.allItemList do 
		local v = self.allItemList[k]
		local per = math.ceil(v.changePer* 10000/allItemPer)
		perlimit = perlimit + per
		v.limitInAllItem = perlimit
		str = str.."|"..v.limitInAllItem
	end
	-- if _G.isLocalDevelopMode then printx(0, str) end
	perlimit = 0 
	local str1 = "allCanFallingItemPer:"
	for k = 1, #self.canfallingItemList do 
		local v = self.canfallingItemList[k]
		local per = math.ceil(v.changePer* 10000/allItemPer)
		perlimit = perlimit + per
		v.limitInCanFallingItem = perlimit
		str1 = str1.."|"..v.limitInCanFallingItem
	end
	-- if _G.isLocalDevelopMode then printx(0, str1) end

	perlimit = 0 
	local str2 = "dropPropPer:"
	for k = 1, #self.dropPropList do
		local v = self.dropPropList[k]
		local per = math.ceil(v.changePer* 10000/allItemPer)

		self.dropPropTotalWeight = self.dropPropTotalWeight + per
		perlimit = perlimit + per
		v.limitInProps = perlimit
		str2 = str2.."|"..v.limitInProps
	end
end

function UncertainCfgMeta:hasDropProps()
	return self.dropPropTotalWeight > 0
end