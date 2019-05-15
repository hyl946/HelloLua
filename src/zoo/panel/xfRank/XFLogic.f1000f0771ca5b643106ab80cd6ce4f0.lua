local XFMeta = require 'zoo.panel.xfRank.XFMeta'
local defaultDateSZ = '2018-8-10 19:00:00'


local nilKey = '___nil___key'

local function memorize( func )
    local cache = {}
    return function ( ... )
        local params = {...}
        local paramsNum = #params
        local result = cache
        for index = 1, paramsNum - 1 do
            local param = params[index]
            if param == nil then
                param = nilKey
            end
            if result[param] == nil then
                result[param] = {}
            end
            result = result[param]
        end
        local lastParam = params[paramsNum]

        if lastParam == nil then
            lastParam = nilKey
        end

        if result[lastParam] == nil then
            result[lastParam] = func(...)
        end
        return result[lastParam] 
    end
end

local MaintenanceManager_isEnabled = memorize(function ( key )
	return MaintenanceManager:getInstance():isEnabled(key)
end)




local XFLogic = {}

XFLogic.Events = {
	kShowedLFLAlert = 'ShowedLFLAlert'
}

function XFLogic:isEnabled( ... )
	local KEY = 'StarRanking'
	if MaintenanceManager_isEnabled(KEY) then
		local meta = MaintenanceManager:getInstance():getMaintenanceByKey(KEY)

		if not meta then
			return false
		end

		local minLevel = tonumber(meta.value or 0x7FFFFFFF) or 0x7FFFFFFF
		local toplevel = UserManager.getInstance().user:getTopLevelId()


		local beginTimeSZ = meta.extra or ''
		local beginTime = parseDate2Time(beginTimeSZ) or parseDate2Time(defaultDateSZ)

		local b1 = toplevel >= minLevel
		local b2 = beginTime and Localhost:timeInSec() >= os.time2(beginTime)

		if UserManager:getInstance():getCurRoundFullStar() >= 0x7FFFFFFF then
			return false
		end

		return (b1 and b2) or (__WIN32 ~= nil)
	end
end


function XFLogic:isPreheadEnabled( ... )
	return false
end


function XFLogic:registerListeners( ... )
	-- body
	if self.__registered then
		return
	end
	self.__registered = true

	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kSceneNoPanel, function ( ... )
		XFLogic:onSceneNoPanel()
	end)

end

-- LFL == last full level

function XFLogic:isLFL( ... )
	local ret = UserManager:getInstance().lastRoundFullLevel
	return ret
end

function XFLogic:hadShowLFLAlert( ... )
	return self:readCache('lfl' .. (UserManager:getInstance().curRoundFullStar or '142857'))
end

function XFLogic:showedLFLAlert( ... )
	self:writeCache('lfl' .. (UserManager:getInstance().curRoundFullStar or '142857'), true)
	self:notify(XFLogic.Events.kShowedLFLAlert)
end


local function time2day(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
	return (dayStart + 8*3600)/24/3600
end

function XFLogic:onSceneNoPanel( ... )

	if self.needHideAnim then

		self:writeCache('preserve.preheat.button', false)
		self.needHideAnim = false

		local homeScene = HomeScene:sharedInstance()
		if not homeScene then return end
		local xfPreheatButton = homeScene.xfPreheatButton
		if not xfPreheatButton then return end
		if xfPreheatButton.isDisposed then return end


		local starButton = homeScene.starButton
		if not starButton then return end
		if starButton.isDisposed then return end

		local xfBounds = xfPreheatButton:getGroupBounds()


		local startPos = xfPreheatButton:getPosition()
		local bounds = starButton.blueBubbleItemRes:getGroupBounds()
		local endPosition = ccp(bounds:getMidX() - xfBounds.size.width/2, bounds:getMidY() + xfBounds.size.height/2)
		local parent = xfPreheatButton:getParent()
		if not parent then return end
		if parent.isDisposed then return end

		endPosition = parent:convertToNodeSpace(endPosition)

		local p2 = ccp(0, 0)

		local bezierConfig = ccBezierConfig:new()
        bezierConfig.controlPoint_1 = ccp(startPos.x +  p2.x, startPos.y +  p2.y)
        bezierConfig.controlPoint_2 = ccp(startPos.x +  p2.x, startPos.y +  p2.y)
        bezierConfig.endPosition = ccp(endPosition.x, endPosition.y)

        local FPS = 24

        local array = CCArray:create()
        array:addObject(CCBezierTo:create(10 / FPS, bezierConfig))
        array:addObject(CCCallFunc:create(function ( ... )
			
			if homeScene and xfPreheatButton and (not xfPreheatButton.isDisposed) then
				homeScene:removeIcon(xfPreheatButton)
			end

			if starButton and (not starButton.isDisposed) then
				starButton:showGuideTip()				
			end

			XFLogic:writeCache('show_enter_icon_anim', true)
        end))

		xfPreheatButton:runAction(CCSequence:create(array))

	end



	if self.needShowPersonalInfoPanel then
		self.needShowPersonalInfoPanel = false

		local lastGuideTime = self:readCache('lastGuideTime') or 0
		local guideCounter = self:readCache('guideCounter') or 0
		if time2day(lastGuideTime) >= time2day(Localhost:timeInSec()) or guideCounter >= 3 then
			return
		end
		self:writeCache('lastGuideTime', Localhost:timeInSec())
		self:writeCache('guideCounter', guideCounter + 1)
		PersonalCenterManager:showPersonalCenterPanel(true)
	end

end
function XFLogic:canPopoutPersonalCenter(  )

	if self.needShowPersonalInfoPanel then
		local lastGuideTime = self:readCache('lastGuideTime') or 0
		local guideCounter = self:readCache('guideCounter') or 0
		if time2day(lastGuideTime) >= time2day(Localhost:timeInSec()) or guideCounter >= 3 then
			return false
		end
	end
	return true
end



function XFLogic:needShowPreheatButton( ... )
	if self:isPreheadEnabled() then
		return true
	end

	if self:readCache('preserve.preheat.button') then
		return true
	end

	return false
end


function XFLogic:isAfterPreheadEnabled( ... )

	if not self:isEnabled() then
		return false
	end

	local KEY = 'StarRankingPreheating'
	if MaintenanceManager_isEnabled(KEY) then
		local meta = MaintenanceManager:getInstance():getMaintenanceByKey(KEY)

		if not meta then
			return false
		end

		local minStar = tonumber(meta.value or 0x7FFFFFFF) or 0x7FFFFFFF
		local totalStar = UserManager.getInstance().user:getHideStar() + UserManager.getInstance().user:getStar()

		local meta = MaintenanceManager:getInstance():getMaintenanceByKey('StarRanking')

		if not meta then
			return false
		end

		local beginTimeSZ = meta.extra or ''
		local beginTime = parseDate2Time(beginTimeSZ) or parseDate2Time(defaultDateSZ)
		local b1 = totalStar < minStar
		local b2 = beginTime and Localhost:timeInSec() >= os.time2(beginTime) + 3600
		local toplevel = UserManager.getInstance().user:getTopLevelId()
		local b3 = toplevel >= 1665 and UserManager:getInstance():hasPassedLevelEx(1665)

		return b1 and b2 and b3
	end
end

function XFLogic:__getMainBeginTime( ... )
	-- body

	local dateSZ = defaultDateSZ

	local KEY = 'StarRanking'

	local meta = MaintenanceManager:getInstance():getMaintenanceByKey(KEY)

	if meta then
		dateSZ = meta.extra or ''
	end

	local date = parseDate2Time(dateSZ) or parseDate2Time(defaultDateSZ)

	return os.time2(date)

end

XFLogic.getMainBeginTime = memorize(XFLogic.__getMainBeginTime)


function XFLogic:popoutMainPanel( force, callback, closeCallback , closeCallback1 , closeAllCallback )

	local XFMainPanel = require 'zoo.panel.xfRank.XFMainPanel'

	local function _afterHttp( online )
		-- body
		if self.__had_data then
			local panel = XFMainPanel:create()
			panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
				if HomeScene:sharedInstance() then
					HomeScene:sharedInstance():runAction(CCCallFunc:create(function ( ... )
						if closeCallback then closeCallback() end
						if _G.isLocalDevelopMode  then printx(100 , "XFLogic self.needShowPersonalInfoPanel " ,self.needShowPersonalInfoPanel ) end
						if self.needShowPersonalInfoPanel and self:canPopoutPersonalCenter() then
							if closeAllCallback then closeAllCallback() end
						else
							if closeCallback1 then closeCallback1() end
						end

					end))
				end
			end)
			panel:popout()

			if callback then callback() end

			if force then
				DcUtil:UserTrack({
					category = 'StarRanking',
					sub_category = 'show_icon',
					t1 = 1
				})
			else
				DcUtil:UserTrack({
					category = 'StarRanking',
					sub_category = 'show_icon',
					t1 = 2
				})

			end

			if not online then
				CommonTip:showTip(localize('starranking.nointernet.desc'))
			end
		else
			CommonTip:showNetworkAlert()
		end
	end

	self:pullInfo(function ( ... )
		_afterHttp(true)
	end, function ( ... )
		_afterHttp(false)
	end, function ( ... )
		_afterHttp(false)
	end)
end


function XFLogic:getTestIdCardData( rank )

	local profile = ProfileRef.new()
	profile.headUrl = tostring(math.floor(math.random() * 10))

	local test_data = {
		profile = profile,
		score = math.ceil(math.random() * 100),
		fullstar_ts = Localhost:time(),
		fullstar_rank = rank,
		fullstar_last_rank = 100,
		fullstar_rank_history = {
			{fullstar_ts = 0, fullstar_rank = 1, rewards = {{itemId = 900000, num = 1}} },
			{fullstar_ts = 1, fullstar_rank = 2, rewards = {{itemId = 900000, num = 1}} },
			{fullstar_ts = 2, fullstar_rank = 3, rewards = {{itemId = 900000, num = 1}} },
			{fullstar_ts = 2, fullstar_rank = 3, rewards = {{itemId = 900000, num = 1}} },
			{fullstar_ts = 2, fullstar_rank = 3, rewards = {{itemId = 900000, num = 1}} },
		},
	}
	return test_data
end

function XFLogic:getDefaultScore( rank )
	local cfgs = XFMeta:getScoreMeta()
	local thisCfg = table.find(cfgs, function ( v )
		return rank >= v.kMinRank and rank <= v.kMaxRank
	end)

	if thisCfg then
		return thisCfg.kScore
	else
		return 0
	end
end

function XFLogic:getUnknownData( rank, random )
	-- body
	local profile = ProfileRef.new()
	profile.headUrl = '[Unknown]'

	local test_data = {
		profile = profile,
		score = self:getDefaultScore(rank),
		fullstar_ts = 0 ,
		fullstar_rank = rank,
		fullstar_last_rank = random and math.ceil(math.random() * 100) or 0,
		fullstar_rank_history = {
		},
	}

	test_data.profile.name = "无人上榜"
	test_data.isUnknown = true 

	return test_data
end

function XFLogic:isUnknownData( xfData )
	return xfData and xfData.isUnknown
end

function XFLogic:isEmptyRankData( rankData )
	return (not rankData) or #rankData <= 0 or self:isUnknownData(rankData[1])
end

function XFLogic:getEmptyData( rank )
	-- body
	local profile = ProfileRef.new()
	profile.headUrl = '[Unknown]'
	profile.name = ' '

	local test_data = {
		profile = profile,
		score = 0,
		fullstar_ts = Localhost:time(),
		fullstar_rank = rank or 0,
		fullstar_last_rank = 0,
		fullstar_rank_history = {
		},
	}
	return test_data

end

function XFLogic:getHistoryTopRank( data )
	local ret = table.reduce(data.fullstar_rank_history or {}, function ( a, b )
		if a.fullstar_rank < b.fullstar_rank then return a end
		return b
	end)
	return ret and ret.fullstar_rank or 0
end

function XFLogic:getHonorCfg( data )
	local ret = {}

	for _, v in ipairs(data.fullstar_rank_history or {}) do
		for _, rewardItem in ipairs(v.rewards or {}) do
			if ItemType:isHonor(rewardItem.itemId) then
				table.insert(ret, {
					honorId = rewardItem.itemId,
					fullstar_ts = v.fullstar_ts,
					fullstar_rank = v.fullstar_rank,
				})
			end
		end
	end

	ret = table.groupBy(ret, function ( v )
		return XFMeta:getHonorType(v.honorId)
	end)

	return ret

end

function XFLogic:getServerStartTime( ... )
	return self.roundStartTime or 0
end

function XFLogic:getServerRankLength( ... )
	return self.rankLength or 0
end



function XFLogic:getServerFullStarNum( ... )
	return self.roundFullStar or 0x7FFFFFFF
end

function XFLogic:cloneXFHistoryData( other_fullstar_rank_history )
	-- body
	local fullstar_rank_history = {}
	for _k, _v in ipairs(other_fullstar_rank_history or {}) do
		local histotyInfo =  {
			fullstar_ts = _v.fullstar_ts or 0,
			fullstar_rank = _v.fullstar_rank or 0,
			rewarded = _v.rewarded,
			rewards = _v.rewards or {},
			fullStar = _v.fullStar or 0,
		}
		table.insert(fullstar_rank_history, histotyInfo)
	end

	return fullstar_rank_history
end

function XFLogic:isValidRank( rank )
	return rank > 0 and rank < 0x7FFFFFFF
end

function XFLogic:cloneXFData( other )

	local xfData = {}
	xfData.profile = ProfileRef.new(other.profile)
	xfData.score = other.score or 0
	xfData.fullstar_ts = other.fullstar_ts or 0
	xfData.fullstar_rank = other.fullstar_rank or 0

	if xfData.fullstar_rank <= 0 then
		xfData.fullstar_rank = 0x7FFFFFFF
	end

	xfData.fullstar_last_rank = other.fullstar_last_rank or 0
	xfData.fullstar_rank_history = self:cloneXFHistoryData(other.fullstar_rank_history or {})

	return xfData
end

function XFLogic:getRankData( ... )




	-- local t1 = XFLogic:getTestIdCardData()
	-- t1.fullstar_rank = 1
	-- local t2 = XFLogic:getTestIdCardData()
	-- t2.fullstar_rank = 2
	-- local t3 = XFLogic:getTestIdCardData()
	-- t3.fullstar_rank = 3

	-- local ret = {t1, t2, t3}
	
	-- local xx = true	

	-- local kk = 5

	-- for i = 4, kk do
	-- 	table.insert(ret, XFLogic:getUnknownData(i, true))
	-- end

	-- if xx then
	-- 	local my = XFLogic:getUnknownData(kk + 1)
	-- 	my.profile = UserManager:getInstance().profile
	-- 	my.fullstar_last_rank = 480
	-- 	table.insert(ret, my)
	-- else
	-- 	t2.profile = UserManager:getInstance().profile
	-- 	t2.fullstar_last_rank = 480
	-- end

	


	-- local ret = table.clone(self.rankData or {}, false)
	local ret = {}

	for _k, _v in ipairs(self.rankData or {}) do
		ret[_k] = self:cloneXFData(_v)
	end

	if not table.find(ret, function ( v )
		if tostring(v.profile.uid) == tostring(UserManager:getInstance():getInviteCode()) then
			return true
		end
	end) then

		local selfInfo = self.selfInfo
		if not selfInfo then
			selfInfo = self:getEmptyData()
			selfInfo.profile = ProfileRef.new(UserManager:getInstance().profile:encode())
			selfInfo.profile.uid = UserManager:getInstance():getInviteCode()
		end

		local myRank = selfInfo.fullstar_rank or 0

		if myRank <= 0 then
			myRank = 0x7FFFFFFF
		end

		local si = #ret + 1

		for i = si, math.min(myRank - 1, XFMeta.RANK_SHOW_SIZE) do
			table.insert(ret, XFLogic:getUnknownData(i))
		end
		table.insert(ret, self:cloneXFData(selfInfo))

	end

	local rankMap2Data = {}

	for _k, _v in ipairs(ret) do
		rankMap2Data[_v.fullstar_rank] = _v
	end

	for i = 1, XFMeta.RANK_SHOW_SIZE do
		if not rankMap2Data[i] then
			table.insert(ret, XFLogic:getUnknownData(i))
		end
	end

	table.sort(ret, function ( a, b )
		return a.fullstar_rank < b.fullstar_rank and a.fullstar_rank > 0
	end)

	local myUID = tostring(UserManager:getInstance():getInviteCode())

	local truncat_ret = {}

	for _k, _v in ipairs(ret) do
		if _k <= XFMeta.RANK_SHOW_SIZE or tostring(_v.profile.uid) == myUID then
			table.insert(truncat_ret, _v)
		end
	end


	return truncat_ret
end


function XFLogic:pullInfo(onSuccess, onFail, onCancel)
	HttpBase:syncPost('fullStarRankList', {}, function ( evt )
		self:cacheData(evt.data or {})
		self.__had_data = true
		if onSuccess then onSuccess() end
	end, onFail, onCancel)
end

function XFLogic:cacheData( data )
	
	local roundFullStar = data.roundFullStar or 0x7FFFFFFF
	self.roundFullStar = roundFullStar

	local roundStartTime = data.roundStartTime or 0
	self.roundStartTime = roundStartTime

	local rankLength = data.rankLength or 0
	self.rankLength = rankLength

	 

	local selfInfo = data.selfInfo or {}
	local rankList = data.rankList or {}

	-- rankList = {rankList[1]}

	local rankDataSize = 0
	local rankData = {}
	for _k, _v in ipairs(rankList) do
		rankData[_v.rank or 1] = _v
		rankDataSize = math.max(_v.rank, rankDataSize)
	end

	for i = 1, rankDataSize do
		rankData[i] = self:formatXFData(rankData[i] or self:getUnknownData(i))
	end

	-- self.rankData = {}
	self.rankData = rankData
	self.selfInfo = self:formatXFData(selfInfo)

	-- self.selfInfo.fullstar_rank = 46
	-- self.selfInfo.fullstar_last_rank = 260
end

function XFLogic:hadAvailableRewards(  )

	if not self.selfInfo then
		return false
	end


	local xfData = self.selfInfo

	for _, v in reverse_ipair(xfData.fullstar_rank_history or {}) do
		if #(v.rewards) > 0 and ( not v.rewarded) then
			return v
		end
	end

end



function XFLogic:receiveRewards( historyInfo , onSuccess, onFail, onCancel)
		
	if not self.selfInfo then
		if onFail then onFail() end
		return
	end

	HttpBase:syncPost('getCommonRankReward', {
		rankDay = historyInfo.fullStar or 0,
		actId = XFMeta.ActId,
	}, function ( evt )
		local rewards = {}
		if evt and evt.data then
			rewards = evt.data.rewardItems or {}
		end

		self:addRewards(historyInfo, rewards)


		local rewardsForUI = {}
		for _k, _v in ipairs(rewards) do
			local tmp = {
				itemId = _v.itemId,
				num = _v.num,
			}

			if ItemType:isHonor(tmp.itemId) then
				tmp.itemId = XFMeta:findSimilarHornorId(tmp.itemId, historyInfo.fullstar_rank)
			end

			if tmp.itemId then
				table.insert(rewardsForUI, tmp)
			end
		end

		if onSuccess then 
			onSuccess(rewardsForUI)
		end
	end, onFail, onCancel)
end

function XFLogic:addRewards(historyInfo, rewardItems)
	if not table.find(UserManager:getInstance():getFullStarRecords(), function ( v )
		return math.abs((v.fullStar or 0) - (historyInfo.fullStar or 0)) <= 0.1
	end) then


		local hasItemRewards = false
		for _,reward in pairs(rewardItems or {}) do
			if ItemType:isHeadFrame(reward.itemId) then
				local delta
				if reward.num == 0 then
					delta = nil --永久
				else
					delta = reward.num * 60 * 1000 --num是个分钟数
				end
				if (not delta) or delta >= 0 then
					HeadFrameType:setProfileContext(nil):addHeadFrame(ItemType:convertToHeadFrameId(reward.itemId), delta)
				end
			elseif ItemType:isHonor(reward.itemId) then
			elseif ItemType.FULL_STAR_SCORE == reward.itemId then
			else
	   			UserManager:getInstance():addReward(reward, true)
	            UserService:getInstance():addReward(reward)
	         	GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStarAndLevel, reward.itemId, reward.num, DcSourceType.kStarRankReward)
			end
		end
		UserManager:getInstance():addFullStarRecode(historyInfo)
		UserService:getInstance():addFullStarRecode(historyInfo)

		Localhost:getInstance():flushCurrentUserData()
	end
end

function XFLogic:formatXFData( rawData )
	local xfData = {}
	xfData.profile = ProfileRef.new(rawData.profile)
	xfData.score = rawData.point or 0
	xfData.fullstar_ts = tonumber(rawData.time or 0) or 0
	xfData.fullstar_rank = rawData.rank or 0

	if xfData.fullstar_rank <= 0 then
		xfData.fullstar_rank = 0x7FFFFFFF
	end

	xfData.fullstar_last_rank = rawData.lastRank or 0
	xfData.fullstar_rank_history = {}

	for _k, _v in ipairs(rawData.records or {}) do
		local historyInfo =  {
			fullstar_ts = tonumber(_v.time or 0) or 0,
			fullstar_rank = _v.rank or 0,
			rewarded = _v.rewarded,
			rewards = _v.rewards or {},
			fullStar = _v.fullStar or 0,
		}
		table.insert(xfData.fullstar_rank_history, historyInfo)
	end

	xfData.fullstar_rank_history = table.filter(xfData.fullstar_rank_history, function (historyInfo )
		return self:isValidRank(historyInfo.fullstar_rank or 0)
	end)

	table.sort(xfData.fullstar_rank_history, function ( a, b )
		local t1 = a.fullstar_ts or 0
		local t2 = b.fullstar_ts or 0
		return t1 > t2
	end)

	return xfData
end

function XFLogic:pullUserDetailInfo( inviteCode, onSuccess, onFail, onCancel )
	
	HttpBase:syncPost('fullStarRankUserInfo', {
		xxlId = inviteCode,
	}, function ( evt )
		local data = evt and (evt.data or {}) or {}
		local xfData = self:formatXFData(data.info)

		if xfData then
			self:cacheUserDetailData(xfData)
		end
		if onSuccess then onSuccess() end

	end, onFail, onCancel)
end

function XFLogic:beforePopoutIdCard( xfData, callback)

	local function _afterHttp( ... )
		if callback then callback () end
	end

	self:pullUserDetailInfo(xfData.profile.uid, _afterHttp, _afterHttp, _afterHttp)
end

function XFLogic:getXFDataByInviteCode( inviteCode )
	-- body
	return table.find(self.rankData or {}, function ( v )
		return tostring(v.profile.uid) == tostring(inviteCode)
	end)
end

function XFLogic:cacheUserDetailData( xfData )
	-- body
	local thisOne = table.find(self.rankData or {}, function ( v )
		if tostring(v.profile.uid) == tostring(xfData.profile.uid) then
			return true
		end
	end)

	if thisOne then
		thisOne.fullstar_rank_history = self:cloneXFHistoryData(xfData.fullstar_rank_history)
	end

	if self.selfInfo then
		if tostring(self.selfInfo.profile.uid) == tostring(xfData.profile.uid) then
			self.selfInfo.fullstar_rank_history = self:cloneXFHistoryData(xfData.fullstar_rank_history)
		end
	end

end

-- One's name is on the list of successful candidates.
-- 检查我是不是进游戏的时候还没上榜，但刚刚上榜了
function XFLogic:checkIfMeJustOnServerRank( onSuccess, onFail, onCancel)

	local totalStar = 0

	local userRef = UserManager:getInstance().user
	if userRef then
		totalStar = userRef:getTotalStar()
	end


	if totalStar < UserManager:getInstance():getCurRoundFullStar() then
		if onSuccess then onSuccess(false) end
		return
	elseif table.find(UserManager:getInstance():getFullStarRecords(), function ( v )
		return (v.fullStar or 0) >= totalStar
	end) then
		if onSuccess then onSuccess(false) end
		return
	else

		local http = OpNotifyHttp.new(true)
    	http:ad(Events.kComplete, function ( evt )
    		local extra = false
    		if evt and evt.data then
    			local fields = string.split(evt.data.extra or '', ',') or {}
    			if fields[1] and fields[2] then
    				if onSuccess then onSuccess(true, tonumber(fields[1]), tonumber(fields[2])) end
    				return
    			end
    		end
    		if onSuccess then onSuccess(false) end
    	end)
	    http:ad(Events.kError, function ( ... )
			if onSuccess then onSuccess(false) end
	    end)
	    http:ad(Events.kCancel, function ( ... )
			if onSuccess then onSuccess(false) end
	    end)
        http:syncLoad(OpNotifyType.kFullStarCheck)
        return
	end

end

function XFLogic:__readCache( ... )
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	local key = "xf.cache.HelloWorld" .. uid
	local data_json = CCUserDefault:sharedUserDefault():getStringForKey(key)
	if data_json and data_json ~= "" then 
		local data = { }
		data = table.deserialize(data_json) or {}
		self.cache_data = data
	end
end

function XFLogic:__writeCache( ... )
	local data_json = table.serialize(self.cache_data or {})
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	local key = "xf.cache.HelloWorld" .. uid
	CCUserDefault:sharedUserDefault():setStringForKey(key, data_json)
	CCUserDefault:sharedUserDefault():flush()

end

function XFLogic:readCache(key)
	self:__readCache()
	if self.cache_data then
		return self.cache_data[key]
	end

end

function XFLogic:writeCache( key, value )
	self:__readCache()
	if not self.cache_data then
		self.cache_data = {}
	end
	self.cache_data[key] = value
	self:__writeCache()
end


local observers = {}

function XFLogic:addObserver(observer)
	table.insert(observers, observer)
end

function XFLogic:removeObserver(observer)
	table.removeValue(observers, observer)
end

function XFLogic:notify(obKey, ... )
	for _, observer in ipairs(observers) do
		if type(observer) =='table' then

			if type(observer['on' .. obKey]) == 'function' then
				observer['on' .. obKey](observer, ...)
			end

		end
	end
end

return XFLogic