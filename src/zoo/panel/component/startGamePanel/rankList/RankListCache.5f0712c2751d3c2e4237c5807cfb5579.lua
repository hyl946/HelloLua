
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月17日  0:34:45
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

local FriendScoreMgr = require "zoo.data.FriendScoreMgr"

assert(not RankListCacheRankType)

RankListCacheRankType = {
	SERVER	= 1,
	FRIEND	= 2
}

function RankListCacheRankType.checkRankType(rankType, ...)
	assert(rankType)
	assert(#{...} == 0)

	assert(rankType == RankListCacheRankType.SERVER or
		rankType == RankListCacheRankType.FRIEND)
end

----------------------------------------------------
---- RankListCache
----
---- Send Message To The Server, To Get Rank List Information
---- And Cache That Information
----------------------------------------------

assert(not RankListCache)

local rankListCacheSharedInstance = nil

RankListCache = class()

function RankListCache:init(levelId, onCachedDataChange, hiddenRankList, ...)
	assert(type(levelId) == "number")
	assert(type(onCachedDataChange) == "function")
	assert(#{...} == 0)

	-- Data
	self.serverRankList = {}
	self.isAllreadyGetAllServerRankData = false

	self.friendRankList = {}
	self.isAllreadyGetAllFriendRankData = false

	self.levelId = levelId
	self.onCachedDataChange = onCachedDataChange
	self.hiddenRankList = hiddenRankList
end

----------------- Get Cached Data Length ----------------------
function RankListCache:getCurCachedRankListLength(rankType, ...)
	assert(rankType)
	RankListCacheRankType.checkRankType(rankType)
	assert(#{...} == 0)

	if rankType == RankListCacheRankType.SERVER then
		return #self.serverRankList
	elseif rankType == RankListCacheRankType.FRIEND then
		return #self.friendRankList
	else
		assert(false)
	end
end

function RankListCache:isAllreadyGetAllRankData(rankType, ...)
	assert(rankType)
	RankListCacheRankType.checkRankType(rankType)
	assert(#{...} == 0)

	if rankType == RankListCacheRankType.SERVER then
		return self.isAllreadyGetAllServerRankData
	elseif rankType == RankListCacheRankType.FRIEND then
		return self.isAllreadyGetAllFriendRankData
	else
		assert(false)
	end
end

-------------- Get Cached Data -------------------------

function RankListCache:getCurCachedServerRankList(rankIndex, ...)
	assert(type(rankIndex) == "number")
	assert(#{...} == 0)

	local result = self.serverRankList[rankIndex]
	
	if result then
		return result
	else
	end

	return nil
end

function RankListCache:getCurCachedFriendRankList(rankIndex, ...)
	assert(type(rankIndex) == "number")
	assert(#{...} == 0)

	local result = self.friendRankList[rankIndex]

	if result then
		return result
	else
	end
	
	return nil
end

function RankListCache:getCurCachedRankList(rankType, rankIndex, ...)
	assert(rankType)
	RankListCacheRankType.checkRankType(rankType)
	assert(type(rankIndex) == "number")
	assert(#{...} == 0)

	if rankType == RankListCacheRankType.SERVER then
		return self:getCurCachedServerRankList(rankIndex)
	elseif rankType == RankListCacheRankType.FRIEND then
		return self:getCurCachedFriendRankList(rankIndex)
	else
		assert(false)
	end
end

function RankListCache:loadInitialData(...)
	self:sendGetLevelScoreRankMessage(1)	-- Server
	self:sendGetLevelTopMessage()		-- Friend
end

function RankListCache:loadInitialServerRank()
	self:sendGetLevelScoreRankMessage(1)	-- Server
end

function RankListCache:setGetServerRankFailedCallback(callback)
	assert(type(callback) == "function")
	self.getServerRankFailedCallback = callback
end

function RankListCache:setGetFriendRankFailedCallback(callback)
	self.getFriendRankFailedCallback = callback
end

function RankListCache:loadInitialFriendRank()
	self:sendGetLevelTopMessage()		-- Friend
end

function RankListCache:sendGetLevelTopMessage(forceQueryServer)
	if self.isAllreadyGetAllFriendRankData or self.hiddenRankList then
		return
	end

	local userUID = tostring(UserManager.getInstance().uid)
	local function updateFriendRankList(scores, withCache)
		local friendRankList = {}
		for k,v in pairs(scores) do
			if v.star > 0 and v.score > 0 then 
				local userData = {uid = v.uid, score = v.score, star = v.star}
				if tostring(v.uid) == userUID then
					local profile = UserManager.getInstance().profile
					userData.name = profile:getDisplayName()
					userData.headUrl = profile.headUrl
				else
					local profile = FriendManager.getInstance().friends[tostring(v.uid)]

					if profile then 
						
						userData.name = profile.name
						userData.headUrl = profile.headUrl
					end
				end
				if not withCache then 
					FriendScoreMgr.getInstance():updateScoreCache(self.levelId, v.uid, v.score, v.star)
				end
				table.insert(friendRankList, userData) 
			end
		end

		table.sort(friendRankList, function (table1, table2)
			if table1.score > table2.score then
				return true
			end
			return false
		end)

		local userManager = UserManager:getInstance()
		for k,v in pairs(friendRankList) do
			if tostring(v.uid) == userUID then
				userManager.selfOldNumberInFriendRank[self.levelId]	= userManager.selfNumberInFriendRank[self.levelId]
				userManager.selfNumberInFriendRank[self.levelId]	= k
			end
		end

		self.friendRankList = friendRankList
		self.onCachedDataChange(RankListCacheRankType.FRIEND)
	end

	local function updateSelfScore(scores, selfScore)
		local hasSelf = false
		for k,v in pairs(scores) do
			if tostring(v.uid) == userUID then
				if selfScore and selfScore.score > v.score then
					v.star	= selfScore.star
					v.score	= selfScore.score
				end
				hasSelf = true
			end
		end

		if not hasSelf and selfScore then
			local selfScoreInfo = {}
			selfScoreInfo.levelId	= self.levelId
			selfScoreInfo.star	= selfScore.star
			selfScoreInfo.score	= selfScore.score
			selfScoreInfo.uid	= userUID
			table.insert(scores, selfScoreInfo)
		end
	end

	if not forceQueryServer and not FriendScoreMgr.getInstance():shouldUpdateFromServer(self.levelId) then 
		local scoreCaches = FriendScoreMgr.getInstance():getScoreCaches(self.levelId)

		local selfScore = UserManager:getInstance():getUserScore(self.levelId)
		updateSelfScore(scoreCaches, selfScore)

		updateFriendRankList(scoreCaches, true)
		return 
	end

	local function onSuccess(event)
		-- if _G.isLocalDevelopMode then printx(0, "GetLevelTopMessage onSuccess", table.tostring(event.data)) end
		local scores = event.data
		if not scores then return end
		-- self.isAllreadyGetAllFriendRankData = true

		local selfScore = UserManager:getInstance():getUserScore(self.levelId)
		updateSelfScore(scores, selfScore)

		FriendScoreMgr.getInstance():clearScoreCache(self.levelId)
		updateFriendRankList(scores)	
	end

	local function onFail(event)
		he_log_warning("comment on send get level top message failed code !")

		if self.getFriendRankFailedCallback then
			self.getFriendRankFailedCallback()
		end
	end

	local http = GetLevelTopHttp.new(forceQueryServer)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:load(self.levelId)
end

--------------
--- Server
--------------
function RankListCache:sendGetLevelScoreRankMessage(rankIndex, ...)
	assert(type(rankIndex) == "number")
	assert(#{...} == 0)
	if _isQixiLevel or self.hiddenRankList then return end
	self.serverRankList = {}
	
	-- Server
	local pageStart = math.floor(rankIndex / 7) + 1
	local pageEnd	= 5

	local largestRankShouldGet = pageEnd * 6

	------------------------
	--- Call Back Function
	------------------------
	local function onSuccess(event)
		assert(event)
		assert(event.name == Events.kComplete)
		assert(event.data)

		local rankData = event.data

		--------------
		-- Store Data
		---------------

		local updatedIndex = {}

		local isThisPageFull = false
		local userUID = tostring(UserManager.getInstance().uid)
		local list = {}
		if rankData.profiles ~= nil then
			for i, v in ipairs(rankData.profiles) do
				if v then list[v.uid] = ProfileRef.new(v) end
			end
		end

		for k,v in pairs(rankData.ranks) do

			local index = (pageStart - 1) * 6  + k 

			if index == largestRankShouldGet then
				isThisPageFull = true
			end

			table.insert(updatedIndex, index)

			local profile = list[v.uid]
			
			if profile then 
				v.name = nameDecode(profile.name or "")
				v.headUrl = profile.headUrl
				if v.uid ~= userUID then
					v.profile = profile
				end
			end

			if v.uid == userUID then
				profile = UserManager.getInstance().profile
				v.name = profile:getDisplayName()
				v.headUrl = profile.headUrl
			end

			self.serverRankList[index] = v
		end

		if not isThisPageFull then
			self.isAllreadyGetAllServerRankData = true
		end


		-- ------------------
		-- Sort On Score
		-- Great Score First
		-- ------------------
		local function sortBasedOnScore(table1, table2, ...)
			assert(type(table1) == "table")
			assert(type(table2) == "table")
			assert(table1.score)
			assert(table2.score)
			assert(#{...} == 0)

			if table1.score > table2.score then
				return true
			end

			return false
		end

		table.sort(self.serverRankList, sortBasedOnScore)

		------------------------------------------
		-- Note Below Is Duplicate Code In self:sendGetLevelTopMessage 
		-- Reform If Needed !!!
		-- -------------------------------------

		-- -----------------------
		-- Check If Self Has Score
		-- -----------------------
		local selfScore = UserManager:getInstance():getUserScore(self.levelId)

		-- ------------------
		-- Check If Has Self
		-- ------------------
		local hasSelf = false
		local selfUid = UserManager:getInstance().uid

		for k,v in pairs(self.serverRankList) do
			if tostring(v.uid) == tostring(selfUid) then
				--table.remove(self.serverRankList, k)
				--self.serverRankList[k] = nil

				if selfScore and selfScore.score > v.score then
					v.score	= selfScore.score
					v.star	= selfScore.star
				end
				hasSelf = true
			end
		end


		-- -----------------------------------------
		-- When Rank List Not Has Self, But We Has Scoreo, 
		-- And Can Enter The Rank, Insert Self
		-- -----------------------------------------------

		-- Check If Self Can Enter Rank
		local lastRankItem = self.serverRankList[#self.serverRankList]
		local playerProfile = UserManager.getInstance().profile

		if lastRankItem then

			local lastItemScore = lastRankItem.score

			if selfScore then

				if selfScore.score > lastItemScore then
					-- Can Enter Rank

					-- Try Insert Self
					if not hasSelf and selfScore then
						local selfRankItem = {}
						selfRankItem.levelId	= self.levelId
						selfRankItem.star	= selfScore.star
						selfRankItem.score	= selfScore.score
						selfRankItem.uid	= tostring(selfUid)
						selfRankItem.name = playerProfile:getDisplayName()
						selfRankItem.headUrl = playerProfile.headUrl

						if selfScore.star > 0 and selfScore.score > 0 then table.insert(self.serverRankList, selfRankItem) end
					end
				end
			end
		else
			-- Has No An Rank Item

			-- Try Insert Self
			if selfScore then
				local selfRankItem = {}
				selfRankItem.levelId	= self.levelId
				selfRankItem.star	= selfScore.star
				selfRankItem.score	= selfScore.score
				selfRankItem.uid	= tostring(selfUid)
				selfRankItem.name = playerProfile:getDisplayName()
				selfRankItem.headUrl = playerProfile.headUrl

				table.insert(self.serverRankList, selfRankItem)
			end
		end


		-- ------------------
		-- Re Sort On Score
		-- Great Score First
		-- ------------------
		local function sortBasedOnScore(table1, table2, ...)
			assert(type(table1) == "table")
			assert(type(table2) == "table")
			assert(table1.score)
			assert(table2.score)
			assert(#{...} == 0)

			if table1.score > table2.score then
				return true
			end

			return false
		end

		table.sort(self.serverRankList, sortBasedOnScore)

		------------------
		-- Get Self Rank
		-- ----------------

		local selfId	= UserManager:getInstance().user.uid
		assert(selfId)

		local userManager	= UserManager:getInstance()

		for k,v in pairs(self.serverRankList) do
			if v.uid == selfId then
				userManager.selfOldNumberInServerRank[self.levelId]	= userManager.selfNumberInServerRank[self.levelId]
				userManager.selfNumberInServerRank[self.levelId]	= k
			end
		end

		----------------------------
		---- Call Callback Function
		----------------------------
		self.onCachedDataChange(RankListCacheRankType.SERVER)
	end

	local function onFail(event)
		if self.getServerRankFailedCallback then
			self.getServerRankFailedCallback()
		end
	end
	-----------------------
	---- Send The Message
	----------------------
	local http = GetLevelScoreRankHttp.new()
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:load(self.levelId, pageStart, pageEnd)
end

function RankListCache:create(levelId, onCachedDataChange, hiddenRankList, ...)
	assert(type(levelId) == "number")
	assert(type(onCachedDataChange) == "function")
	assert(#{...} == 0)

	local cache = RankListCache.new()
	cache:init(levelId, onCachedDataChange, hiddenRankList)

	return cache
end
