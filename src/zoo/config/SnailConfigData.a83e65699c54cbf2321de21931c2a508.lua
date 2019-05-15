require "zoo.config.TileMetaData"
SnailConfigData = class(TileMetaData)
function SnailConfigData:ctor()
	self.x = 1    --col
	self.y = 1    --row
	self.tileProperties = {}
	for i = 1, RouteConst.kMaxTile do
		table.insert(self.tileProperties, false)
	end
end

function SnailConfigData:hasProperty(property)
	if property == RouteConst.kInvalid then
		for i = 1, #self.tileProperties do
			if self.tileProperties[i] then
				return false
			end
		end

		return true
	end

	return self.tileProperties[property]
end

function SnailConfigData:addPropertiesArray(value)
	local reverse = #value + 1
	for i = 1, #value do
		local c = string.sub(value, i, i)
		self.tileProperties[reverse - i] = c ~= "0"
	end

	--如果是个空格，把第一位标志设成true
	-- local a, b = string.find(value, "1")
	-- if a and a < #value then
	-- 	self:removeTileData(TileConst.kEmpty)
	-- else
	-- 	self:setTileData(TileConst.kEmpty)
	-- end
end

function SnailConfigData:create(x, y)
  	local t = SnailConfigData.new()
  	t.x = x
  	t.y = y
  	return t
end

function SnailConfigData:convertFromBitToTileIndex(value, x, y)

	local t = SnailConfigData:create(x, y)
	local bit = BigInt.bigInt2str(BigInt.str2bigInt(tostring(value), 10, 1), 2)
	t:addPropertiesArray(bit)

	return t
end

---------
--isDigExtened 表示挖地额外地形
---------
function SnailConfigData:convertArrayFromBitToTile(map, isDigExtend)
	local t = {}
	local maxRow = GamePlayConfig_Max_Item_Y - 1
	if isDigExtend then
		maxRow = #map
	end

	local maxCol = GamePlayConfig_Max_Item_Y - 1
	for r = 1, maxRow do 
		if not map[r] then map[r] = {} end
		for c = 1, maxCol do 
			if not map[r][c] then map[r][c] = 0 end
		end
	end

	for h = 1, #map do
		local rt = {}
		table.insert(t, rt)
		for w = 1, #map[h] do
			table.insert(rt, SnailConfigData:convertFromBitToTileIndex(map[h][w], w, h))
		end
	end
	return t
end
