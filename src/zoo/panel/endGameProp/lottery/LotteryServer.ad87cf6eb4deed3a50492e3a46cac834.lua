local LotteryServer = class()

local instance

function LotteryServer:isAddStep( itemId )
	return table.exist({
		ItemType.ADD_FIVE_STEP,
		ItemType.ADD_15_STEP,
		ItemType.TIMELIMIT_ADD_FIVE_STEP,
		ItemType.ADD_1_STEP,
		ItemType.ADD_2_STEP,
		ItemType.TIMELIMIT_ADD_FIVE_STEP,
	}, itemId) 
end

function LotteryServer:getInstance( ... )
	-- body
	if not instance then
		instance = LotteryServer.new()
	end
	return instance
end

function LotteryServer:ctor( ... )
	self:initLotteryConfig()
	self:initFreeLotteryConfig()
	self:initNewLotteryConfig()
	self:reset()
end

function LotteryServer:initLotteryConfig( ... )
	self.lotteryConfig, self.onlyAddStepLotteryConfig = self:parseConfig('NewFiveStepsLottery')
end

function LotteryServer:initFreeLotteryConfig( ... )
	self.freeLotteryConfig, self.freeOnlyAddStepLotteryConfig = self:parseConfig(
		'NewFiveStepsLotteryFree', 
		'10004:1:6.66666666,10088:1:18.75,10004:1:6.66666666,10100:1:18.75,10004:1:6.66666666,10069:1:18.75,10086:1:5,10060:1:18.75'
	)
end

function LotteryServer:initNewLotteryConfig( ... )
	self.newLotteryConfig = self:parseConfig('NewStepsLotteryGROUP')
end

function LotteryServer:parseConfig( maintenanceKey, defaultConfig , isCustomConfig)
	local rawConfig = defaultConfig or "10115:1:1,10116:1:1,10115:1:1,10004:1:1,10115:1:1,10116:1:1,10115:1:1,10004:1:1"

	if not isCustomConfig then
		local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey(maintenanceKey)
		if maintenance and maintenance.enable and maintenance.extra then
			rawConfig = maintenance.extra
		end
	end

	rawConfig = string.match(rawConfig, '([^;]+)$')

	local totalWeight = 0
	local lotteryConfig = {}
	local onlyAddStepLotteryConfig = {}
	local onlyAddStepTotalWeight = 0
	for itemId, num, weight in string.gmatch(rawConfig, '(%d+):(%d+):([%d%.]+)') do
		itemId, num, weight = tonumber(itemId), tonumber(num), tonumber(weight)
		totalWeight = totalWeight + weight
		table.insert(lotteryConfig, {
			rewards = {
				{itemId = itemId, num = num},
			},
			weight = totalWeight,
		})
		if self:isAddStep(itemId) then
			onlyAddStepTotalWeight = onlyAddStepTotalWeight + weight
			table.insert(onlyAddStepLotteryConfig, {
				rewards = {
					{itemId = itemId, num = num},
				},
				weight = onlyAddStepTotalWeight,
			})
		end
	end
	for _, v in ipairs(lotteryConfig) do
		v.weight = v.weight / totalWeight
	end
	for _, v in ipairs(onlyAddStepLotteryConfig) do
		v.weight = v.weight / onlyAddStepTotalWeight
	end
	return lotteryConfig, onlyAddStepLotteryConfig
end

function LotteryServer:__getReward( pLotteryConfig, pOnlyAddStepLotteryConfig )

	local rewardIndex = nil
	local rewards = {}

	local curLotteryConfig = pLotteryConfig

	local onlyCanGetAddStep = self.notAddStepCounter >= 3

	if onlyCanGetAddStep then
		curLotteryConfig = pOnlyAddStepLotteryConfig or curLotteryConfig
	end

	local randNum = math.random()
	for index, v in ipairs(curLotteryConfig) do
		if randNum <= v.weight then
			rewardIndex = index
			rewards = v.rewards
			break
		end 
	end

	if not table.find(rewards, function ( item )
		return self:isAddStep(item.itemId)
	end) then
		self.notAddStepCounter = self.notAddStepCounter + 1
	else
		self.notAddStepCounter = 0
	end

	return rewardIndex, rewards
end

function LotteryServer:lotteryReward( ... )
	return self:__getReward(self.lotteryConfig, self.onlyAddStepLotteryConfig)
end

function LotteryServer:freeLotteryReward( ... )
	return self:__getReward(self.freeLotteryConfig, self.freeOnlyAddStepLotteryConfig)
end

function LotteryServer:newLotteryReward( ... )
	return self:__getReward(self.newLotteryConfig)
end

function LotteryServer:getLotteryConfig( ... )
	return self.lotteryConfig
end

function LotteryServer:getNewLotteryConfig( ... )
	return self.newLotteryConfig
end

function LotteryServer:getFreeLotteryConfig( ... )
	return self.freeLotteryConfig
end

function LotteryServer:reset( ... )
	self.notAddStepCounter = 0
end

function LotteryServer:setCustomLotteryConfig(lotteryConfigName, lotteryConfig)
	if not self.customLotteryConfig then
		self.customLotteryConfig = {}
	end
	local config, onlyAddStepConfig = self:parseConfig('in the moment, this param is not used, just leave it freely', lotteryConfig, true)
	self.customLotteryConfig[lotteryConfigName] = {config, onlyAddStepConfig}
end

function LotteryServer:customLotteryReward( lotteryConfigName )
	if self.customLotteryConfig and self.customLotteryConfig[lotteryConfigName] then
		self:reset()
		return self:__getReward(self.customLotteryConfig[lotteryConfigName][1], self.customLotteryConfig[lotteryConfigName][2])
	end
end

return LotteryServer