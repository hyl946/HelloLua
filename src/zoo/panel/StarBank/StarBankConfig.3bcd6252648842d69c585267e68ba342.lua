--[[
 * StarBankConfig
 * @date    2017-11-29 11:06:16
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local StarBankConfig = {
	[1] = {
		goodsId = 478,
		wm = {3,4,5},
		wmMin = 45,
		wmMax = 60,
		coolDuration = 20, --day，冷却时长
		buyTimeOut = 60, --购买时效
	},
	[2] = {
		goodsId = 478,
		wm = {5,6,9},
		wmMin = 75,
		wmMax = 120,
		coolDuration = 30, --day，冷却时长
		buyTimeOut = 60, --购买时效
	},
	[3] = {
		goodsId = 478,
		wm = {10,12,17},
		wmMin = 150,
		wmMax = 240,
		coolDuration = 40, --day，冷却时长
		buyTimeOut = 60, --购买时效
	},
	[4] = {
		goodsId = 478,
		wm = {20,25,35},
		wmMin = 300,
		wmMax = 500,
		coolDuration = 50, --day，冷却时长
		buyTimeOut = 60, --购买时效
	},

}

local data  = {
		curWm = 0,  --目前储蓄的风车币（可能大于本level的最大值）
		level = 3, --当前档位
		jarId = 3,
		buyCount = 0, --本档位已购买次数
		coolStartTime = 0, --开始冷却时的时间
		continuousCoolCount = 0, --连续冷却次数
		isSynced = false,
		state = StarBankState.kInvalid,
		hadBuy = false,
		buyDeadline = 0,--购买截止日期
		server_config = "[]",
		config = {
			levelIndex = {1,2,3,4},
			bank = StarBankConfig,
		},
	}

return data