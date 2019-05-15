SeasonWeeklyMatchRankData = class()

function SeasonWeeklyMatchRankData:ctor(rankMinNum)
	rankMinNum = rankMinNum or 20
	self.uid = 0
	self.rankMinNum = rankMinNum
	self.rankList = {}
	self.activeFriends = {}
end

function SeasonWeeklyMatchRankData:initWithData(uid, rankList, activeFriends)
	self.uid = uid
	rankList = rankList or {}
	self.activeFriends = activeFriends or {}

	local rankUids = {}
	local distinctRankList = {} -- 去重后的排行数据
	for _, v in pairs(rankList) do
		if not rankUids[tostring(v.uid)] then
			table.insert(distinctRankList, {uid = tostring(v.uid), score = v.score , globalRank = v.globalRank})
			rankUids[tostring(v.uid)] = true
		end
	end

	self.rankList = distinctRankList

	-- 将自己放入排行榜
	if not rankUids[tostring(self.uid)] then
		table.insert(self.rankList, {uid = tostring(self.uid), score = 0 , globalRank=0})
	end
	if #self.rankList < 4 then
		-- 填充活跃但未上榜的好友，最多3名
		if #self.activeFriends > 0 then
			for _, fuid in pairs(self.activeFriends) do
				if #self.rankList >= 4 then break end
				if not rankUids[tostring(fuid)] then
					table.insert(self.rankList, {uid = tostring(fuid), score = 0 , globalRank=0})
					rankUids[tostring(fuid)] = true
				end
			end
		end
		-- 还不够？填充普通好友
		if #self.rankList < 4 then
			local friends = FriendManager.getInstance().friends
			for fuid, _ in pairs(friends) do
				if #self.rankList >= 4 then break end
				if not rankUids[tostring(fuid)] then
					table.insert(self.rankList, {uid = tostring(fuid), score = 0 , globalRank=0})
					rankUids[tostring(fuid)] = true
				end
			end
		end
	end

	self:updateAndSortRankList()
end

function SeasonWeeklyMatchRankData:updateAndSortRankList()
	if #self.rankList > 1 then
		table.sort(self.rankList, function(a, b)
			if a.score == b.score then
				if (type(a.globalRank) == 'number' and a.globalRank > 0 and a.globalRank <= 10000) and (type(b.globalRank) == 'number' and b.globalRank > 0 and b.globalRank <= 10000) then
					return a.globalRank < b.globalRank
				else
					if type(a.globalRank) == 'number' and a.globalRank > 0 and a.globalRank <= 10000 then
						return true
					elseif type(b.globalRank) == 'number' and b.globalRank > 0 and b.globalRank <= 10000 then
						return false
					else
						if tostring(a.uid) == tostring(self.uid) then return true end
						if tostring(b.uid) == tostring(self.uid) then return false end
						return tonumber(a.uid) < tonumber(b.uid)
					end
				end
			end
			return a.score > b.score
		end)
	end
end

function SeasonWeeklyMatchRankData:updateMyScore(newScore , globalRank)
	if newScore >= self.rankMinNum then
		local myRank = nil
		for _, v in pairs(self.rankList) do
			if tostring(v.uid) == tostring(self.uid) then
				myRank = v
				myRank.score = newScore
				myRank.globalRank = globalRank
			end
		end
		if not myRank then
			myRank = {uid=self.uid, score = newScore , globalRank = globalRank}
			table.insert(self.rankList, myRank)
		end
		self:updateAndSortRankList()
	end
end

function SeasonWeeklyMatchRankData:getRankList()
	return self.rankList
end

function SeasonWeeklyMatchRankData:getRankNum( ... )
	local rankNum = 0
	for _, rank in ipairs(self.rankList) do
		if rank.score >= self.rankMinNum then
			rankNum = rankNum + 1
		else
			break
		end
	end
	return rankNum 
end

function SeasonWeeklyMatchRankData:getMyRank()
	for index, rank in ipairs(self.rankList) do
		if tostring(rank.uid) == tostring(self.uid) and rank.score >= self.rankMinNum then
			return index
		end
	end
	return 0
end

function SeasonWeeklyMatchRankData:getSurpassFriends()
	local inRankList = false
	local myScore = 0
	local ret = {}
	for _, rank in ipairs(self.rankList) do
		if rank.score < self.rankMinNum then break end
		if inRankList then 
			if myScore >= rank.score then
				table.insert(ret, rank.uid)
			end
		elseif tostring(rank.uid) == tostring(self.uid) then
			inRankList = true
			myScore = rank.score
		end
	end
	return ret
end

function SeasonWeeklyMatchRankData:getSurpassCount()
	local surpassFriends = self:getSurpassFriends()
	return #surpassFriends
end

function SeasonWeeklyMatchRankData:initPassFriendInfo(pRankList, pGlobalProfile)
	local rankList = pRankList or {}
	local globalProfile = pGlobalProfile or {}

	self.passFriendInfos = {}
	local function getProfileFromGlobal(uid)
		for k,v in pairs(globalProfile) do
			if uid == v.uid then 
				return v
			end
		end
	end
	for i,v in ipairs(rankList) do
		local singleInfo = {}
		singleInfo.uid = v.uid
		singleInfo.itemNum = v.score
		singleInfo.globalRank = v.globalRank
		local friendRef = FriendManager.getInstance().friends[tostring(v.uid)]
		if friendRef then 
			singleInfo.name = friendRef.name
			singleInfo.headUrl = friendRef.headUrl
		else
			local globalRef = getProfileFromGlobal(tostring(v.uid))
			if globalRef then 
				singleInfo.name = globalRef.name
				singleInfo.headUrl = globalRef.headUrl
				singleInfo.isGlobal = true
			end
		end
		if singleInfo.name and singleInfo.headUrl then 
			table.insert(self.passFriendInfos, singleInfo)
		end
	end

	if #self.passFriendInfos > 0 then 
		table.sort(self.passFriendInfos, function (a, b)
			if a.itemNum < b.itemNum then 
				return true
			elseif a.itemNum > b.itemNum then
				return false
			else
				local aUid = tonumber(a.uid) or 0
				local bUid = tonumber(b.uid) or 0
				return aUid < bUid
			end
		end)
	end

	local extraTargetConfig = SeasonWeeklyRaceManager:getInstance():getExtraTargetConfig()
	local targetNum = #extraTargetConfig
	if targetNum > 0 then 
		local friendGroup = {}
		for i=1,targetNum do
			if not friendGroup[i] then 
				friendGroup[i] = {}
			end
			friendGroup[i].min = extraTargetConfig[i].itemNum
			if extraTargetConfig[i+1] then
				friendGroup[i].max = extraTargetConfig[i+1].itemNum
			else 
				friendGroup[i].max = 9999
			end
			friendGroup[i].level = extraTargetConfig[i].level
			friendGroup[i].friends = {}
		end

		for i,v in ipairs(self.passFriendInfos) do
			for m,n in ipairs(friendGroup) do
				if v.itemNum >= n.min and v.itemNum < n.max then 
					v.level = m
					table.insert(friendGroup[m].friends, v)
					break
				end
			end
		end

		for i=1,targetNum-1 do
			local num = #friendGroup[i].friends
			if num >= 1 then 
				if num > 1 then 
					num = math.ceil(num/2)
				end
				local friend = friendGroup[i].friends[num]
				friendGroup[i].friends = {}
				table.insert(friendGroup[i].friends, friend)
			end
		end

		self.passFriendInfos = {}
		for i,v in ipairs(friendGroup) do
			self.passFriendInfos = table.union(self.passFriendInfos, v.friends)
		end
	end
end

function SeasonWeeklyMatchRankData:getPassFriendInfo()
	return self.passFriendInfos or {}
end

function SeasonWeeklyMatchRankData:getMyScore( ... )
	for index, rank in ipairs(self.rankList) do
		if tostring(rank.uid) == tostring(self.uid) then
			return rank.score
		end
	end
	return 0
end