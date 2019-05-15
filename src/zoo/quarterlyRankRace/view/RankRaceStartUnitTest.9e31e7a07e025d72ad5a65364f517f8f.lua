--[[
 * RankRaceStartUnitTest
 * @date    2018-05-18 11:17:56
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

RankRaceStartUnitTest = {}

local common = {
		unlockNextNum = math.random(100, 150),
		bonus = math.random(1, 99),
		goodsId = 496,
	}

--12
local config = {
	{--1
		levelIndex = 1,
		leftFreePlay = math.random(1, 90),
		isLimit = false,
	},
	{--2
		levelIndex = 1,
		leftFreePlay = 0,
		isLimit = false,
	},
	{--3
		levelIndex = 1,
		leftFreePlay = 0,
		isLimit = false,
		isRmbBuy = true,
	},
	{--4
		levelIndex = 1,
		leftFreePlay = math.random(1, 90),
		isLimit = true,
	},
	{--5
		levelIndex =  math.random(2, 5),
		leftFreePlay = math.random(1, 90),
		isLimit = false,
	},
	{--6
		levelIndex =  math.random(2, 5),
		leftFreePlay = 0,
		isLimit = false,
	},
	{--7
		levelIndex =  math.random(2, 5),
		leftFreePlay = 0,
		isLimit = false,
		isRmbBuy = true,
	},
	{--8
		levelIndex =  math.random(2, 5),
		leftFreePlay = 0,
		isLimit = true,
	},
	{--9
		levelIndex =  6,
		leftFreePlay = math.random(1, 90),
		isLimit = false,
	},
	{--10
		levelIndex =  6,
		leftFreePlay = 0,
		isLimit = false,
	},
	{--11
		levelIndex =  6,
		leftFreePlay = 0,
		isLimit = false,
		isRmbBuy = true,
	},
	{--12
		levelIndex =  6,
		leftFreePlay = 0,
		isLimit = true,
	},
}

function RankRaceStartUnitTest:getTestData()
	self.index = self.index or 0
	self.index = self.index + 1
	if self.index > 12 then
		self.index = 1
	end

	local data = table.merge(common, config[self.index])
	-- data.leftFreePlay = 8
	data.unlockIndex = math.random(data.levelIndex, 6)
	data = {
			levelIndex = 1,
			unlockNextNum = 120,
			leftFreePlay = 4,
			bonus = 50,
			goodsId = 496,
			isLimit = true,
			isRmbBuy = false,
			unlockIndex = 1,
		}
	printx(10, "test index:", self.index, table.tostring(data))
	return data
end