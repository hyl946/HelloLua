DropBuffLogic = class()

local DropBuffLogicDebugMode = true

function DropBuffLogic:ctor()
	self.mainLogic = nil
	self.dropBuff = nil
	self.dropBuffEnable = false
	self.canBeTriggered = false
	self.orderColorList = {}
end

function DropBuffLogic:init(mainLogic, config)
	assert(mainLogic)

	self.mainLogic = mainLogic
	self.dropBuff = config.dropBuff
	-- 概率为浮点数时解析出来为string类型
	if self.dropBuff then
		self.dropBuff.toRate = tonumber(self.dropBuff.toRate)
	end
	self.totalWeight = 0

	self:initOrderColorList(config)
end

function DropBuffLogic:initOrderColorList(config)
	if config.orderMap then
		local list = {}
        for k,v in pairs(config.orderMap) do
            local ts1 = 0
            local ts2 = 0
            local ts3 = 0
            for k2,v2 in pairs(v) do
                if k2 == "k" then
                    local thestrings = v2:split("_")
                    ts1 = tonumber(thestrings[1])
                    ts2 = tonumber(thestrings[2])
                    if ts1 == GameItemOrderType.kAnimal then
                    	table.insert(list, ts2)
                    end
                end
            end
        end
   	 	self.orderColorList = list
    end
end

function DropBuffLogic:create(mainLogic, dropBuff)
	local logic = DropBuffLogic.new()
	logic:init(mainLogic, dropBuff)
	return logic
end

function DropBuffLogic:setDropBuffEnable(isEnable)
	if self.canBeTriggered then
		if _G.isLocalDevelopMode then printx(0, "setDropBuffEnable:", isEnable) end
		self.dropBuffEnable = isEnable

		if DropBuffLogicDebugMode then
			self:updateDropBuffLabelStatus()
		end
	end
end

function DropBuffLogic:checkIfCanBeTriggered(levelId)
	if _G.useDropBuffByEditor ~= nil then
		return _G.useDropBuffByEditor
	end
	
	if not MaintenanceManager:isAvailbleForUid("DropBuffEnable_New", UserManager:getInstance().uid, 100) then
		return false
	end
	-- if not MaintenanceManager:isEnabled("DropBuffEnable") then -- old maintenance
	-- 	return false
	-- end

	if self.dropBuff and table.size(self.dropBuff) > 0 then -- 有神奇掉落规则
		-- 最高关
		local topLevelId = UserManager:getInstance().user:getTopLevelId()
		if topLevelId == levelId then -- 最高关卡
			if not UserManager:getInstance():hasPassedLevel(levelId) then -- 尚未通过此关
				local failCount = UserManager:getInstance().userExtend.topLevelFailCount
				if failCount > self.dropBuff.failTriggerNum then -- 连续失败次数达到触发条件
					return true
				end	
			end
		elseif UserManager.getInstance():hasPassedByTrick( levelId ) then -- 跳过的关卡
			local failCount = FUUUManager:getLevelContinuousFailNum(levelId) or 0
			if failCount > self.dropBuff.failTriggerNum then
				return true
			end
		end
	end
	return false
end

function DropBuffLogic:onGameInit(realCostMove)
	realCostMove = realCostMove or 0
	if self.canBeTriggered and realCostMove == self.dropBuff.startMove then
		self:recalcColorDropWeights()
		self:setDropBuffEnable(true)
	end
end

function DropBuffLogic:onUseMoves(realCostMove)
	if self.canBeTriggered then
		if not self.dropBuffEnable and realCostMove == self.dropBuff.startMove then
			self:recalcColorDropWeights()
			self:setDropBuffEnable(true)
		end
		if self.dropBuffEnable and realCostMove == self.dropBuff.endMove + 1 then
			self:setDropBuffEnable(false)
		end
	end
end

function DropBuffLogic:onAnimalOrderCompleted(colors)
	-- if _G.isLocalDevelopMode then printx(0, "onAnimalOrderCompleted:", table.tostring(colors)) end
	if not self.dropBuffEnable or not colors or #colors < 1 then 
		return 
	end

	local dropAnimalOrder = false
	for _, color in pairs(colors) do
		local colorType = AnimalTypeConfig.convertIndexToColorType(color)
		if self:isColorInMapColorList(colorType) then
			dropAnimalOrder = true
			break
		end
	end
	if dropAnimalOrder then
		self:recalcColorDropWeights()
	end
end

-- [key = weight], return keys
function DropBuffLogic:randomWithWeights(weights, retNum)
	assert(type(weights) == "table")
	retNum = retNum or 1
	local retIndexs = {}
	if table.size(weights) <= retNum then
		for k, _ in pairs(weights) do
			table.insert(retIndexs, k)
		end
	else
		local totalWeight = 0
		for k, v in pairs(weights) do
			totalWeight = totalWeight + v
		end
		local temp = {}
		while table.size(retIndexs) < retNum do
			local random = self.mainLogic.randFactory:rand(1, totalWeight)
			for k, v in pairs(weights) do
				if not temp[k] then
					random = random - v
					if random <= 0 then
						temp[k] = true
						table.insert(retIndexs, k)
						totalWeight = totalWeight - v
						break
					end
				end
			end
		end
	end
	return retIndexs
end

-- return keys of list
function DropBuffLogic:randomFromList(list, retNum)
	assert(type(list) == "table")
	if #list < 1 then return {} end

	local listWithWeight = {}
	for k, _ in pairs(list) do
		listWithWeight[k] = 1
	end
	return self:randomWithWeights(listWithWeight, retNum)
end

function DropBuffLogic:randomColor()
	local color = nil
	if self.dropBuffEnable then
		if self.totalWeight > 0 then
			-- if _G.isLocalDevelopMode then printx(0, "randomColor with new weights!!") end
			local random = self.mainLogic.randFactory:rand(1, self.totalWeight)
			for index, v in pairs(self.dropBuffWeights) do
				random = random - v
				if random <= 0 then 
					color = self.mainLogic.mapColorList[index] 
					break
				end
			end
		end
	end
	if not color then
		-- if _G.isLocalDevelopMode then printx(0, "randomColor with default weights!!") end
		local x = self.mainLogic.randFactory:rand(1, #self.mainLogic.mapColorList)
		color = self.mainLogic.mapColorList[x]
	end

	if DropBuffLogicDebugMode then
		local colorIdx = AnimalTypeConfig.convertColorTypeToIndex(color)
		self:testColorStat(colorIdx)
	end

	return color
end

function DropBuffLogic:isColorInMapColorList( colorType )
	for _, v in pairs(self.mainLogic.mapColorList) do
		if v == colorType then return true end
	end
	return false
end

function DropBuffLogic:getOrderDataByColorIdx(colorIdx)
	if colorIdx and self.mainLogic.theOrderList then
		for _, v in pairs(self.mainLogic.theOrderList) do
			if v.key1 == GameItemOrderType.kAnimal and v.key2 == colorIdx then
				return v
			end
		end
	end
	return nil
end

function DropBuffLogic:randomTargetColorIdxs()
	local lastChangeRateColorIdxs = self.changeRateColorIdxs or {}
	-- 指定消除未完成的颜色
	local targetColorIdxs = {}
	local theOrderList = self.mainLogic.theOrderList or {}
	for _, colorIdx in pairs(self.orderColorList) do
		local colortype = AnimalTypeConfig.convertIndexToColorType(colorIdx)
		if self:isColorInMapColorList(colortype) then -- 过滤掉不在生成颜色中的目标颜色
			local order = self:getOrderDataByColorIdx(colorIdx)
			if not order or (order.f1 < order.v1) then
				table.insert(targetColorIdxs, colorIdx)
			end
		end
	end
	local ret = {}
	if #targetColorIdxs > 0 then -- 还有未收集完的消除目标
		local targetColorIdxsNotHandled = {}
		-- 优先之前随机到的颜色
		for _, colorIdx in pairs(targetColorIdxs) do
			if lastChangeRateColorIdxs[colorIdx] then 
				table.insert(ret, colorIdx)
			else
				table.insert(targetColorIdxsNotHandled, colorIdx)
			end
		end
		-- 如果还有需要，从剩下的未完成目标中随机
		local moreColorNum = self.dropBuff.colorNum - table.size(ret)
		if moreColorNum > 0 and #targetColorIdxsNotHandled > 0 then -- 从剩余未完成的颜色中随机
			local randIndexs = self:randomFromList(targetColorIdxsNotHandled, moreColorNum)
			for _, index in pairs(randIndexs) do
				local colorIdx = targetColorIdxsNotHandled[index]
				table.insert(ret, colorIdx)
			end
		end
	end 
	return ret
end

function DropBuffLogic:recalcColorDropWeights()
	if not self.dropBuff or table.size(self.dropBuff) < 1 then -- 没有配置dropBuff
		return 
	end

	if self.dropBuff.colorNum >= #self.mainLogic.mapColorList then -- 产品保证配置数量正确
		return
	end
	self.dropBuffWeights = {}
	local changeRateColorIdxs = {}

	if self.dropBuff.toRate >= (100 / #self.mainLogic.mapColorList) then -- 只有调高概率时优先考虑消除目标
		local randTargetColorIdxs = self:randomTargetColorIdxs()
		for _, colorIdx in pairs(randTargetColorIdxs) do
			changeRateColorIdxs[colorIdx] = true
		end
	end

	-- 剩余的从其他颜色中随机
	local moreColorNum = self.dropBuff.colorNum - table.size(changeRateColorIdxs)
	if moreColorNum > 0 then
		local leftColorsWithWeight = {}
		-- 筛选出尚未随机到的颜色
		for _, v in pairs(self.mainLogic.mapColorList) do
			local colorIdx = AnimalTypeConfig.convertColorTypeToIndex(v)
			if not changeRateColorIdxs[colorIdx] then
				leftColorsWithWeight[colorIdx] = 1 -- weight = 1
			end
		end
		-- 从中随机n种
		local randColorIdxs = self:randomWithWeights(leftColorsWithWeight, moreColorNum)
		for _, v in pairs(randColorIdxs) do
			changeRateColorIdxs[v] = true
		end
	end

	-- 计算调整后的概率 out of 1000
	local weight = math.floor(self.dropBuff.toRate * 10) 
	local othersWeight = (100 - self.dropBuff.toRate * self.dropBuff.colorNum ) / (#self.mainLogic.mapColorList - self.dropBuff.colorNum) * 10
	othersWeight = math.floor(othersWeight)

	local totalWeight = 0
	for i, v in ipairs(self.mainLogic.mapColorList) do
		local colorIdx = AnimalTypeConfig.convertColorTypeToIndex(v)
		if changeRateColorIdxs[colorIdx] then
			table.insert(self.dropBuffWeights, weight)
			totalWeight = totalWeight + weight
		else
			table.insert(self.dropBuffWeights, othersWeight)
			totalWeight = totalWeight + othersWeight
		end
	end

	self.totalWeight = totalWeight
	self.changeRateColorIdxs = changeRateColorIdxs

	-- if _G.isLocalDevelopMode then printx(0, "changeRateColorIdxs:", table.tostring(changeRateColorIdxs)) end
	-- if _G.isLocalDevelopMode then printx(0, "mapColorList:", table.tostring(self.mainLogic.mapColorList)) end
	-- if _G.isLocalDevelopMode then printx(0, "recalcColorDropWeights:", table.tostring(self.dropBuffWeights)) end

	if DropBuffLogicDebugMode then
		self:testColorStatClean()
		self:updateDropBuffAnimals(changeRateColorIdxs)
	end
end

-----------------------------------
-- 以下为调试代码
-----------------------------------

function DropBuffLogic:testColorStat(colorIdx)
	self.colorStat = self.colorStat or {}
	self.colorStat[colorIdx] = self.colorStat[colorIdx] and self.colorStat[colorIdx] + 1 or 1
	local totalCount = 0
	for c, v in pairs(self.colorStat) do
		totalCount = totalCount + v
	end

	if self.displayLayer and not self.displayLayer.isDisposed then
		for c, label in pairs(self.displayLayer.colorPercentLabels) do
			local num = self.colorStat[c] or 0
			label:setString(string.format("%.2f%%", num / totalCount * 100))
		end
		for c, label in pairs(self.displayLayer.colorNumLabels) do
			local num = self.colorStat[c] or 0
			label:setString(string.format("%d", num))
		end
	end
	-- if _G.isLocalDevelopMode then printx(0, "--------------------------------------") end
	-- for c, v in pairs(self.colorStat) do
	-- 	if _G.isLocalDevelopMode then printx(0, string.format("colorIdx:%2d\t%3d\t%.2f%%", c, v, v / totalCount * 100)) end
	-- end
	-- if _G.isLocalDevelopMode then printx(0, "--------------------------------------") end
end

function DropBuffLogic:testColorStatClean()
	self.colorStat = {}
	if self.displayLayer and not self.displayLayer.isDisposed then
		for _, v in pairs(self.displayLayer.colorPercentLabels) do
			v:setString(string.format("%.2f%%", 0))
		end
		for _, v in pairs(self.displayLayer.colorNumLabels) do
			v:setString(string.format("%d", 0))
		end
	end
end

function DropBuffLogic:updateDropBuffAnimals(colorIdxs)
	colorIdxs = colorIdxs or {}
	if self.displayLayer and not self.displayLayer.isDisposed then
		local colorsFlag = {}
		for colorIdx, _ in pairs(colorIdxs) do
			colorsFlag[colorIdx] = true
		end
		
		for k, v in pairs(self.displayLayer.colorPercentLabels) do
			if colorsFlag[k] then
				v:setColor(ccc3(255, 255, 0))
			else
				v:setColor(ccc3(255, 255, 255))
			end
		end
		for k, v in pairs(self.displayLayer.colorNumLabels) do
			if colorsFlag[k] then
				v:setColor(ccc3(255, 255, 0))
			else
				v:setColor(ccc3(255, 255, 255))
			end
		end

	end
end

function DropBuffLogic:updateDropBuffLabelStatus()
	if self.displayLayer and not self.displayLayer.isDisposed then
		if self.dropBuffEnable then
			local text = string.format("规则已生效,%d种颜色概率变为%.2f%%", self.dropBuff.colorNum, self.dropBuff.toRate)
			self.displayLayer.statusLabel:setString(text)
		else
			self.displayLayer.statusLabel:setString("规则已失效")
		end
	end
end

function DropBuffLogic:setDropStatDisplayLayer( displayLayer )
	if not displayLayer then return end
	
	local itemsName = { "horse", "frog", "bear", "cat", "fox", "chicken"}
	self.displayLayer = displayLayer
	self.displayLayer.statusLabel = TextField:create("规则尚未启用", nil, 26)
	self.displayLayer.statusLabel:setAnchorPoint(ccp(0, 1))
	self.displayLayer.statusLabel:setPosition(ccp(10, 110))
	self.displayLayer.statusLabel:setColor(ccc3(255, 255, 0))
	self.displayLayer:addChild(self.displayLayer.statusLabel)
	self.displayLayer.colorPercentLabels = {}
	self.displayLayer.colorNumLabels = {}
	local index = 0
	for _, colortype in pairs(self.mainLogic.mapColorList) do
		local colorIdx = AnimalTypeConfig.convertColorTypeToIndex(colortype)
		local char = TileCharacter:create(itemsName[colorIdx])
		local position = ccp(index * 110 + 60, 50)
		char:setPosition(position)
		char:setScale(0.7)
		self.displayLayer:addChild(char)

		local colorPercentLabel = TextField:create("", nil, 24)
		colorPercentLabel:setAnchorPoint(ccp(0.4, 0))
		colorPercentLabel:setPosition(ccp(position.x, position.y - 50))
		self.displayLayer:addChild(colorPercentLabel)
		self.displayLayer.colorPercentLabels[colorIdx] = colorPercentLabel

		local colorNumLabel = TextField:create("", nil, 24)
		colorNumLabel:setAnchorPoint(ccp(0, 0.5))
		colorNumLabel:setPosition(ccp(position.x + 30, position.y))
		self.displayLayer:addChild(colorNumLabel)
		self.displayLayer.colorNumLabels[colorIdx] = colorNumLabel

		index = index + 1
	end

	if self.dropBuffEnable then
		self:updateDropBuffLabelStatus()
		self:updateDropBuffAnimals(self.changeRateColorIdxs)
	end
end
