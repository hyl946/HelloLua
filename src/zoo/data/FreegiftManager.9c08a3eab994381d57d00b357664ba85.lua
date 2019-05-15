require "zoo.data.UserManager"

RequestType = {
	kNeedUpdate = 0,
	kReceiveFreeGift = 1,--别人送精力
	kSendFreeGift = 2,--别人请求精力
    kUnlockLevelArea = 3,--请求帮解锁
    kAddFriend = 5,--请求加好友
    kActivity = 6,--活动相关
    kLevelSurpass = 7,   -- 好友关卡超越
    kLevelSurpassLimited = 8, -- 后端用来限制数量的类型，功能同上
    kPassLastLevelOfLevelArea = 9, -- 好友超越区域最后一关
    kScoreSurpass = 10,  -- 好友分数超越
    kPassMaxNormalLevel = 11, -- 好友通过版本最高关卡
    kPushEnergy = 12,   -- NPC免费精力推送
    kDengchaoEnergy = 13, -- 邓超送经理
    kWeeklyRace = 14,
    kThanks = 15, --要答谢的推送
    kClover_AddFriend = 16, -- 消消乐2
    kLevelSurpassNation = 17,--好友过关
    kScoreSurpassNation = 18,--好友过关
    kWeeklySurpassNation = 19,--好友过关
    kPushActivity = 20, -- 活动入口, 跟kActivity用处不同
	kAskForHelp = 21,--好友求过关
	kAskForHelpSuccess = 22, -- 代打成功
	kFriendWithEnergy = 23,	--新加的好友 提示送精力
	kActRecallRemind = 24, 	--召回活动 被召回的玩家收到新鲜事提醒
	kFCGift = 25, 	--礼包，来自fc工具的补偿等
	kThanksForYourFullGift = 26,
	KFLGInbox = 27 , --收到红包类型
	kMergedThanksForYourFullGift = -26, -- 只在前端存在
    kNewVersionRewardItem = -25, --新版本奖励
	
}

local getMessageLimit = {
	kAll = 180,            -- 消息中心最大消息数
	kNeedUpdate = 10,      -- 神秘消息（优先级最低）
	kReceiveFreeGift = 20, -- 收取精力
	kSendFreeGift = 40,    -- 发送精力
    kUnlockLevelArea = 20, -- 区域解锁
    kAddFriend = 30,       -- 加好友
    kActivity = 10,        -- 活动帮助
    kNews = 30,            -- 新鲜事
    kPushActivity = 10,	   -- 推广消2新加的
	kAskForHelp = 10,	   -- 帮好友闯关
}

MergedMessageType = {
	RequestType.kThanksForYourFullGift,
}

--前端自己加的信件 不是后端发来的 ids
local messageClientIDs = {
    kNewVersionRewardID = -101,
}



FreegiftManager = class()

local freegiftManager = nil
function FreegiftManager:sharedInstance()
	if not freegiftManager then
		freegiftManager = FreegiftManager.new()
		freegiftManager:init()
	end
	return freegiftManager;
end

function FreegiftManager:init()
	self.requestInfos = {}
	self.leftFreegiftInfos = {}
	self.lockedSendIds = {}
	self.lockedReceiveCount = 0
	self.pushMessages = {}
end

function FreegiftManager:isMergedMessageType( _type )
	return table.indexOf(MergedMessageType, _type) ~= nil
end

function FreegiftManager:update(load, callback)
	local function onSuccess(evt)
		local panelConfig = require 'zoo.panel.messageCenter.PanelConfig'
		panelConfig.clearUpdateIgnoreType()
		self:setHelpRequestTip(evt.data.rewardLimitDesc)

        ---版本更新奖励
        local hasReward = NewVersionUtil:hasUpdateReward()
--        hasReward = true --test  UserManager:changeRequestNum() 里面也有test 一起开生效
	    if hasReward then
            local Info = {}
            Info.id = messageClientIDs.kNewVersionRewardID
            Info.type = RequestType.kNewVersionRewardItem
		    Info.rewards = UserManager.getInstance().updateRewards or {{itemId = 10003, num = 8}}
            if not evt.data.requestInfos then
                evt.data.requestInfos = {}
            end

            table.insert(evt.data.requestInfos, 1, Info)
	    end
        --

		if evt.data.requestInfos then
			self.requestInfos = evt.data.requestInfos
		end

		local __filtered = {}

		local activityList = PushActivity:getActivityList()
		local rules = require 'zoo.panel.askForHelp.AskForHelpRules'

		for k, v in ipairs(self.requestInfos) do
			if v.type == RequestType.kPushActivity then
				local actId = v.itemId
				if table.find(activityList, function ( actInfo )
					return tostring(actInfo.actId) == tostring(actId)
				end) then
					table.insert(__filtered, v)
				end
			elseif v.type == RequestType.kAskForHelp then
				if rules:isValidMessage(v.senderUid, v.itemId) then
					table.insert(__filtered, v)
				end
			else
				table.insert(__filtered, v)
			end
		end

		self.requestInfos = __filtered

		__filtered = nil

		local requestNum = #self.requestInfos

		-- self.requestInfos = {}
		-- for j=1,200 do
		-- 	-- for k,i in pairs(RequestType) do
		-- 		table.insert(self.requestInfos,{
		-- 			id=j,
		-- 			type=(j%2)+1,
		-- 			senderUid=j,
		-- 			itemId=10012,
		-- 			itemNum=1,
		-- 			receiveDay=16944,
		-- 		})
		-- 	-- end
		-- end

		self.maxMessageID = evt.data.maxId



		self.invalidGiftRequest = {}
		for k, v in ipairs(self.requestInfos) do
			if (v.type == RequestType.kSendFreeGift or v.type == RequestType.kReceiveFreeGift) and
				not BagManager:getInstance():isValideItemId(v.itemId) then
					v.originType = v.type
					v.type = 0--神秘来信
					table.insert(self.invalidGiftRequest, v)
			else
				local found = false
				for i, j in pairs(RequestType) do
					if v.type == j then
						found = true
						break
					end
				end
				if not found then--神秘来信
					panelConfig.addUpdateIgnoreType(v.type)
					v.originType = 0
					v.type = 0
				else
					v.originType = v.type
				end
			end
			if evt.data.inviteProfiles then
				for i, j in ipairs(evt.data.inviteProfiles) do
					if j.uid == v.senderUid then
						if j.name then v.name = nameDecode(j.name) end
						if j.headUrl then v.headUrl = j.headUrl end
						v.profile = j
					end
				end
			end


			if evt.data.inviteAchievements then
				for i, j in ipairs(evt.data.inviteAchievements) do
					if j.uid == v.senderUid then
						v.achievement = j
					end
				end
			end

			if evt.data.inviteUsers then
				for i, j in ipairs(evt.data.inviteUsers) do
					if j.uid == v.senderUid then
						v.user = j
					end
				end
			end
		end

		local myTopLevel = UserManager:getInstance().user:getTopLevelId()

		self.pushMessages = {}
		local hasFriendEnergyRequest = false
		local hasDengchaoEnergy = false
		local limit = {}
		for k, v in pairs(getMessageLimit) do limit[k] = v end
		local tmpList = {}

		local hasThanks = false
		local passTopLevelId = 0
		local passTopLevelUids = {}
		local needSync = false

		local mergedMsgCounter = {}

		for k, v in ipairs(self.requestInfos) do
			if self:isMergedMessageType(v.type) then
				mergedMsgCounter[v.type] = (mergedMsgCounter[v.type] or 0) + 1
			end
		end

		for _type, num in pairs(mergedMsgCounter) do
			if num >= 3 then
				mergedMsgCounter[_type] = 1
			end
		end

		for k, v in ipairs(self.requestInfos) do
			if v.type == RequestType.kSendFreeGift and limit.kSendFreeGift > 0 then
				table.insert(tmpList, v)
				limit.kSendFreeGift = limit.kSendFreeGift - 1
				limit.kAll = limit.kAll - 1
				hasFriendEnergyRequest = true
			elseif v.type == RequestType.kReceiveFreeGift and limit.kReceiveFreeGift > 0 then
				table.insert(tmpList, v)
				limit.kReceiveFreeGift = limit.kReceiveFreeGift - 1
				limit.kAll = limit.kAll - 1
				hasFriendEnergyRequest = true
			elseif v.type == RequestType.kUnlockLevelArea and limit.kUnlockLevelArea > 0 then
				table.insert(tmpList, v)
				limit.kUnlockLevelArea = limit.kUnlockLevelArea - 1
				limit.kAll = limit.kAll - 1
			elseif (v.type == RequestType.kAddFriend or v.type == RequestType.kFriendWithEnergy) and limit.kAddFriend > 0 then
				table.insert(tmpList, v)
				limit.kAddFriend = limit.kAddFriend - 1
				limit.kAll = limit.kAll - 1
			elseif v.type == RequestType.kActivity and limit.kActivity > 0 then
				table.insert(tmpList, v)
				limit.kActivity = limit.kActivity - 1
				limit.kAll = limit.kAll - 1
			elseif ((v.type >= RequestType.kLevelSurpass and v.type <= RequestType.kPassMaxNormalLevel) 
			or v.type == RequestType.kWeeklyRace
			or v.type == RequestType.kThanksForYourFullGift
			or v.type == RequestType.kMergedThanksForYourFullGift
			or v.type == RequestType.kAskForHelpSuccess
			or (v.type >= RequestType.kLevelSurpassNation and v.type <= RequestType.kWeeklySurpassNation)
			or v.type == RequestType.kActRecallRemind)
			and limit.kNews > 0 then
				if v.type == RequestType.kPassMaxNormalLevel then
					local levelId = tonumber(v.itemId) or 0
					if levelId >= myTopLevel then -- 如果好友的最大关卡<=我的topLevelId就不显示
						table.insert(tmpList, v)
						limit.kNews = limit.kNews - 1
						limit.kAll = limit.kAll - 1

						if passTopLevelId < levelId then
							passTopLevelId = levelId
						end

						table.insert(passTopLevelUids,v.senderUid)
					end
				elseif mergedMsgCounter[v.type] then
					table.insert(tmpList, v)
					if mergedMsgCounter[v.type] > 0 then
						--printx(61, 'mergedMsgCounter[v.type]', mergedMsgCounter[v.type])
						mergedMsgCounter[v.type] = mergedMsgCounter[v.type] - 1
						limit.kNews = limit.kNews - 1
						limit.kAll = limit.kAll - 1
					end
				else
					table.insert(tmpList, v)
					limit.kNews = limit.kNews - 1
					limit.kAll = limit.kAll - 1
				end
			elseif v.type == RequestType.kPushEnergy or v.type == RequestType.kDengchaoEnergy then
				table.insert(self.pushMessages, v)
				if v.type == RequestType.kDengchaoEnergy then
					hasDengchaoEnergy = true
				end
			elseif v.type == RequestType.kNeedUpdate and limit.kNeedUpdate > 0 then
				table.insert(tmpList, v)
				limit.kNeedUpdate = limit.kNeedUpdate - 1
				limit.kAll = limit.kAll - 1
			elseif v.type == RequestType.kThanks then
				table.insert(tmpList,v)
				hasThanks = true
			elseif v.type == RequestType.kPushActivity and limit.kPushActivity > 0 then
				limit.kPushActivity = limit.kPushActivity - 1
				limit.kAll = limit.kAll - 1
				table.insert(tmpList,v)
			elseif v.type == RequestType.kAskForHelp and limit.kAskForHelp > 0 then
				limit.kAskForHelp = limit.kAskForHelp - 1
				limit.kAll = limit.kAll - 1
				table.insert(tmpList, v)
			elseif v.type == RequestType.kFCGift and limit.kNews > 0 then
			    local data = table.deserialize(v.extra or "") or {}
			    if data.items then
			        local r=string.split2(data.items,",")
			        for i,v in pairs(r) do
			            local l = string.split2(v,":")
			            r[tonumber(i)]={id=tonumber(l[1]),num=tonumber(l[2])}
			        end
			        data.items=r
			    end
			    v.extraData=data
			    local hadTime = data.time and UserManager.getInstance().currentLoginTime
			    if hadTime and UserManager.getInstance().currentLoginTime<data.time then
			    	requestNum=requestNum-1
			    else
					limit.kNews = limit.kNews - 1
					limit.kAll = limit.kAll - 1
					table.insert(tmpList, v)
					needSync = true
			    end
			elseif v.type == RequestType.KFLGInbox and limit.kNews > 0 then
			    local data = table.deserialize(v.extra or "") or {}
			    if data.items then
			        local r=string.split2(data.items,",")
			        for i,v in pairs(r) do
			            local l = string.split2(v,":")
			            r[tonumber(i)]={id=tonumber(l[1]),num=tonumber(l[2])}
			        end
			        data.items=r
			    end
			    v.extraData=data
			    -- local hadTime = data.time and UserManager.getInstance().currentLoginTime
			    -- if hadTime and UserManager.getInstance().currentLoginTime<data.time then
			    -- 	requestNum=requestNum-1
			    -- else
					limit.kNews = limit.kNews - 1
					limit.kAll = limit.kAll - 1
					table.insert(tmpList, v)
					needSync = true
			    -- end
            elseif v.type == RequestType.kNewVersionRewardItem and limit.kNews > 0 then
                limit.kNews = limit.kNews - 1
				limit.kAll = limit.kAll - 1
				table.insert(tmpList, v)
			end
			if limit.kAll <= 0 then break end
		end

        if needSync then
	        RequireNetworkAlert:callFuncWithLogged(function( ... )
	            local logic = SyncExceptionLogic:create()
	            logic:syncData(nil, nil, kRequireNetworkAlertAnimation.kNoAnimation)
	        end,nil,kRequireNetworkAlertAnimation.kSync)
	    end

		-- 消消乐2的独立计算
		local cloverAddFriendRequestNum = 0
		local isCloverInviteEnable = self:isCloverInviteEnable()
		for k, v in ipairs(self.requestInfos) do
			if v.type == RequestType.kClover_AddFriend then
				if isCloverInviteEnable then
					cloverAddFriendRequestNum = cloverAddFriendRequestNum + 1
					table.insert(tmpList,v)
				else -- 过滤掉消消乐2邀请的请求
					requestNum = requestNum - 1
				end
			end
		end

		self.requestInfos = tmpList

		UserManager:getInstance().requestNum = requestNum
		UserManager:getInstance():setRequestInfos(evt.data.requestInfos)

		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))

		if hasFriendEnergyRequest then
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kReceiveFriendEnergyRequest))
		end
		if hasDengchaoEnergy then
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kDengchaoEnergy))
		end

		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kCloverAddFriendRequest, {num=cloverAddFriendRequestNum}))

		if callback then callback("success", evt) end

		if load then
			-- 看到感谢消息，更新成就数据
			if hasThanks then
				self:updatePopularityData()
			end

			-- 获取第一个通关的好友，
			if passTopLevelId > 0 then
				self:getFirstPassLevelData(passTopLevelId,passTopLevelUids)
			end

		end
	end

	local function onFail(evt)
		self:setHelpRequestTip(nil)
		if callback then callback("fail", evt) end
	end

	if load == nil then load = false end
	local http = GetRequestInfoHttp.new(load)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:load()
end

function FreegiftManager:isCloverInviteEnable()
	local uid = UserManager:getInstance().uid
	return MaintenanceManager:getInstance():isAvailbleForUid("CloverInvite", uid)
end

function FreegiftManager:getIgnoreRequestTypes()
	local ret = {}
	if not self:isCloverInviteEnable() then
		table.insert(ret, RequestType.kClover_AddFriend)
	end

	local activityList = PushActivity:getActivityList()
	if not table.find(activityList, function ( actInfo )
		return tostring(actInfo.actId) == tostring(169) --消二推广actid
	end) then
		table.insert(ret, RequestType.kPushActivity)
	end

	return ret
end

function FreegiftManager:updatePopularityData( ... )
	local http = getBackgroundAchievement.new(false)
	http:ad(Events.kComplete,function( evt )
		local achiValue = evt.data.achiValue or {}
		local curLikeCount = 0
		for k,v in pairs(achiValue) do
			if v.key == AchiId.kTotalGetLikeCount then
				curLikeCount = v.value break
			end
		end
		local lastLikeCount = UserManager:getInstance().userExtend:getAchievementValue(AchiId.kTotalGetLikeCount) or 0
		local addcount = curLikeCount - lastLikeCount
		if addcount > 0 then
			Notify:dispatch("AchiEventDataUpdate",AchiDataType.kGetLikeAddCount, addcount)
		end
	end)
	http:load({AchiId.kTotalGetLikeCount})
end

function FreegiftManager:getFirstPassLevelUid( passTopLevelId )
	if self.cacheFirstPassLevelData then
		return self.cacheFirstPassLevelData[passTopLevelId]
	end
end

function FreegiftManager:getFirstPassLevelData( passTopLevelId,passTopLevelUids )
	if self.cacheFirstPassLevelData and self.cacheFirstPassLevelData[passTopLevelId] then
		return
	end

	local friendIds = UserManager:getInstance().friendIds
	local friends = FriendManager.getInstance().friends

	local friendIdList = {}
	for k,v in pairs(friendIds) do
		if friends[v] and friends[v].topLevelId >= passTopLevelId then
			table.insert(friendIdList,v)
		end
	end

	for k,v in pairs(passTopLevelUids) do
		if not table.includes(friendIdList,v) then
			table.insert(friendIdList,v)
		end
	end

	self.cacheFirstPassLevelData = {}

	local http = getFriendSingleLevelRank.new(false)	
	http:addEventListener(Events.kComplete, function( evt )
		local ranks = {}
		if evt.data.ranks and #evt.data.ranks > 0 then
			ranks = evt.data.ranks
		end

		local uid = nil
		local t = nil
		for k,v in pairs(ranks) do
			if not t then
				t = v.timeStamp
				uid = v.uid
			end
			if t > v.timeStamp then
				t = v.timeStamp
				uid = v.uid
			end
		end

		if uid then
			-- 只缓存一个
			self.cacheFirstPassLevelData = { [passTopLevelId] = uid }
			
			GlobalEventDispatcher:getInstance():dispatchEvent(
				Event.new(MessageCenterPushEvents.kGetFirstPassLevelUidComplete,uid)
			)
		end
	end)
	http:load(friendIdList,passTopLevelId)
end

function FreegiftManager:updateFriendInfos(load, callback)
	local function onSuccess(evt)
		if evt.data.leftFreegiftInfos then
			self.leftFreegiftInfos = evt.data.leftFreegiftInfos
		end
		if callback then callback("success", evt) end
	end
	local function onFail(evt)
		if callback then callback("fail", evt) end
	end
	if load == nil then load = true end
	local http = GetLeftAskInfoHttp.new(load)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:load()
end

function FreegiftManager:getSendGiftList(callback)
	if inRequestGiftLock then
		return false
	else
		local function onSuccess(evt)
			if callback then callback(true, evt.data.uids) end
		end
		local function onFail(evt)
			local errcode = evt and evt.data or nil
	        if errcode then
	            local scene = Director:sharedDirector():run()
	            if  scene ~= nil then
	                CommonTip:showTip(localize("error.tip."..tostring(errcode)), "negative")
	            end
	        end
	        callback(false, nil, errcode)
		end
		if load == nil then load = true end
		local http = AskEnergyGetUids.new(load)
		http:ad(Events.kComplete, onSuccess)
		http:ad(Events.kError, onFail)
		http:load()
	end
	return true
end

function FreegiftManager:getMessageNumByType(msgType)
	if type(msgType) ~= "table" then return #self.requestInfos end
	local res = 0
	for k, v in ipairs(self.requestInfos) do
		for k2, v2 in ipairs(msgType) do
			if v.type == v2 then
				res = res + 1
				break
			end
		end
	end
	for k, v in ipairs(self.pushMessages) do
		for k2, v2 in ipairs(msgType) do
			if v.type == v2 then
				res = res + 1
				break
			end
		end
	end
	return res
end

function FreegiftManager:getMessages(msgType)
	if type(msgType) ~= "table" then return self.requestInfos end
	local res = {}
	for k2, v2 in ipairs(msgType) do
		for k, v in ipairs(self.requestInfos) do
			if v.type == v2 then
				table.insert(res, v)
				-- break
			end
		end
	end

    --找出更新奖励插入到最前
    local findRewardIndex = 0
    for i,v in ipairs(res) do
        if v.type == RequestType.kNewVersionRewardItem then
            findRewardIndex = i
            break
        end
    end

    if findRewardIndex ~= 0 then
        local copyTab = table.clone( res[findRewardIndex] )
        table.remove( res,findRewardIndex )
        table.insert( res, 1, table.clone( copyTab ) )
    end

	return res
end

function FreegiftManager:getPushMessages(msgType)
	if type(msgType) ~= "table" then return self.pushMessages end
	local ret = {}

	for k, v in pairs(self.pushMessages) do
		for k2, v2 in pairs(msgType) do
			if v.type == v2 then
				table.insert(ret, v)
				break
			end
		end
	end
	return ret

end

function FreegiftManager:getMessageById(id)
	for k, v in pairs(self.requestInfos) do
		if v.id == id then
			return v
		end
	end
	return nil, 0
end

function FreegiftManager:removeMessageById(id)
	for k, v in pairs(self.requestInfos) do
		if v.id == id then
			table.remove(self.requestInfos, k)
			return
		end
	end
end

function FreegiftManager:removeMessageByTypes(msgTypes)
	for i=1, #msgTypes do
		for j=#self.requestInfos, 1, -1 do
			if self.requestInfos[j].type == msgTypes[i] then
				table.remove(self.requestInfos, j)
			end
		end
	end
end

function FreegiftManager:getFriends()
	return self.leftFreegiftInfos
end

function FreegiftManager:getCanGiveFriends()
	local wantIds = UserManager:getInstance():getWantIds()

	local res = {}
	local function findId(target)
		for k, v in ipairs(wantIds) do
			if tonumber(v) == target then return true end
		end
		return false
	end
	for k, v in ipairs(self.leftFreegiftInfos) do
		if v.dailyLeftFreeGiftCount > 0 and not findId(tonumber(v.friendUid)) then
			table.insert(res, v)
		end
	end
	return res
end

local inRequestGiftLock = false
function FreegiftManager:requestGift(uids, itemId, successCallback, failCallback, withLoading)
	local function onSuccess(data)
		inRequestGiftLock = false
		UserManager:getInstance():addWantIds(uids)
		if successCallback then successCallback(data) end
	end

	local function onFail(err)
		inRequestGiftLock = false
		if failCallback then failCallback(err) end
	end

	inRequestGiftLock = true
	withLoading = withLoading or false
	local http = SendFreegiftHttp.new(withLoading)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)

	local function afterRequestSent( ... )
	end

	if WXJPPackageUtil.getInstance():isWXJPLoginWX() then 
		local WXJPConfirmPanel = require "zoo.panel.WXJPConfirmPanel"
		local panel = WXJPConfirmPanel:create("请求已发送，是否微信告诉TA？", function ()
			http:load(2, nil, uids, itemId, true)
			afterRequestSent()
		end, function ()
			http:load(2, nil, uids, itemId)
			afterRequestSent()
		end)
		panel:popout()
	else
		http:load(2, nil, uids, itemId)
		afterRequestSent()
	end
end

-- local ___i = 1
function FreegiftManager:sendGiftTo(receiverUid, successCallback, failCallback, withLoading)
	-- 好友排行中的给好友送东西，这个功能已经不存在了。
	-- 还有调用，所以不删除接口，然而调了也不会有什么卵用。
	-- 不好意思，这个功能又加回来了，以后别乱删代码。
	local function onFail(err)

		UserManager:getInstance():removeSendId(receiverUid)
		if failCallback then failCallback(err) end
	end

	local function onSuccess(data)
		-- if ___i == 4 or ___i == 5 then 
		-- 	onFail()
		-- end
		-- ___i = ___i+1
		if successCallback then successCallback(data) end
	end
	UserManager:getInstance():addSendId(receiverUid)

	-- HomeScene:sharedInstance():runAction(CCSequence:createWithTwoActions(CCDelayTime:create(4), CCCallFunc:create(onSuccess)))

	withLoading = withLoading or false
	local http = SendFreegiftHttp.new(withLoading)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	--(sendType, messageId, targetUids, itemId)
	http:load(1, nil, {receiverUid}, 10012)
end

function FreegiftManager:sendGift(id, successCallback, failCallback, isBatch)
	self:doSendGift(id, successCallback, failCallback, isBatch, false)
end

function FreegiftManager:sendBackGift(id, successCallback, failCallback, isBatch)
	self:doSendGift(id, successCallback, failCallback, isBatch, true)
end

function FreegiftManager:doSendGifts(messageids, successCallback, failCallback)
	-- local message = self:getMessageById(id)

	local messages = {}

	for i=1,#messageids do
		local messageNode = self:getMessageById(messageids[i]) 
		if messageNode then
			table.insert( messages , messageNode )
		else

		end
	end
	
	if #messages == 0 then
		if failCallback then failCallback() end
		return
	end

	local funcCalled = false
	local function sendFail(data)
		for k, v in ipairs(self.lockedSendIds) do

			local hasIt = table.find( messageids , function ( value_id )
				return value_id == v
			end )
			if hasIt then
				table.remove(self.lockedSendIds, k)
				break
			end
		end
		if failCallback and not funcCalled then
			failCallback(data)
			funcCalled = true
		end
	end

	local function ignoreFail(err)
		for k, v in ipairs(self.lockedSendIds) do
			local hasIt = table.find( messageids , function ( value_id )
					return value_id == v
				end )
			if hasIt then
				table.remove(self.lockedSendIds, k)
				break
			end
		end
		if failCallback and not funcCalled then
			failCallback(err)
			funcCalled = true
		end
	end
	local function ignoreSuccess(data)
		-- UserManager:getInstance():addSendId(message.senderUid)

		for i=1,#messages do
			UserManager:getInstance():addSendId(messages[i].senderUid)
		end

		for k, v in ipairs(self.lockedSendIds) do
			local hasIt = table.find( messageids , function ( value_id )
				return value_id == v
			end )
			if hasIt then
				table.remove(self.lockedSendIds, k)
				break
			end
		end
		for i=1,#messageids do
			local id = messageids[i]
			self:removeMessageById(id)
			UserManager:getInstance().requestNum = UserManager:getInstance().requestNum - 1
		end
		
		if successCallback and not funcCalled then
			successCallback(data)
			funcCalled = true
		end
	end
	local senderUidTable = {}
	for i=1,#messages do
		local senderUid = messages[i].senderUid
		table.insert(self.lockedSendIds, senderUid)
		table.insert(senderUidTable, senderUid) 
	end

	-- table.insert(self.lockedSendIds, message.senderUid)


	local sendHttp = SendFreegiftHttp.new()
	sendHttp:addEventListener(Events.kError, sendFail)
	sendHttp:ad(Events.kComplete, ignoreSuccess)
	sendHttp:ad(Events.kError, ignoreFail)
	sendHttp:load2(1, messageids,senderUidTable, messages[1].itemId)
	
	-- local http = IgnoreFreegiftHttp.new(false)
	-- http:ad(Events.kComplete, ignoreSuccess)
	-- http:ad(Events.kError, ignoreFail)
	-- http:load(id)


	if not isBatch then ConnectionManager:flush() end
end
function FreegiftManager:doSendGift(id, successCallback, failCallback, isBatch, isSendBack,doNotSendHttp)
	local message = self:getMessageById(id)
	if not message then
		if failCallback then failCallback() end
		return
	end

	local funcCalled = false
	local function sendFail(data)
		for k, v in ipairs(self.lockedSendIds) do
			if v == message.senderUid then
				table.remove(self.lockedSendIds, k)
				break
			end
		end
		if failCallback and not funcCalled then
			failCallback(data)
			funcCalled = true
		end
	end
	local function ignoreFail(err)
		for k, v in ipairs(self.lockedSendIds) do
			if v == message.senderUid then
				table.remove(self.lockedSendIds, k)
				break
			end
		end
		if failCallback and not funcCalled then
			failCallback(err)
			funcCalled = true
		end
	end
	local function ignoreSuccess(data)
		UserManager:getInstance():addSendId(message.senderUid)
		for k, v in ipairs(self.lockedSendIds) do
			if v == message.senderUid then
				table.remove(self.lockedSendIds, k)
				break
			end
		end
		self:removeMessageById(id)
		UserManager:getInstance().requestNum = UserManager:getInstance().requestNum - 1
		if successCallback and not funcCalled then
			successCallback(data)
			funcCalled = true
		end
	end

	table.insert(self.lockedSendIds, message.senderUid)
	if not isBatch then ConnectionManager:block() end
	local sendHttp = SendFreegiftHttp.new()
	sendHttp:addEventListener(Events.kError, sendFail)
	if isSendBack then
		sendHttp:load(1, nil, {message.senderUid}, message.itemId)
	else
		sendHttp:load(1, id, {message.senderUid}, message.itemId)
	end
	local http = IgnoreFreegiftHttp.new(false)
	http:ad(Events.kComplete, ignoreSuccess)
	http:ad(Events.kError, ignoreFail)
	http:load(id)
	if not isBatch then ConnectionManager:flush() end
end

function FreegiftManager:ignoreFreegift(id, successCallback, failCallback)
	local message = self:getMessageById(id)
	if not message then
		if failCallback then failCallback() end
		return
	end

	local function onSuccess(data)
		self:removeMessageById(id)
		UserManager:getInstance().requestNum = UserManager:getInstance().requestNum - 1
		if successCallback then successCallback(data) end
	end

	local function onFail(err)
		if failCallback then failCallback(err) end
	end

	local http = IgnoreFreegiftHttp.new(false)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:load(id)
end

function FreegiftManager:acceptFreegift(id, successCallback, failCallback)
	local message = self:getMessageById(id)
	if not message then
		if failCallback then failCallback() end
		return
	end

	local function onSuccess(data)
		UserManager:getInstance():incReceiveGiftCount()
		self.lockedReceiveCount = self.lockedReceiveCount - 1
		UserManager:getInstance():addUserPropNumber(message.itemId, message.itemNum)
		UserManager:getInstance().requestNum = UserManager:getInstance().requestNum - 1

		GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kMessageCenter, message.itemId, message.itemNum, DcSourceType.kFreeGift)

		if successCallback then successCallback(data) end
	end

	local function onFail(err)
		-- UserManager:getInstance():decReceiveGiftCount()
		self.lockedReceiveCount = self.lockedReceiveCount - 1
		if failCallback then failCallback(err) end
	end

	-- UserManager:getInstance():incReceiveGiftCount()
	self.lockedReceiveCount = self.lockedReceiveCount + 1
	local http = AcceptFreegiftHttp.new(false)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:load(id)
	-- onSuccess()
end

function FreegiftManager:getReceivedNum()
	local maxCount = MetaManager:getDailyMaxReceiveGiftCount()
	local receivedCount = UserManager:getInstance():receiveGiftCount()
	return maxCount - receivedCount
end

function FreegiftManager:getSentNum()
	local max = MetaManager:getInstance():getDailyMaxSendGiftCount()
	local sendIds = UserManager:getInstance():getSendIds()
	local sentCount = #sendIds
	return max - sentCount
end

function FreegiftManager:canSendMore()
	local max = MetaManager:getInstance():getDailyMaxSendGiftCount()
	local sendIds = UserManager:getInstance():getSendIds()
	local sentCount = #sendIds
	-- max = 5
	local newestCfg = Localhost.getInstance():getUpdatedGlobalConfig()
	if newestCfg and newestCfg.dailyMaxSendGiftCount then
		max = newestCfg.dailyMaxSendGiftCount + Achievement:getRightsExtra( "SendReceiveEnergyNum" )
	end

	local remain = max - sentCount - #self.lockedSendIds
	if remain < 0 then remain = 0 end
	return (sentCount + #self.lockedSendIds) < max, remain

end

function FreegiftManager:canSendBackTo(receiverUid)
	local sendIds = UserManager:getInstance():getSendIds()
	local hasSentTo = false
	for k, v in pairs(sendIds) do
		if tonumber(v) == tonumber(receiverUid) then
			hasSentTo = true
			break
		end

	end
	for k, v in ipairs(self.lockedSendIds) do
		if receiverUid == v then
			hasSentTo = true
			break
		end
	end
	local canSendMore = self:canSendMore()
	return canSendMore and not hasSentTo
end

function FreegiftManager:hasSendTo(receiverUid)
	local sendIds = UserManager:getInstance():getSendIds()
	local hasSentTo = false
	for k, v in pairs(sendIds) do
		if tonumber(v) == tonumber(receiverUid) then
			hasSentTo = true
			break
		end
	end
	for k, v in ipairs(self.lockedSendIds) do
		if receiverUid == v then
			hasSentTo = true
			break
		end
	end
	return hasSentTo
end

function FreegiftManager:canSendTo(receiverUid)
	return self:canSendBackTo(receiverUid)
end	

function FreegiftManager:canReceiveMore()
	local receivedCount = UserManager:getInstance():receiveGiftCount()
	local maxCount = MetaManager:getDailyMaxReceiveGiftCount()
	
	local newestCfg = Localhost.getInstance():getUpdatedGlobalConfig()
	if newestCfg and newestCfg.dailyMaxReceiveGiftCount then
		maxCount = newestCfg.dailyMaxReceiveGiftCount
	end

	local canReceive = (receivedCount + self.lockedReceiveCount) < maxCount
	local remain = maxCount - receivedCount - self.lockedReceiveCount
	if remain < 0 then remain = 0 end
	return canReceive, remain
end

function FreegiftManager:canReceiveFrom(senderUid)
	self:canReceiveMore()
end

function FreegiftManager:setHelpRequestTip(requestTip)
	if requestTip then 
		local len = string.len(requestTip)
		if len>2 then 
			requestTip = string.sub(requestTip, 2, len-1)
		end
	end
	self.requestTip = requestTip or ""
end

function FreegiftManager:getHelpRequestTip()
	return self.requestTip or ""
end

function FreegiftManager:dispose()
	self.requestInfos = nil
	self.leftFreegiftInfos = nil
	panelConfig.clearUpdateIgnoreType()
end