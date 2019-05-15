require "zoo.panel.incite.IncitePanel"
require "zoo.panel.incite.VideoAdPanel"
require "zoo.panel.incite.AdNode"
require "zoo.panel.incite.InciteConfig"

InciteManager = {}

function InciteManager:initialize()
	if self.isInit then return end
	if not self:isEnabled() then return end

	if __WIN32 then
		local tfn = function() return true end
		--测试开关，包括 VideoAdUnitTest 的后端测试渠道数据等
		self.isDebug = tfn
		--广告测试渠道，方便初始化channel，稳定执行到 ready
		self.isTestChannel = tfn
		--显示输出
		-- self.isShowPrint = tfn
	end

	self.isInit = true
	self.state = {}
	self.data = {}
	self.curPlayInfo = nil
	self.channels = {}

	--request and check condition
	Notify:dispatch("AutoPopoutEventWaitAction", IncitePanelPopoutAction)
	-- self:requestInfo()

	Notify:register("VideoAdEventSyncInfo", self.syncInfo, self)

	self:readLocalData()

	-- self:checkGroupTestType()

	if self:isDebug() then
		require "zoo.panel.incite.VideoAdUnitTest"
		VideoAdUnitTest:init()
	end

	self:syncInfo()

end

local debug_config = {
	appId = "1282",
	appKey = "27531c7c64157934",
	placementIds = {
		"e01480dcea2","e01480dcea2","e01480dcea2","e01480dcea2",
	},
}

function InciteManager:isTestChannel()
	return MaintenanceManager:getInstance():isEnabled("VideoAdTestPara", false)
end

function InciteManager:isShowPrint()
	return MaintenanceManager:getInstance():isEnabled("InciteDebug", false)
end

function InciteManager:createChannel()
	if not self.info then return end
	local config = self.info.config

	local function getAppInfo(name)
		for _,info in ipairs(config) do
			if info.first == name or __WIN32 then
				return table.deserialize(info.second)
			end
		end
		return nil
	end

	local enableSDKs = self:getEnableSDKs()
	local testPara = self:isTestChannel()

	for name,conf in pairs(InciteConfig) do
		local appinfo = getAppInfo(name)
		if conf.delegate and appinfo and not self.channels[name] then

			if __ANDROID then
				pcall(function ()
					if testPara then
						appinfo = debug_config
					end
					conf.delegate:setAppInfo(appinfo.appId, appinfo.appKey)
				end)
			end

			local placementIds = {}
			for et,pid in pairs(appinfo.placementIds) do
				placementIds[tonumber(et)] = pid
			end

			local channel = AdNode.new(name, conf.flag, conf.delegate, placementIds)
			self.channels[name] = channel

			self:print("channel:",name," create success!")
		end
	end
end

function InciteManager:isDebug()
	return false
end

function InciteManager:print( ... )
	if self:isShowPrint() then
		local t={...}
		printx(0,"InciteManager:", ...)
		RemoteDebug:uploadLogWithTag("AD_"..tostring(t[1]),...)
	end
end

function InciteManager:isEnabled()
	if __WIN32 then
		return true
	end

	if __IOS then
		local enable = MaintenanceManager:getInstance():isEnabled("IosVideoAdsFeature", false)
		if not enable then
			return false
		end

		local iosVideoAdsLowDevice = MaintenanceManager:getInstance():isEnabled("IosVideoAdsLowDevice", false)
		if not iosVideoAdsLowDevice and _G.__isLowDevice then
			return false
		end

		return true
	end

	if __ANDROID then
		return MaintenanceManager:getInstance():isEnabled("AndroidVideoAdsFeature", false)
	end
end

function InciteManager:syncInfo()
	self.info = UserManager:getInstance().videoSDKInfo

	if self.info and self.info.enableSceneUIMap then
		local r = {}
		for k,v in pairs(self.info.enableSceneUIMap) do
			r[tonumber(k)] = tonumber(v)
		end
		self.info.enableSceneUIMap = r
	end

	if _G.isLocalDevelopMode then
		self:print("enableSceneUIMap:", table.tostring(self.info and self.info.enableSceneUIMap))
	end

	if self.info and self:isEnabled() then
		if self:checkState() or self:checkCondition() then
			self:initSdk()
			if not self:canForcePop() then
				Notify:dispatch("AutoPopoutEventAwakenAction", IncitePanelPopoutAction)
			end
		else
			self:removeHomeBtn()
		end
	else
		self:removeHomeBtn()
	end
end

function InciteManager:getSceneUIVersion(entranceType)
	-- do return 3 end
	if self.info and self.info.enableSceneUIMap then
		return self.info.enableSceneUIMap[entranceType]
	end
	return -1
end

function InciteManager:removeHomeBtn()
	local scene = HomeScene:sharedInstance()
	if scene and scene.inciteVedioBtn then
		local btn = scene.inciteVedioBtn
		btn:removeFromParentAndCleanup(true)
		scene.inciteVedioBtn = nil
	end
	Notify:dispatch("AutoPopoutEventAwakenAction", IncitePanelPopoutAction)
end

function InciteManager:initSdk()
	if self.info then
		local function IsAdsSupport( ads_name )
			local channel = self.channels[ads_name]
			return channel and channel:isSupported()
		end

		self:createChannel()
		local enableSDKs = self:getEnableSDKs()
		local needRemoveIcon = true
		for _,sdk in ipairs(enableSDKs) do
			local ads_name = sdk.first
			self:print("try to init sdk:", ads_name, IsAdsSupport(ads_name))
			if IsAdsSupport(ads_name)  then
				needRemoveIcon = false
				local channel = self.channels[ads_name]
				if channel and not channel.isInit then
					channel:initSdk()
					DcUtil:adsIOSLoad({
						sub_category = "load_start",
						adver = sdk.first,
					})
				end
			end
		end

		if needRemoveIcon then
			self:removeHomeBtn()
		elseif not self.hasTryShowIcon then
			setTimeOut(function ( ... )
				self:tryShowIcon()
				self.hasTryShowIcon = true
			end, self:getIconShowTime())
		end
	end
end

--初始化条件
function InciteManager:checkCondition()
	if not self.info then return false end

	local hasRemaind = false
	for t=2,4 do
		local count = self:getCount(t)
		if count > 0 then
			hasRemaind = true
			break
		end
	end

	local enableScenes = self.info.enableScenes

	local enable = false
	for _,scene in ipairs(enableScenes) do
		for k,v in pairs(EntranceType) do
			if scene == v then
				enable = true
				break
			end
		end
	end

	if enable then
		DcUtil:adsIOSLoad({
							sub_category = "match_conditions",
						})
	end

	return hasRemaind and enable
end

function InciteManager:checkState()
	--剩余次数
	local hasRemaind = self.data.remaindTime > 0
	if hasRemaind then
		DcUtil:adsIOSLoad({
							sub_category = "lottery_start_ago",
						})
	end

	return hasRemaind
end

function InciteManager:saveState()
	self.data.remaindTime = self:getRemaindTime()
	self:writeLocalData()
end

function InciteManager:tryShowIcon()
	self:createEntranceBtn(EntranceType.kPassLevel, -2)

	local readySdkId = self:getReadySdk(nil, EntranceType.kPassLevel)
	Notify:dispatch("AutoPopoutEventAwakenAction", IncitePanelPopoutAction, readySdkId)
end

function InciteManager:getSdkPriority( name )
	local enableSDKs = self:getEnableSDKs()

	for priority,sdk in ipairs(enableSDKs) do
		if sdk.first == name then
			return priority
		end
	end
	return nil
end

function InciteManager:onAdsReady( name, placementId )
	self:print("onAdsReady :", name, placementId)
	DcUtil:adsIOSLoad( {
						sub_category = "load_end",
						adver = name,
					} )

	if self.panel then
		self.panel:refrash()
	end

	if not self.info then
		return
	end

	local showIcon = false

	local enableSDKs = self:getEnableSDKs()

	if #enableSDKs > 0 then
		if name == enableSDKs[1].first then
			showIcon = true
		end
	end

	if self.hasTryShowIcon or showIcon then
		self:tryShowIcon()
	end
end

function InciteManager:onAdsPlayed( name, placementId )
	self:print("onAdsPlayed :", name, placementId)
	DcUtil:adsIOSClick({
					sub_category = "sdk_vedio_start",
					entry = self.entranceType,
					adver = name,
					priority = self:getSdkPriority(name)
				})
end

function InciteManager:onAdsFinished( name, placementId, state )
	self:print("onAdsFinished :", name, placementId, state)

	if state == AdsFinishState.kNotCompleted then
		CommonTip:showTip("未观看完整，请重新观看", "negative")
	end

	if self.curPlayInfo then
		local info = self.curPlayInfo

		if name == info.sdk then
			if info.scb then
				info.scb(name, placementId, state)
			end
		end
	end

	if state == AdsFinishState.kCompleted or state == AdsFinishState.kNotCompleted then
		DcUtil:adsIOSClick({
			sub_category = "click_off",
			entry = self.entranceType,
			adver = name,
		})
	end

	self.curPlayInfo = nil
end

function InciteManager:onAdsError( name, code, msg )
	self:print("onAdsError :", name, code, msg)

	if self.curPlayInfo then
		local info = self.curPlayInfo

		if code == AdsError.kVideoNotReady then
			CommonTip:showTip("糟糕，暂时没有视频可看,请稍后尝试！", "negative")
		elseif code == AdsError.kPlayError then
			CommonTip:showTip("播放出错了，请重新观看", "negative")
		end

		if name == info.sdk then
			if info.fcb then
				info.fcb(name, code, msg)
			end
		end

		self.curPlayInfo = nil
	end

	self:notifyServerError(name)

	DcUtil:adsIOSLoad({
				sub_category = "ads_error",
				adver = name,
				code = code,
			})
end

function InciteManager:onAdsClicked( name )
	self:print("onAdsClicked :", name)
	DcUtil:adsIOSClick( {
					sub_category = "click_down",
					entry = self.entranceType,
					adver = name,
				} )
end

function InciteManager:canForcePop()
	if not self.isInit or not self.info then return false end

	local popNum = self.info.popNum
	local popSeq = self.info.popSeq
	local popEveryTime = self.info.popEveryTime

	local time = self:getRemaindTime() or 0
	local nextCd = self:getRewardCountdown()

	local can = ((popNum and self.data.popNum < popNum and 
		popSeq and popSeq > 0 and self.data.comeToFrontCount == popSeq) or
		popEveryTime) and time > 0 and nextCd <= 0

	return can
end

function InciteManager:tryPopoutIncitePanel( isClick, close_cb )
	if not self.isInit or not self.info then
		if close_cb then close_cb() end
		return
	end

	self.data.popNum = self.data.popNum + 1
	self.data.updateTime = Localhost:time()

	self:writeLocalData()
	self:showIncitePanel(EntranceType.kPassLevel, true)
	self.close_cb = close_cb
end

function InciteManager:onEnterFQA()
	if not self.isInit then return end
	self.entranceType = EntranceType.kFAQ
	local time = Localhost:timeInSec()

	self:syncInfo()
	self:createEntranceBtn(EntranceType.kFAQ)
end

function InciteManager:onEnterHomeScene()
	if not self.isInit then
		self:readLocalData()
	end

	self.data.comeToFrontCount = self.data.comeToFrontCount + 1
	self.data.updateTime = Localhost:time()

	self:writeLocalData()
end

function InciteManager:getDataPath()
	local path = HeResPathUtils:getUserDataPath() .. "/incite_"
	local uid = "0"
	if UserManager.getInstance().user then
		uid = UserManager.getInstance().user.uid or "0"
	end
	return path .. uid
end

function InciteManager:readLocalData()
	self.data = self.data or {}
	local path = self:getDataPath()
	local file = io.open(path, "r")
    if file then
        local content = file:read("*a") 
        file:close()
        if content then
            local _data = table.deserialize(content) or {}
            for k,v in pairs(_data) do
            	self.data[k] = v
            end
        end
    end

    self:initLocalData()
end

function InciteManager:initLocalData()
	self.data.updateTime = self.data.updateTime or 631123200000
	self.data.remaindTime = self.data.remaindTime or 0

	local time = Localhost:time()
	if compareDate(os.date('*t', math.floor(time / 1000)), os.date('*t',
		math.floor(self.data.updateTime / 1000))) ~= 0
	then
		self.data.comeToFrontCount = 0
		self.data.popNum = 0
		self.data.updateTime = time
	end
end

function InciteManager:writeLocalData()
	local path = self:getDataPath()
	local file = io.open(path,"w")
    if file then 
        file:write(table.serialize(self.data or {}))
        file:close()
    end

    if _G.isLocalDevelopMode then
    	local file = io.open(path..".DEBUG","w")
	    if file then 
	        file:write(table.tostring(self.data or {}))
	        file:close()
	    end
    end
end

function InciteManager:onPassLevel()
	--do nothing
end

function InciteManager:createHomeSceneBtn(time, ads)
	local scene = HomeScene:sharedInstance()

	if scene then
		local function createBtn()
			local btn = scene:createInciteVedioButton()
			if btn then
				btn:setRemaind(time)

				DcUtil:adsIOSLoad( {
					sub_category = "lottery_start",
					show_type = EntranceType.kPassLevel,
				} )
			end
		end

		if not scene.inciteVedioBtn then
			scene:runAction(CCCallFunc:create(createBtn))
		end
	end
end

function InciteManager:createFQABtn(time)
	local isUseNewFAQ = FAQ:useNewFAQ()

	if isUseNewFAQ then
		local function createBtn()
			local nextCd = InciteManager:getRewardCountdown()
        	local showAnimate = time > 0 and nextCd <= 0
			FAQManager:getInstance():showInciteVideoBtn_animate(time, showAnimate)
			self:handleFAQBtn()
			 
			DcUtil:adsIOSLoad( {
					sub_category = "lottery_start",
					show_type = EntranceType.kFAQ,
				} )
		end
		CCDirector:sharedDirector():getRunningScene():runAction(CCCallFunc:create(createBtn))
	else
		if not isUseNewFAQ then
			self:print("用的是旧版客服!")
		end
	end
end

function InciteManager:checkGroupTestType()
	-- local config = {
	-- 	["A1"] = {AdsTestGroupType.kOldUi},
	-- 	["A2"] = {AdsTestGroupType.kNewUi},

	-- 	["A3"] = {AdsTestGroupType.kOldUi, AdsTestGroupType.kStartLevel},
	-- 	["A4"] = {AdsTestGroupType.kNewUi, AdsTestGroupType.kStartLevel},

	-- 	["A5"] = {AdsTestGroupType.kOldUi, AdsTestGroupType.kTree},
	-- 	["A6"] = {AdsTestGroupType.kNewUi, AdsTestGroupType.kTree},

	-- 	["A7"] = {AdsTestGroupType.kOldUi, AdsTestGroupType.kStartLevel, AdsTestGroupType.kTree},
	-- 	["A8"] = {AdsTestGroupType.kNewUi, AdsTestGroupType.kStartLevel, AdsTestGroupType.kTree},
	-- }

	-- self.groups = {}
	-- local uid = UserManager:getInstance():getUID() or "12345"
	-- for name,c in pairs(config) do
	-- 	local enable = MaintenanceManager:getInstance():isEnabledInGroup("VideoAdTestGroup" , name, uid)
	-- 	if enable then
	-- 		for _,t in ipairs(c) do
	-- 			self.groups[t] = true
	-- 		end
	-- 	end
	-- end
end

-- function InciteManager:isGroupEnabled( groupType )
-- 	self.groups = self.groups or {}

-- 	if not self.info then return false end

-- 	local scenes = self.info.enableScenes
-- 	local index = table.indexOf(scenes, groupType)

-- 	if groupType == AdsTestGroupType.kOldUi then
-- 		index = table.indexOf(scenes, AdsTestGroupType.kNewUi)
-- 	end

-- 	self:print(table.tostring(self.groups))

-- 	return self.groups[groupType] and index
-- end

function InciteManager:isEntryEnable( entranceType )
	return InciteManager:getSceneUIVersion(entranceType) and InciteManager:getSceneUIVersion(entranceType)>0
	-- if et == EntranceType.kPassLevel then
	-- 	return self:isGroupEnabled(AdsTestGroupType.kNewUi) or self:isGroupEnabled(AdsTestGroupType.kOldUi)
	-- end

	-- return self:isGroupEnabled(et)
end

function InciteManager:isStartLevelOpen(items)
	if not items then return false end
	if not self.info then return false end
	if not self.info.prePropId then return false end

	local has = false
	for _,itemId in ipairs(items) do
		if itemId == self.info.prePropId then
			has = true break
		end
	end
	if not has then return false end
	return self:isEntryEnable(EntranceType.kStartLevel)
			and self:getReadySdk(nil, EntranceType.kStartLevel)
			and self:getCount(EntranceType.kStartLevel) > 0
end

function InciteManager:createEntranceBtn(entranceType, ads)
	if not self.isInit then
		return
	end

	local time = self:getRemaindTime()
	local readySdkId = self:getReadySdk(nil, entranceType)

	if time <= 0 or not readySdkId then
		self:print("time:", time, "readySdkId:",readySdkId)
		return
	end

	if self:isEntryEnable(EntranceType.kPassLevel) and entranceType == EntranceType.kPassLevel then
		self:createHomeSceneBtn(time, ads)
	elseif self:isEntryEnable(EntranceType.kFAQ) and entranceType == EntranceType.kFAQ then
		self:createFQABtn(time)
	else
		self:print("create btn failed, maintenance close this.")
	end
end

function InciteManager:handleFAQBtn( )
	local function update()
        local time = InciteManager:getRemaindTime() or 0
        local nextCd = InciteManager:getRewardCountdown()
        local showDot = time > 0 and nextCd <= 0
        FAQManager:getInstance():setInciteBtnDotVisible_time(showDot, time)
    end
    self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 20, false)
    update()
end

function InciteManager:onExitFAQ()
	if self.schedule then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
		self.schedule = nil
	end

	--self.entranceType = EntranceType.kPassLevel
end

function InciteManager:canDirectShowAd(entranceType, isAutoPop)
	local can = self.data.isPlayed 
				and not isAutoPop 
				and entranceType ~= EntranceType.kFAQ
				and self:getReadySdk(nil, entranceType)
				and self:getRemaindTime() > 0
				and self:getRewardCountdown() <= 0

	if self:isDebug() then
		return VideoAdUnitTest:canDirectShowAd(can)
	end

	-- return can and self:isEntryEnable(AdsTestGroupType.kNewUi)
	return can and self:isEntryEnable(EntranceType.kPassLevel)
end

function InciteManager:showIncitePanel(entranceType, isAutoPop)
	local version = self:getSceneUIVersion(EntranceType.kPassLevel)
	if not version then return end

	if self:isDebug() then
		VideoAdUnitTest:showTest()
	end
	local function popout()
		local version = self:getSceneUIVersion(EntranceType.kPassLevel)
		if version == 1 then
			self.panel = IncitePanel:create()
		elseif version >= 2 then
			self.panel = VideoAdPanel:create()
		else
			self:removeHomeBtn()
			return
		end
		
		self.panel:popout()

		-- if self:canDirectShowAd(entranceType, isAutoPop) then 
		-- 	self.panel:onTapBtn()
		-- end

		if entranceType == EntranceType.kFAQ then
			DcUtil:adsIOSClick( {
				sub_category = "click_forum",
			} )
		end

		DcUtil:adsIOSClick( {
				sub_category = "click_lottery",
				entry = entranceType,
			} )

		local data = 
				{
					sub_category = "show_reward",
					entry = entranceType,
				}

		local rewards = self:getRewardPool()
		for index,reward in ipairs(rewards) do
			data["reward_id"..index] = reward.itemId
		end
		DcUtil:adsIOSReward(data)
	end

	local function show()
		self.entranceType = entranceType
		CCDirector:sharedDirector():getRunningScene():runAction(CCCallFunc:create(popout))
	end

	PaymentNetworkCheck.getInstance():check(show, function ()
		CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
	end)

end

function InciteManager:notifyServerError(ads)
	--error notify server
	local http = InvokeVideoSDKErrorHttp.new()
	http:load(ads)
end

function InciteManager:getWhiteListSdk(isClick, entranceType)
	local enableSDKs = self:getEnableSDKs()
	local max = #enableSDKs
	
	if max <= 0 then return nil end

	if self.curWhiteSdkIndex == nil then 
		self.curWhiteSdkIndex = CCUserDefault:sharedUserDefault():getIntegerForKey("incite.video.white.list.index", 0)
	end

	local curIndex = self.curWhiteSdkIndex
	if isClick then
		curIndex = curIndex + 1
	end

	if curIndex > max or curIndex == 0 then curIndex = 1 end
	self.curWhiteSdkIndex = curIndex

	local ads_info = enableSDKs[curIndex]
	local ads_name = ads_info and ads_info.first

	for index=curIndex,max do
		local ads_info = enableSDKs[curIndex]
		if ads_info and self.channels[ads_info.first] then
			local ads_name = ads_info.first
			local isReady = self.channels[ads_name]:isReady(entranceType)
			if isReady then
				CCUserDefault:sharedUserDefault():setIntegerForKey("incite.video.white.list.index", curIndex)
				return ads_name
			else
				self:notifyServerError(ads_name)
			end
		end
	end

	return nil
end

function InciteManager:getReadySdk(isClick, entranceType)
	if not self.info then
		return nil
	end

	entranceType = entranceType or self.entranceType
	
	local enableSDKs = self.info.enableSDKs or {}
	local function less( p,n )
		return tonumber(p.second) < tonumber(n.second)
	end
	table.sort(enableSDKs, less)

	if self.info.inWhitelist then
		return self:getWhiteListSdk(isClick, entranceType)
	end

	for _,sdk in ipairs(enableSDKs) do
		local ads_name = sdk.first
		local isReady = false
		if self.channels[ads_name] then
			pcall(function ()
				isReady = self.channels[ads_name]:isReady(entranceType)
			end)
		end

		if isReady then
			if isClick then
				DcUtil:adsIOSClick({
					sub_category = "play_start",
					entry = entranceType,
					reture_code = 1,
					adver = ads_name,
				})
			end
			return ads_name
		else
			if isClick then
				DcUtil:adsIOSClick({
					sub_category = "play_start",
					entry = entranceType,
					reture_code = 2,
					adver = ads_name,
				})

				self:notifyServerError(ads_name)
			end
		end
	end

	if #enableSDKs == 0 then
		self:print("配置没有任何SDK开启！")
	end

	return nil
end

function InciteManager:showAds(entranceType, scb, fcb)
	self:print("InciteManager:showAds",entranceType, scb, fcb,debug.traceback())
	if self.curPlayInfo then
		self:print("[warring] pre play is not finsished!")
	end

	if entranceType then
		self.entranceType = entranceType
	end

	self.entranceType = self.entranceType or EntranceType.kPassLevel
	
	local readySdkId = self:getReadySdk(true, self.entranceType)

	DcUtil:adsIOSClick({
					sub_category = "click_play",
					entry = self.entranceType,
				})

	self.curPlayInfo = {
		entranceType = entranceType,
		scb = scb,
		fcb = fcb,
		sdk = readySdkId,
	}

	self.readyAd = readySdkId

	if readySdkId then
		PaymentNetworkCheck.getInstance():check(function ()
			self.channels[readySdkId]:play(self.entranceType)

			DcUtil:adsIOSClick({
					sub_category = "show_vedio_start",
					entry = self.entranceType,
					adver = readySdkId,
					priority = self:getSdkPriority(readySdkId)
				})

			local http = InvokeVideoSDKHttp.new()
			http:load(readySdkId)

			self.data.isPlayed = true
			self:writeLocalData()
		end, function ()
			CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
			self:onAdsError(readySdkId, AdsError.kNetError, "no network")
		end)
	else
		self:onAdsError(readySdkId, AdsError.kVideoNotReady, "no ad")
	end
end

function InciteManager:onCloseIncitePanel()
	if self.entranceType == EntranceType.kFAQ then
		--open FQA
		FAQ:openFAQClientIfLogin()
	end

	local scene = HomeScene:sharedInstance()
	local time = self:getRemaindTime()
	if scene and time and scene.inciteVedioBtn then
		local btn = scene.inciteVedioBtn
		if time > 0 then
			btn:setRemaind(time)
		else
			btn:removeFromParentAndCleanup(true)
			scene.inciteVedioBtn = nil
		end
	end

	self.panel = nil

	if self.close_cb then
		self.close_cb()
		self.close_cb = nil
	end
end

function InciteManager:addReward( reward )
	table.insert(self.info.gotRewardsToday, reward)
	self:saveState()
end

function InciteManager:getRemaindTime()
	if self.info and self.info.gotRewardsToday and self.info.timesLimit then
		return self.info.timesLimit - #self.info.gotRewardsToday
	end

	return 0
end

function InciteManager:getRewardConfig()
	if not self.info then
		return {}
	end
	return {
		timesLimit = self.info.timesLimit or 0,
		timesLimitSig = self.info.timesLimitSig or "",
	}
end

function InciteManager:refrashRewardTime( time )
	if self.info and time then
		self.info.nextRewardTime = time
	end
end

function InciteManager:refreshLastTime( time )
	if self.info and time then
		self.info.lastRewardTime = time
	end
end

function InciteManager:getRewardCountdown()
	if self.info and self.info.nextRewardTime then
		return math.floor(tonumber(self.info.nextRewardTime)/1000) - Localhost:timeInSec()
	end
	return 0
end

function InciteManager:getCountdownProg()
	if self.info and self.info.nextRewardTime and self.info.lastRewardTime then
		local last = tonumber(self.info.lastRewardTime)
		local nextt = tonumber(self.info.nextRewardTime)
		return (nextt - Localhost:time())/(nextt - last)
	end
	return 0
end

function InciteManager:getRewardPool()
	if self.info and self.info.rewardPoolToday then
		return self.info.rewardPoolToday
	end

	return {}
end

function InciteManager:getSerialLoginDaysLimit()
	if self.info and self.info.serialLoginDaysLimit then
		return self.info.serialLoginDaysLimit
	end

	return 7
end

--sdk初始化到主动尝试显示icon的时间
function InciteManager:getIconShowTime()
	if self.info and self.info.showTime then
		return self.info.showTime
	end

	return 60
end

function InciteManager:getEnableSDKs()
	if self.info then
		local enableSDKs = self.info.enableSDKs or {}
		local function less( p,n )
			return tonumber(p.second) < tonumber(n.second)
		end
		table.sort(enableSDKs, less)

		return enableSDKs
	end

	return {}
end

function InciteManager:getCount( groupType,param )
	if not self.info then return 0 end
	if groupType == EntranceType.kStartLevel then
		return self.info.prePropCount or 0
	elseif groupType == EntranceType.kTree then
		if param == true then
			return self.info.resetFruitCount or 0
		end
		return self.info.fruitCount or 0
	else
		--FAQ 和 passLevel 都是抽奖，公用一个数据
		return self:getRemaindTime()
	end
end

function InciteManager:subCount( groupType,param )
	if not self.info then return end
	if groupType == EntranceType.kStartLevel then
		self.info.prePropCount = self.info.prePropCount or 0
		if self.info.prePropCount > 0 then
			self.info.prePropCount = self.info.prePropCount - 1
		end
	elseif groupType == EntranceType.kTree then
		if param == true then
			self.info.resetFruitCount = math.max((self.info.resetFruitCount or 0)-1,0)
		else
			--获得一个免费视频果子时，重置免费视频重生次数
			self.info.resetFruitCount = 1
			self.info.fruitCount = math.max((self.info.fruitCount or 0)-1,0)
		end
	end
end

function InciteManager:hasVideoChance()
	local has = false
	for t=2,3 do
		local enable = self:isEntryEnable(t)
		local count = self:getCount(t)
		if enable and count > 0 then
			has = true
			break
		end
	end

	return has
end

function InciteManager:onEnterForground()
	if not self.isInit then return end
	if self.curPlayInfo then return end
	if not self:hasVideoChance() then return end

	for name,channel in pairs(self.channels or {}) do
		channel:onEnterForground()
	end
end

function InciteManager:tryLoadAd()
	if not self.isInit then return end
	for name,channel in pairs(self.channels or {}) do
		if channel.isInit then
			channel:tryLoadAd()
		end
	end
end