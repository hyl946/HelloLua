require "zoo.net.Http" 
-------------------------------------------------------------------------
--  Class include: GetStarRewardsHttp, UnLockLevelAreaHttp, MarkHttp, SellPropsHttp, BuyHttp, 
--		GetLadyBugRewards, GetInviteFriendsReward, UpdateUserGuideStep, ConfirmInvite
-------------------------------------------------------------------------

--
-- GetStarRewardsHttp ---------------------------------------------------------
--
GetStarRewardsHttp = class(HttpBase)
function GetStarRewardsHttp:load(rewardId, ...)
	assert(type(rewardId) == "number")
	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endPoint, data, err)
		if err then
			he_log_info("get reward fail, err: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("get reward success")
			if type(data) == "table" and type(data.rewardItems) == "table" then
				UserManager:getInstance():addRewards(data.rewardItems)
				UserService:getInstance():addRewards(data.rewardItems)
				GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kStarAndLevel, data.rewardItems, DcSourceType.kStarBoardReward)
				if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
				else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getStarRewards, {starRewardId = rewardId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- StartLadyBugTask ---------------------------------------------------------
--
StartLadyBugTask = class(HttpBase)
function StartLadyBugTask:load(...)
	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("start lady bug task error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("start lady bug task success !")
			UserService:getInstance().ladyBugInfos = {}
			for k,v in ipairs(data.ladyBugInfos) do
				local info = LadyBugInfoRef.new()
				info:fromLua(v)
				UserService:getInstance().ladyBugInfos[k] = info
			end
			UserManager:getInstance().ladyBugInfos = {}
			for k,v in ipairs(data.ladyBugInfos) do
				local info = LadyBugInfoRef.new()
				info:fromLua(v)
				UserManager:getInstance().ladyBugInfos[k] = info
			end
			-- context:onLoadingComplete(data.metaClient)
			-- fix
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.startLadyBugTask, nil, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- UnLockLevelAreaHttp ---------------------------------------------------------
--
UnLockLevelAreaHttp = class(HttpBase) 

--  <request>
--	  <property code="type" type="type" desc="è§£é”ç±»åž‹,1: æ˜Ÿæ˜Ÿï¼Œ2ï¼šé‡‘è±†ï¼Œ3: å¥½å‹è¯·æ±‚, 4:å·²æœ‰è¶³å¤Ÿå¥½å‹å¸®åŠ©ï¼ŒçŽ©å®¶è§£é”" />
--	  <list code="friendUids" ref="long" desc="å¥½å‹è¯·æ±‚çš„ å¥½å‹id" />
--  </request>
function UnLockLevelAreaHttp:load(unlockType, friendUids , npcNumber , snsName, wxNotify)
	assert(unlockType ~= nil, "unlockType must not a nil")
	assert(type(friendUids) == "table", "friendUids not a table")
	
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("unLockLevelArea fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("unLockLevelArea success")
	    	if data and data.user then
	    		local topLevelID = data.user.topLevelId --only sync top level. we need to sync other data by sync htt[]
	    		UserManager.getInstance().user:setTopLevelId(topLevelID) --local 
	    		UserService.getInstance().user:setTopLevelId(topLevelID) --server

	    		UserManager:getInstance().userExtend:resetTopLevelFailCount()
				UserService:getInstance().userExtend:resetTopLevelFailCount()
				UserTagManager:onTopLevelChanged()

	    		DcUtil:logLevelUp(topLevelID)

	    		--UserManager.getInstance():syncUserFromLua(data.user)
	    		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
				else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
	    	end

	    	context:onLoadingComplete()
	    end
	end

	local selfUser = UserService:getInstance():getUserRef()
	local meta = MetaManager:getInstance():getNextLevelAreaRefByLevelId(selfUser:getTopLevelId())
	if--[[ selfUser:getTopLevelId() == 15 and]] unlockType == 1 then
		local star = selfUser:getTotalStar()
		--在发起http之前 已经判断过星星数了
		-- if meta and meta.star and star >= meta.star then
			local level = UserService:getInstance().user:getTopLevelId()
			loadCallback(kHttpEndPoints.unLockLevelArea, {user = {topLevelId = level + 1}})
			UserService.getInstance():cacheHttp(kHttpEndPoints.unLockLevelArea, {type=unlockType, friendUids=friendUids, areaId=meta.id})

			UserManager:getInstance().userExtend:resetTopLevelFailCount()
			UserService:getInstance().userExtend:resetTopLevelFailCount()
			UserTagManager:onTopLevelChanged()

			if NetworkConfig.writeLocalDataStorage then 
				Localhost:getInstance():flushCurrentUserData()
			else 
				if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
			end
		-- else
		-- 	UserManager:getInstance().userExtend:resetTopLevelFailCount()
		-- 	UserService:getInstance().userExtend:resetTopLevelFailCount()
			
		-- 	loadCallback(kHttpEndPoints.unLockLevelArea, {}, 0)
		-- end
	elseif unlockType == 6 then     --推送召回活动 任务关卡解锁
		local level = UserService:getInstance().user:getTopLevelId()
		loadCallback(kHttpEndPoints.unLockLevelArea, {user = {topLevelId = level + 1}})
		UserService.getInstance():cacheHttp(kHttpEndPoints.unLockLevelArea, {type=unlockType, friendUids=friendUids, areaId=meta.id})

		UserManager:getInstance().userExtend:resetTopLevelFailCount()
		UserService:getInstance().userExtend:resetTopLevelFailCount()
		UserTagManager:onTopLevelChanged()

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
	else
		if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
		local areaId = 0
		if meta then areaId = meta.id end
		self.transponder:call(kHttpEndPoints.unLockLevelArea, {type=unlockType, friendUids=friendUids, areaId=areaId , npcNumber = npcNumber , snsName = snsName, wxNotify = wxNotify}, loadCallback, rpc.SendingPriority.kHigh, false)
	end
end

--
-- MarkHttp ---------------------------------------------------------
--
MarkHttp = class(HttpBase)
function MarkHttp:load()
	local context = self
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local function updateUserMark()
		local markNum = UserManager.getInstance().mark.markNum or 0
		UserManager.getInstance().mark.markNum = markNum + 1
		UserManager.getInstance().mark.markTime = Localhost:time()

		Localhost:mark() --sync online data
	end 	
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("mark fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("mark success")
	    	updateUserMark()

	    	Notify:dispatch("AchiEventDataUpdate",AchiDataType.kMarkAddCount, 1)

	    	context:onLoadingComplete()

	    	if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.ONLINE_SETTER)
				triggerContext:addValue( kHttpEndPoints.mark , {data = data} )
				MissionManager:getInstance():checkAll(triggerContext)
			end
	    end
	end
	self.transponder:call(kHttpEndPoints.mark, nil, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- SellPropsHttp ---------------------------------------------------------
--
SellPropsHttp = class(HttpBase) --å–å‡ºé“å…·

--  <request>
--	  <property code="itemID" type="int" desc="é“å…·id" />
--	  <property code="num" type="int" desc="é“å…·æ•°é‡" />
--  </request>
function SellPropsHttp:load(itemID, num)
	assert(itemID ~= nil, "itemID must not a nil")
	assert(num ~= nil, "num must not a nil")
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("sellProps fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("sellProps success")
	    	context:onLoadingComplete()
	    	Localhost:sellProps(itemID, num) --used only for sync data
	    	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
	    end
	end

	self.transponder:call(kHttpEndPoints.sellProps, {itemID=itemID, num=num}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- BuyHttp ---------------------------------------------------------
--
BuyHttp = class(HttpBase)
function BuyHttp:load(goodsId , num , moneyType, targetId)
	assert(goodsId ~= nil, "goodsId type is int")
	assert(num ~= nil, "num type is int")
    assert(moneyType ~= nil, "moneyType type is int")
    assert(targetId ~= nil, "targetId type is int")
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("buy goods fail, err: " .. err)
	    	context:onLoadingError(err)
	    	return true
	    else
	    	if goodsId == 15 then
	    		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kMarkAddCount, 1)
	    	end
	    	he_log_info("buy goods success")
	    	local meta = MetaManager:getInstance():getGoodMeta(goodsId)
	    	if meta and meta.limit > 0 then
	    		UserService.getInstance():addBuyedGoods(goodsId, num)
	    	end
	    	context:onLoadingComplete()
	    	
	    	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			return true
	    end
	end

	if moneyType == 1 then -- silver
		local user = UserService:getInstance().user
		local meta = MetaManager:getInstance():getGoodMeta(goodsId)
		if user and meta then
			if user:getCoin() >= meta.coin then
		    	local succeed, err = Localhost.getInstance():buy(goodsId , num , moneyType , targetId)
				if succeed then
					UserService.getInstance():cacheHttp(kHttpEndPoints.buy, {goodsId=goodsId , num=num , moneyType=moneyType , targetId=targetId})
					if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
					else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.1") end end
				end
				loadCallback(kHttpEndPoints.buy, {}, err)
			else
				loadCallback(kHttpEndPoints.buy, {}, 730321)
			end
		else
			loadCallback(kHttpEndPoints.buy, {}, 211)
		end
	else
		if NetworkConfig.useLocalServer and (__ANDROID or __WP8 or __WIN32 or __IOS) then 
			local user = UserService:getInstance().user
			local meta = MetaManager:getInstance():getGoodMeta(goodsId)
			if user and meta then
				local finalCash = meta.qCash
				if meta.discountQCash and meta.discountQCash ~=0 then 
					finalCash = meta.discountQCash
				end
				if user:getCash() >= finalCash then
		    		local succeed, err = Localhost.getInstance():buy(goodsId , num , moneyType , targetId)
		    		if succeed then
						UserService.getInstance():cacheHttp(kHttpEndPoints.buy, {goodsId=goodsId, num=num, moneyType=moneyType, targetId=targetId, requestTime=Localhost:time()})
						if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
						else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.2") end end
					end
					loadCallback(kHttpEndPoints.buy, {}, err)
				else
					loadCallback(kHttpEndPoints.buy, {}, 730330)
				end
			else
				loadCallback(kHttpEndPoints.buy, {}, 211)
			end
		else
			local onlineLoadCallback = function(endpoint, data, err)
				if err then
			    	he_log_info("buy goods fail, err: " .. err)
			    	context:onLoadingError(err)
			    	return true
			    else
			    	Localhost.getInstance():buy(goodsId , num , moneyType , targetId) --sync local server
			    	if goodsId == 15 then
			    		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kMarkAddCount, 1)
			    	end
			    	he_log_info("buy goods success")
			    	local meta = MetaManager:getInstance():getGoodMeta(goodsId)
			    	if meta and meta.limit > 0 then
			    		UserService.getInstance():addBuyedGoods(goodsId, num)
			    	end
			    	context:onLoadingComplete()
			    	
			    	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
					else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

					return true
			    end
			end
			if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
			self.transponder:call(kHttpEndPoints.buy, {goodsId=goodsId , num=num , moneyType=moneyType , targetId=targetId}, onlineLoadCallback, rpc.SendingPriority.kHigh, false)
		end
	end
end

BuyHttpOnline = class(HttpBase)
function BuyHttpOnline:load(goodsId , num , moneyType, targetId)
	assert(goodsId ~= nil, "goodsId type is int")
	assert(num ~= nil, "num type is int")
    assert(moneyType ~= nil, "moneyType type is int")
    assert(targetId ~= nil, "targetId type is int")
    assert(moneyType ~= 1, "moneyType is not 1")

	local context = self

	local onlineLoadCallback = function(endpoint, data, err)
		if err then
			he_log_info("buy goods fail, err: " .. err)
			context:onLoadingError(err)
			return true
		else
			Localhost.getInstance():buy(goodsId , num , moneyType , targetId) --sync local server
			if goodsId == 15 then
			    Notify:dispatch("AchiEventDataUpdate",AchiDataType.kMarkAddCount, 1)
			end
			he_log_info("buy goods success")
			local meta = MetaManager:getInstance():getGoodMeta(goodsId)
			if meta and meta.limit > 0 then
			    UserService.getInstance():addBuyedGoods(goodsId, num)
			end
			context:onLoadingComplete()
			    	
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			return true
		end
	end
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	self.transponder:call(kHttpEndPoints.buy, {goodsId=goodsId , num=num , moneyType=moneyType , targetId=targetId}, onlineLoadCallback, rpc.SendingPriority.kHigh, false)
end


--
-- GetLadyBugRewards ---------------------------------------------------------
--
GetLadyBugRewards = class(HttpBase)
function GetLadyBugRewards:load(taskId, ...)
	assert(type(taskId) == "number")
	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)

		if err then
			he_log_info("get lady bug reward taskId:" .. taskId .. " error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("getlady bug reward taskId:" .. taskId .. " success !")
			if _G.isLocalDevelopMode then printx(0, table.tostring(data)) end
			
			local rewards = data.rewardItems or {}
			UserManager:getInstance():addRewards(rewards)
    		UserService:getInstance():addRewards(rewards)
    		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kLadyBug, rewards, DcSourceType.kLadybugReward)
    		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			context:onLoadingComplete(data.metaClient)
		end
	end

	self.transponder:call(kHttpEndPoints.getLadyBugRewards, {id = taskId}, loadCallback, rpc.SendingPriority.kHigh, false)
end


NewGetLadyBugRewards = class(HttpBase)
function NewGetLadyBugRewards:load(taskId, type, ...)
	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)

		if err then
			context:onLoadingError(err)
		else
			local rewards = data.rewardItems or {}
			UserManager:getInstance():addRewards(rewards)
    		UserService:getInstance():addRewards(rewards)
    		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kLadyBug, rewards, DcSourceType.kLadybugReward)
    		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getLadyBugRewards, {id = taskId, type = type}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- GetInviteFriendsReward ---------------------------------------------------------
--
GetInviteFriendsReward = class(HttpBase)
function GetInviteFriendsReward:load(friendId, rewardId, ...)
	assert(type(friendId) == "string")
	--assert(type(rewardId) == "number")
	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("get invite friends reward error: " .. err)
			context:onLoadingError(err)
		else
			if _G.isLocalDevelopMode then printx(0, "GetInviteFriendsReward Success Called !") end

	  		local rewards
	  		if rewardId then
	  			rewards = MetaManager.getInstance():inviteReward_getInviteRewardMetaById(rewardId).rewards or {}
	  		else 
	  			rewards = data.rewardItems or {}
	  		end 
	  		UserManager:getInstance():addRewards(rewards)
	    	UserService:getInstance():addRewards(rewards)
	    	GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kFriend, rewards, DcSourceType.kInviteRewardA)

			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			he_log_info("get invite friends reward success !")
			context:onLoadingComplete()
		end
	end

	self.transponder:call(kHttpEndPoints.getInviteFriendsReward, {friendUid = friendId, rewardId = rewardId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetUserGuideStep		这个暂时不再使用了
-- 
UpdateUserGuideStep = class(HttpBase)
function UpdateUserGuideStep:load(guideType, guideStep, ...)
	assert(type(guideType) == "number")
	assert(type(guideStep) == "number")
	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("" .. err)
			context:onLoadingError(err)
		else
			he_log_info("")
			if guideType == 0 then
				UserManager:getInstance().userExtend.tutorialStep = guideStep
				UserService:getInstance().userExtend.tutorialStep = guideStep

				if _G.isLocalDevelopMode then printx(0, "HTTP", UserManager:getInstance().userExtend.tutorialStep) end
				if _G.isLocalDevelopMode then printx(0, "HTTP", UserService:getInstance().userExtend.tutorialStep) end
				context:onLoadingComplete()
			elseif guideType == 1 then
				UserManager:getInstance().userExtend.playStep = guideStep
				UserService:getInstance().userExtend.playStep = guideStep
				context:onLoadingComplete()
			end
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write userExtend data to the device.") end end
			if _G.isLocalDevelopMode then printx(0, UserService:getInstance().userExtend.tutorialStep, UserService:getInstance().userExtend.playStep) end
			if _G.isLocalDevelopMode then printx(0, "write to file complete") end
		end
	end

	self.transponder:call(kHttpEndPoints.updateUserGuideStep, {type = guideType, step = guideStep}, loadCallback, rpc.SendingPriority.kHigh, false)
end


--
-- RewardMetalHttp ---------------------------------------------------------
--
RewardMetalHttp = class(HttpBase)

function RewardMetalHttp:load( shareID )
	local result = false
	local metals = UserService.getInstance().metals
	if metals then
		local shareKey = tostring(shareID)
		if metals[shareKey] == nil then
			metals[shareKey] = 1
			result = true
		end
	end
	
	local gamecenterID = kShareConfig[tostring(shareID)]
	if _G.isLocalDevelopMode then printx(0, "gamecenterID:", gamecenterID) end
	if gamecenterID then GameCenterSDK:getInstance():submitAchievement(gamecenterID.gamecenter, 100) end
	--todo: add server implements
	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
	else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
	return result
end

-- 
-- UpdateProfileHttp
-- 
UpdateProfileHttp = class(HttpBase)
function UpdateProfileHttp:load(name, headUrl, snsPlatform, snsName, customProfile)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("UpdateProfileHttp err" .. err)
			context:onLoadingError(err)
		else
			he_log_info("UpdateProfileHttp ok")
			context:onLoadingComplete(data)
		end
	end

	if customProfile then
		UserManager:getInstance().profile.customProfile = customProfile 
	end

	local birthDate = UserManager:getInstance().profile.birthDate
	local location = UserManager:getInstance().profile.location
	local constellation = UserManager:getInstance().profile.constellation
	local age = UserManager:getInstance().profile.age
	local gender = UserManager:getInstance().profile.gender
	local secret = UserManager:getInstance().profile.secret
	local fileId = UserManager:getInstance().profile.fileId

	UserService:getInstance().profile.name = UserManager:getInstance().profile.name
	UserService:getInstance().profile.headUrl = UserManager:getInstance().profile.headUrl
	if _G.isLocalDevelopMode then printx(0, "profile change", UserService:getInstance().profile.name) end
	UserService:getInstance().profile.snsMap = UserManager:getInstance().profile.snsMap
	UserService:getInstance().profile.constellation = constellation
	UserService:getInstance().profile.location = location
	UserService:getInstance().profile.birthDate = birthDate
	UserService:getInstance().profile.age = age
	UserService:getInstance().profile.gender = gender
	UserService:getInstance().profile.secret = secret
	UserService:getInstance().profile.fileId = fileId
	UserService:getInstance().profile.customProfile = customProfile


	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
	else if _G.isLocalDevelopMode then printx(0, "Did not write data to the device.") end end
	
	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kProfileUpdate))

	local dataTable = {
						name = name,
						headUrl = headUrl,
						snsPlatform = snsPlatform,
						snsName = snsName,
						constellation = constellation,
						birthDate = birthDate,
						location = location,
						age = age,
						gender = gender,
						secret = secret,
						fileId = fileId,
						customProfile = customProfile
					  }

	self.transponder:call(kHttpEndPoints.updateProfile, dataTable, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- ConfirmInvite
-- 
ConfirmInvite = class(HttpBase)
function ConfirmInvite:load(inviteCode, srcType)
	assert(type(inviteCode) == "number")
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("confirm invite fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("confirm invite success")
		    local meta = MetaManager:getInstance():getEnterInviteCodeReward()
		    local service = UserService:getInstance()
		    local user = service.user
		    for i = 1, 2 do
		    	if meta[i].itemId == 2 then
		    		local money = user:getCoin()
					money = money + meta[i].num
					user:setCoin(money)
		    	else
		    		service:addUserPropNumber(meta[i].itemId, meta[i].num)
		    	end
		    end
		    if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			
			context:onLoadingComplete(data)
	    end
	end

	self.transponder:call(kHttpEndPoints.confirmInvite, {inviteCode = inviteCode, type = srcType}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetInviteeReward for WanDouJia platform ---------------------------------------------------------
-- 
GetInviteeRewardHttp = class(HttpBase)
function GetInviteeRewardHttp:load(inviters)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	if not inviters or type(inviters) ~= 'table' then 
		return
	end

	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetInviteeReward error: " .. err)
			self:onLoadingError(err)
		else  
			he_log_info("GetInviteeReward success !")
			self:onLoadingComplete(data)
		end
	end
	local params = {inviters = inviters}
	if __ANDROID and _G.sns_token then
		params.snsPlatform = PlatformConfig:getPlatformAuthName()
	end
	self.transponder:call(kHttpEndPoints.getInviteeReward, params, loadCallback, rpc.SendingPriority.kHigh, false)

end

-- 
-- InviteFriendsHttp ---------------------------------------------------------
-- 
InviteFriendsHttp = class(HttpBase)
function InviteFriendsHttp:load(uids)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	if not uids or type(uids) ~= 'table' then 
		return
	end

	if _G.isLocalDevelopMode then printx(0, "InviteFriendsHttp:uids="..table.tostring(uids)) end

	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("InviteFriends error: " .. err)
			self:onLoadingError(err)
		else  
			he_log_info("InviteFriends success !")
			-- TODO, record sended today, and filter them
			self:onLoadingComplete(data)
		end
	end
	local params = {}
	if __IOS_FB then -- snsIds<string>
		params.snsIds = uids
	else
		params.friendUids = uids
	end
	self.transponder:call(kHttpEndPoints.inviteFriends, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- SendFreegift ---------------------------------------------------------
-- 
SendFreegiftHttp = class(HttpBase)
function SendFreegiftHttp:load(sendType, messageId, targetUids, itemId, wxNotify)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("SendFreegiftHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("SendFreegiftHttp success !")
			if sendType == 2 and not __IOS_FB then -- facebook不送免费礼物
				local tab = UserManager:getInstance():getWantIds()
				if #tab < 1 then
					UserManager:getInstance():addUserPropNumber(ItemType.MIDDLE_ENERGY_BOTTLE, 1)
					UserService:getInstance():addUserPropNumber(ItemType.MIDDLE_ENERGY_BOTTLE, 1)
					GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kMessageCenter, ItemType.MIDDLE_ENERGY_BOTTLE, 1, DcSourceType.kAskFreeGift)
				end
			end
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			if sendType == RequestType.kReceiveFreeGift and itemId == 10012 then
				Notify:dispatch("AchiEventDataUpdate",AchiDataType.kSendPrimaryEnergyAddCount, 1)
			elseif sendType == RequestType.kPassMaxNormalLevel then
				Notify:dispatch("AchiEventDataUpdate",AchiDataType.kSendLikeAddCount, 1)
			end
			context:onLoadingComplete(data)
		end
	end
	local sendee = {messageId = messageId, receiverUids = targetUids, itemId = itemId}
	sendee.type = sendType
	sendee.wxNotify = wxNotify
	sendee.disableFirstAskReward = true
	self.transponder:call(kHttpEndPoints.sendFreegift, sendee, loadCallback, rpc.SendingPriority.kHigh, false)
end

function SendFreegiftHttp:load2(sendType, messageIds, targetUids, itemId, wxNotify)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("SendFreegiftHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("SendFreegiftHttp success !")
			if sendType == 2 and not __IOS_FB then -- facebook不送免费礼物
				local tab = UserManager:getInstance():getWantIds()
				if #tab < 1 then
					UserManager:getInstance():addUserPropNumber(ItemType.MIDDLE_ENERGY_BOTTLE, 1)
					UserService:getInstance():addUserPropNumber(ItemType.MIDDLE_ENERGY_BOTTLE, 1)
					GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kMessageCenter, ItemType.MIDDLE_ENERGY_BOTTLE, 1, DcSourceType.kAskFreeGift)
				end
			end
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			if sendType == RequestType.kReceiveFreeGift and itemId == 10012 then
				Notify:dispatch("AchiEventDataUpdate",AchiDataType.kSendPrimaryEnergyAddCount, 1)
			elseif sendType == RequestType.kPassMaxNormalLevel then
				Notify:dispatch("AchiEventDataUpdate",AchiDataType.kSendLikeAddCount, 1)
			end
			context:onLoadingComplete(data)
		end
	end
	local sendee = {messageIds = messageIds, receiverUids = targetUids, itemId = itemId}
	sendee.type = sendType
	sendee.wxNotify = wxNotify
	sendee.disableFirstAskReward = true
	self.transponder:call(kHttpEndPoints.sendFreegift, sendee, loadCallback, rpc.SendingPriority.kHigh, false)
end

WXJPServerShare = class(HttpBase)
function WXJPServerShare:load(targetUids, itemId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	local data = {
		tradeId = tradeId,
		verifyCode = verifyCode
	}
	local data = {receiverUids = targetUids, itemId = itemId}
	self.transponder:call(kHttpEndPoints.wxjpServerShare, data, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- AcceptFreegift
-- 
AcceptFreegiftHttp = class(HttpBase)
function AcceptFreegiftHttp:load(messageId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("accept freegift fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	local message = FreegiftManager:sharedInstance():getMessageById(messageId)
	    	if not message then 
	    		he_log_info("no message matching messageId:" .. messageId)
	    		context:onLoadingError()
	    		return
	    	end
	    	UserService:getInstance():addUserPropNumber(message.itemId, message.itemNum)
		    if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			
			context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.acceptFreegift, {id = messageId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetExchangeCodeReward---------------------------------------------------------
-- 
GetExchangeCodeRewardHttp = class(HttpBase)
function GetExchangeCodeRewardHttp:load(code,mt)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("IgnoreFreegiftHttp error: " .. err)
			context:onLoadingError(err)
		else
			UserManager:getInstance():addRewards(data.rewardItems)
    		UserService:getInstance():addRewards(data.rewardItems)
    		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kTrunk, data.rewardItems, DcSourceType.kExchangeCode)

			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getExchangeCodeReward, {exchangeCode = code, machineType = mt}, loadCallback, rpc.SendingPriority.kHigh, false)
end

ContextHttp = class(HttpBase)
function ContextHttp:load( actId, contact,extra )
	-- body
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			context:onLoadingError(err)
		else
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.contact, { actId = actId, contact = contact,extra=extra }, loadCallback, rpc.SendingPriority.kHigh, false)

end

-- 
-- DeleteFriendHttp ---------------------------------------------------------
-- 
DeleteFriendHttp = class(HttpBase)
function DeleteFriendHttp:load(friendUids)
	if not friendUids or type(friendUids) ~= 'table' or #friendUids == 0 then 
		return
	end
 	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local mgr = FriendManager:getInstance()

	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_warning("IgnoreFreegiftHttp error: " .. err)
			self:onLoadingError(err)
		else
			for key, id in pairs(friendUids) do 
				mgr:removeFriend(id)
			end
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			self:onLoadingComplete(data)
		end
	end

	-- loadCallback()

	self.transponder:call(kHttpEndPoints.deleteFriend, {friendUids = friendUids}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- PickFruitHttp ---------------------------------------------------------
--

--id 果子索引，-1为激励视频果实
--mType 0摘取 1重生
--version 0 旧版本，带CD的无限重生
--version 1 激励视频2期，看视频的无限重生无CD生长
--version 2 激励视频3期，看视频的一果一次重生无CD生长
PickFruitHttp = class(HttpBase)
function PickFruitHttp:load(id, mType,version)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("PickFruitHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("PickFruitHttp success !")
			if type(data.reward) == "table" then
				UserService:getInstance():addReward(data.reward)
			end
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.ONLINE_SETTER)
				triggerContext:addValue( kHttpEndPoints.pickFruit , data )
				MissionManager:getInstance():checkAll(triggerContext)
			end

			if mType == 1 then
				Notify:dispatch("AchiEventDataUpdate",AchiDataType.kRebirthFruitAddCount, 1)
			end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.pickFruit, {id = id, type = mType,version = version}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetCompenRewardHttp ----------------------------------------------------
-- 
GetCompenRewardHttp = class(HttpBase)
function GetCompenRewardHttp:load(index)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetCompenRewardHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetCompenRewardHttp success !")
			if UserManager:getInstance().compenList then
				local reward = UserManager:getInstance().compenList[index]
				if type(reward) == "table" and type(reward.rewards) == "table" then
					for k, v in ipairs(reward.rewards) do
						if v.itemId == 2 then
							local user = UserService:getInstance().user
							if user then
								user:setCoin(user:getCoin() + v.num)
							end
						elseif v.itemId == 14 then
							local user = UserService:getInstance().user
							if user then
								user:setCash(user:getCash() + v.num)
							end
						else
							UserService:getInstance():addUserPropNumber(v.itemId, v.num)
						end
					end
				end
			end
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			context:onLoadingComplete(data)
		end
	end
	local device = "unknown"
	if __IOS then
		device = "ios"
	elseif __ANDROID then
		device = "android"
	elseif __WP8 then
		device = "wp"
	end
	self.transponder:call(kHttpEndPoints.getCompenReward, {compenId = index, deviceOS = device}, loadCallback, rpc.SendingPriority.kHigh, false)
	-- loadCallback(kHttpEndPoints.getCompenReward, nil, nil) -- success directly
end

DoOrderHttp = class(HttpBase)
function DoOrderHttp:load(tradeId, goodsId, goodsType, num)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doPaymentOrder, {tradeId=tradeId, goodsId=goodsId, goodsType=goodsType, num=num}, loadCallback, rpc.SendingPriority.kHigh, false)
end

DoWXOrderHttp = class(HttpBase)
function DoWXOrderHttp:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee, ip, appId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoWXOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoWXOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doWXPaymentOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName,
															totalFee=totalFee, ip=ip, appId = appId}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end

DoWXOrderV2Http = class(HttpBase)
function DoWXOrderV2Http:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee, ip, appId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoWXOrderV2Http error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoWXOrderV2Http success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doWXPaymentOrderV2, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName,
															totalFee=totalFee, ip=ip, appId = appId}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end

DoAliOrderHttp = class(HttpBase)
function DoAliOrderHttp:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee, signString)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoAliOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoAliOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doAliPaymentOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName,
															totalFee=totalFee, signString = signString}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end


DoMSDKOrderHttp = class(HttpBase)
function DoMSDKOrderHttp:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee, openId, accessToken, payToken, pf, pfKey, isLogin)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoMSDKOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoMSDKOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doMSDKPaymentOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName, totalFee=totalFee, 
															openId=openId, accessToken=accessToken, payToken=payToken, pf=pf, pfKey=pfKey,
															login=isLogin}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end

DoMidasOrderHttp = class(HttpBase)
function DoMidasOrderHttp:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee, openId, accessToken, payToken, pf, pfKey, loginType)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoMidasOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoMidasOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doMidasPaymentOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName, totalFee=totalFee, 
															openId=openId, accessToken=accessToken, payToken=payToken, pf=pf, pfKey=pfKey,
															loginType=loginType}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end

DoYsdkOrderHttp = class(HttpBase)
function DoYsdkOrderHttp:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee, openId, accessToken, payToken, pf, pfKey, loginType)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoYsdkOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoYsdkOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doYsdkPaymentOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName, totalFee=totalFee, 
															openId=openId, accessToken=accessToken, payToken=payToken, pf=pf, pfKey=pfKey,
															loginType=loginType}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end

DoHuaweiOrderHttp = class(HttpBase)
function DoHuaweiOrderHttp:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoHuaweiOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoHuaweiOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doHuaweiPaymentOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName,
															totalFee=totalFee}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end

GetRewardsHttp = class(HttpBase)
function GetRewardsHttp:load(rewardId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetRewardsHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetRewardsHttp success !")
			if _G.isLocalDevelopMode then printx(0, table.tostring(data)) end
			local ret = {}
			if type(data.rewardItems) == "table" then
				for k, v in ipairs(data.rewardItems) do
					if type(v.itemId) == "number" and type(v.num) == "number" then
						if v.itemId == 2 then
							local user = UserService:getInstance():getUserRef()
							user:setCoin(user:getCoin() + v.num)
						elseif v.itemId == 14 then
							local user = UserService:getInstance():getUserRef()
							user:setCash(user:getCash() + v.num)
						else
							UserService:getInstance():addUserPropNumber(v.itemId, v.num)
						end
						table.insert(ret, v)
					end
				end
			end
			data.rewardItems = ret
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getRewards, {rewardId = rewardId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

WXShareHttp = class(HttpBase)
function WXShareHttp:load(uiType, turntableIndex)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("WXShareHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("WXShareHttp success !")
			local ret = {}
			if type(data.reward) == "table" and type(data.reward.itemId) == "number" and
				type(data.reward.num) == "number" then
				if data.reward.itemId == 2 then
					local user = UserService:getInstance():getUserRef()
					user:setCoin(user:getCoin() + data.reward.num)
				elseif data.reward.itemId == 14 then
					local user = UserService:getInstance():getUserRef()
					user:setCash(user:getCash() + data.reward.num)
				else
					UserService:getInstance():addUserPropNumber(data.reward.itemId, data.reward.num)
				end
			end
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.wxShare, {uitype = uiType, turntable = turntableIndex},
		loadCallback, rpc.SendingPriority.kHigh, false)
end

TurnTableHttp = class(HttpBase)
function TurnTableHttp:load(pTableId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("TurnTableHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("TurnTableHttp success !")
			local ret = {}
			if type(data.reward) == "table" and type(data.reward.itemId) == "number" and
				type(data.reward.num) == "number" then
				if data.reward.itemId == 2 then
					local user = UserService:getInstance():getUserRef()
					user:setCoin(user:getCoin() + data.reward.num)
				elseif data.reward.itemId == 14 then
					local user = UserService:getInstance():getUserRef()
					user:setCash(user:getCash() + data.reward.num)
				else
					UserService:getInstance():addUserPropNumber(data.reward.itemId, data.reward.num)
				end
			end
			if NetworkConfig.writeLocalDataStorage then 
				Localhost:getInstance():flushCurrentUserData()
			else 
				if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
			end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.turnTable, {tableId = pTableId},
		loadCallback, rpc.SendingPriority.kHigh, false)
end

PushNotifyHttp = class(HttpBase)
function PushNotifyHttp:load(uidList, msg, typeId, targetTime, levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("PushNotifyHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("PushNotifyHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.pushNotify, {uids = uidList, msg = msg, typeId = typeId, targetTime = targetTime, levelId = levelId},
		loadCallback, rpc.SendingPriority.kHigh, false)
end

DeleteCashLogsHttp = class(HttpBase)
function DeleteCashLogsHttp:load()
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DeleteCashLogsHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DeleteCashLogsHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.delCashLog, {}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

DisposeBindingHttp = class(HttpBase)
function DisposeBindingHttp:load(snsPlatforms)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
			context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("disConnect", {snsPlatforms = snsPlatforms}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 注释掉是因为现在已经不再调用 如果后期重新有这两个接口 请在道具获得时 加入相应打点
-- GetAutumnMatchHelpRewardsHttp = class(HttpBase)
-- function GetAutumnMatchHelpRewardsHttp:load(inviteCode)
-- 	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
-- 	local context = self

-- 	local loadCallback = function(endpoint, data, err)
-- 		if err then
-- 	    	context:onLoadingError(err)
-- 	    else
-- 	    	local usr = UserManager:getInstance():getUserRef()
-- 	    	local srv = UserService:getInstance():getUserRef()
-- 	    	for i,v in ipairs(data.rewards or {}) do
-- 	    		if v.itemId == ItemType.COIN then
-- 	    			UserManager:getInstance():addCoin(v.num)
-- 	    			UserService:getInstance():addCoin(v.num)
-- 	    		elseif v.itemId == ItemType.GOLD then
-- 					UserManager:getInstance():addCash(v.num)
-- 	    			UserService:getInstance():addCash(v.num)
-- 	    		else
-- 	    			UserManager:getInstance():addUserPropNumber(v.itemId, v.num)
-- 	    			UserService:getInstance():addUserPropNumber(v.itemId, v.num)
-- 	    		end
-- 	    	end

-- 	    	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
-- 			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

-- 			context:onLoadingComplete(data)
-- 	    end
-- 	end
-- 	self.transponder:call(kHttpEndPoints.getAutumnMatchHelpRewards, {inviteId = inviteCode},
-- 		loadCallback, rpc.SendingPriority.kHigh, false)
-- end

-- GetWeChatQrCodeReward = class(HttpBase)
-- --weeklyType "周赛版本，0：默认是秋季，2：冬季"
-- function GetWeChatQrCodeReward:load(id, weeklyType)
-- 	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
-- 	local context = self

-- 	local loadCallback = function(endpoint, data, err)
-- 		if err then
-- 	    	context:onLoadingError(err)
-- 	    else
-- 	    	for i,v in ipairs(data.rewards or {}) do
-- 	    		if v.itemId == ItemType.COIN then
-- 	    			UserManager:getInstance():addCoin(v.num)
-- 	    			UserService:getInstance():addCoin(v.num)
-- 	    		elseif v.itemId == ItemType.GOLD then
-- 					UserManager:getInstance():addCash(v.num)
-- 	    			UserService:getInstance():addCash(v.num)
-- 	    		elseif v.itemId == ItemType.KWATER_MELON then
-- 	    			local manager = SeasonWeeklyRaceManager:getInstance()
-- 	    			if type(v.num) == "number" and v.num > 0 then
-- 						manager:getAndUpdateMatchData()
-- 						manager.matchData:addScore(v.num)
-- 						manager:flushToStorage()

-- 						if manager:hasWeeklyRewards() then
-- 							LocalNotificationManager.getInstance():setWeeklyRaceRewardNotification()
-- 						end
-- 					end
-- 	    		else
-- 	    			UserManager:getInstance():addUserPropNumber(v.itemId, v.num)
-- 	    			UserService:getInstance():addUserPropNumber(v.itemId, v.num)
-- 	    		end
-- 	    	end

-- 	    	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
-- 			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

-- 			context:onLoadingComplete(data)
-- 	    end
-- 	end
-- 	self.transponder:call(kHttpEndPoints.getWeChatQrCodeRewards, {type = weeklyType, qrCodeId = id}, loadCallback, rpc.SendingPriority.kHigh, false)
-- end

JumpLevelHttp = class(HttpBase)
function JumpLevelHttp:load( levelId )
	-- body
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	-- user toplevelId, score update
	    	local result, errmsg = UserLocalLogic:jumpLevel(levelId, data.pawnNum)
	    	if result then

	    		if MissionManager then
					local triggerContext = TriggerContext:create(TriggerContextPlace.ONLINE_SETTER)
					triggerContext:addValue( kHttpEndPoints.passLevel , {levelId=levelId,star=0,score=0} )
					MissionManager:getInstance():checkAll(triggerContext)
				end

				context:onLoadingComplete(data)

				if MissionManager then
					local triggerContext = TriggerContext:create(TriggerContextPlace.ANY_WHERE)
					MissionManager:getInstance():checkAll(triggerContext)
				end

				local topLevelId = UserService:getInstance().user:getTopLevelId()
				--RemoteDebug:uploadLog("JumpLevelHttp   " , levelId , topLevelId)
				if tonumber(levelId + 1) == tonumber(topLevelId) then
					UserManager:getInstance().userExtend:resetTopLevelFailCount()
					UserService:getInstance().userExtend:resetTopLevelFailCount()
					UserTagManager:onTopLevelChanged()
				end

	    	else
	    		local msg = errmsg or "nil"
	    		if _G.isLocalDevelopMode then printx(0, "JumpLevel http error message: "..errmsg) end
	    	end
	    end
	end
	-- loadCallback()
	self.transponder:call(kHttpEndPoints.jumpLevel, {levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

SetLevelStarHttp = class(HttpBase)
function SetLevelStarHttp:load( levelId,star )
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	-- loadCallback()
	self.transponder:call(kHttpEndPoints.setLevelStar, {levelId = levelId,star = star}, loadCallback, rpc.SendingPriority.kHigh, false)
end


EditorRecordLevel = class(HttpBase)
function EditorRecordLevel:load(data)
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("EditorRecordLevel error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("EditorRecordLevel success !")
			context:onLoadingComplete(data)
		end
	end
	
	self.transponder:call(kHttpEndPoints.editorRecordLevel, data, loadCallback, rpc.SendingPriority.kHigh, false)
end

DoQQPaymentOrder = class(HttpBase)
function DoQQPaymentOrder:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoQQPaymentOrder error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoQQPaymentOrder success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doQQPaymentOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName,
															totalFee=totalFee}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end

DoWpAliPaymentOrder = class(HttpBase)
function DoWpAliPaymentOrder:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoWpAliPaymentOrder error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoWpAliPaymentOrder success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doWpAliPaymentOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName,
															totalFee=totalFee}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end

--微信代付
DoWXFriendPayHttp = class(HttpBase)
function DoWXFriendPayHttp:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee, ip, paramList)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("DoWXFriendPayHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("DoWXFriendPayHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.doWxFriendPayOrder, {platform=platform, checkStr=sign, tradeId=tradeId, goodsId=goodsId, 
															goodsType=goodsType, num=amount, goodsName=goodsName,
															totalFee=totalFee, ip=ip, paramList=paramList}, 
															loadCallback, rpc.SendingPriority.kHigh, false)
end



GetWxFriendResult = class(HttpBase)
function GetWxFriendResult:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetWxFriendResult error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetWxFriendResult success !")
			context:onLoadingComplete(data)
		end
	end

	local isAndroid = false
	if __ANDROID then
		isAndroid = true
	end

	self.transponder:call(kHttpEndPoints.getPayForAnotherCashLogs, {onAndroidPlatform = isAndroid}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetUnionPromotionInfo = class(HttpBase)
function GetUnionPromotionInfo:load(version)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.getUnionPromotionInfo, {version = version or 0}, loadCallback, rpc.SendingPriority.kHigh, false)
end

TriggerUnionPromotionInfo = class(HttpBase)
function TriggerUnionPromotionInfo:load(version)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.triggerUnionPromotionInfo, {version = version or 0}, loadCallback, rpc.SendingPriority.kHigh, false)
end

DoUMPaymentOrder = class(HttpBase)
function DoUMPaymentOrder:load(platform, sign, tradeId, goodsId, goodsType, amount, goodsName, totalFee, ip, mobileid)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	local data = {
		platform = platform,
		tradeId = tradeId,
		goodsId = goodsId,
		goodsType = goodsType,
		num = amount,
		goodsName = goodsName,
		totalFee = totalFee,
		ip = ip,
		mobileid = mobileid,
		checkStr = sign
	}

	self.transponder:call(kHttpEndPoints.doUMPaymentOrder, data, loadCallback, rpc.SendingPriority.kHigh, false)
end

UmConfirmPay = class(HttpBase)
function UmConfirmPay:load(tradeId, verifyCode)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	local data = {
		tradeId = tradeId,
		verifyCode = verifyCode
	}
	
	self.transponder:call(kHttpEndPoints.umConfirmPay, data, loadCallback, rpc.SendingPriority.kHigh, false)
end


SaveZhimaCertifyHttp = class(HttpBase)
function SaveZhimaCertifyHttp:load(name, idCard)
	local context = self
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("mark fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("mark success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.zhimaCertify, {
		name = name,
		certNo = idCard
	}, loadCallback, rpc.SendingPriority.kHigh, false)
end

RequestZhimaCertifyUrlHttp = class(HttpBase)--请求调用支付宝APP实名要传递的参数
function RequestZhimaCertifyUrlHttp:load()
	local context = self
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("mark fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("mark success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.zhimaCertifyUrl, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

SendZhimaCertifyResultHttp = class(HttpBase)--向后端发送支付宝客户端返回来的参数
function SendZhimaCertifyResultHttp:load(params, sign)
	local context = self
	local httpParams = {
		params = params,
		sign = sign
	}
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("mark fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("mark success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.zhimaCertifyResult, httpParams, loadCallback, rpc.SendingPriority.kHigh, false)
end

VipPreOrderHttp = class(HttpBase)--向后端发送支付宝客户端返回来的参数
function VipPreOrderHttp:load(params)
	local context = self
	local httpParams = params or {}
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("mark fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("mark success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.vipPreOrder, httpParams, loadCallback, rpc.SendingPriority.kHigh, false)
end

IosPreOrderHttp = class(HttpBase)--苹果支付前 向服务器发个预订单
function IosPreOrderHttp:load(params)
	local context = self
	local httpParams = params or {}
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("IosPreOrderHttp fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("IosPreOrderHttp success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.iosPreOrder, httpParams, loadCallback, rpc.SendingPriority.kHigh, false)
end

function HttpBase:post(endPoint, params, onSuccess, onFail, onCancel, sync)
	local http = HttpBase.new(true)
	function http:load( params )
		if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
		local context = self
		local loadCallback = function(endpoint, data, err)
			if err then
				context:onLoadingError(err)
			else
				context:onLoadingComplete(data)
			end
		end
		self.transponder:call(endPoint, params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
	end
	if onSuccess then
		http:ad(Events.kComplete, onSuccess)
	end
	if onFail then
		http:ad(Events.kError, onFail)
	end
	if onCancel then
		http:ad(Events.kCancel, onCancel)
	end
	if sync then
		http:syncLoad(params)
	else
		http:load(params)
	end
end

--这只是个尝试
function HttpBase:syncPost(endPoint, params, onSuccess, onFail, onCancel)
	HttpBase:post(endPoint, params, onSuccess, onFail, onCancel, true)
end