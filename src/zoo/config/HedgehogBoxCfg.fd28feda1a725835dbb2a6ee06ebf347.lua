HedgehogBoxCfg = class()
HedgehogBoxCfgConst = table.const{
	kJewl = 1,
	kAddMove = 2,
	kSpecial = 3,
	kProp = 4,
}
function HedgehogBoxCfg:ctor()
	
end

function HedgehogBoxCfg:create( config )
	-- body
	local meta = HedgehogBoxCfg.new()
	meta:init(config)
	return meta
end

function HedgehogBoxCfg:init( config )
	-- body
	local allItemPer = 0
	local allItemPer_with_out_prop = 0
	self.itemList = {}
	self.propList = {}
	for k, v in pairs(config) do
		local item = {}
		local value = v.k:split("_")
		item.changeType = tonumber(value[1])
		item.changeItem = tonumber(value[2])
		item.changPer = tonumber(v.v)
		if item.changeType == HedgehogBoxCfgConst.kProp then
			table.insert(self.propList, item)
		else
			table.insert(self.itemList, item)
		end
	end

	--prop
	self:initPropPercent()
	self:changPercent(0)
end

function HedgehogBoxCfg:initPropPercent( ... )
	-- body
	local perlimit = 0
	local allItemPer = 0

	for k = 1, #self.propList do 
		local v = self.propList[k]
		allItemPer = allItemPer + v.changPer
	end

	-- if _G.isLocalDevelopMode then printx(0, "lyh------------------------------------------") end
	-- if _G.isLocalDevelopMode then printx(0, "dropPropsPercent = ",dropPropsPercent) end
	for k = 1, #self.propList do
		local v = self.propList[k]
		perlimit = perlimit + v.changPer
		v.limitInAllItem = math.ceil(perlimit * 10000 / allItemPer)
		if _G.isLocalDevelopMode then printx(0, v.changeType, v.changeItem, v.limitInAllItem, v.changPer, allItemPer) end
	end
	-- if _G.isLocalDevelopMode then printx(0, "lyh++++++++++++++++++++++++++++++++++++++++++") end
	-- debug.debug()
end

function HedgehogBoxCfg:changPercent( dropPropsPercent )
	-- body
	for k, v in pairs(self.itemList) do 
		if v.changeType == HedgehogBoxCfgConst.kProp then
			table.removeValue(self.itemList, v)
		end
	end

	local perlimit = 0
	for k = 1, #self.itemList do
		local v = self.itemList[k]
		perlimit = perlimit + v.changPer
	end

	local total = 100
	if dropPropsPercent == 100 then
		self.itemList = {{changeType = HedgehogBoxCfgConst.kProp, changeItem = 0, changPer = 100}}
	else
		total = perlimit / ((100 - dropPropsPercent)/100) 
		local item = {}
		item.changeType = HedgehogBoxCfgConst.kProp
		item.changPer = total * dropPropsPercent/100
		table.insert(self.itemList, item)
	end

	-- if _G.isLocalDevelopMode then printx(0, "lyh------------------------------------------") end
	-- if _G.isLocalDevelopMode then printx(0, "changPercent = ",dropPropsPercent) end
	local perlimit = 0
	for k = 1 , #self.itemList do
		local v = self.itemList[k]
		perlimit = perlimit + v.changPer
		v.limitInAllItem = math.ceil(10000 * perlimit /total)
		-- if _G.isLocalDevelopMode then printx(0, v.changeType, v.changeItem, v.limitInAllItem, v.changPer, total) end
	end
	-- if _G.isLocalDevelopMode then printx(0, "lyh++++++++++++++++++++++++++++++++++++++++++") end
	-- debug.debug()
end
