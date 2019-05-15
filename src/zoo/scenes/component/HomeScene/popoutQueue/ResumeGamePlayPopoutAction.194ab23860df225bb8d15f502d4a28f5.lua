require "zoo.common.FAQ"
require "zoo.panel.CommonTip"
require "zoo.gamePlay.ReplayDataManager"

ResumeGamePlayPopoutAction = class(HomeScenePopoutAction)

CrashResumeGamePlaySpeedUp = true
NationalDay2018ActivityIsGetReady = false
Christmas2018ActivityIsGetReady = false
Spring2019ActivityIsGetReady = false


ResumeFailReason = {
	
	kLevelRangeIllegal = 1 ,--不是主线关，隐藏关，周赛关
	kUdidNotExist = 2 ,--无法获取本机udid
	kUserChanged = 3 ,--不是当前用户的闪退数据
	kDeviceChanged = 4 ,--不是当前设备的闪退数据
	kCrashOver12Hour = 5 ,--闪退时间是12小时以前
	kMd5CheckFail = 6 ,--Md5校验失败
	kUserDataNeedRevert = 7 ,--看见了恢复面板，但数据异常
	kIsTimeLevel = 10 ,--时间关
	kIsUFOLevel = 11 ,--飞碟关
	kLevelConfigNotExist = 12 ,--没有关卡配置
	kWeeklyRacePassDay = 13 ,--周赛跨天
	kWeeklyRaceSwitchOff = 14 ,--周赛开关未打开

	kMainLevelAndGreaterTopLevel = 92 ,--主线关，且要恢复的关卡大于topLevel
	kActivityIsEnd = 93 ,--跨活动关卡
	kCanNotResumeOnSectionLevel = 95 ,--闪退数据来自上一次恢复打关
	kSpringFestival2019OverTime = 96 ,--跨活动关卡
	kCanNotResumeOnReplayLevel = 97 ,--闪退数据来自上一次恢复打关
	kLaunchGameByUrlLink = 98 ,--由链接启动游戏
	kUserClose = 99 ,--用户主动取消
	
}


function ResumeGamePlayPopoutAction:ctor(url)
	self.name = "ResumeGamePlayPopoutAction"
	self.recallUserNotPop = false
	self:setSource(AutoPopoutSource.kInitEnter)
end

function ResumeGamePlayPopoutAction:onCheckPopResult(canPop)

	-- printx( 1 , debug.traceback() )
	-- printx( 1 , "ResumeGamePlayPopoutAction:onCheckPopResult  ~~~~~~~~~~~~~~~~~~ canPop" , canPop , "self.replayData" , self.replayData )
	-- debug.debug()

	if self.replayData and not canPop then
		-- printx( 1 , "ResumeGamePlayPopoutAction:onCheckPopResult  ~~~~~~~~~~~~~~~~~~ PreBuffLogic:onPassLevel" )
		self:afterResumeFailed( self.replayData.level )
	else
		local buffOnResumeFlag = LocalBox:getData( "buffOnResumeFlag" )
		if buffOnResumeFlag then
			if type(buffOnResumeFlag) == "number" and tonumber(buffOnResumeFlag) ~= 0 then
				self:afterResumeFailed( tonumber(buffOnResumeFlag) )
			end
			LocalBox:setData( "buffOnResumeFlag" , false )
		end
	end

	if self.replayData and canPop then
		LocalBox:setData( "buffOnResumeFlag" , tonumber(self.replayData.level) )
	end
	
	return HomeScenePopoutAction.onCheckPopResult( self , canPop )
end

function ResumeGamePlayPopoutAction:afterResumeFailed( levelId )
	if levelId then
		PreBuffLogic:onPassLevel( levelId , 0 , GameGuide:isNoPreBuffLevel(levelId) , false , "crash" )
	end

	if self.replayData then
		ReplayDataManager:setHasReplayOnInitAndResumeFailed( true )
	end
end

function ResumeGamePlayPopoutAction:checkCanPop()
	ResumeGamePlayPopoutActionCheckFlag = "checked"
	local replayData = nil

	if ReplayDataManager:checkNeedResumeGamePlayByReplayData() then
		replayData = ReplayDataManager:getLastCrashReplay()
	end
	self.replayData = replayData

	if not MaintenanceManager:getInstance():isEnabledInGroup( "CrashResumeNew" , "A2" , UserManager:getInstance():getUID() ) then 
		return self:onCheckPopResult(false)
	end

	local uid = UserManager:getInstance():getUID() or "12345"
	local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"
	local time = Localhost:timeInSec()
	local levelNameStr = ""
	local topLevelId = UserManager:getInstance():getUserRef():getTopLevelId()

	if replayData then
		local datastr = replayData.idStr
		local md5str = HeMathUtils:md5( datastr )
		local isSummerMatchLevel = LevelType:isSummerMatchLevel( replayData.level )
		local isMoleWeeklyRaceLevel = LevelType:isMoleWeeklyRaceLevel( replayData.level )
		local isNationalDay2018Level = LevelType:isSummerFishLevel( replayData.level )
        local isJamSperadLevel = LevelType:isJamSperadLevel( replayData.level )
        local isSpringFestival2019Level = LevelType:isSpringFestival2019Level( replayData.level )

		if not MaintenanceManager:getInstance():isEnabledInGroup( "CrashResumeNew" , "D2" , UserManager:getInstance():getUID() ) then
			isNationalDay2018Level = false
            isJamSperadLevel = false
            isSpringFestival2019Level = false
		end
        

		self.canResumeRepeatedly = false
		local function checkCanResumeRepeatedly()
			if replayData.propUseInfo then

				local num = 0
				local function check( propId )
					if replayData.propUseInfo["p" .. tostring(propId)] then
						num = num + tonumber(replayData.propUseInfo["p" .. tostring(propId)])
					end
				end

				check( ItemType.ADD_FIVE_STEP )
				check( ItemType.ADD_BOMB_FIVE_STEP )
				check( ItemType.ADD_15_STEP )
				check( ItemType.TIMELIMIT_48_ADD_BOMB_FIVE_STEP )

				if num > 0 then
					return true
				end
			end

			if replayData.propBagInfo then

				local function check( propId )

					if replayData.propBagInfo["p" .. tostring(propId)] then
						local logNum = tonumber(replayData.propBagInfo["p" .. tostring(propId)]) or 0

						local prop = UserManager.getInstance():getUserProp( tonumber(propId) )
						local num = prop and prop.num or 0

						if num > logNum then
							return true
						end
					end

					return false
				end

				if check( ItemType.ADD_FIVE_STEP ) then return true end
				if check( ItemType.ADD_BOMB_FIVE_STEP ) then return true end
				if check( ItemType.ADD_15_STEP ) then return true end
				if check( ItemType.TIMELIMIT_48_ADD_BOMB_FIVE_STEP ) then return true end
			end

			if replayData.allowResumeCount and replayData.allowResumeCount > 0 then
				return true
			end

			return false
		end

		if replayData.isSectionResumeReplay or replayData.isResumeReplay then
			if checkCanResumeRepeatedly() then
				self.canResumeRepeatedly = true
			else
				if replayData.isSectionResumeReplay then
					DcUtil:crashResumeFailed( ResumeFailReason.kCanNotResumeOnSectionLevel , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--闪退数据来自上一次恢复打关
					return self:onCheckPopResult(false)
				end

				if replayData.isResumeReplay then
					DcUtil:crashResumeFailed( ResumeFailReason.kCanNotResumeOnReplayLevel , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--闪退数据来自上一次恢复打关
					return self:onCheckPopResult(false)
				end
			end
		end

		if replayData.actContext then
			local r = true
			local blockedActName
			for k,v in pairs(replayData.actContext) do
				if not ReplayDataManager:checkResumeEnableByActContext( v ) then
					r = false
					if type(v) == "string" then
						blockedActName = v
					end
					break
				end
			end
			
			if not r then
				DcUtil:crashResumeFailed( ResumeFailReason.kActivityIsEnd , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str, blockedActName)--跨活动关卡
				return self:onCheckPopResult(false)
			end
		end


		if _G.launchURL and _G.launchURL ~= "" then
			DcUtil:crashResumeFailed( ResumeFailReason.kLaunchGameByUrlLink , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--由链接启动游戏
			return self:onCheckPopResult(false)
		end

		if LevelType:isMainLevel( replayData.level ) 
			or LevelType:isHideLevel( replayData.level ) 
			or isSummerMatchLevel 
			or isMoleWeeklyRaceLevel 
			or isNationalDay2018Level
            or isJamSperadLevel
            or isSpringFestival2019Level
			then

			if LevelType:isMainLevel( replayData.level ) and replayData.level > topLevelId then
				DcUtil:crashResumeFailed( ResumeFailReason.kMainLevelAndGreaterTopLevel , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--主线关，且要恢复的关卡大于topLevel
				return self:onCheckPopResult(false)
			end

			if isSummerMatchLevel or isMoleWeeklyRaceLevel then
				if not MaintenanceManager:getInstance():isEnabledInGroup( "CrashResumeNew" , "C2" , uid ) then
					DcUtil:crashResumeFailed( ResumeFailReason.kWeeklyRaceSwitchOff , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--周赛开关未打开
					return self:onCheckPopResult(false)
				end

				local od = os.date( "%x", tonumber(replayData.currTime) )
				local cd = os.date( "%x", tonumber(time) )

				if tostring(od) ~= tostring(cd) then
					DcUtil:crashResumeFailed( ResumeFailReason.kWeeklyRacePassDay , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--周赛跨天
					return self:onCheckPopResult(false)
				end
			end

			local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID( replayData.level )

			if not levelConfig then
				DcUtil:crashResumeFailed( ResumeFailReason.kLevelConfigNotExist , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--没有关卡配置
				return self:onCheckPopResult(false)
			end

			if levelConfig.gameMode == GameModeType.CLASSIC then
				DcUtil:crashResumeFailed( ResumeFailReason.kIsTimeLevel , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--时间关
				return self:onCheckPopResult(false)
			end

			if levelConfig.hasDropDownUFO then
				DcUtil:crashResumeFailed( ResumeFailReason.kIsUFOLevel , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--飞碟关
				return self:onCheckPopResult(false)
			end

			if tonumber(time) - tonumber(replayData.currTime) > 3600*12  then
				DcUtil:crashResumeFailed( ResumeFailReason.kCrashOver12Hour , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--闪退时间是12小时以前
				return self:onCheckPopResult(false)
			end
		else
			DcUtil:crashResumeFailed( ResumeFailReason.kLevelRangeIllegal , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--不是主线关，隐藏关，周赛关
			return self:onCheckPopResult(false)
		end

		if udid == "hasNoUdid" then
			DcUtil:crashResumeFailed( ResumeFailReason.kUdidNotExist , replayData.level ,  uid , udid , replayData.uid , replayData.udid , md5str )--无法获取本机udid
			return self:onCheckPopResult(false)
		end

		if tostring(replayData.uid) ~= tostring(uid) then
			DcUtil:crashResumeFailed( ResumeFailReason.kUserChanged , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--不是当前用户的闪退数据
			return self:onCheckPopResult(false)
		end

		if tostring(replayData.udid) ~= tostring(udid) then
			DcUtil:crashResumeFailed( ResumeFailReason.kDeviceChanged , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--不是当前设备的闪退数据
			return self:onCheckPopResult(false)
		end

		self:onCheckPopResult(true)
	else
		self:onCheckPopResult(false)
	end
	
end

function ResumeGamePlayPopoutAction:testpop( addSpd )

	local path = "meta/" .. "testReplay.json"
	path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)

	local ret = lua_read_file(path)
	local replayData = table.deserialize(ret)

	--[[
	local checkReplayCachePath = HeResPathUtils:getUserDataPath() .. "/" .. "testReplay.json"
	local checkReplayCacheText = nil
	
	local hFile, err = io.open(checkReplayCachePath, "r")
	if hFile and not err then
		checkReplayCacheText = hFile:read("*a")
		io.close(hFile)
	end
	]]

	--local replayData = nil
	--local ssss = "{\"hasDropBuff\":false,\"ctx\":{\"dc1\":0,\"dc2\":0},\"randomSeed\":1502355388,\"passed\":0,\"context\":{},\"replaySteps\":[\"2,5:3,5\",\"2,5:3,5\",\"3,3:3,4\",\"3,5:3,6\",\"5,5:6,5\",\"4,4:5,4\",\"5,5:5,6\",\"5,5:4,5\",\"5,5:6,5\",\"5,5:6,5\",\"6,4:6,5\",\"6,3:6,4\",\"5,5:6,5\",\"5,4:5,5\",\"6,7:7,7\",\"5,5:5,6\",\"7,5:8,5\",\"5,5:6,5\",\"6,5:6,6\",\"5,6:5,7\"],\"uid\":\"28985\",\"curMd5\":\"local_dev_version\",\"score\":90460,\"ver\":2,\"info\":\"NRCD2050\",\"curConfigMd5\":\"9868aaea5f8cd30f9fee4b8e9f1fecdb\",\"udid\":\"d5a88faddef68b06227dd85819992bb1\",\"currTime\":1502355392,\"idStr\":\"28985d5a88faddef68b06227dd85819992bb11502355392\",\"selectedItemsData\":{},\"level\":993}"
	--replayData = table.deserialize( ssss )

	local function yesCallback()
		require "zoo.panelBusLogic.NewStartLevelLogic"
	    local step = replayData
		local newStartLevelLogic = NewStartLevelLogic:create( nil , step.level , {} , false , {} )
		newStartLevelLogic:startWithReplay( ReplayMode.kResume , step )
	end
	

	require "zoo.panel.CrashResumePanel"
	local panel = nil
	panel = CrashResumePanel:create( CrashResumePanelType.kSelectPanel , "测试回放" , yesCallback, noCallback )
	panel:popout()

	CrashResumeGamePlaySpeedUp = addSpd
end

function ResumeGamePlayPopoutAction:popout( next_action )
	--RemoteDebug:uploadLog( "ResumeGamePlayPopoutAction:popout"  )
	if isLocalDevelopMode then

		--[[
		local autoReplayCheckData = ReplayAutoCheckManager:readLocalData()
		if autoReplayCheckData and autoReplayCheckData.result then

			require "zoo.panel.AutoPlayCheckToolbar"
			local function showSuccess() 
				AutoPlayCheckToolbar:showSuccess() 
			end

			local function showError(failedLevels) 
				AutoPlayCheckToolbar:showError(failedLevels)
			end

			ReplayAutoCheckManager:checkByList( 
				autoReplayCheckData.checkList , 
				autoReplayCheckData.checkByListParameter , 
				showSuccess , 
				showError , 
				autoReplayCheckData.checkListIndex , 
				autoReplayCheckData.currCount )

			return
		else
			ReplayAutoCheckManager:deleteLocalData()
		end
		]]


		local hasAutoCheckLevel = nil
		if AutoCheckLevelManager and AutoCheckLevelManager.resumeContext then
			hasAutoCheckLevel = AutoCheckLevelManager:resumeContext()
		end

		if hasAutoCheckLevel then
			--
--
--
--
--
--
--
--
--
--
--

			AutoCheckLevelManager:nextCheck()

			return
		else
			ReplayAutoCheckManager:deleteLocalData()
		end
	end
	
	local onClose = next_action
	local noPop = next_action

	local replayData = nil

	if ReplayDataManager:checkNeedResumeGamePlayByReplayData() then
		replayData = ReplayDataManager:getLastCrashReplay()
	end

	local uid = UserManager:getInstance():getUID() or "12345"
	local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"
	local time = Localhost:timeInSec()
	local levelNameStr = ""

	if replayData then
		
		local datastr = replayData.idStr
		local md5str = HeMathUtils:md5( datastr )
		local isSummerMatchLevel = LevelType:isSummerMatchLevel( replayData.level )
		local isMoleWeeklyRaceLevel = LevelType:isMoleWeeklyRaceLevel( replayData.level )
		local isNationalDay2018Level = LevelType:isSummerFishLevel( replayData.level )
        local isJamSperadLevel = LevelType:isJamSperadLevel( replayData.level )
        local isSpringFestival2019Level = LevelType:isSpringFestival2019Level( replayData.level )
		--local md5str = HeMathUtils:md5( datastr .. tostring(os.time()) )
		
		if LevelType:isMainLevel( replayData.level ) 
			or LevelType:isHideLevel( replayData.level ) 
			or isSummerMatchLevel 
			or isMoleWeeklyRaceLevel 
			or isNationalDay2018Level 
            or isJamSperadLevel
            or isSpringFestival2019Level then

			local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID( replayData.level )
			if LevelType:isMainLevel( replayData.level ) then
				levelNameStr = "第" .. tostring(replayData.level) .. "关"
			elseif LevelType:isHideLevel( replayData.level ) then
				levelNameStr = "+" .. tostring( tonumber(replayData.level) - LevelConstans.HIDE_LEVEL_ID_START ) .. "关"
			elseif LevelType:isSummerMatchLevel( replayData.level ) or isMoleWeeklyRaceLevel then
				levelNameStr = "周赛关"
			elseif LevelType:isSummerFishLevel( replayData.level ) or isNationalDay2018Level then
				levelNameStr = "活动关"
            elseif LevelType:isJamSperadLevel( replayData.level ) or isJamSperadLevel then
				levelNameStr = "活动关"
            elseif LevelType:isSpringFestival2019Level( replayData.level ) or isSpringFestival2019Level then
				levelNameStr = "活动关"
			else
				levelNameStr = "第" .. tostring(replayData.level) .. "关"
			end
		end

		require "zoo.panel.CrashResumePanel"
		local panel = nil

		local function yesCallback()

			local function __doYesCallback( startGameDelegate )
				NewStartLevelLogic:addWaitingPanel()
				local function onSuccess()
					require "zoo.panelBusLogic.NewStartLevelLogic"
					----[[
				    local step = replayData
					local newStartLevelLogic = NewStartLevelLogic:create( startGameDelegate , step.level , {} , false , {} )
					--
					local passSection = false
					local sectionData = nil

					for k,v in pairs(step) do
						printx( 1 , "k" , k , "v" , v ) 
					end

					if step.sectionData then
						sectionData = step.sectionData
					elseif step.lastSectionData then
						sectionData = step.lastSectionData
					end

					if not sectionData then
						passSection = true
					end

					if sectionData and sectionData.nextSectionData and sectionData.nextSectionData.sectionType == SectionType.kInit then
						passSection = true
					end

					if isSummerMatchLevel then
						passSection = true
					end

					if not passSection and 
						(_G.useSectionWhenCrash or MaintenanceManager:getInstance():isEnabledInGroup( "CrashResumeNew" , "useSection" , uid ) ) 
						then
						newStartLevelLogic:startWithReplay( ReplayMode.kSectionResume , step )
					else
						newStartLevelLogic:startWithReplay( ReplayMode.kResume , step )
					end
					

					--]]

					--[[
					local step = replayData
					local scene = CheckPlayScene:create(step.level, step)
					scene:startReplay(CheckPlayScenePLayMode.kResume)
					--]]

					local totalSteps = #step.replaySteps
					DcUtil:crashResumeStart( replayData.level , totalSteps , uid , udid , replayData.uid , replayData.udid , md5str )--恢复开始

					ReplayDataManager:setLastCrashReplayHasResumed(true)
					LocalBox:setData( "buffOnResumeFlag" , false )

					panel:onCloseBtnTapped()

					--for test ------------------
					--[[
					local path = HeResPathUtils:getUserDataPath() .. "/dnwInfo_" .. tostring(Localhost:timeInSec()) .. ".ds" 
					Localhost:safeWriteStringToFile( table.serialize(replayData) , path )
					]]
					------------------------------
					setTimeOut( function () onClose() end , 2 ) 
				end

				local function onFail(evt)
					--local errId = evt.data
					--RemoteDebug:uploadLog( "RecoveryLevelHttp onFail " .. tostring(evt.data) )
					local text = {tip = Localization:getInstance():getText("crash.resume.failed")  , yes = "确定"}
					CommonTipWithBtn:showTip( text , "negative" , nil, nil , nil , true )

					panel:onCloseBtnTapped()
					setTimeOut( function () onClose() end , 0.1 ) 
					DcUtil:crashResumeFailed( ResumeFailReason.kMd5CheckFail , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--后端MD5校验失败
					NewStartLevelLogic:removeWaitingPanel()
				end

				local function hasLogin()

					if ReplayDataManager:getLastCrashReplay() then--二次确认，登录后，可能数据异常，这时ReplayDataManager:getLastCrashReplay()会返回nil
						--RemoteDebug:uploadLog( "RecoveryLevelHttp hasLogin ")

						if self.canResumeRepeatedly then
							onSuccess()
						else
							local http = RecoveryLevelHttp.new(true)	
							http:addEventListener(Events.kComplete, onSuccess)
						    http:addEventListener(Events.kError, onFail)
							http:syncLoad( md5str )
						end
					else
						local text = {tip = Localization:getInstance():getText("crash.resume.tip.not.success")  , yes = "确定"}
						CommonTip:showTip( text.tip , "negative" )

						DcUtil:crashResumeFailed( ResumeFailReason.kUserDataNeedRevert , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--看见了恢复面板，但数据异常
						panel:onCloseBtnTapped()
						setTimeOut( function () onClose() end , 0.1 ) 
						NewStartLevelLogic:removeWaitingPanel()
						return
					end
					
				end

				local function hasNotLogin()
					--RemoteDebug:uploadLog( "RecoveryLevelHttp hasNotLogin ")
					local text = {tip = Localization:getInstance():getText("crash.resume.has.no.login")  , yes = "确定"}
					CommonTip:showTip( text.tip , "negative" )

					DcUtil:crashResumeHasNoNetwork( replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--没有Login
					NewStartLevelLogic:removeWaitingPanel()
				end


				local function hasNetwork()
					--RemoteDebug:uploadLog( "RecoveryLevelHttp hasNetwork ")
					RequireNetworkAlert:callFuncWithLogged( hasLogin , hasNotLogin )
				end

				local function hasNoNetwork()
					--RemoteDebug:uploadLog( "RecoveryLevelHttp hasNoNetwork ")
					local text = {tip = Localization:getInstance():getText("crash.resume.has.no.net")  , yes = "确定"}
					CommonTip:showTip( text.tip , "negative" )
					DcUtil:crashResumeHasNoNetwork( replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--联网失败
					NewStartLevelLogic:removeWaitingPanel()
				end

				PaymentNetworkCheck:getInstance():check( hasNetwork , hasNoNetwork )
			end

            --双蛋活动断面
            if isSpringFestival2019Level then
				local function openActivity()
				    local version = nil
				    local source = nil
				    for k,v in pairs(ActivityUtil:getActivitys() or {}) do
				        if v.source == "FifthAnniversary/Config.lua" then 
				        	version = v.version
				        	source = v.source
				        	break
				        end
				    end

				    local function actcallback( startGameDelegate , resumeResule )
				    	if resumeResule then
				    		__doYesCallback( startGameDelegate )
				    	else
				    		DcUtil:crashResumeFailed( ResumeFailReason.kSpringFestival2019OverTime , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--看见了恢复面板，但数据异常
							panel:onCloseBtnTapped()
							setTimeOut( function () onClose() end , 0.1 ) 
							NewStartLevelLogic:removeWaitingPanel()
							CommonTip:showTip( "活动关卡已过期！" , "negative" )
							LocalBox:setData( "buffOnResumeFlag" , false )
				    	end
				    end

				    local par = { levelId = replayData.level , callback = actcallback }
				    ActivityData.new({source=source,version=version}):start(false, nil , nil, nil, nil , nil , par )
				end

				if Spring2019ActivityIsGetReady then
					openActivity()
					-- __doYesCallback()
				else
					local text = {tip = Localization:getInstance():getText("crash.resume.NationalDay2018.not.ready")  , yes = "确定"}
					CommonTip:showTip( text.tip , "negative" )
				end
			else
				__doYesCallback()
			end
		end

		local function noCallback()
			DcUtil:crashResumeFailed( ResumeFailReason.kUserClose , replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )--用户主动取消
			ReplayDataManager:setLastCrashReplayHasResumed(true)

			self:afterResumeFailed( replayData.level )
			LocalBox:setData( "buffOnResumeFlag" , false )

			onClose()
		end
		
        local function pop()
        	panel = CrashResumePanel:create( CrashResumePanelType.kSelectPanel , levelNameStr , yesCallback, noCallback )
		    panel:popout()
		    DcUtil:popCrashResumePanel(replayData.level , uid , udid , replayData.uid , replayData.udid , md5str )
        end
        
        local CurTime = math.floor( Localhost:time()/1000 )
        local realLevelId = LevelConfigGroupMgr.getInstance():getRealLevelId(replayData.level)
        if isSpringFestival2019Level and not PigYearLogic:isActInMain_ClientTime() then
            noPop()
        elseif realLevelId ~= replayData.meta_level then
        	if not replayData.meta_level and not LevelType:isGroupLevel(realLevelId) then
        		pop() 
        	else
        		noPop()
        	end
        else
        	pop()
		end
	else
		--RemoteDebug:uploadLog( "ResumeGamePlayPopout break 12 no data")
		noPop()
	end
	
end