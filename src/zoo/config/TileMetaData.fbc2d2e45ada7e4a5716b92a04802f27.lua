---------------------------------------------------------------------------------
-- 从配置解出来的tile定义
---------------------------------------------------------------------------------

require "zoo.config.TileConfig"
TileMetaData = class()

function TileMetaData:ctor()
	self.x = 1    --col
	self.y = 1    --row
	self.tileProperties = {}
	for i = 1, TileConst.kMaxTile do
		table.insert(self.tileProperties, false)
	end
	self.tileAttrs = {}
end

function TileMetaData:dispose()
	self.tileProperties = nil
	self.tileAttrs = nil
end

function TileMetaData:removeTileData(index)
	self.tileProperties[index] = false
	self:removeAttrOfProperty(index)
end

function TileMetaData:isEmptyTile()
	return self.tileProperties[1]
end

function TileMetaData:clearAllProperties()
	--空格的定义不用清
	if not self:isEmptyTile() then
		for i = 2, #self.tileProperties do
			self.tileProperties[i] = false
		end
	end
	self.tileAttrs = {}
end

function TileMetaData:getAllPropertys()
	local arr = {}
	for k,v in pairs(self.tileProperties) do
		if v then
			table.insert( arr , k )
		end
	end
	return arr
end

function TileMetaData:hasProperty(property)
	if property == TileConst.kInvalid then
		for i = 1, #self.tileProperties do
			if self.tileProperties[i] then
				return false
			end
		end

		return true
	end
	return self.tileProperties[property]
end

function TileMetaData:getChainsMeta()
	local chains = {}
	for i = TileConst.kChain1, TileConst.kChain5_Left do
		if self.tileProperties[i] then
			local chain = {}
			chain.level = math.floor((i - TileConst.kChain1) / 5) + 1	-- 取值：1-5
			chain.direction = (i - TileConst.kChain1) % 5				-- 1-4：上右下左
			table.insert(chains, chain)
		end
	end 
	return chains
end

function TileMetaData:hasMagicStoneProperty()
	for i = TileConst.kMagicStone_Up, TileConst.kMagicStone_Left do
		if self.tileProperties[i] then
			local dir = i - TileConst.kMagicStone_Up + 1
			return true, dir
		end
	end
	return false, nil
end

function TileMetaData:getCrossStrengthLevel()
	return self.crossStrengthLevel
end

function TileMetaData:getCrossStrengthColor()

	if self.crossStrengthColor and tostring(self.crossStrengthColor) ~= "0" then
		--return AnimalTypeConfig.convertIndexToColorType( self.crossStrengthColor )
		return self.crossStrengthColor
	end
	return 0
end

function TileMetaData:setTileData(index)
	self.tileProperties[index] = true
end

function TileMetaData:copyProperties(t)
	for i = 1, #t.tileProperties do
		if t.tileProperties[i] then
			self:setTileData(i)
		end
	end
end

function TileMetaData:copyAttrs(t)
	self.tileAttrs = table.clone(t, true)
end

function TileMetaData:addTileData(property)
	if property ~= TileConst.kInvalid then
		self.tileProperties[property] = true
	else
		self:clearAllProperties()
	end
end

function TileMetaData:removeMultipleTileData(properties)
	for i = 1, #properties do
		self:removeTileData(properties[i])
	end
end

function TileMetaData:convertFromStringToTileIndex(value)
	local propertyList = value:split(",")
	for k, v in pairs(propertyList) do
		local tileValue = v
		local tileValueArr = tileValue:split("_")
		local prop = tonumber(tileValueArr[1]) + 1
		self:setTileData(prop)
		if tileValueArr[2] then
			self:setAttrOfProperty(prop, tileValueArr[2])
	end
	end
	if #propertyList > 0 then
		self:removeTileData(TileConst.kEmpty)
	end
end

function TileMetaData:addPropertiesArray(value)
	local reverse = #value + 1
	for i = 1, #value do
		local c = string.sub(value, i, i)
		self.tileProperties[reverse - i] = c ~= "0"
	end

	--如果是个空格，把第一位标志设成true
	local a, b = string.find(value, "1")
	if a and a < #value then
		self:removeTileData(TileConst.kEmpty)
	else
		self:setTileData(TileConst.kEmpty)
	end
end

function TileMetaData:getProperties()
	return self.tileProperties
end

function TileMetaData:removeAttrOfProperty(property)
	if property then
		self.tileAttrs[property] = nil
	end
end

function TileMetaData:setAttrOfProperty(property, attr)
	if property then
		self.tileAttrs[property] = attr
	end
end

function TileMetaData:getAttrOfProperty(property)
	if property then
		return self.tileAttrs[property]
	end
	return nil
end

function TileMetaData:setTileAttrs(tileAttrs)
	if tileAttrs and string.len(tileAttrs) > 0 then
		for _, attr in pairs(string.split(tileAttrs, ",")) do
			local kvParis = string.split(attr, "=")
			self:setAttrOfProperty(tonumber(kvParis[1])+1, kvParis[2]) 
		end
	end
end

function TileMetaData:setAddInfoData(addInfoData)
    self.addInfo = {}
    if type(addInfoData) == "string" and string.len(addInfoData) > 0 then 
        local strA1 = string.split(addInfoData, ";")
	    for _, v in pairs(strA1) do
	        local strA2 = string.split(v, "=")
	        if #strA2 == 2 and tonumber(strA2[1]) then
	        	self:setAddInfoOfProperty(tonumber(strA2[1])+1, strA2[2])
	        end
	    end 
    end
end

function TileMetaData:getAddInfoOfProperty(property)
	return self.addInfo and self.addInfo[property] or nil
end

function TileMetaData:removeAddInfoOfProperty(property)
	if self.addInfo then
		self.addInfo[property] = nil
	end
end

function TileMetaData:setAddInfoOfProperty(property, addInfo)
	if not self.addInfo then self.addInfo = {} end
	self.addInfo[property] = addInfo
end

function TileMetaData:toString()
	local str = ""
	local len = #self.tileProperties
	while len > 0 do
		if self.tileProperties[len] then
			str = str .. "1"
		else
			str = str .. "0"
		end
		len = len - 1
	end

	local val = BigInt.str2bigInt(str, 2, 0)
	str = BigInt.bigInt2str(val, 10)
	return str
end

function TileMetaData:clone()
	local t = TileMetaData:create(self.x, self.y)
	--t:removeTileData(1)
	t:copyProperties(self)
	t:copyAttrs(self)
	return t
end

--------------------------------------------------------------------
-- static function
--------------------------------------------------------------------

--static create function
function TileMetaData:create(x, y)
  	local t = TileMetaData.new()
  	t.x = x
  	t.y = y
  	return t
end

function TileMetaData:getEmptyArray()
	local t = {}
	for h = 1, 9 do
		local rt = {}
		table.insert(t, rt)
		for w = 1, 9 do
			table.insert(rt, TileMetaData:create(w, h))
		end
	end
	return t
end

totalClockUsedByConvertFromBitToTileIndex = 0

function TileMetaData:convertFromBitToTileIndex(value, x, y)

	local t = TileMetaData:create(x, y)
	local bit = BigInt.bigInt2str(BigInt.str2bigInt(tostring(value), 10, 1), 2)
	t:addPropertiesArray(bit)

	return t
end

function TileMetaData:convertArrayFromBitToTile(bitMap, stringMap , crossStrengthCfg, tileAttrsCfg, addInfoCfg)
	local t = {}
	for h = 1, #bitMap do
		local rt = {}
		table.insert(t, rt)
		for w = 1, #bitMap[h] do

			local tileMap2Data = nil
			if stringMap and stringMap[h] and stringMap[h][w] then
				tileMap2Data = stringMap[h][w]
			end

			local crossStrengthCfgData = "0"
			if crossStrengthCfg and type(crossStrengthCfg) == "table" then
				if crossStrengthCfg[h] and type(crossStrengthCfg[h]) == "table" then
					crossStrengthCfgData = tostring(crossStrengthCfg[h][w] or "0")
				end 
			end

			local addInfoData = nil
			if addInfoCfg and addInfoCfg[h] and addInfoCfg[h][w] then
				addInfoData = addInfoCfg[h][w]
			end

			local tileData = self:buildTileData( h , w , bitMap[h][w] ,  tileMap2Data , crossStrengthCfgData, addInfoData )
			table.insert(rt, tileData)
		end
	end
	return t
end

function TileMetaData:buildTileData( r , c , tileMapData, tileMap2Data , crossStrengthCfgData, addInfoData)
	local tileData = TileMetaData:convertFromBitToTileIndex( tileMapData , c , r)
	if tileMap2Data then
		tileData:convertFromStringToTileIndex( tileMap2Data )
	end

	if not crossStrengthCfgData or crossStrengthCfgData == "0" then
		tileData.crossStrengthLevel = 0
	    tileData.crossStrengthColor = 0
	else
		if crossStrengthCfgData == "1" then
			tileData.crossStrengthLevel = 1
	    	tileData.crossStrengthColor = 0
		elseif crossStrengthCfgData == "2" then
			tileData.crossStrengthLevel = 2
	    	tileData.crossStrengthColor = 0
		elseif crossStrengthCfgData == "3" then
			tileData.crossStrengthLevel = 3
	    	tileData.crossStrengthColor = 0
		else
			local arr = crossStrengthCfgData:split("_")
		    tileData.crossStrengthLevel = tonumber( arr[1] )
		    tileData.crossStrengthColor = tonumber( arr[2] )
		end
	end

	tileData:setAddInfoData(addInfoData)

	--tileData.crossStrengthValue = tostring(crossStrengthCfgData or "0") --我给大家讲个笑话：crossStrengthValue这个参数意思其实是妖精瓶子的初始化等级，哈哈哈哈哈哈
	return tileData
end
