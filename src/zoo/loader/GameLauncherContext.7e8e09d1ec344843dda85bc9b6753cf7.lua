require "zoo.util.TimerUtil"

GameLauncherContext = {}
GameLauncherContext.ver = 2
local _instance = nil


function GameLauncherContext:getInstance()
	if not _instance then
		_instance = GameLauncherContext
		_instance:init()
	end
	return _instance
end


function GameLauncherContext:init()
	self:reset()
end

function GameLauncherContext:reset()

	self.dcPool = {}

	self.timeOnLauncher = 0
	self.timeOnPreloadingScene = 0
	self.timeOnPreloadingSceneResLoadFinish = 0

	self.timeOnTouchLogin = 0
	self.timeOnStartLogin = 0

	self.timeOnInitUserDataByServer = 0
	self.timeOnInitUserDataByLocal = 0

	self.timeOnCreateHomeScene = 0
	self.timeOnCreateHomeSceneDone = 0

	self.timeOnHomeSceneInitMoveToTop = 0
	self.timeOnHomeSceneInitMoveToTopFinish = 0

	self.timeOnBuildFriendPic = 0
	self.timeOnBuildFriendPicFinished = 0

	self.timeOnStartInitPopoutQueue = 0
	self.timeOnInitPopoutQueueDone = 0
	self.timeOnOnePopoutDone = 0

	self.timeOnActivityFrameStart = 0
	self.timeOnAllActivityConfigLoaded = 0
	self.timeOnAllActivityIconStartLoad = 0
	self.timeOnAllActivityIconLoaded = 0
	self.timeOnAllActivityIconCreated = 0
		
		
	-- self.oneActivityStartList = {}

	self.actIconLoadList = {}
	self.actConfigLoadList = {}
	self.actIconCreateList = {}
	self.actResLoadList = {}
	self.actStartList = {}

--------------------------------------------------------

	self.frameOnLauncher = 0
	self.frameOnPreloadingScene = 0
	self.frameOnPreloadingSceneResLoadFinish = 0

	self.frameOnTouchLogin = 0
	self.frameOnStartLogin = 0

	self.frameOnInitUserDataByServer = 0
	self.frameOnInitUserDataByLocal = 0

	self.frameOnCreateHomeScene = 0
	self.frameOnCreateHomeSceneDone = 0

	self.frameOnHomeSceneInitMoveToTop = 0
	self.frameOnHomeSceneInitMoveToTopFinish = 0

	self.frameOnBuildFriendPic = 0
	self.frameOnBuildFriendPicFinished = 0

	self.frameOnStartInitPopoutQueue = 0
	self.frameOnInitPopoutQueueDone = 0
	self.frameOnOnePopoutDone = 0

	self.frameOnActivityFrameStart = 0
	self.frameOnAllActivityConfigLoaded = 0
	self.frameOnAllActivityIconStartLoad = 0
	self.frameOnAllActivityIconLoaded = 0
	self.frameOnAllActivityIconCreated = 0
end

function GameLauncherContext:check()
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
--
--
--
--
--
--

end

local categoryList = {
	[1] = "Launcher" ,
	[2] = "LoadResOnPreloadingScene" ,
	[3] = "TouchLogin" ,
	[4] = "InitUserDataByLocal" ,
	[5] = "InitUserDataByServer" ,
	[6] = "CreateHomeScene" ,
	[7] = "HomeSceneBuildUserPic" ,
	[8] = "ActLoadConfig" ,
	[9] = "ActLoadIconRes" ,
	[10] = "ActFrameShowIcon" ,
	[11] = "HomeScenePopoutQueue" ,
}

function GameLauncherContext:addToDCPool( category , startTime , endTime , startFrame , endFrame , datas )
	
	local function _doAddToDCPool()

		local timePass = endTime - startTime
		local framePass = endFrame - startFrame
		local FPS = framePass/timePass*1000

		local obj = {}
		obj.category = category
		obj.timePass = timePass / 1000
		obj.framePass = framePass
		obj.FPS = FPS
		
		-- --
--


		table.insert( self.dcPool , obj )

		for k , v in ipairs( categoryList ) do
			if obj.category == v then
				table.remove( categoryList , k )
				break
			end
		end

		local newUserDoDC = false
		if #self.dcPool == 10 and #categoryList == 1 and ( categoryList[1] == "InitUserDataByLocal" or categoryList[1] == "HomeSceneBuildUserPic" ) then
			newUserDoDC = true
		elseif #self.dcPool == 9 and #categoryList == 2 then

			local a , b = false ,false
			if categoryList[1] == "InitUserDataByLocal" or categoryList[2] == "HomeSceneBuildUserPic" then
				a = true
			end

			if categoryList[1] == "HomeSceneBuildUserPic" or categoryList[2] == "HomeSceneBuildUserPic" then
				b = true
			end

			if a and b then
				newUserDoDC = true
			end
		end

		if #self.dcPool >= 11 or newUserDoDC then

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
--
--
--


			local resultList = {}
			for k,v in ipairs( self.dcPool ) do
				
				if v.category == "LoadResOnPreloadingScene" and ( v.timePass > 10 or (v.FPS < 15 and v.FPS > 0) ) then
					resultList["LoadResOnPreloadingScene"] = v
				end

				if v.category == "InitUserDataByLocal" and ( v.timePass > 6 or (v.FPS < 15 and v.FPS > 0) ) then
					resultList["InitUserDataByLocal"] = v
				end

				if v.category == "InitUserDataByServer" and ( v.timePass > 6 or (v.FPS < 15 and v.FPS > 0) ) then
					resultList["InitUserDataByServer"] = v
				end

				if v.category == "ActLoadConfig" and v.timePass > 18 --[[or v.FPS < 10]] then
					resultList["ActLoadConfig"] = v
					resultList.actConfigLoadList = self.actConfigLoadList
				end

				if v.category == "HomeScenePopoutQueue" and (v.FPS < 15 and v.FPS > 0) then
					resultList["HomeScenePopoutQueue"] = v
				end

				if v.category == "ActLoadIconRes" and (v.FPS < 15 and v.FPS > 0) then
					resultList["ActLoadIconRes"] = v
				end

				if v.category == "ActFrameShowIcon" and v.timePass > 20 and (v.FPS < 5 and v.FPS > 0) then
					resultList["ActFrameShowIcon"] = v
				end
			end

			local num = 0
			for k,v in pairs( resultList ) do
				if k ~= "actConfigLoadList" then
					local datas = nil
					if k ~= "ActLoadConfig" then
						datas = resultList.actConfigLoadList
					end
					-- RemoteDebug:uploadLogWithTag( "DcUtil" , "gameLauncherContextWarning --- " , k , v.timePass , v.FPS , datas )

					local key = "LauncherContextWarning"
					local uid = UserManager:getInstance():getUID()
					local switch = MaintenanceManager:getInstance():isEnabledInGroup( key , "ON" ,  uid ) or false

					if switch then
						DcUtil:gameLauncherContextWarning( k , v.timePass , v.FPS , datas )
					end
				end
			end
		end
	end

	local status, msg = xpcall( _doAddToDCPool , __G__TRACKBACK__ )
	if not status then
	    if _G.isLocalDevelopMode then printx(-99, msg) end
	end
end

function GameLauncherContext:onLauncher( _launcher )
	if self.timeOnLauncher == 0 then
		self.timeOnLauncher = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnLauncher = TimerUtil.frameId
	end
end

function GameLauncherContext:onPreloadingScene( _preloadingScene )
	if self.timeOnPreloadingScene == 0 then
		self.timeOnPreloadingScene = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnPreloadingScene = TimerUtil.frameId

		-- local time1 = self.timeOnPreloadingScene - self.timeOnLauncher
		-- local frame1 = self.frameOnPreloadingScene - self.frameOnLauncher
		-- --RemoteDebug:uploadLogWithTag( 1 , "Launcher ---" , time1/1000 , frame1 , frame1/time1*1000)

		self:addToDCPool( "Launcher" , self.timeOnLauncher , self.timeOnPreloadingScene , self.frameOnLauncher , self.frameOnPreloadingScene )
	end
end

function GameLauncherContext:onPreloadingSceneResLoadFinish( _preloadingScene )
	if self.timeOnPreloadingSceneResLoadFinish == 0 then
		self.timeOnPreloadingSceneResLoadFinish = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnPreloadingSceneResLoadFinish = TimerUtil.frameId

		-- local time2 = self.timeOnPreloadingSceneResLoadFinish - self.timeOnPreloadingScene
		-- local frame2 = self.frameOnPreloadingSceneResLoadFinish - self.frameOnPreloadingScene
		-- --RemoteDebug:uploadLogWithTag( 1 , "ResLoad ---" , time2/1000 , frame2 , frame2/time2*1000) 

		self:addToDCPool( "LoadResOnPreloadingScene" , self.timeOnPreloadingScene , self.timeOnPreloadingSceneResLoadFinish , self.frameOnPreloadingScene , self.frameOnPreloadingSceneResLoadFinish )
	end
end

function GameLauncherContext:onTouchLogin(  )
	if self.timeOnTouchLogin == 0 then
		self.timeOnTouchLogin = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnTouchLogin = TimerUtil.frameId
	end
end

function GameLauncherContext:onStartLogin(  )
	if self.timeOnStartLogin == 0 then
		self.timeOnStartLogin = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnStartLogin = TimerUtil.frameId

		self:addToDCPool( "TouchLogin" , self.timeOnTouchLogin , self.timeOnStartLogin , self.frameOnTouchLogin , self.frameOnStartLogin )
	end
end

function GameLauncherContext:onInitUserDataByServer(  )
	if self.timeOnInitUserDataByServer == 0 then
		self.timeOnInitUserDataByServer = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnInitUserDataByServer = TimerUtil.frameId

		self:addToDCPool( "InitUserDataByServer" , self.timeOnStartLogin , self.timeOnInitUserDataByServer , self.frameOnStartLogin , self.frameOnInitUserDataByServer )
	end
end

function GameLauncherContext:onInitUserDataByLocal(  )
	if self.timeOnInitUserDataByLocal == 0 then
		self.timeOnInitUserDataByLocal = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnInitUserDataByLocal = TimerUtil.frameId

		self:addToDCPool( "InitUserDataByLocal" , self.timeOnStartLogin , self.timeOnInitUserDataByLocal , self.frameOnStartLogin , self.frameOnInitUserDataByLocal )
	end
end

function GameLauncherContext:onCreateHomeScene(  )
	if self.timeOnCreateHomeScene == 0 then
		self.timeOnCreateHomeScene = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnCreateHomeScene = TimerUtil.frameId
	end
end

function GameLauncherContext:onCreateHomeSceneDone(  )
	if self.timeOnCreateHomeSceneDone == 0 then
		self.timeOnCreateHomeSceneDone = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnCreateHomeSceneDone = TimerUtil.frameId

		-- local time3 = self.timeOnCreateHomeSceneDone - self.timeOnCreateHomeScene
		-- local frame3 = self.frameOnCreateHomeSceneDone - self.frameOnCreateHomeScene
		-- --RemoteDebug:uploadLogWithTag( 1 , "HomeScene Create ---" , time3/1000 , frame3 , frame3/time3*1000) 

		self:addToDCPool( "CreateHomeScene" , self.timeOnCreateHomeScene , self.timeOnCreateHomeSceneDone , self.frameOnCreateHomeScene , self.frameOnCreateHomeSceneDone )
	end
end

function GameLauncherContext:onHomeSceneInitMoveToTop(  )
	if self.timeOnHomeSceneInitMoveToTop == 0 then
		self.timeOnHomeSceneInitMoveToTop = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnHomeSceneInitMoveToTop = TimerUtil.frameId
	end
end

function GameLauncherContext:onHomeSceneInitMoveToTopFinish(  )
	if self.timeOnHomeSceneInitMoveToTopFinish == 0 then
		self.timeOnHomeSceneInitMoveToTopFinish = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnHomeSceneInitMoveToTopFinish = TimerUtil.frameId

		-- local time4 = self.timeOnHomeSceneInitMoveToTopFinish - self.timeOnHomeSceneInitMoveToTop
		-- local frame4 = self.frameOnHomeSceneInitMoveToTopFinish - self.frameOnHomeSceneInitMoveToTop
		-- --RemoteDebug:uploadLogWithTag( 1 , "HomeScene Move To Top Pic ---" , time4/1000 , frame4 , frame4/time4*1000) 

		self:addToDCPool( "HomeSceneMoveToTop" , self.timeOnHomeSceneInitMoveToTop , self.timeOnHomeSceneInitMoveToTopFinish , self.frameOnHomeSceneInitMoveToTop , self.frameOnHomeSceneInitMoveToTopFinish )
	end
end

function GameLauncherContext:onBuildFriendPic(  )
	if self.timeOnBuildFriendPic == 0 then
		self.timeOnBuildFriendPic = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnBuildFriendPic = TimerUtil.frameId
	end
end

function GameLauncherContext:onBuildFriendPicFinished(  )
	if self.timeOnBuildFriendPicFinished == 0 then
		self.timeOnBuildFriendPicFinished = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnBuildFriendPicFinished = TimerUtil.frameId

		-- local time5 = self.timeOnBuildFriendPicFinished - self.timeOnBuildFriendPic
		-- local frame5 = self.frameOnBuildFriendPicFinished - self.frameOnBuildFriendPic
		-- --RemoteDebug:uploadLogWithTag( 1 , "HomeScene Build Pic ---" , time5/1000 , frame5 , frame5/time5*1000) 

		self:addToDCPool( "HomeSceneBuildUserPic" , self.timeOnBuildFriendPic , self.timeOnBuildFriendPicFinished , self.frameOnBuildFriendPic , self.frameOnBuildFriendPicFinished )
	end
end

function GameLauncherContext:onStartInitPopoutQueue(  )
	if self.timeOnStartInitPopoutQueue == 0 then
		self.timeOnStartInitPopoutQueue = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnStartInitPopoutQueue = TimerUtil.frameId
	end
end

function GameLauncherContext:onInitPopoutQueueDone(  )
	if self.timeOnInitPopoutQueueDone == 0 then
		self.timeOnInitPopoutQueueDone = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnInitPopoutQueueDone = TimerUtil.frameId

		-- local time6 = self.timeOnInitPopoutQueueDone - self.timeOnStartInitPopoutQueue
		-- local frame6 = self.frameOnInitPopoutQueueDone - self.frameOnStartInitPopoutQueue
		-- --RemoteDebug:uploadLogWithTag( 1 , "HomeScene PopoutQueue ---" , time6/1000 , frame6 , frame6/time6*1000 ) 

		self:addToDCPool( "HomeScenePopoutQueue" , self.timeOnStartInitPopoutQueue , self.timeOnInitPopoutQueueDone , self.frameOnStartInitPopoutQueue , self.frameOnInitPopoutQueueDone )
	end
end

function GameLauncherContext:onOnePopoutDone(  )
	if self.timeOnOnePopoutDone == 0 then
		self.timeOnOnePopoutDone = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnOnePopoutDone = TimerUtil.frameId
	end
end

function GameLauncherContext:onActivityFrameStart(  )--活动框架启动，开始加载
	if self.timeOnActivityFrameStart == 0 then
		self.timeOnActivityFrameStart = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnActivityFrameStart = TimerUtil.frameId
	end
end

function GameLauncherContext:onOneActivityConfigStartLoad( source , version )--活动框架开始加载某一个活动的Config.lua
	if not self.actConfigLoadList[source] then
		local obj = {}
		obj.source = source
		obj.version = version
		obj.startTime = HeTimeUtil:getCurrentTimeMillis()
		obj.startFrame = TimerUtil.frameId
		self.actConfigLoadList[source] = obj
	end
end

function GameLauncherContext:onOneActivityConfigLoaded( source , version , result , isReload )--活动框架加载完成了某一个活动的Config.lua
	if self.actConfigLoadList[source] then
		local obj = self.actConfigLoadList[source]
		obj.endTime = HeTimeUtil:getCurrentTimeMillis()
		obj.endFrame = TimerUtil.frameId
		obj.result = result
		obj.isReload = isReload
	end
end

function GameLauncherContext:onAllActivityConfigLoaded(  )--活动框架加载了所有活动的Config.lua文件
	if self.timeOnAllActivityConfigLoaded == 0 then
		self.timeOnAllActivityConfigLoaded = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnAllActivityConfigLoaded = TimerUtil.frameId

		-- local time7 = self.timeOnAllActivityConfigLoaded - self.timeOnActivityFrameStart
		-- local frame7 = self.frameOnAllActivityConfigLoaded - self.frameOnActivityFrameStart
		-- --RemoteDebug:uploadLogWithTag( 1 , "HomeScene Activity Frame Config ---" , time7/1000 , frame7 , frame7/time7*1000)


		self:addToDCPool( "ActLoadConfig" , self.timeOnActivityFrameStart , self.timeOnAllActivityConfigLoaded , self.frameOnActivityFrameStart , self.frameOnAllActivityConfigLoaded )
	end
end

function GameLauncherContext:onAllActivityIconStartLoad(  )--活动框架开始加载所有活动的Icon依赖文件
	if self.timeOnAllActivityIconStartLoad == 0 then
		self.timeOnAllActivityIconStartLoad = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnAllActivityIconStartLoad = TimerUtil.frameId
	end
end

function GameLauncherContext:onAllActivityIconLoaded(  )--活动框架加载了所有活动的Icon依赖文件
	if self.timeOnAllActivityIconLoaded == 0 then
		self.timeOnAllActivityIconLoaded = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnAllActivityIconLoaded = TimerUtil.frameId

		-- local time8 = self.timeOnAllActivityIconLoaded - self.timeOnAllActivityConfigLoaded
		-- local frame8 = self.frameOnAllActivityIconLoaded - self.frameOnAllActivityConfigLoaded
		-- --RemoteDebug:uploadLogWithTag( 1 , "HomeScene Activity Frame Icon ---" , time8/1000 , frame8 , frame8/time8*1000)

		self:addToDCPool( "ActLoadIconRes" , self.timeOnAllActivityConfigLoaded , self.timeOnAllActivityIconLoaded , self.frameOnAllActivityConfigLoaded , self.frameOnAllActivityIconLoaded )
	end
end

function GameLauncherContext:onOneActivityIconStartLoad( source , version )--活动框架开始加载某一个活动的Icon依赖文件
	if not self.actIconLoadList[source] then
		local obj = {}
		obj.source = source
		obj.version = version
		obj.startTime = HeTimeUtil:getCurrentTimeMillis()
		obj.startFrame = TimerUtil.frameId
		self.actIconLoadList[source] = obj
	end
end

function GameLauncherContext:onOneActivityIconLoaded( source , version )--活动框架加载了某一个活动的Icon依赖文件
	if self.actIconLoadList[source] then
		local obj = self.actIconLoadList[source]
		obj.endTime = HeTimeUtil:getCurrentTimeMillis()
		obj.endFrame = TimerUtil.frameId
	end
end

function GameLauncherContext:onAllActivityIconCreated(  )--活动框架创建了所有活动的Icon
	if self.timeOnAllActivityIconCreated == 0 then
		self.timeOnAllActivityIconCreated = HeTimeUtil:getCurrentTimeMillis()
		self.frameOnAllActivityIconCreated = TimerUtil.frameId

		-- local time9 = self.timeOnAllActivityIconCreated - self.timeOnActivityFrameStart
		-- local frame9 = self.frameOnAllActivityIconCreated - self.frameOnActivityFrameStart
		-- --RemoteDebug:uploadLogWithTag( 1 , "HomeScene Activity Frame ALL ---" , time9/1000 , frame9 , frame9/time9*1000) 


		self:addToDCPool( "ActFrameShowIcon" , self.timeOnActivityFrameStart , self.timeOnAllActivityIconCreated , self.frameOnActivityFrameStart , self.frameOnAllActivityIconCreated )
	end
end

function GameLauncherContext:onOneActivityIconCreated( source , version )--活动框架创建了某一个活动的Icon
	if not self.actIconCreateList[source] then
		local obj = {}
		obj.source = source
		obj.version = version
		obj.startTime = HeTimeUtil:getCurrentTimeMillis()
		obj.startFrame = TimerUtil.frameId
		self.actIconCreateList[source] = obj
	end
end

-- function GameLauncherContext:onAllActivityResLoaded(  )--活动框架加载了所有活动的依赖文件

-- end

function GameLauncherContext:onOneActivityResStartLoad( source , version )--活动框架开始加载某一个活动的依赖文件
	if not self.actResLoadList[source] then
		local obj = {}
		obj.source = source
		obj.version = version
		obj.startTime = HeTimeUtil:getCurrentTimeMillis()
		obj.startFrame = TimerUtil.frameId
		self.actResLoadList[source] = obj
	end
end

function GameLauncherContext:onOneActivityResLoaded( source , version )--活动框架加载了某一个活动的依赖文件
	if self.actResLoadList[source] then
		local obj = self.actResLoadList[source]
		obj.endTime = HeTimeUtil:getCurrentTimeMillis()
		obj.endFrame = TimerUtil.frameId
	end
end

-- function GameLauncherContext:onAllActivityStartFinish(  )--活动框架启动了所有活动的Start文件并处理完毕强弹逻辑

-- end

function GameLauncherContext:onOneActivityStart( source , version )--活动框架开始启动某一个活动的Start文件并尝试处理强弹逻辑
	if not self.actStartList[source] then
		local obj = {}
		obj.source = source
		obj.version = version
		obj.startTime = HeTimeUtil:getCurrentTimeMillis()
		obj.startFrame = TimerUtil.frameId
		self.actStartList[source] = obj
	end
end

function GameLauncherContext:onOneActivityStartFinish( source , version , result )--活动框架启动了某一个活动的Start文件并处理完毕强弹逻辑
	if self.actStartList[source] then
		local obj = self.actStartList[source]
		obj.endTime = HeTimeUtil:getCurrentTimeMillis()
		obj.endFrame = TimerUtil.frameId
		obj.result = result
	end
end

function GameLauncherContext:onAllActivityStartExecuteAutoLua(  )--活动框架开始处理所有活动的ExecuteAutoLua

end

function GameLauncherContext:onAllActivityExecuteAutoLuaFinish(  )--活动框架处理完毕了所有活动的ExecuteAutoLua

end

function GameLauncherContext:onOneActivityStartExecuteAutoLua(  )--活动框架开始处理某一个活动的ExecuteAutoLua

end

function GameLauncherContext:onOneActivityExecuteAutoLuaFinish(  )--活动框架处理完毕了某一个活动的ExecuteAutoLua

end

