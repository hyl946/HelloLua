
require "zoo.net.Http" 

--
-- LoginHttp ---------------------------------------------------------
--
LoginHttp = class(HttpBase)
function LoginHttp:load()
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("game login fail, err: " .. err)

	    	if tostring(err) == "739006" then
	    		--疑似旧版本作弊，禁止登录
	    		local function exitGame()
	    			Director.sharedDirector():exitGame()
	    		end
	    		local tiptext = {
				 	tip = Localization:getInstance():getText("login.disabled.by.cheating"),
				 	yes = "确定",
				}
	    		CommonTipWithBtn:showTip(tiptext, "negative", exitGame, exitGame, nil, true)
	    	else
	    		context:onLoadingError(err)
	    	end
	    else
	    	he_log_info("game login success")
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call(kHttpEndPoints.login, nil, loadCallback, rpc.SendingPriority.kHigh, true)
end

--
-- FriendHttp ---------------------------------------------------------
--
FriendHttp = class(HttpBase)

--  <request>
--	  <property code="refresh" type="boolean" desc="æ˜¯å¦éœ€è¦åˆ·æ–°åŽç«¯å¥½å‹åˆ—è¡¨" /> 
--	  <list code="friendIds" type="long" desc="å¥½å‹idåˆ—è¡¨" /> 
--  </request>
function FriendHttp:load(refresh, friendIds)
	-- test
	-- for i=1140, 1350 do table.insert(friendIds, tostring(i)) end

	assert(type(friendIds) == "table", "friendIds not a table")
	local context = self
	if refresh == nil then refresh = false end
	if friendIds == nil or #friendIds == 0 then 
		--NO Friend need to refresh, just finish it.
		context:onLoadingComplete()
		return 
	end



	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("get friends fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("get friends success")
	    	if data.users and type(data.users) == "table" then	    		
	    		FriendManager.getInstance():syncFromLua(data.users, data.profiles, data.snsFriendIds, data.achievementList, data.friendSource, data.friendLastLoginDays,data.lastLoginInfoMap)
	    		Localhost.getInstance():flushCurrentFriendsData() -- why? how about delete it.
	    	end
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.friends, {refresh=refresh, friendIds=friendIds}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetFriendsHttp	= class(HttpBase)

function GetFriendsHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)

		if err then
			he_log_info("get friends id fail, err: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("get friends id success ! ")

			-- test
			-- for i=1140, 1350 do table.insert(data.friendIds, tostring(i)) end

			UserManager:getInstance().friendIds = data.friendIds

			context:onLoadingComplete(data)
		end
	end

	local parameters = {}
	if __IOS_FB then
		parameters.openId = Localhost:getInstance():readCurrentUserData().openId
		parameters.accessToken = FacebookProxy:getInstance():accessToken()
		if _G.isLocalDevelopMode then printx(0, "openId="..tostring(parameters.openId)..",accessToken="..tostring(parameters.accessToken)) end
	end

	self.transponder:call(kHttpEndPoints.getFriends, parameters, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- GetRecommendFriendsHttp ---------------------------------------------------------
--
GetRecommendFriendsHttp	= class(HttpBase)
function GetRecommendFriendsHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)

		if err then
			he_log_info("get friends id fail, err: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("get friends id success ! ")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getRecommendFriends, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- GetUnlockFriendHttp ---------------------------------------------------------
--
GetUnlockFriendHttp = class(HttpBase)
function GetUnlockFriendHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local unlockFriendCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("get unlock friend fail, err: " .. err)
	    	context:onLoadingError(err)
	    else 
	    	he_log_info("get unlock friend success")
			for k,v in pairs(data.unLockFriendInfos) do
				local function updateUnlockInfo(ipt)
					local unLockFriendInfos = UserManager:getInstance().unLockFriendInfos
					for k, v in ipairs(unLockFriendInfos) do
						if v.id == ipt.id then
							v.friendUids = ipt.friendUids
							return
						end
					end

					local unlockFriendInfo = UnLockFriendInfoRef.new()
					unlockFriendInfo.id		= ipt.id
					unlockFriendInfo.friendUids	= ipt.friendUids
					table.insert(unLockFriendInfos, unlockFriendInfo)
				end
				updateUnlockInfo(v)				
			end
			UserManager:getInstance().areaId = data.areaId
			UserManager:getInstance().npcNumber = data.npcNumber
	    	context:onLoadingComplete()
	    end
	end
	self.transponder:call(kHttpEndPoints.getUnLockFriend, nil, unlockFriendCallback, rpc.SendingPriority.kHigh, false)
end

--
-- QueryUserHttp ---------------------------------------------------------
--
QueryUserHttp = class(HttpBase)
-- <request>
-- 	<property code="inviteCode" type="int" desc="好友邀请码"/>
-- </request>
-- <response>
-- 	<property code="user" ref="User" desc="好友用户信息"/>
-- </response>
function QueryUserHttp:load(code)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local function loadCallback(endPoint, data, err)
		if err then
			he_log_info("QueryUserHttp, err:" .. err)
			context:onLoadingError(err)
		else
			he_log_info("QueryUserHttp success")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.queryUser, {inviteCode = code}, loadCallback, rpc.SendingPriority.kHigh, false)
end

AddFriend = class(HttpBase)
function AddFriend:load(uid)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local function loadCallback(endPoint, data, err)
		if err then
			he_log_info("QueryUserHttp, err:" .. err)
			context:onLoadingError(err)
		else
			he_log_info("QueryUserHttp success")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.addFriend, {friendUid = uid}, loadCallback, rpc.SendingPriority.kHigh, false)
end
--
-- RequestFriend ---------------------------------------------------------
--
RequestFriendHttp = class(HttpBase)
-- <request>
-- 	<property code="inviteCode" type="int" desc="好友邀请码"/>
-- 	<property code="friendUid" type="long" desc="好友的uid"/>
-- 	type: 1 --手机好友，0--其他方式的好友
-- </request>
-- <response>
-- </response>
function RequestFriendHttp:load(code, uid, type, uids)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local function loadCallback(endPoint, data, err)
		if err then
			he_log_info("RequestFriendHttp fail, err:" .. err)
			context:onLoadingError(err)
		else
			he_log_info("RequestFriendHttp success")
			context:onLoadingComplete()
		end
	end
	self.transponder:call(kHttpEndPoints.requestFriend, {inviteCode = code, friendUid = uid, friendUids = uids, type = type}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- GetLevelScoreRankHttp ---------------------------------------------------------
--
GetLevelScoreRankHttp = class(HttpBase) --èŽ·å–å…³å¡å¾—åˆ†å…¨æœæŽ’è¡Œ

-- dispatched event.data = response

--  <request>
--	  <property code="levelId" type="int" desc="å…³å¡id" />
--	  <property code="pageStart" type="int" desc="æŸ¥è¯¢å¼€å§‹é¡µ" />
--    <property code="pageEnd" type="int" desc="æŸ¥è¯¢ç»“æŸé¡µ" />
--  </request>
--  <response>
--		<list code="ranks" ref="Rank" desc="æŽ’è¡Œæ¦œä¿¡æ¯"/>
--		<property code="rank" type="int" desc="å½“å‰çŽ©å®¶æŽ’å" />
--	</response>

function GetLevelScoreRankHttp:load(levelId, pageStart, pageEnd)
	assert(levelId ~= nil, "levelId must not a nil")
	assert(pageStart ~= nil, "pageStart must not a nil")
	assert(pageEnd ~= nil, "pageEnd must not a nil")
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("getLevelScoreRank fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("getLevelScoreRank success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.getLevelScoreRank, 
		{levelId=levelId, pageStart=pageStart, pageEnd=pageEnd}, 
		loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- GetLevelTopHttp ---------------------------------------------------------
--
GetLevelTopHttp = class(HttpBase) --èŽ·å–å…³å¡å¾—åˆ†å…¨æœæŽ’è¡Œ

-- dispatched event.data = response.scores å¥½å‹æŽ’ååˆ—è¡¨

--  <request>
--	  <property code="levelId" type="int" desc="å…³å¡id" />
--  </request>
--  <response>
--		<list code="scores" ref="Score" desc="å¥½å‹æŽ’ååˆ—è¡¨"/>
--	</response>
function GetLevelTopHttp:load(levelId)
	assert(levelId ~= nil, "levelId must not a nil")
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("getLevelTop fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("getLevelTop success")
	    	context:onLoadingComplete(data.scores)
	    end
	end
	self.transponder:call(kHttpEndPoints.getLevelTop, {levelId=levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- EndLadyBugTask ---------------------------------------------------------
--
EndLadyBugTask = class(HttpBase)
function EndLadyBugTask:load(...)
	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)

		if err then
			he_log_info("end lady bug task error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("end lady bug task success !")
			-- context:onLoadingComplete(data.metaClient)
			-- fix
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.endLadyBugTask, nil, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- FinishChildLadyBugTask ---------------------------------------------------------
--
FinishChildLadyBugTask = class(HttpBase)
function FinishChildLadyBugTask:load(taskId, ...)
	assert(type(taskId) == "number")
	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)

		if err then
			he_log_info("finish child lady bug task taskId:" .. taskId .. " error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("finish child lady bug task taskId:" .. taskId .. " success !")

			-- context:onLoadingComplete(data.metaClient)
			-- fix
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.finishChildLadyBugTask, {taskId = taskId}, loadCallback, rpc.SendingPriority.kHigh, false)
end


--
-- GetInvitedFriendsUserInfo ---------------------------------------------------------
--
GetInvitedFriendsUserInfo = class(HttpBase)
function GetInvitedFriendsUserInfo:load(invitedFriendsInfo)
	if _G.isLocalDevelopMode then printx(0, 'this debug GetInvitedFriendsUserInfo:load') end
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local friendIds = {}
	for k, v in pairs(invitedFriendsInfo) do
		if tonumber(v.friendUid) ~= 0 and v.invite == true then
			table.insert(friendIds, tonumber(v.friendUid))
		end
	end

	local function loadCallback(endPoint, data, err)
		if err then
			he_log_info("GetInvitedFriendsUserInfo: error: " .. err)
			self:onLoadingError(err)
		else
			if _G.isLocalDevelopMode then printx(0, 'this debug loadCallback sucess') end
			FriendManager:getInstance():syncFromLuaForInvitedFriends(data.users, data.profiles)
			self:onLoadingComplete(data)
		end

	end

	self.transponder:call(kHttpEndPoints.friends, {refresh=refresh, friendIds=friendIds}, loadCallback, rpc.SendingPriority.kHigh, false)
end


--
-- GetInviteFriendsInfo ---------------------------------------------------------
--
GetInviteFriendsInfo = class(HttpBase)
function GetInviteFriendsInfo:load(...)

	assert(#{...} == 0)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)

		if err then
			he_log_info("get invite frinds info error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("get invite friends info success !")
			--if _G.isLocalDevelopMode then printx(0, table.tostring(data)) end
			UserManager:getInstance().inviteFriendsInfo = data.groupInfos
			context:onLoadingComplete(data.groupInfos)
		end
	end
	self.transponder:call(kHttpEndPoints.getInviteFriendsInfo, nil, loadCallback, rpc.SendingPriority.kHigh, false)
end


--
-- RespRequest ---------------------------------------------------------
--
-- <property code="action" type="int" desc="用户操作 1：同意帮助，2：忽略, 3:按类型全部同意, 4:按类型全部忽略" />
-- <property code="id" type="int" desc="请求id" />
RespRequest = class(HttpBase)
function RespRequest:load(id, action, types, maxID)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)

		if err then
			he_log_info("RespRequest error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("RespRequest success !")
			if action == 1 or action == 2 then
				UserManager.getInstance():removeRequestInfo(id)
				UserManager.getInstance().requestNum = UserManager.getInstance().requestNum - 1
			else
				UserManager.getInstance():removeRequestInfoByTypes(types)
			end
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.respRequest, {id=id, action=action, types=types, maxId=maxID}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- NewUserEnergy ---------------------------------------------------------
-- 
NewUserEnergy = class(HttpBase)
function NewUserEnergy:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("Request error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("Request success !")
			context:onLoadingComplete()
		end
	end
	self.transponder:call(kHttpEndPoints.newUserEnergy, nil, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetUserHttp ---------------------------------------------------------
-- 
GetUserHttp = class(HttpBase)
function GetUserHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetUserHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetUserHttp success !")
			context:onLoadingComplete(data)
		end
	end

	local userbody = {}
	if _G.isPrePackage then 
		userbody.pre = 1
	else
		userbody.pre = 0
	end

	userbody.clientType = MetaInfo:getInstance():getDeviceModel()
	userbody.osVersion = MetaInfo:getInstance():getOsVersion()
	userbody.networkType = NetworkUtil:getNetworkStatus()

	self.transponder:call(kHttpEndPoints.getUser, userbody, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetLeftAskInfoHttp ---------------------------------------------------------
-- 
GetLeftAskInfoHttp = class(HttpBase)
function GetLeftAskInfoHttp:load(uid)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetLeftAskInfoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetLeftAskInfoHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getLeftAskInfos, {uids = uid}, loadCallback, rpc.SendingPriority.kHigh, false)
end

AskEnergyGetUids = class(HttpBase)
function AskEnergyGetUids:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("askEnergyGetUids error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("askEnergyGetUids success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.askEnergyGetUids, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

AskEnergyShareHttp = class(HttpBase)
function AskEnergyShareHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("askEnergyShare error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("askEnergyShare success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.askEnergyShare, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetRequestInfoHttp ---------------------------------------------------------
-- 
GetRequestInfoHttp = class(HttpBase)
function GetRequestInfoHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetRequestInfoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetRequestInfoHttp success !")
			context:onLoadingComplete(data)
		end
	end
	local body = {uilds = uid}
	body.ignoreMsgTypes = FreegiftManager:sharedInstance():getIgnoreRequestTypes()
	self.transponder:call(kHttpEndPoints.getRequestInfos, body, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetRequestNumHttp ---------------------------------------------------------
-- 
GetRequestNumHttp = class(HttpBase)
function GetRequestNumHttp:load(source)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetRequestNumHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetRequestNumHttp success !")
			context:onLoadingComplete(data)
		end
	end

	local userbody = {
		curMd5 = ResourceLoader.getCurVersion(),
		pName = _G.packageName 
	}
	if StartupConfig:getInstance():getSmallRes() then 
		userbody.mini = 1
	else
		userbody.mini = 0
	end

	if _G.isPrePackage then 
		userbody.pre = 1
	else
		userbody.pre = 0
	end

	if __ANDROID then
		userbody.smsPayMd5 = AndroidPayment.getInstance():getDecisionScriptMd5()
	end

	if __IOS then
		userbody.idfa = AppController:getAdvertisingIdentifier() or ""
		userbody.cloverInstalled = UIApplication:sharedApplication():canOpenURL(NSURL:URLWithString('happyclover3://'))
	elseif __WIN32 then
		userbody.idfa = '12345'
		userbody.cloverInstalled = false
	elseif __ANDROID then
		require 'zoo.util.CloverUtil'
		userbody.cloverInstalled = CloverUtil:isAppInstall()
	end

	userbody.ignoreMsgTypes = FreegiftManager:sharedInstance():getIgnoreRequestTypes()

	--推送召回 前端向后端发送流失状态
	userbody.lostType = RecallManager.getInstance():getRecallRewardState()

	userbody.clientType = MetaInfo:getInstance():getDeviceModel()
	userbody.osVersion = MetaInfo:getInstance():getOsVersion()
	userbody.networkType = NetworkUtil:getNetworkStatus()
	
	userbody.province = Cookie.getInstance():read(CookieKey.kLocationProvince)

	if source and source == "home" then
		require "zoo.data.BitFlag"
		local bitFlag = BitFlag:create()

		for k,v in pairs(UserTagGroupKey) do
			local lastUpdateTime = UserTagManager:getTagLocalUpdateTime( v )

			local tagsName = UserTagNameKey[v]
			local needUpdate = false
			if tagsName then
				for k2,v2 in pairs(tagsName) do

					local staticMetaConfig = UserTagManager:getUserTagStaticConfig(v2)
					if staticMetaConfig and staticMetaConfig.dcStrategy and staticMetaConfig.dcStrategy[ tostring(UserTagDCSource.kHome) ] then
						needUpdate = true
						break
					end
				end
			end 
			if needUpdate and lastUpdateTime and type(lastUpdateTime) == "number" and Localhost:timeInSec() - lastUpdateTime > DefaultUserTagUpdateDelayAtHomeScene then
				for k1,v1 in ipairs(UserTagGroupKeyIndex) do
					if v1 == v then
						bitFlag:setFlagBit( k1 , true )
						break
					end
				end
			end
		end
		userbody.flag = bitFlag:getFlagValue()
	end

	self.transponder:call(kHttpEndPoints.getRequestNum, userbody, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- IgnoreFreegift ---------------------------------------------------------
-- 
IgnoreFreegiftHttp = class(HttpBase)
function IgnoreFreegiftHttp:load(messageId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("IgnoreFreegiftHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("IgnoreFreegiftHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.ignoreFreegift, {id = messageId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- updateConfigFromServer ---------------------------------------------------------
-- 
UpdateConfigFromServerHttp = class(HttpBase)
function UpdateConfigFromServerHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("updateConfigFromServer error: " .. err)
			self:onLoadingError(err)
		else  
			he_log_info("updateConfigFromServer success !")
			self:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.updateConfigFromServer, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end


------------
--- queryQihooOrder
-------------
QueryQihooOrderHttp = class(HttpBase)
function QueryQihooOrderHttp:load(orderId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("QueryQihooOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("QueryQihooOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.queryQihooOrder, {orderId = orderId}, loadCallback, rpc.SendingPriority.kHigh, false)
end


QueryAliOrderHttp = class(HttpBase)
function QueryAliOrderHttp:load(orderId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("QueryAliOrderHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("QueryAliOrderHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.queryAliOrder, {orderId = orderId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

ExtraConnectHttp = class(HttpBase)
function ExtraConnectHttp:load(openId,accessToken,snsPlatform,snsName)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("QQConnectHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("QQConnectHttp success !")
			context:onLoadingComplete(data)

			Notify:dispatch("AchiEventDataUpdate",AchiDataType.kBindAnyAccount, 1)
		end
	end
	local connectProtocol = "extraConnect"
	local params = {
		openId=openId,
		accessToken=accessToken,
		snsPlatform=snsPlatform,
		snsName = snsName,
	}

	self.transponder:call(connectProtocol, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- QQConnect ---------------------------------------------------------
-- 
QQConnectHttp = class(HttpBase)
function QQConnectHttp:load(openId, accessToken,snsPlatform,snsName)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("QQConnectHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("QQConnectHttp success !")
			context:onLoadingComplete(data)
		end
	end
	local connectProtocol = "otherConnectV3"
	if PlatformConfig:isQQPlatform() then
		if snsPlatform == PlatformAuthDetail[PlatformAuthEnum.kQQ].name then
			connectProtocol = "qqConnectV3"
		end
	end

	local params = {
		openId=openId,
		accessToken=accessToken,
		snsPlatform=snsPlatform,
		-- oldSnsPlatform=oldSnsPlatform,
		snsName = snsName,
		deviceUdid = MetaInfo:getInstance():getUdid(),
	}

	self.transponder:call(connectProtocol, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

--rebinding
RebindingHttp = class(HttpBase)
function RebindingHttp:load(snsName, openId,accessToken)
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("RebindingHttp error: " .. err)
			self:onLoadingError(err)
		else
			he_log_info("RebindingHttp success !")
			self:onLoadingComplete(data)
		end
	end
	local connectProtocol = "reBinding"
	self.transponder:call(connectProtocol, {snsName = snsName, openId = openId, accessToken=accessToken}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- PreQQConnectHttp ---------------------------------------------------------
-- 
PreQQConnectHttp = class(HttpBase)
function PreQQConnectHttp:load(openId,accessToken,haveSyncCache,snsPlatform,snsName)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("QQConnectHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("QQConnectHttp success !")
			context:onLoadingComplete(data)
			Notify:dispatch("AchiEventDataUpdate",AchiDataType.kBindAnyAccount, 1)
		end
	end

	local connectProtocol = "preOtherConnectV3"
	if PlatformConfig:isQQPlatform() then
		if snsPlatform == PlatformAuthDetail[PlatformAuthEnum.kQQ].name then
			connectProtocol = "preQqConnectV3"
		end
	end

	-- if _G.isLocalDevelopMode then printx(0, "openId="..openId..",accessToken="..accessToken) end
	local params = {
		openId=openId,
		accessToken=accessToken,
		snsPlatform=snsPlatform,
		-- oldSnsPlatform=oldSnsPlatform,
		hasCache=haveSyncCache,
		snsName = snsName,
		deviceUdid = MetaInfo:getInstance():getUdid()
	}

	self.transponder:call(connectProtocol, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- PreQQConnectV2Http = class(PreQQConnectHttp)
-- function PreQQConnectV2Http:syncLoad(...)
-- 		if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
-- 	  	local para = {...}

-- 	  	local function onSyncError(err)
-- 	  		self:onLoadingError(err)
-- 	  	end

-- 	  	local function onSyncFinished()
-- 	  		self:load(para[1], para[2], para[3], para[4], para[5], para[6],
-- 	    		para[7], para[8], para[9], para[10], para[11], para[12], para[13], para[14], para[15])
-- 	  	end

-- 	  	SyncManager.getInstance():sync(onSyncFinished, onSyncError, kRequireNetworkAlertAnimation.kNone)
-- end

PreQQConnectV1Http = class(HttpBase)
function PreQQConnectV1Http:load(openId, accessToken, haveSyncCache)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("QQConnectHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("QQConnectHttp success !")
			context:onLoadingComplete(data)
		end
	end
	local connectProtocol = "preOtherConnect"
	if PlatformConfig:isQQPlatform() then
		assert(false)
		-- connectProtocol = "preQqConnect"
	end
	-- if _G.isLocalDevelopMode then printx(0, "openId="..openId..",accessToken="..accessToken) end
	local params = {openId=openId,accessToken=accessToken,hasCache=haveSyncCache}
	if __ANDROID and _G.sns_token then
		params.snsPlatform = PlatformConfig:getPlatformAuthName()
	end
	self.transponder:call(connectProtocol, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

PreOtherConnectV4Http = class(HttpBase)
function PreOtherConnectV4Http:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			context:onLoadingError(err)
		else
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.preOtherConnectV4, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

OtherConnectV4Http = class(HttpBase)
function OtherConnectV4Http:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			context:onLoadingError(err)
		else
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.otherConnectV4, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

PreExtraConnectV4Http = class(HttpBase)
function PreExtraConnectV4Http:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			context:onLoadingError(err)
		else
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.preExtraConnectV4, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

ExtraConnectV4Http = class(HttpBase)
function ExtraConnectV4Http:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			context:onLoadingError(err)
		else
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.extraConnectV4, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- SyncSnsFriendHttp ----------------------------------------------------
-- 
SyncSnsFriendHttp = class(HttpBase)
function SyncSnsFriendHttp:load(friendOpenIds, openId, accessToken,authorType)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("syncSnsFriend fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("syncSnsFriend success")
	    	-- if _G.isLocalDevelopMode then printx(0, "friendsData:"..table.tostring(data)) end
	    	if data.users and type(data.users) == "table" then
	    		FriendManager.getInstance():syncFromLua(data.users, data.profiles, data.snsFriendIds)
	    		Localhost.getInstance():flushCurrentFriendsData()
	    	end
	    	context:onLoadingComplete(data)
	    end
	end
	local params = {friendOpenIds=friendOpenIds, openId=openId, openKey=accessToken}
	if __ANDROID and _G.sns_token then
		params.snsPlatform = PlatformConfig:getPlatformAuthName(authorType)
	end
	self.transponder:call(kHttpEndPoints.syncSnsFriend, params, loadCallback, rpc.SendingPriority.kHigh, false)
end
-- 
-- GetNearbyHttp ----------------------------------------------------
-- 
-- <request>
-- 	<property code="longitude" type="double" desc="经度"/>
-- 	<property code="latitude" type="double" desc="纬度"/>
-- </request>
-- <response>
-- 	<list code="users" ref="User" desc="用户列表"/>
-- 	<list code="profiles" ref="Profile" desc="用户头像列表"/>
-- </response>
GetNearbyHttp = class(HttpBase)
function GetNearbyHttp:load(longitude, latitude)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetNearbyHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetNearbyHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getNearby, {longitude = longitude, latitude = latitude}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- SendLocationHttp ----------------------------------------------------
-- 
-- <request>
-- 	<property code="longitude" type="double" desc="经度"/>
-- 	<property code="latitude" type="double" desc="纬度"/>
-- </request>
-- <response>
-- </response>
SendLocationHttp = class(HttpBase)
function SendLocationHttp:load(longitude, latitude)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("SendLocationHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("SendLocationHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.sendLocation, {longitude = longitude, latitude = latitude}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- GetMatchsHttp ----------------------------------------------------
-- 
-- <request>
-- </request>
-- <response>
-- 	<list code="users" ref="User" desc="用户列表"/>
-- 	<list code="profiles" ref="Profile" desc="用户头像列表"/>
-- </response>
GetMatchsHttp = class(HttpBase)
function GetMatchsHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetMatchsHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetMatchsHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getMatchs, nil, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- ConfirmMatchHttp ----------------------------------------------------
-- 
-- <request>
-- 	<property code="friendUid" type="long" desc="待添加的好友id"/>
-- </request>
-- <response>
-- </response>
ConfirmMatchHttp = class(HttpBase)
function ConfirmMatchHttp:load(uid)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("ConfirmMatchHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("ConfirmMatchHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.confirmMatch, {friendUid = uid}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 
-- AckMatchHttp ----------------------------------------------------
-- 
-- <request>
-- </request>
-- <response>
-- 	<property code="ret" type="int" desc="0：成功 1：失败 2：继续等待"/>
-- </response>
AckMatchHttp = class(HttpBase)
function AckMatchHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("AckMatchHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("AckMatchHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.ackMatch, nil, loadCallback, rpc.SendingPriority.kHigh, false)
end


-- getUpdateReward

GetUpdateRewardHttp = class(HttpBase)
function GetUpdateRewardHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetUpdateRewardHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetUpdateRewardHttp success !")
			context:onLoadingComplete(data)
		end
	end
	local userbody = {
		curMd5 = ResourceLoader.getCurVersion(),
		pName = _G.packageName 
	}
	if StartupConfig:getInstance():getSmallRes() then 
		userbody.mini = 1
	else
		userbody.mini = 0
	end
	if _G.isPrePackage then 
		userbody.pre = 1
	else
		userbody.pre = 0
	end

	--推送召回 前端向后端发送流失状态
	userbody.lostType = RecallManager.getInstance():getRecallRewardState()
	self.transponder:call(kHttpEndPoints.getUpdateReward, userbody, loadCallback, rpc.SendingPriority.kHigh, false)
end


-- getPromoStatus

GetPromoStatusHttp = class(HttpBase)
function GetPromoStatusHttp:load(appId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetPromoStatusHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetPromoStatusHttp success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call(kHttpEndPoints.getPromStatus, {appId = appId}, loadCallback, rpc.SendingPriority.kHigh, false)
end


-- getPromoReward

GetPromoRewardHttp = class(HttpBase)
function GetPromoRewardHttp:load(appId, rewardId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetPromoRewardHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetPromoRewardHttp success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call(kHttpEndPoints.getPromReward, {appId = appId, rewardId = rewardId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- clickPromo

ClickPromoHttp = class(HttpBase)
function ClickPromoHttp:load(appId, idfa, mac, promIdfa)
	if _G.isLocalDevelopMode then printx(0, 'load') end
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("ClickPromoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("ClickPromoHttp success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call(kHttpEndPoints.clickProm, {appId = appId, idfa = idfa, mac= mac, fishIdfa = promIdfa}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- GetFruitsInfoHttp ---------------------------------------------------------
--
GetFruitsInfoHttp = class(HttpBase)
function GetFruitsInfoHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetFruitsInfoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetFruitsInfoHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getFruitsInfo, {version = 2}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- UpgradeFruitTreeHttp ---------------------------------------------------------
--
UpgradeFruitTreeHttp = class(HttpBase)
function UpgradeFruitTreeHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("UpgradeFruitTreeHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("UpgradeFruitTreeHttp success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call(kHttpEndPoints.upgradeFruitTree, {fruitsVersion=1}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- GetPassNumHttp ---------------------------------------------------------
--
GetPassNumHttp = class(HttpBase)
function GetPassNumHttp:load(levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetPassNumHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetPassNumHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getPassNum, {levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- GetShareRankHttp ---------------------------------------------------------
--
GetShareRankHttp = class(HttpBase)
function GetShareRankHttp:load(levelId, score)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetShareRankHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetShareRankHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getShareRank, {levelId = levelId, score = score}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- getShareRankWithPosition ---------------------------------------------------------
--
GetShareRankWithPosition = class(HttpBase)
function GetShareRankWithPosition:load(levelId, score)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetShareRankWithPosition error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetShareRankWithPosition success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getShareRankWithPosition, {levelId = levelId, score = score}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- CanSendLinkShowOff ---------------------------------------------------------
--
CanSendLinkShowOff = class(HttpBase)
function CanSendLinkShowOff:load(levelId, score)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("CanSendLinkShowOff error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("CanSendLinkShowOff success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.canSendLinkShowOff, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetWeekMatchDataHttp = class(HttpBase)
function GetWeekMatchDataHttp:load(levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetWeekMatchDataHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetWeekMatchDataHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getWeekMatchData, {levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

CommonRankType = table.const {
	kWeeklyRace = 1,
	kRabbitWeeklyMatch = 5,
	kLaborDay = 6,
	kDragonBoat = 7,
	kSummerWeeklyMatch = 8,
	kQiXi2015 = 9,
	kAutumnWeekMatch = 11,
	kWinterWeekMatch = 22,
	kSpringWeekMatck = 29,
}
GetCommonRankListHttp = class(HttpBase)
function GetCommonRankListHttp:load(rankType, subType, levelId, startIndex, endIndex)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	startIndex = startIndex or 0
	endIndex = endIndex or 0
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetCommonRankListHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetCommonRankListHttp success !")
			context:onLoadingComplete(data)
		end
	end
	local params = {
		rankType = rankType, 
		subType = subType, 
		levelId = levelId, 
		startIndex = startIndex, 
		endIndex = endIndex,
	}
	self.transponder:call(kHttpEndPoints.getCommonRankList, params, loadCallback, rpc.SendingPriority.kHigh, false)
end

ExchangeWeekMatchItemsHttp = class(HttpBase)
function ExchangeWeekMatchItemsHttp:load(rewardId, number, levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("ExchangeWeekMatchItemsHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("ExchangeWeekMatchItemsHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.exchangeWeekMatchItems, {rewardId = rewardId, num = number, levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

ReceiveWeekMatchRewardsHttp = class(HttpBase)
function ReceiveWeekMatchRewardsHttp:load(id, levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("ReceiveWeekMatchRewardsHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("ReceiveWeekMatchRewardsHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.receiveWeekMatchRewards, {type = id, levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

CnValentineInfoHttp = class(HttpBase)
function CnValentineInfoHttp:load()
if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("CnValentineInfoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("CnValentineInfoHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.cnValentineInfo, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

CnValentineExchangeHttp = class(HttpBase)
function CnValentineExchangeHttp:load(rewardId)
if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("CnValentineExchangeHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("CnValentineExchangeHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.cnValentineExchange, {id = rewardId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

MergeConnectHttp = class(HttpBase)
function MergeConnectHttp:load(weiboOpenId, qqOpenId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("MergeConnectHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("MergeConnectHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.mergeConnect, {weiboOpenId = weiboOpenId, qqOpenId = qqOpenId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

ClickActivityHttp = class(HttpBase)
function ClickActivityHttp:load(actId)
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("ClickActivityHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("ClickActivityHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.clickActivity, {actId=actId}, loadCallback, rpc.SendingPriority.kHigh, false)
end


GetCashLogsHttp = class(HttpBase)
function GetCashLogsHttp:load(start,_end)
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetCashLogsHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetCashLogsHttp success !")
			context:onLoadingComplete(data)
		end
	end
	local d = {}
	d["start"] = start
	d["end"] = _end
	self.transponder:call(kHttpEndPoints.getCashLogs, d, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetRabbitMatchDatasHttp = class(HttpBase)
function GetRabbitMatchDatasHttp:load(levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetRabbitMatchDatasHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetRabbitMatchDatasHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getRabbitMatchDatas, {levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

ReceiveRabbitMatchRewardsHttp = class(HttpBase)
function ReceiveRabbitMatchRewardsHttp:load(levelId, rewardType, boxIdx)
	-- if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	if not kUserLogin then return self:onLoadingError({}) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("ReceiveRabbitMatchRewardsHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("ReceiveRabbitMatchRewardsHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.receiveRabbitMatchRewards, {type = rewardType, levelId = levelId, idx = boxIdx}, loadCallback, rpc.SendingPriority.kHigh, false)
end

OpNotifyType = {
	kShare = 1, --分享
	kNewYearAsk = 2,
	kXuanYao = 3,
	kSpringVideo = 4,--新春点击视频统计
	kVideoAdPlay = 6, --观看视频广告
	kAnniversaryShare = 7, --周年纪念分享得100银币 活动里用 
	kWeeklyMatchShare = 10, -- 周赛分享
	kSummerShare = 11, --夏日分享活动分享
	kOppoSummerLottery = 12,
	kQiXiLevel2015 = 13,
	kNdShare2015TurnTable = 19, -- 分享得转盘次数
	kNdShare2015Coin = 20, -- 分享得银币
	kNdShare2015AskFriend = 21, -- 求助好友抽取小动物
	kAutumnWeekMatchShare = 22,
	kPassMaxNormalLevel = 24, 	-- 通过版本最高关卡
	kRequestPushEnergy = 25,  -- 请求生成NPC免费精力推送
	kRdefAutumnWeekMatchShare = 26, -- 此版本添加多少游戏次数由后端返回决定
	kCheckUnlockRecord = 27,
	kDengchaoEnergy = 28, -- 邓超送精力
	kRdefWinterWeekMatchShare = 30, --冬季周赛分享加次数
	kRdefSpringWeekMatchShare = 31, --冬季周赛分享加次数
	kAndroidSalesPromotion = 32 , 	--安卓破冰促销
	kReplayDataUploaded = 33,
	kFAQAddIssue = 35,
	kUnlockAreaByTime = 39,
	kAskForHelp = 42,
	kGetShortUrl = 44,
	kUpdateLocation = 45,
	kSkipBindAccountTip = 49,
	kIpPush4010 = 50,
	kAchi = 53,--成就
	kOnlineUnlockArea = 54, 		--新15关开放 倒计时统一解锁
    kSVIPGetPhoneGetReward = 60,	
    kSaveSelectedAnimal = 61,		--占坑 61是暑期活动 存小动物用的
    kOnlineUnlockHide = 62, 		--新隐藏关开放 倒计时统一解锁
	kOnlineUnlockFourStar = 63, 	--新四星关开放 倒计时统一解锁
	kRecommendLevel = 64 ,			--刷星活动 (关卡号用逗号分隔)
	kChangeLevel= 65 ,				--刷新活动 (n,levelId   第n个换成levelId关)
	kFullStarCheck = 66,
	kWarpStep = 68,					
	kWarpColor = 69,				
	kACT1027 = 70, 					--中秋活动占坑
	kShowHideAlert = 71, 			--刷星活动上传已经弹过的隐藏关
	kCoupon = 76,							--春节活动 ip券填写手机号发短信接口
	kPreMagicBirdDiscountIOS = 80,	-- iOS前置魔力鸟打折
}

OpNotifyHttp = class(HttpBase)
function OpNotifyHttp:load(opType, param)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("OpNotifyHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("OpNotifyHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.opNotify, {type = opType, param = param}, loadCallback, rpc.SendingPriority.kHigh, false)
end

LevelConfigUpdateHttp = class(HttpBase)
function LevelConfigUpdateHttp:load(os, version, curMd5)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("LevelConfigUpdateHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("LevelConfigUpdateHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.levelConfigUpdate, {platform = os, version = version, md5 = curMd5}, loadCallback, rpc.SendingPriority.kHigh, false)
end

LevelDifficultyUpdate = class(HttpBase)
function LevelDifficultyUpdate:load(clientVersion, localCfgVersion)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("levelDifficultyUpdate error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("levelDifficultyUpdate success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.levelDifficultyUpdate, {version = clientVersion, md5 = localCfgVersion}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetSummerWeekMatchInfoHttp = class(HttpBase)
function GetSummerWeekMatchInfoHttp:load( levelId )
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetSummerWeekMatchInfoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetSummerWeekMatchInfoHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getSummerWeekMatchInfo, {levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetWeeklyRaceRewardsType = table.const {
	kDailyReward = 0, 
	kWeeklyReward = 1, --普通累计奖励
	--2 老周赛使用
	kLastWeekRankRewards = 3, --上周单次排行奖励
	kLastWeekRewards = 4, --上周所有奖励一起领
	kLastWeekTotalRankRewards = 5, --上周单次、累计排行奖励一起领
}
GetSummerWeekMatchRewardHttp = class(HttpBase)
function GetSummerWeekMatchRewardHttp:load(levelId, type, index, day)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	day = day or 0
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetSummerWeekMatchRewardHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetSummerWeekMatchRewardHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getSummerWeekMatchReward, {levelId = levelId, type = type, index = index, day = day}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 秋季周赛
GetAutumnWeekMatchInfoHttp = class(HttpBase)
function GetAutumnWeekMatchInfoHttp:load( levelId )
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetAutumnWeekMatchInfoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetAutumnWeekMatchInfoHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getSummerWeekMatch2016Info, {levelId = levelId, weekMatchVersion = SeasonWeeklyRaceHttpUtil.weekMatchVersion}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetAutumnWeekMatchRewardHttp = class(HttpBase)
function GetAutumnWeekMatchRewardHttp:load(levelId, type, index, day)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	day = day or 0
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetAutumnWeekMatchRewardHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetAutumnWeekMatchRewardHttp success !")
			context:onLoadingComplete(data)
		end
	end

	local dataT = {
					levelId = levelId,
					type = type, 
					index = index, 
					day = day,
					weekMatchVersion = SeasonWeeklyRaceHttpUtil.weekMatchVersion,
				}
	self.transponder:call(kHttpEndPoints.getSummerWeekMatch2016Reward, dataT, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetMissionInfoHttp = class(HttpBase)
function GetMissionInfoHttp:load()
if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	day = day or 0
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetMissionInfoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetMissionInfoHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getMissionInfo, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

CreateMissionHttp = class(HttpBase)
function CreateMissionHttp:load(userReturnDay, positions, tasks, loginInfo)
if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	day = day or 0
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("CreateMissionHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("CreateMissionHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.createMission, {userReturnDay = userReturnDay, positions = positions,
		tasks = tasks, loginInfo = loginInfo}, loadCallback, rpc.SendingPriority.kHigh, false)
end

-- 特殊状况，道具在上层处理逻辑中添加给用户，所以是一个OnlineGetter
GetMissionRewardHttp = class(HttpBase)
function GetMissionRewardHttp:load(positions)
if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	day = day or 0
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetMissionRewardHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetMissionRewardHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getMissionReward, {positions = positions}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--支付宝签约
GetAliPaymentSign = class(HttpBase)
function GetAliPaymentSign:load(phoneNumber, aliAccount)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetAliPaymentSign error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@GetAliPaymentSign success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getAliPaymentSignV2, {phoneNum = phoneNumber, aliAccount = aliAccount}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--支付宝签约
GetAliPaymentVerify = class(HttpBase)
function GetAliPaymentVerify:load(applyId, smsCode)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetAliPaymentSign error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetAliPaymentSign success !")
			context:onLoadingComplete(data)
		end
	end
	if _G.isLocalDevelopMode then printx(0, "applyId: "..tostring(applyId), "code: "..tostring(smsCode)) end
	self.transponder:call(kHttpEndPoints.getAliPaymentVerify, {applyId = applyId, code = smsCode}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--支付宝签约
GetAliPaymentUnsign = class(HttpBase)
function GetAliPaymentUnsign:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetAliPaymentUnsign error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetAliPaymentUnsign success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getAliPaymentUnsignV2, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--支付宝签约
GetAliIngamePayment = class(HttpBase)
function GetAliIngamePayment:load(tradeId, platform, goodsId, goodsType, num, goodsName, totalFee, checkStr)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetAliIngamePayment error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetAliIngamePayment success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call(kHttpEndPoints.getAliIngamePayment, {tradeId = tradeId, platform = platform, 
						goodsId = goodsId, goodsType = goodsType, num = num, goodsName = goodsName, 
						totalFee = totalFee, checkStr = checkStr}, loadCallback, rpc.SendingPriority.kHigh, false)
end

SendQrCodeHttp = class(HttpBase)
function SendQrCodeHttp:load(raceType, timeStamp, targetCount)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
			context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.sendQrCode, {type = raceType, timestamp = timeStamp, targetCount = targetCount},
		loadCallback, rpc.SendingPriority.kHigh, false)
end

--获取促销信息
GetIosOneYuanPromotionInitInfo = class(HttpBase)
function GetIosOneYuanPromotionInitInfo:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetIosOneYuanPromotionInitInfo error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetIosOneYuanPromotionInitInfo success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call(kHttpEndPoints.getIosOneYuanPromotionInitInfo, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--触发促销
TriggerIosOneYuanPromotion = class(HttpBase)
function TriggerIosOneYuanPromotion:load(promotionType)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("TriggerIosOneYuanPromotion error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("TriggerIosOneYuanPromotion success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call(kHttpEndPoints.triggerIosOneYuanPromotion, {type = promotionType}, loadCallback, rpc.SendingPriority.kHigh, false)
end

--重置道具信息
ResetIosOneYuanShop = class(HttpBase)
function ResetIosOneYuanShop:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("ResetIosOneYuanShop error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("ResetIosOneYuanShop success !")
			context:onLoadingComplete(data)
		end
	end

	self.transponder:call(kHttpEndPoints.resetIosOneYuanShop, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetLevelPawnNumHttp = class(HttpBase)
function GetLevelPawnNumHttp:load(levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetLevelPawnNumHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetLevelPawnNumHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getLevelPawnNum, {levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetLoginInfosHttp = class(HttpBase)
function GetLoginInfosHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetLoginInfos error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetLoginInfos success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getLoginInfos, {deviceUdid = MetaInfo:getInstance():getUdid()}, loadCallback, rpc.SendingPriority.kHigh, false)
end

LoadFriendsByPhoneNumbersHttp = class(HttpBase)
function LoadFriendsByPhoneNumbersHttp:load(phoneNumbers)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("LoadFriendsByPhoneNumbersHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("LoadFriendsByPhoneNumbersHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.loadFriendsByPhoneNumbers, {phoneNumbers = phoneNumbers}, loadCallback, rpc.SendingPriority.kHigh, false)
end

LoadProfilesByUidsHttp = class(HttpBase)
function LoadProfilesByUidsHttp:load(uids)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("LoadProfilesByUidsHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("LoadProfilesByUidsHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.loadProfilesByUids, {uids = uids}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetQQOpenIDHttp = class(HttpBase)
function GetQQOpenIDHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetQQOpenIDHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetQQOpenIDHttp success !")
			context:onLoadingComplete(data)
		end
	end
	self.transponder:call(kHttpEndPoints.getQQOpenID, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetPctOfRank = class(HttpBase)
function GetPctOfRank:load( star )
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
	self.transponder:call(kHttpEndPoints.getPctOfRank, {star = star}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetHideAreaRewardsHttp = class(HttpBase)
function GetHideAreaRewardsHttp:load( hideAreaId )
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
	self.transponder:call(kHttpEndPoints.getHideAreaRewards, { id = hideAreaId }, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetSignHttp = class(HttpBase)
function GetSignHttp:load( fileId, expired )
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
	self.transponder:call(kHttpEndPoints.getSign, { fileId = fileId, expired = expired }, loadCallback, rpc.SendingPriority.kHigh, false)
end

MaRankInfoHttp = class(HttpBase)
function MaRankInfoHttp:load()
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
	self.transponder:call(kHttpEndPoints.maRankInfo, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetUserCommonRewardsHttp = class(HttpBase)
function GetUserCommonRewardsHttp:load(rewardType)
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
	self.transponder:call(kHttpEndPoints.getUserCommonRewards, {type = rewardType}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

ActivityRewardHttp = class(HttpBase)
function ActivityRewardHttp:load(actId , rewardId)
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end    
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("getRewardHttp error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("getRewardHttp success !")
            context:onLoadingComplete(data)
        end
    end
    self.transponder:call("activityReward", { actId = actId , rewardId = rewardId }, loadCallback, rpc.SendingPriority.kHigh, false)
end

GreyPublishRewardHttp = class(HttpBase)
function GreyPublishRewardHttp:load(actId , rewardId)
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end    
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("getRewardHttp error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("getRewardHttp success !")
            context:onLoadingComplete(data)
        end
    end

	local insideVersion = getInsideVersion()

    self.transponder:call("activityReward", { actId = actId , rewardId = rewardId , extra = insideVersion }, loadCallback, rpc.SendingPriority.kHigh, false)
end

WxGetContractUrl = class(HttpBase)
function WxGetContractUrl:load()
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end    
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("WxGetContractUrl error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("WxGetContractUrl success !")
            context:onLoadingComplete(data)
        end
    end
    self.transponder:call(kHttpEndPoints.wxGetContractUrl, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

WxDeleteContract = class(HttpBase)
function WxDeleteContract:load()
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end    
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("WxDeleteContract error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("WxDeleteContract success !")
            context:onLoadingComplete(data)
        end
    end
    self.transponder:call(kHttpEndPoints.wxDeleteContract, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

WxQueryContract = class(HttpBase)
function WxQueryContract:load()
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end    
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("WxQueryContract error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("WxQueryContract success !")
            context:onLoadingComplete(data)
        end
    end
    self.transponder:call(kHttpEndPoints.wxQueryContract, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

WxIngame = class(HttpBase)
function WxIngame:load(tradeId, pf, goodsId, goodsType, num, goodsName, totalFee, checkStr)
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end    
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("WxIngame error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("WxIngame success !")
            context:onLoadingComplete(data)
        end
    end
    self.transponder:call(kHttpEndPoints.wxIngame, 
    {
    	tradeId = tradeId, platform = pf, goodsId = goodsId, goodsType = goodsType,
    	num = num, goodsName = goodsName, totalFee = totalFee, checkStr = checkStr,
    }, loadCallback, rpc.SendingPriority.kHigh, false)
end

getEasterEggReward = class(HttpBase)
function getEasterEggReward:load(animalId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.getEasterEggReward, {animalId = animalId}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

getFriendSingleLevelRank = class(HttpBase)
function getFriendSingleLevelRank:load(friendIdList,levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	kHttpEndPoints.getFriendSingleLevelRank = "getFriendSingleLevelRank"
	self.transponder:call(kHttpEndPoints.getFriendSingleLevelRank, {friendIdList=friendIdList,levelId=levelId}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

recordAndGetTopLevelRank = class(HttpBase)
function recordAndGetTopLevelRank:load(topLevelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	kHttpEndPoints.recordAndGetTopLevelRank = "recordAndGetTopLevelRank"
	self.transponder:call(kHttpEndPoints.recordAndGetTopLevelRank, {topLevelId = topLevelId}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

getBackgroundAchievement = class(HttpBase)
function getBackgroundAchievement:load(achiKeys)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("getBackgroundAchievement", { achiKey = achiKeys }, loadCallback, rpc.SendingPriority.kHigh, false)	
end

GetRefuelPromotionHttp = class(HttpBase)
function GetRefuelPromotionHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("getRefuelPromotion", {}, loadCallback, rpc.SendingPriority.kHigh, false)	
end


GetWeekMatchInfoV1Http = class(HttpBase)
function GetWeekMatchInfoV1Http:load( levelId )
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetWeekMatchInfoV1Http error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetWeekMatchInfoV1Http success !")
			context:onLoadingComplete(data)
		end
	end

	local dataT = {
					levelId = levelId, 
					weekMatchVersion = SeasonWeeklyRaceHttpUtil.weekMatchVersion
				}

	self.transponder:call(kHttpEndPoints.getWeekMatchInfoV1, dataT , loadCallback, rpc.SendingPriority.kHigh, false)
end

GetWeekMatchRewardV1Http = class(HttpBase)
function GetWeekMatchRewardV1Http:load(levelId, type, index, day)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	day = day or 0
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("GetWeekMatchRewardV1Http error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("GetWeekMatchRewardV1Http success !")
			context:onLoadingComplete(data)
		end
	end

	local dataT = {
					levelId = levelId,
					type = type, 
					index = index, 
					day = day,
					weekMatchVersion = SeasonWeeklyRaceHttpUtil.weekMatchVersion,
				}
	self.transponder:call(kHttpEndPoints.getWeekMatchRewardV1, dataT, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetChestRewardsHttp = class(HttpBase)
function GetChestRewardsHttp:load(chestId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("getChestRewards", {chestId = chestId}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

GetVideoSDKInfoHttp = class(HttpBase)
function GetVideoSDKInfoHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("getVideoSDKInfo", {}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

GetVideoSDKInfoV2Http = class(HttpBase)
function GetVideoSDKInfoV2Http:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("getVideoSDKInfoV2", {}, loadCallback, rpc.SendingPriority.kHigh, false)	
end


GetVideoSDKTurntableRewardHttp = class(HttpBase)
function GetVideoSDKTurntableRewardHttp:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("getVideoSDKTurntableReward", params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

InvokeVideoSDKErrorHttp = class(HttpBase)
function InvokeVideoSDKErrorHttp:load(ads)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("invokeVideoSDKError", {sdkId = ads}, loadCallback, rpc.SendingPriority.kHigh, false)
end

InvokeVideoSDKHttp = class(HttpBase)
function InvokeVideoSDKHttp:load(sdkId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("invokeVideoSDK", {sdkId = sdkId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetSharePageSignHttp = class(HttpBase)
function GetSharePageSignHttp:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("getSharePageSign", {params = params}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

ShareMomentsSwitchHttp = class(HttpBase)
function ShareMomentsSwitchHttp:load(appId, shareType)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("shareMomentsSwitch", {appid = appId, shareType = shareType}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

ShareMomentsSuccHttp = class(HttpBase)
function ShareMomentsSuccHttp:load(appId, shareType)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call("shareMomentsSucc", {appid = appId, shareType = shareType}, loadCallback, rpc.SendingPriority.kHigh, false)	
end


RecoveryLevelHttp = class(HttpBase)
function RecoveryLevelHttp:load(md5)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call( "recoveryLevel" , {md5=md5}, loadCallback, rpc.SendingPriority.kHigh, false)	
end


GetPassLevelDataHttp = class(HttpBase)
function GetPassLevelDataHttp:load(passLevelDataKeys , propSeedKeys , propSeedLogLevelIds , virtualModeLogLevelIds , levelLeftMoves , levelTargetProgress)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	local datas = {
					levelVersion=GamePlayClientVersion,
					passLevelDataKeys=passLevelDataKeys,
					propSeedKeys=propSeedKeys,
					propSeedLogLevelIds=propSeedLogLevelIds,
					virtualModeLogLevelIds=virtualModeLogLevelIds,
					levelLeftMoves = levelLeftMoves,
					levelTargetProgress = levelTargetProgress,
				}

	self.transponder:call( "getPassLevelData" , datas , loadCallback, rpc.SendingPriority.kHigh, false)	
end

MonthCardInfoHttp = class(HttpBase)
function MonthCardInfoHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call( "monthCardInfo" , {} , loadCallback, rpc.SendingPriority.kHigh, false)	
end


GetDifficultyTagHttp = class(HttpBase)
function GetDifficultyTagHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call( "getDifficultyTag" , {} , loadCallback, rpc.SendingPriority.kHigh, false)	
end

OppoLaunchRewardHttp = class(HttpBase)
function OppoLaunchRewardHttp:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local context = self

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call( "oppoCustomInfo" , {} , loadCallback, rpc.SendingPriority.kHigh, false)	
end

AFHGetFriends = class(HttpBase)
function AFHGetFriends:load(type, params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("AFHGetFriends fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("AFHGetFriends success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.getSortedFriends, {type=type, params=params or {}}, loadCallback, rpc.SendingPriority.kHigh, false)
end

StrategyGetLevels = class(HttpBase)
function StrategyGetLevels:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("StrategyGetLevels fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("StrategyGetLevels success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.getRaidersInfo, {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

StrategyGetRelay = class(HttpBase)
function StrategyGetRelay:load(levelId)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local cMd5 = ResourceLoader.getCurVersion()
	local lMd5 = nil
	local meta = LevelMapManager.getInstance():getMeta(levelId)
	if meta then
		lMd5 = LevelDifficultyAdjustManager:getMD5ByLevelMeta(meta)
	end
	local vs = _G.bundleVersion

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("StrategyGetRelay fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("StrategyGetRelay success")
	    	context:onLoadingComplete(data)
	    end
	end
	self.transponder:call(kHttpEndPoints.getRaidersReplay, {level = levelId, clientMd5 = cMd5, levelMd5 = lMd5, version = vs}, loadCallback, rpc.SendingPriority.kHigh, false)
end

StarJarInfo = class(HttpBase)
function StarJarInfo:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("StarJarInfo fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("StarJarInfo success")
	    	context:onLoadingComplete(data)
	    end
	end

	local data = {}
	if params then
		data = params
	end
	self.transponder:call("starJarInfo", data, loadCallback, rpc.SendingPriority.kHigh, false)
end

StarJarInfoVTwo = class(HttpBase)
function StarJarInfoVTwo:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("StarJarInfoVTwo fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("StarJarInfoVTwo success")
	    	context:onLoadingComplete(data)
	    end
	end

	local data = {}
	if params then
		data = params
	end
	self.transponder:call("starJarInfoV2", data, loadCallback, rpc.SendingPriority.kHigh, false)
end

AchievementRank = class(HttpBase)
function AchievementRank:load(params)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("AchievementRank fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("AchievementRank success")
	    	context:onLoadingComplete(data)
	    end
	end

	local data = {}
	if params then
		data = params
	end
	self.transponder:call("achievementRank", data, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetRecommendFriendInfo = class(HttpBase)
function GetRecommendFriendInfo:load()
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("GetRecommendFriendInfo fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("GetRecommendFriendInfo success")
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call("recommendFriendsWithLimit", {}, loadCallback, rpc.SendingPriority.kHigh, false)
end

AcceptRecommendFriendAndReward = class(HttpBase)
function AcceptRecommendFriendAndReward:load(_uids)
	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("AcceptRecommendFriendAndReward fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("AcceptRecommendFriendAndReward success")
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call("acceptRecommendAndReward", {uids = _uids}, loadCallback, rpc.SendingPriority.kHigh, false)
end