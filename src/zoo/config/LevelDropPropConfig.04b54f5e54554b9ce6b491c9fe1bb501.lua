LevelDropPropConfig = class()

-- config "dragonBoatPropGen":[{"k":"10059","v":5},{"k":"10060","v":5},{"k":"10061","v":5},{"k":"10063","v":5}]
function LevelDropPropConfig:create(config)
 	local meta = LevelDropPropConfig.new()
 	meta:init(config)
 	return meta
end

function LevelDropPropConfig:createWithProps(propsWithWeight, totalWeight)
	local meta = LevelDropPropConfig.new()
	meta.totalWeight = totalWeight or 0
	if type(propsWithWeight) == "table" then
		meta.propList = table.clone(propsWithWeight)
	end
 	return meta
end

function LevelDropPropConfig:ctor()
	self.totalWeight = 0
	self.propList = {}
end

function LevelDropPropConfig:init(config)
	if type(config) == "table" then
		local totalWeight = 0
		for _, prop in pairs(config) do
			totalWeight = totalWeight + tonumber(prop.v)
		end

		if totalWeight > 0 then
			for _, prop in pairs(config) do
				local weight = math.floor(tonumber(prop.v) / totalWeight * 10000)
				
				local propid = tonumber(prop.k)
				if not propid then
					--"3_1"
					local str = tostring(prop.k)
					local findIndex1 , finIndex2 = string.find( str , "_")
					if finIndex2 and finIndex2 > 0 then
						local str1 = string.sub( str , 1 , finIndex2 - 1 ) 
						local str2 = string.sub( str , finIndex2 + 1) 
						if str1 == "4" then
							propid = tonumber(str2)
						end
					end
				end
				if propid then
					self.totalWeight = self.totalWeight + weight
					table.insert(self.propList, {propId = propid, weight = weight})
				end
			end
		end
	end
end

function LevelDropPropConfig:getTotalWeight()
	return self.totalWeight
end

function LevelDropPropConfig:getRandProp(random)
	if type(random) == "number" and random <= self.totalWeight then
		for _, prop in pairs(self.propList) do
			random = random - prop.weight
			if random <= 0 then
				return prop.propId
			end
		end
	end
	return nil
end