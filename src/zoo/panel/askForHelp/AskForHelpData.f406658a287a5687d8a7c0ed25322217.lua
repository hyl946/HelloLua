local AskForHelpData = class()

function AskForHelpData:ctor()
	-- offline
	self.mruLevelId = -1
	self.failedTimes = 0
	self.eGuide = 0

	-- dailydata
	self.dailyPopoutQuato = 1		-- 每日强弹次数
	self.dailyPopoutLevels = {}		-- 每天强弹过的关卡
	self.pendingSnsFriends = {}		-- 未SNS求助过的好友

	-- volatile
	self.cachedLevelId = 0
	
	-- syned
	self.dailyHelpOtherCount = 0	-- 当天已成功帮助其它人的次数
	self.beHelpedCount = 0			-- 被其他人帮助的次数
	self.levelAskedFriends = {}		-- 求助过的好友
	self.leftAskNum = 0
	self.dailyAskedLevelIds = {}	-- 当天发送过求助的关卡id
	self.totalHelpOtherCount = 0	-- 成功帮助别人过关的总次数
	self.recentHelpOtherRecords = {}
	self.dailyBeHelpedCount = 0		-- 当天被好友成功帮助过的次数
	self.friendIds = {}				-- 好友排序列表
end

function AskForHelpData:onPassDay()
	self.dailyPopoutTimes = 0

	-- syned
	self.dailyHelpOtherCount = 0
	self.dailyBeHelpedCount = 0
	self.levelAskedFriends = {}
	self.dailyAskedLevelIds = {}
end

function AskForHelpData:getExcludeFriends()
	local function filter(excludeUids, rhs)
  		local intersection = {}
  		for i, v in ipairs(rhs) do
   			if table.includes(excludeUids, v) then table.insert(intersection, v) end
 		end
		
		local ret = {}
		for i, v in ipairs(excludeUids) do
   			if not table.includes(intersection, v) then table.insert(ret, v) end
 		end
		return ret
	end

	return filter(self.levelAskedFriends, self.pendingSnsFriends)
end

function AskForHelpData:hasHelped()
	return self.dailyBeHelpedCount > 0
end

function AskForHelpData:addLevelAskedFriends(uid)
	return table.insertIfNotExist(self.levelAskedFriends, uid)
end
function AskForHelpData:hasAskedFriend(uid)
	return table.exist(self.levelAskedFriends, uid)
end

function AskForHelpData:hasAskedLevel(uid)
	return table.exist(self.dailyAskedLevelIds, uid)
end

function AskForHelpData:isPendingStatus(uid)
	return table.exist(self.pendingSnsFriends, uid)
end

function AskForHelpData:addPendingStatus(uid)
	return table.insertIfNotExist(self.pendingSnsFriends, uid)
end

function AskForHelpData:removePendingStatus(uid)
	return table.removeIfExist(self.pendingSnsFriends, uid)
end

function AskForHelpData:hasCached(levelId)
	return self.cachedLevelId == levelId
end

function AskForHelpData:onFailLevel(levelId)
	if self.mruLevelId ~= levelId then
		self.mruLevelId = levelId
		self.failedTimes = 1
	else
		self.failedTimes = self.failedTimes + 1
	end
end

function AskForHelpData:clearFailLevel()
	self.mruLevelId = -1
	self.failedTimes = 0
end

local function cloneMetaTableArray(dst)
	local result = {}
	for i,v in ipairs(dst) do
		result[i] = v
	end
	return result
end 
function AskForHelpData:synWithServer(data, src, cachedLevelId)
	local ret = data or AskForHelpData.new()
	if src then
		ret.dailyHelpOtherCount = src.dailyHelpOtherCount or 0
		ret.beHelpedCount = src.beHelpedCount or 0
		ret.dailyAskedLevelIds = cloneMetaTableArray(src.dailyAskedLevelIds)
		ret.levelAskedFriends = cloneMetaTableArray(src.levelAskedFriends)
		ret.leftAskNum = src.leftAskNum or 0
		ret.totalHelpOtherCount = src.totalHelpOtherCount or 0
		ret.recentHelpOtherRecords = src.recentHelpOtherRecords or {}
		ret.dailyBeHelpedCount = src.dailyBeHelpedCount or 0

		-- cached flag
		ret.cachedLevelId = cachedLevelId or 0
	end
	return ret
end

--serialize-----------------------------------------------------------------------------
function AskForHelpData:fromRespData(src)
	local ret = AskForHelpData.new()
	if src then
		ret.eGuide = src.eGuide
        ret.mruLevelId = src.mruLevelId or - 1
        ret.failedTimes = src.failedTimes or 0

		-- syned
		ret.beHelpedCount = src.beHelpedCount or 0
		ret.leftAskNum = src.leftAskNum or 0
		ret.totalHelpOtherCount = src.totalHelpOtherCount or 0
		ret.recentHelpOtherRecords = src.recentHelpOtherRecords or {}
		ret.levelAskedFriends = cloneMetaTableArray(src.levelAskedFriends or {})
		ret.pendingSnsFriends = cloneMetaTableArray(src.pendingSnsFriends or {})
	end

	local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) == 'table' and userDailyData.AskForHelpData then
		local src = userDailyData.AskForHelpData
		ret.dailyPopoutQuato = src.dailyPopoutQuato or 1
		ret.dailyPopoutLevels = cloneMetaTableArray(src.dailyPopoutLevels or {})
		ret.pendingSnsFriends = src.pendingSnsFriends or {}
		ret.dailyBeHelpedCount = src.dailyBeHelpedCount or 0

		ret.dailyHelpOtherCount = src.dailyHelpOtherCount or 0
		ret.dailyAskedLevelIds = cloneMetaTableArray(src.dailyAskedLevelIds or {})
	end

	return ret
end

function AskForHelpData:encode()
	local data = {}
	for k, v in pairs(self) do
		if k ~= "class" and v ~= nil and type(v) ~= "function" then data[k] = v end
	end
	return data
end

function AskForHelpData:flushToStorage()
	local ret = {}
	ret.dailyPopoutQuato = self.dailyPopoutQuato
	ret.dailyPopoutLevels = cloneMetaTableArray(self.dailyPopoutLevels or {})
	ret.pendingSnsFriends = self.pendingSnsFriends

	ret.dailyHelpOtherCount = self.dailyHelpOtherCount	-- 当天已成功帮助其它人的次数
	ret.dailyBeHelpedCount = self.dailyBeHelpedCount or 0
	ret.dailyAskedLevelIds = cloneMetaTableArray(self.dailyAskedLevelIds or {})	-- 当天发送过求助的关卡id
	ret.totalHelpOtherCount = self.totalHelpOtherCount or 0
	ret.recentHelpOtherRecords = self.recentHelpOtherRecords or 0

	local dailyData = Localhost:readLocalDailyData()
	dailyData.AskForHelpData = ret
	dailyData.resetTime = Localhost:timeInSec()
	Localhost:writeLocalDailyData(nil, dailyData)

	Localhost.getInstance():writeAskForHelpData(self:encode())
end

-- protocal----------------------------------------------------------------------------

local function showErrorTip(evt)
	local errcode = evt and evt.data or nil
	if errcode then
		local key = "askforhelp.error.tip." ..tostring(errcode)
		if key == Localization:getInstance():getText(key) then
			key = "error.tip."..tostring(errcode)
		end
		setTimeOut(function ( ... ) CommonTip:showTip(Localization:getInstance():getText(key), "negative") end, 0.001)
	end
end

return AskForHelpData