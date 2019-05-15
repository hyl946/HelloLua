---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-11-30 19:25:32
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-03-11 15:21:11
---------------------------------------------------------------------------------------
UserContext = {}

function UserContext:getUserLocation()
	local location = nil
	if UserManager and UserManager:hadInited() then
		location = UserManager.getInstance():getUserLocation()
	end
	if not location then
		location = LocationManager_All.getInstance():getIPLocationCached()
	end
	return location
end

function UserContext:getCurrPlayId()
	local gamePlayContext = nil
	local preStartContext = nil
	if GamePlayContext then
		gamePlayContext = GamePlayContext:getInstance()
	end
	if GamePreStartContext then
		preStartContext = GamePreStartContext:getInstance()
	end

	if preStartContext and preStartContext.isActive then
		return preStartContext.playId
	elseif gamePlayContext and gamePlayContext.inLevel then
		return gamePlayContext.playId
	end
	return nil
end

function UserContext:getPlayLevelContext()
	local playLevelContext = {
		levelId = 0,
		stageMode = -1, -- DcDataStageMode.kNotInLevel
		playId = nil,
		algorithmTag = nil,
		eventId = nil,
		aiSeedValue = nil,
		seedValue = nil,
		aiDataSetup = 0,
	}

	local gamePlayContext = nil
	local preStartContext = nil
	if GamePlayContext then
		gamePlayContext = GamePlayContext:getInstance()
	end
	if GamePreStartContext then
		preStartContext = GamePreStartContext:getInstance()
	end

	if preStartContext and preStartContext.isActive then
		playLevelContext.preStart = true
		playLevelContext.playId 		= preStartContext.playId
		playLevelContext.levelId 		= preStartContext.levelInfo.level or 0
		local seedsData = nil
		if playLevelContext.levelId > 0 then -- 种子数据可能是中途才回来的
			seedsData = HEAICore.getInstance():getSeedDataByLevel(playLevelContext.levelId)
		end
		if seedsData then
			playLevelContext.algorithmTag 	= seedsData.algorithmId
			playLevelContext.eventId 		= seedsData.eventId
		else
			playLevelContext.algorithmTag 	= "unknown"
		end
	elseif gamePlayContext and gamePlayContext.inLevel then
		playLevelContext.inLevel = true
		playLevelContext.playId 		= gamePlayContext.playId
		playLevelContext.levelId 		= gamePlayContext.levelInfo.levelId
		playLevelContext.algorithmTag 	= gamePlayContext.levelInfo.aiAlgorithmTag
		playLevelContext.eventId 		= gamePlayContext.levelInfo.aiEventId
		playLevelContext.aiSeedValue 	= gamePlayContext.levelInfo.aiSeedValue
		playLevelContext.seedValue 		= gamePlayContext.levelInfo.seedValue
		playLevelContext.aiDataSetup 	= gamePlayContext.levelInfo.aiDataSetup
	end
	if playLevelContext.levelId > 0 then
		require "zoo.dc.DcDataHelper"
		playLevelContext.stageMode = DcDataHelper:getStageModeByLevelId(playLevelContext.levelId)
		if playLevelContext.preStart then
			playLevelContext.stageContext = DcFeatureType.kStageStart
		elseif playLevelContext.inLevel then
			playLevelContext.stageContext = DcFeatureType.kStagePlay
		end
	end
	return playLevelContext
end

function UserContext:getHeaderOthersParams()
	local ret = {}
	local location = UserContext:getUserLocation()
	if location then
		ret._ip 		= location.ip
		ret._district 	= location.district
		ret._province 	= location.province
		ret._city 		= location.city
	end
	return ret
end

function UserContext:addGamePlayContextDatas(data)
	data = data or {}
	local playLevelContext = UserContext:getPlayLevelContext()
	-- 详细版本信息
	data._major_version		= _G.bundleVersion
	data._minor_version		= ResourceLoader.getCurVersion()
	data._level_config_md5	= LevelMapManager.getInstance():getLevelUpdateVersion() or ""
	-- 用户信息
	data._current_stage = playLevelContext.levelId
	data._stageMode 	= playLevelContext.stageMode
	data._playId 		= playLevelContext.playId

	data._ai_setup		= playLevelContext.aiDataSetup
	data._algorithmTag 	= playLevelContext.algorithmTag
	data._event_id 		= playLevelContext.eventId
	data._seed_value 	= playLevelContext.aiSeedValue
	data._seed 			= playLevelContext.seedValue
	data._ai_flag		= HEAICore:getUserGroupId() -- AI分组标志

	require "zoo.util.NetworkUtil"
	data._scenes 		= playLevelContext.stageContext
	data._network_state = NetworkUtil:getNetworkStatus()
	
	data._v 			= "1"

	return data
end

local UserPlayLevelState = {
	kPreLevel	= "pre_level",	-- StartGamePanel create - GamePlayScene onEnter
	kInLevel 	= "in_level",	-- GamePlayScene onEnter - Passlevel/FailLevel
	kEndLevel	= "end_level",	-- Passlevel/FailLevel - GamePlayScene popout
	kOutLevel	= "out_level",	-- Not in GamePlay and StartGamePanel
}

function UserContext:getPlayLevelState()
	local gamePlayContext = nil
	local preStartContext = nil
	if GamePlayContext then
		gamePlayContext = GamePlayContext:getInstance()
	end
	if GamePreStartContext then
		preStartContext = GamePreStartContext:getInstance()
	end
	if preStartContext and preStartContext.isActive then
		return UserPlayLevelState.kPreLevel
	elseif gamePlayContext and gamePlayContext.inLevel then
		if gamePlayContext.levelWillEnd then
			return UserPlayLevelState.kEndLevel
		else
			return UserPlayLevelState.kInLevel
		end
	else
		return UserPlayLevelState.kOutLevel
	end
end