require "zoo.gamePlay.GamePlayContext"
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013Äê10ÔÂ28ÈÕ  19:18:09
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- StartLevelLogic
---------------------------------------------------
StartLevelLogic = class()

-----------------------------------------------
-- startGameDelegate(Delegate) 所有方法均为optional
-- Delegate:onStartLevelLogicSuccess()
-- Delegate:onStartLevelLogicFailed(err)
-- Delegate:onEnergyNotEnough()		精力不足的处理
-- Delegate:playEnergyAnim(onAnimFinish, selectedItemsData) 播放精力消耗的动画
-- Delegate:onWillEnterPlayScene()	进入GamePlayScene之前执行的逻辑
-- Delegate:onDidEnterPlayScene(gamePlayScene)	进入GamePlayScene之后执行的逻辑
---------
-- notConsumeEnergy 是否消耗精力
-----------------------------------------------


function StartLevelLogic:create(startGameDelegate, levelId, levelType, itemList, notConsumeEnergy, usePropList, startLevelType, ...)

	local slType = startLevelType or StartLevelType.kCommon
	if slType ~= StartLevelType.kAskForHelp then
		AskForHelpManager:getInstance():leaveMode()
	end

	local function isUseNewStartLevelLogic(startLevelType)
		return true
		--[[
		if MaintenanceManager:getInstance():isEnabledInGroup( "CrashResumeNew" , "B2" , UserManager:getInstance():getUID()) then return true end
		if slType == StartLevelType.kAskForHelp then return true end
		return false
		]]
	end

	if isUseNewStartLevelLogic(startLevelType) then
		assert(type(levelId) == "number")
		assert(type(itemList) == "table")
		assert(#{...} == 0)

		local newNewStartLevelLogic = NewStartLevelLogic.new()
		newNewStartLevelLogic:init(startGameDelegate, levelId , itemList, notConsumeEnergy, usePropList, startLevelType)
		return newNewStartLevelLogic
	else
		
	end
end
