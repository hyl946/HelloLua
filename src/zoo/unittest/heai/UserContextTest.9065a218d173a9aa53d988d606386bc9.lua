---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2019-01-30 19:31:22
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-02-19 14:36:05
---------------------------------------------------------------------------------------

--[[
{
  "ai_setup": "0",
  "level_config_md5": "771f7212fdc81cc80157d6eee9b59a15",
  "plt": "oppo",
  "_src": "svr",
  "user_id": "46619950",
  "seed_value": "null",
  "current_stage": "1935",
  "server_name": "logdc.happyelements.cn",
  "itemID_currency_consumed": "10012",
  "request_ip": "119.29.100.182",
  "time_send": "1548822599339",
  "event_id": "null",
  "major_version": "1.64",
  "ip": "183.226.224.201",
  "platform": "oppo",
  "minor_version": "9854ce42f6dd7a024f21dda3fb330447",
  "seed": "null",
  "udid": "a1401162367f1d3f",
  "gameversion": "1.64",
  "front_end_time": "1548822284605",
  "city": "重庆",
  "stage_mode": "-1",
  "sub_category": "consume",
  "session_id": "B49E2BFD-6081-476D-939C-217C7863285E",
  "district": "",
  "province": "重庆",
  "browser": "SmF2YS8xLjcuMF84MA",
  "lang": "zh_CN",
  "item_currency_count": "1.0",
  "currency_stock_after_consumed": "ezI6NDIzMzcxMTYsMTQ6MzV9",
  "playId": "46619950a1401162367f1d3f1548822280",
  "g_id": "7800105600",
  "high_stage": "1935",
  "category": "item",
  "item_stock_after_consumed": "ezEwMDEzOjEzMiwxMDAxMjo3MiwxMDA1ODoxLDEwMDExOjgzLDEwMDQwOjIsMTAwODU6M30=",
  "back_end_time": "1548822599339",
  "v": "1",
  "ai_flag": "1"
}]]

-- Mock Class
_G.bundleVersion = "1.64"

local curVersion = "9854ce42f6dd7a024f21dda3fb330447"
local levelUpdateMd5 = "771f7212fdc81cc80157d6eee9b59a15"
local playId = "46619950a1401162367f1d3f1548822280"
local levelId = 1910
local stageMode = 0
local seedValue = 101
local userGroupId = 1

local seedData = {
	seed = 100,
	algorithmId = "algorithmId",
	eventId = "eventId",
}

LevelMapManager = {
	getInstance = function() return LevelMapManager end,
	getLevelUpdateVersion = function() return levelUpdateMd5 end,
}

ResourceLoader = {
	getCurVersion = function() return curVersion end,
}

GamePlayContext = {
	getInstance = function() return GamePlayContext end,
	playId = playId,
	inLevel = true,
	levelInfo = {
		levelId = levelId,
		aiAlgorithmTag = seedData.algorithmId,
		aiEventId = seedData.eventId,
		aiSeedValue = seedData.seed,
		seedValue = seedValue,
		aiDataSetup = 1,
	},
}

GamePreStartContext = {
	getInstance = function() return GamePreStartContext end,
	playId = playId,
	isActive = false,
	levelInfo = {
		levelId = levelId,
	},
}

HEAICore = {
	getInstance = function() return HEAICore end,
	getSeedDataByLevel = function(levelId) return seedData  end,
	getUserGroupId = function() return userGroupId end,
}

-- Do Unit-test
UserContextTest = class(UnittestTask)

function UserContextTest:ctor()

end

function UserContextTest:run(callback_success_message)
	require "zoo.util.UserContext"
	require "zoo.net.LevelType"
	require "zoo.util.NetworkUtil"

	NetworkUtil.getNetworkStatus = function()
		return NetworkUtil.NetworkStatus.kWifi
	end

	local data = {}
	UserContext:addGamePlayContextDatas(data)

	assert(data._major_version == _G.bundleVersion)
	assert(data._minor_version == curVersion)
	assert(data._level_config_md5 == levelUpdateMd5)
	assert(data._current_stage == levelId)
	assert(data._stageMode == stageMode)
	assert(data._playId == playId)
	assert(data._ai_setup == 1)
	assert(data._algorithmTag == seedData.algorithmId)
	assert(data._event_id == seedData.eventId)
	assert(data._seed_value == seedData.seed)
	assert(data._seed == seedValue)
	assert(data._ai_flag == userGroupId)
	assert(data._scenes == "stage_play")
	assert(data._network_state == "kWifi")
	assert(data._v == "1")

	callback_success_message(true, "UserContextTest success")
end