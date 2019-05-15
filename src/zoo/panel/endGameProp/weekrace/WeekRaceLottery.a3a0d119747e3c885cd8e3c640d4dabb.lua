WeekRaceLottery = class()

function WeekRaceLottery:create()
	local lottery = WeekRaceLottery.new()
	lottery:init()
	lottery:getRewards()
	return lottery
end

function WeekRaceLottery:init()
	self.list = table.const{
		[1] = {
			items = {
				{id = 10061, num = 1},
				{id = 10063, num = 1},
				{id = 10060, num = 1},
				{id = 10062, num = 1},
			},
			weight = 1,
		},
		[2] = {
			items = {
				{id = 18, num = 60},
				{id = 10013, num = 1},
				{id = 10071, num = 1},
				{id = 10064, num = 1},
			},
			weight = 10,
		},
		[3] = {
			items = {
				{id = 18, num = 40},
				{id = 10058, num = 1},
				{id = 10059, num = 1},
			},
			weight = 39,
		},
		[4] = {
			items = {
				{id = 2, num = 2000},
				{id = 10012, num = 1},
			},
			weight = 50,
		},
	}

	self.totalWeight = 0
	self.rewards = {}
	self.boxRewards = {}
	self.manager = SeasonWeeklyRaceManager:getInstance()
	self.mainLogic = GameBoardLogic:getCurrentLogic()
end

function WeekRaceLottery:getRewards()
	for i=1,4 do
		local config = self.list[i]
		local items = config.items
		local rnd = self.mainLogic.randFactory:rand(1, #items)
		local reward = table.clone(items[rnd])
		reward.weight = config.weight
		reward.index = i
		table.insert(self.rewards, reward)
	end
end

function WeekRaceLottery:getNextBoxReward(index)
	if self.totalWeight == 0 then 
		for _, v in pairs(self.rewards) do 
			self.totalWeight = self.totalWeight + v.weight
		end
	end

	local exWeightCount = 0
	local exIds = {}
	for _, v in pairs(self.boxRewards) do
		exWeightCount = exWeightCount + v.weight
		table.insert(exIds, v.index)
	end

	local rnd = self.mainLogic.randFactory:rand(1, self.totalWeight - exWeightCount)
	for _, v in pairs(self.rewards) do
		if not table.exist(exIds, v.index) then 
			if rnd <= v.weight then 
				self.boxRewards[index] = v
				return v
			end
			rnd = rnd - v.weight
		end
	end
	--printx(5, "getNextBoxReward", mem, table.tostring(self.rewards))
	return nil
end

function WeekRaceLottery:getBoxReward(index)
	local reward = self.boxRewards[index]
	if reward then return reward end
	reward = self.boxRewards[tostring(index)]
	return reward
end

function WeekRaceLottery:addRewards()
	for _, v in pairs(self.boxRewards) do 
		if v.id == 21 then 
			self.manager:addPieceNum(v.num)
		elseif v.id == 18 then
			local digJewelCount = GameBoardLogic:getCurrentLogic().digJewelCount
			digJewelCount:setValue(digJewelCount:getValue() + v.num)
		else
			-- 注释掉因为暂时不用了 再启用请加打点
			assert(false, "look at here!")
			-- UserManager:getInstance():addReward({itemId = v.id, num = v.num})
      		-- UserService:getInstance():addReward({itemId = v.id, num = v.num})
		end
	end
end

function WeekRaceLottery:test()
	local function doing(index)
		local count = 100000
		local st = {}
		for i = 1, count do
			local lottery = WeekRaceLottery:create()
			for j = 1, index do
				local reward = lottery:getNextBoxReward(j)
				local key = reward.id..'_'..reward.num
				if not st[key] then st[key] = 0 end
				st[key] = st[key] + 1
			end
		end
		-- printx(5, index..' = ', table.tostring(st))
		print(index..' = ', table.tostring(st))
	end

	for i = 1, 4 do
		doing(i) 
	end
end