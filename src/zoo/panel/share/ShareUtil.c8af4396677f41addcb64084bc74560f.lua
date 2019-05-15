 
local ShareScene = table.const {
	Timeline = "1",
	Session = "2",
}

ShareUtil = { configs = {} }
ShareUtil.supportShareIds = {
	20,30,40,80,140,150,160,170,180,100000
}

local kConfigName = "shareConfig"

function ShareUtil:getPf( ... )
	if PlatformConfig:isQQPlatform() then
		return "yyb"
	end

	return PlatformConfig.name
end

function ShareUtil:filterConfigs( shareConfigs )
	local configs = {}
	for k,v in pairs(shareConfigs) do
		if v.pfs and string.len(v.pfs) > 0 then
			if v.pfs and table.exist(v.pfs:split(","),self:getPf()) or v.pfs == "default" then
				table.insert(configs,{
					shareId = tostring(v.shareId),
					hasReward = tostring(v.hasReward) == "true",
					shareUrl = tostring(v.shareUrl),
					shareScene = tostring(v.shareScene),
					isGetPage = tostring(v.isGetPage) == "true",--是否是微下载链接，需要特殊参数
					pfs = v.pfs, 
				})
			end
		end
	end
	return configs
end

function ShareUtil:loadLocalConfig( ... )
	self.configs = Localhost:readFromStorage(kConfigName)

	if self.configs == nil then
		self.configs = self:filterConfigs(MetaManager.getInstance().share_config)
	end
end

function ShareUtil:loadNetworkConfig( ... )
	if PrepackageUtil:isPreNoNetWork() then
		return
	end
	
	local function onCallback(response)
		if response.httpCode == 200 then
			
			local shareConfigsXML = xml.find(xml.eval(response.body), "share_config")
			local shareConfigs = {}
			for k,v in pairs(shareConfigsXML or {}) do
				if type(v) == "table" then
					table.insert(shareConfigs,v)
				end
			end

			if #shareConfigs > 0 then
				self.configs = self:filterConfigs(shareConfigs)
				Localhost:writeToStorage(self.configs, kConfigName)
			end	
		end
	end

	local configUrl = string.format("%s?name=share_config&uid=%s&_v=%s",NetworkConfig.maintenanceURL,tostring(UserManager.getInstance().uid),_G.bundleVersion)
	local request = HttpRequest:createGet(configUrl)
	local connection_timeout = 2
	if __WP8 then
		connection_timeout = 5
	end
	request:setConnectionTimeoutMs(connection_timeout * 1000)
	request:setTimeoutMs(30 * 1000)
	HttpClient:getInstance():sendRequest(onCallback, request)	
end

function ShareUtil:getConfig( shareId )
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		return nil
	end

	if not table.exist(self.supportShareIds,shareId) then
		return nil
	end

	for k,v in pairs(self.configs) do
		if v.shareId == tostring(shareId) and v.pfs ~= "default" then
			if not v.isGetPage then --当前版本不支持微下载传参，后面版本支持了再去掉
				return v
			end
		end
	end

	for k,v in pairs(self.configs) do
		if v.shareId == tostring(shareId) and v.pfs == "default" then
			if not v.isGetPage then --当前版本不支持微下载传参，后面版本支持了再去掉
				return v
			end
		end
	end

	return nil
end

function ShareUtil:hasReward( shareId )
	--禁用了分享奖励

	-- local config = self:getConfig(shareId)
	-- if not config then
	-- 	return false
	-- end

	-- if config.hasReward then
	-- 	-- 每天首次分享有奖励
	-- 	local dailyData = UserManager:getInstance():getDailyData()
	-- 	if not dailyData.showOffRewardFlag then
	-- 		return true
	-- 	end
	-- end

	return false 
end

-- function ShareUtil:receiveReward( successCallback,failCallback,cancelCallback )

-- 	local function onSuccess( evt )
-- 		local dailyData = UserManager:getInstance():getDailyData()
-- 		dailyData.showOffRewardFlag = true

-- 		local rewards = evt.data.rewardItems or {}
-- 		if __WIN32 then
-- 			rewards = {{itemId=ItemType.GOLD,num=1}}
-- 		end
-- 		UserManager:getInstance():addRewards(rewards, true)
-- 		UserService:getInstance():addRewards(rewards)
-- 		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kShow, rewards, DcSourceType.kShareCommon)

-- 		if #rewards > 0 then
-- 			local boxRes = Sprite:createWithSpriteFrameName("ShareRewardIconImage0000")
-- 			local anim = OpenBoxAnimation:create(rewards,boxRes.refCocosObj)
-- 			anim:setFinishCallback(function( ... )
-- 				if successCallback then
-- 					successCallback(rewards)
-- 				end				
-- 			end)
-- 			anim:play()
-- 		else
-- 			if successCallback then
-- 				successCallback(rewards)
-- 			end
-- 		end
-- 	end

-- 	local function onFail( evt )
-- 		CommonTip:showTip(
-- 			Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative",failCallback)
-- 	end

-- 	local function onCancel( ... )
-- 		if cancelCallback then
-- 			cancelCallback()
-- 		end
-- 	end

-- 	local http = GetUserCommonRewardsHttp.new(true)
-- 	http:addEventListener(Events.kComplete, onSuccess)
-- 	http:addEventListener(Events.kError, onFail)
-- 	http:addEventListener(Events.kCancel, onCancel)
-- 	http:load(23)
-- end

-- config: title,message,shareScene,thumb
function ShareUtil:share( config, shareSource,successCallback,failCallback,cancelCallback )
	local title,message,toTimeLine
	local thumb = config.thumb or CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	local shareUrl = config.shareUrl

	if config.shareScene == ShareScene.Timeline then --朋友圈
		title = config.message or ""
		message = ""
		toTimeLine = true
	else -- 点对点
		title = config.title or ""
		message = config.message or ""
		toTimeLine = false
	end

	local shareCallback = {
		onSuccess = function(result)
			if successCallback then
				successCallback()
			end
		end,
		onError = function(errCode, errMsg)
			if failCallback then
				failCallback(errCode, errMsg)
			end
		end,
		onCancel = function()
			if cancelCallback then
				cancelCallback()
			end
		end
	}
	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendLinkMessage( shareType, title, message, thumb, shareUrl, toTimeLine, shareCallback, shareSource)
end


function ShareUtil:toCallbacks( shareCallback,newSuccessCallback )
	local params = {}
	params[1] = shareCallback.onSuccess or function() end
	params[2] = shareCallback.onError or function() end
	params[3] = shareCallback.onCancel or function() end

	if newSuccessCallback then
		params[1] = newSuccessCallback
	end

	return unpack(params)
end

function ShareUtil:toShareUrl( shareUrl, params,isGetPage )
	if not string.starts(shareUrl,"http://") and
		not string.starts(shareUrl,"https://") then

		shareUrl = NetworkConfig:getShareHost() .. shareUrl
	end

	-- pid 必传
	if not params["pid"] then
		params["pid"] = tostring(PlatformConfig.name)
	end

	local p = {}
	for k,v in pairs(params) do
		table.insert(p,k.."="..HeDisplayUtil:urlEncode(v))
	end

	if #p == 0 then
		return shareUrl
	elseif string.find(shareUrl,"%?") then
		return shareUrl .."&".. table.concat(p,"&")
	else
		return shareUrl .."?".. table.concat(p,"&")
	end
end

function ShareUtil:toHeadUrl( url )
	if not url or url == "" then
		url = 0
	end
	
	if tonumber(url) ~= nil then
		if PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) then
			return 'http://static.manimal.happyelements.cn/hd/activity/businessCard/wandoujia_'..url..'.png'
		else
			return 'http://static.manimal.happyelements.cn/hd/activity/businessCard/'..url..'.png'
		end
	else
		return url
	end
end


function ShareUtil:shareByShareId( shareId,shareCallback,params,thumb,title,message, shareSource )
	local config = self:getConfig(shareId)
	if not config or not config.shareUrl then
		if shareCallback.onError then 
			shareCallback.onError()
		end
		return
	end

	config = table.merge(config,{})
	config.thumb = thumb
	config.title = title 
	config.message = message
	config.shareUrl = self:toShareUrl(config.shareUrl,params or {},config.isGetPage)

	if _G.isLocalDevelopMode then printx(0, table.tostring(config)) end

	if __WIN32 then
		--禁用了分享奖励
		-- self:receiveReward(self:toCallbacks(shareCallback))
		return 
	end

	--禁用了分享奖励
	-- if self:hasReward(shareId) then
	-- 	if config.shareScene == ShareScene.Timeline and not _G.__use_small_res then			
	-- 		local function onSuccess( ... )
	-- 			self:receiveReward(self:toCallbacks(shareCallback))
	-- 		end
	-- 		self:share(config, nil, self:toCallbacks(shareCallback,onSuccess))
	-- 	else
	-- 		local function onSuccess( rewards )
	-- 			self:share(config, nil, self:toCallbacks(shareCallback,function( ... )
	-- 				if shareCallback.onSuccess then
	-- 					shareCallback.onSuccess( rewards )
	-- 				end
	-- 			end))
	-- 		end
	-- 		self:receiveReward(self:toCallbacks(shareCallback,onSuccess))
	-- 	end
	-- else
		self:share(config, shareSource, self:toCallbacks(shareCallback))
	-- end
end


function ShareUtil:buildTestButton( homeScene )
	local counter = 0
	local subCount = 0
	homeScene:addTestButton("炫耀优化",function( ... )
		-- counter = counter + 1
		-- subCount = subCount + 1
		-- local config =  require "zoo.PersonalCenter.ObstacleIconConfig"
		-- local configCount = table.size(config)
		-- if counter == 1 then
			Achievement:set(AchiDataType.kLevelId,76)
			Achievement:set(AchiDataType.kAllScoreRank,100)
		-- 	-- ShareThousandOnePanel:create(10):popout()
			




		-- 	-- SharePyramidPanel:create(20):popout()
		-- 	-- ShareTrophyPanel:create(40):popout()
		-- 	-- ShareLastStepPanel:create(170):popout()
		-- 	-- AchievementManager:setData(AchievementManager.TOTAL_COIN_COST_NUM,100000000)
		-- 	-- ShareNWSliverConsumer:create(230):popout()
		-- 	-- AchievementManager:setData(AchievementManager.TOTAL_PICK_FRUIT_NUM,1000)
		-- 	-- ShareCollectedNFruit:create(240):popout()
			



			
			-- -- ShareTrophyPanel:create(40):popout()
			-- ShareFourStarPanel:create(80):popout()
			-- ShareNStarRewardPanel:create(90):popout()
			-- -- ShareFourStarPanel:create(15):popout()
			-- ShareThousandOnePanel:create(10):popout()
			-- -- Share5Time4StarPanel:create(70):popout()
			-- -- ShareHiddenLevelPanel:create(60):popout()
			-- -- ShareAreaFullStar:create(220):popout()

		-- 	-- SharePassFiveLevelPanel:create(150):popout()
		-- 	-- ShareFinalPassLevelPanel:create(160):popout()		
		-- 	ShareLeftTenStepPanel:create(180):popout()
		-- 	-- ShareFirstInFriendsPanel:create(30):popout()
		-- 	-- ShareChestPanel:create(140):popout()
		-- 	local config =  require "zoo.PersonalCenter.ObstacleIconConfig"
		-- 	for k, v in pairs(config) do
		-- 		Achievement:set(AchiDataType.kLevelId,k)
		-- 		Achievement:set(AchiDataType.kAllScoreRank,100)
		-- 		ShareUnlockNewObstaclePanel:create(50):popout()
		-- 	end


		-- 	-- local surpassFriends = FriendManager:getInstance().friends or {}
		-- 	-- local panel = SeasonWeeklyRacePassPanel:create(surpassFriends)
		-- 	-- PopoutQueue:push(panel)

		-- 	local function delayFunc()
		--     	Achievement:set(AchiDataType.kScoreOverFriendTable,FriendManager:getInstance().friends or {})
		-- 		SharePassFriendPanel:create(110):popout()
		-- 	end
		-- 	setTimeOut(delayFunc, 2)
		-- elseif counter == 2 then
		-- 	Achievement:set(AchiDataType.kLevelOverFriendTable,FriendManager:getInstance().friends or {})
		-- 	SharePassFriendPanel:create(120):popout()

		-- elseif counter == 3 then
	    -- 	-- AchievementManager:setData(AchievementManager.SCORE_OVER_NATION_RESULT,1)
	    -- 	-- AchievementManager:setData(AchievementManager.SCORE_OVER_FRIEND_TABLE,FriendManager:getInstance().friends or {})
	    -- 	-- SharePassFriendPanel:create(250):popout()
	    -- elseif counter == 4 then

	    -- 	-- AchievementManager:setData(AchievementManager.LEVEL_OVER_NATION_RESULT,1)
	    -- 	-- AchievementManager:setData(AchievementManager.LEVEL_OVER_FRIEND_TABLE,FriendManager:getInstance().friends or {})
	    -- 	-- SharePassFriendPanel:create(260):popout()

	    -- 	require "zoo.panel.seasonWeekly.SeasonWeeklyRacePassPanel"
	    -- 	if subCount % 2 == 0 then 
		-- 		local panel = SeasonWeeklyRacePassPanel:create({uid = 1})
		-- 		panel:popout(onShareFinished)
		-- 	else
		-- 		local panel = SeasonWeeklyRacePassPanel:create(nil, subCount % 4 + 1)
		-- 		panel:popout(onShareFinished)
		-- 	end
	    -- elseif counter >= 5 and counter <= configCount + 5 then
	    -- 	local i = 5
	    -- 	for k, v in pairs(config) do
	    -- 		if i == counter then
		-- 			Achievement:set(AchiDataType.kLevelId,k)
		-- 			Achievement:set(AchiDataType.kAllScoreRank,100)
		-- 			ShareUnlockNewObstaclePanel:create(50):popout()
		-- 		end
		-- 		i = i + 1
		-- 	end
	    -- else
	    -- 	counter = 0
		-- end
		
		require "zoo.panel.share.sharePanelVerB.SharePanel_B"
		do
			__tempTestIndex = __tempTestIndex or 1
			if(__tempTestIndex>4) then __tempTestIndex = __tempTestIndex % 4 end
			local panels = {30, 150, 160, 180}
			SharePanel_B:create(panels[__tempTestIndex]):popout()
			__tempTestIndex = __tempTestIndex + 1
		end
		-- SharePanel_B:create(30):popout()
		-- SharePanel_B:create(150):popout()
	    -- SharePanel_B:create(160):popout()
		-- SharePanel_B:create(180):popout()
	end, true)
	-- homeScene:addTestButton("假装截屏",function (...) GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kUserTakeScreenShot)) end)
end

function ShareUtil:getQRCodePath()
	local pathPre = "share/share_background_2d"
	if __use_small_res then 
		pathPre = "share/share_background_2d_small"
	end
	if WXJPPackageUtil.getInstance():isWXJPPackage() then 
		pathPre = pathPre .. "_wxjp"
	elseif PlatformConfig:isPlatform(PlatformNameEnum.kUC) then 
		pathPre = pathPre .. "_uc"
	end
	return pathPre..".png"
end

function ShareUtil:saveShareImgToLocal(url, finishCallback)
	local pathPre = HeResPathUtils:getResCachePath()
	if __ANDROID then
		pathPre = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
	end
	if not pathPre then
		assert(false, "no external storage~") 
		return 
	end 

	local function onCallBack(data, imgName)        
        local sprite = Sprite:create(data.realPath)
        sprite:setAnchorPoint(ccp(0, 0))
        local size = sprite:getContentSize()
        local filePath 
        if imgName then 
        	filePath = pathPre .. "/"..imgName..".png"
        else
        	filePath = pathPre .. "/"..os.time()..".jpg"
        end
		local renderTexture = CCRenderTexture:create(size.width, size.height)
		renderTexture:begin()
		sprite:visit()
		renderTexture:endToLua()
		renderTexture:saveToFile(filePath)
  		if finishCallback then finishCallback(filePath) end 
    end

	if string.sub(url, 1, 7) == "https:/" or string.sub(url, 1, 6) == "http:/" then 
	    ResUtils:getResFromUrls({url}, onCallBack)
	else
		local data = {}
		data.realPath = url
		onCallBack(data, "ani_img")
	end
end