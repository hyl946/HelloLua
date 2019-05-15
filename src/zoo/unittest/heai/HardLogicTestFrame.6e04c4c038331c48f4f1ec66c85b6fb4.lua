MACRO_DEV_START = MACRO_DEV_START or function() end
MACRO_DEV_END = MACRO_DEV_END or function() end

Localhost = {}
function Localhost:timeInSec()
	local time = __g_utcDiffSeconds or 0
	return (os.time() + time)
end

DcUtil= {}
function DcUtil:DifficultyAdjustUnactivate()
end

function DcUtil:log()
end
AcType = {}
AcType.kExpire30Days = "-.-"

ProductItemDiffChangeMode = {
	kNone = 0 ,
	kDropEff = 1 ,
	kDropEffAndBird = 2 ,
	kAddColor = 3 ,
	kAIAddColor = 4 ,
	kAICoreAddColor = 5,
}

require "zoo.net.LevelType"
require "zoo.panel.qatools.DiffAdjustQAToolManager"
require "zoo.gamePlay.userTags.UserTagModel"
HardLogicTestFrame = class(UnittestTask)

local CheckKey = {
	kDiffAdjust = "diff_adjust",
	kTopLevelDiffTag = "top_level_diff_tag",
}

local Config = {
	[CheckKey.kDiffAdjust] = {
		classPath = "zoo.gamePlay.LevelDifficultyAdjustManager",
		className = "LevelDifficultyAdjustManager",
		funcName = "unitTestByContext",
		configPath = "zoo.unittest.leveldiffadjust.AdjustConfig",
	},

	[CheckKey.kTopLevelDiffTag] = {
		classPath = "zoo.gamePlay.userTags.conditions.TopLevelDiffTagLogic",
		className = "TopLevelDiffTagLogic",
		funcName = "unitTestByContext",
		configPath = "zoo.unittest.topLevelDiffTag.MockConfig",
	},
}

local TestMode = {
	kImmediate = "immediate",
	kDelay = "delay",
}
function HardLogicTestFrame:ctor()
	self.testMode = TestMode.kDelay
end

function HardLogicTestFrame:run(callback_success_message)
	local checkSuccess = true
	local checkMsg = "" 
	for ck,cv in pairs(Config) do
		require (cv.classPath)
		local dataConfig = require (cv.configPath)
		for k,v in pairs(dataConfig) do
			local result, newData = _G[cv.className][cv.funcName](v.mockData, v.result)
			if not result then
				checkSuccess = false

				if checkMsg == "" then
					checkMsg = "Error：\n" .. string.format("%s key %s current result is %s", ck, k, newData) .. '\n'
				else
					checkMsg = checkMsg  .. string.format("%s key %s current result is %s", ck, k, newData) .. '\n'
				end

				if self.testMode == TestMode.kImmediate then
					assert(false, checkMsg)
				end
			end
		end
	end
	callback_success_message(checkSuccess, checkMsg)
end