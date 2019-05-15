SeasonWeeklyRaceData = class()

local function copyTable(t)
	local ret = {}
	if type(t) == "table" then
		for k, v in pairs(t) do
			ret[k] = v
		end
	end
	return ret
end

function SeasonWeeklyRaceData:ctor()
	self.levelMax 	= 0
	self.dailyShare 	= 0
	self.dailyLevelPlay = 0
	self.receivedDailyRewards = {}
	self.leftPlay 		= 0
	self.dailyDropPropCount = 0
	self.dailyDropPropCount2 = 0

	self.weeklyScore 	= 0
	self.receivedWeeklyRewards = {}
	self.dropPropCount = 0
	self.totalPlayed = 0
	self.firstGuideRewarded = false

	self.updateTime = Localhost:timeInSec()
	self.lastPlayedTime = Localhost:time() -- 任务系统过滤任务用



	-- 上周奖励相关数据	

	self.lastWeekRewards = {}

	--上周单次排行奖励

	self.lastWeekSurpass = 0
	self.lastWeekRank = 0
	self.lastWeekRankRewards = {}

	--上周累计排行奖励

	self.lastWeekTotalSurpass = 0
	self.lastWeekTotalRank = 0
	self.lastWeekTotalRankRewards = {}


	-- 关卡ID随机需求
	self.randomedIndices = {}
	self.lastIndexFinished = false

	self.medals = 0
	self.oldLevelMax = 0

	self.version = SeasonWeeklyRaceHttpUtil.weekMatchVersion

	self.dailyMaxScore 	= 0
end

function SeasonWeeklyRaceData:decrLeftPlay()
	self.leftPlay = self.leftPlay - 1
end

function SeasonWeeklyRaceData:resetDailyData()

	if PlatformConfig:isPlatform(PlatformNameEnum.kQQ) then
		self.levelMax 	= 0
	end
	
	self.dailyLevelPlay = 0
	self.dailyShare 	= 0
	self.leftPlay 		= 0
	self.receivedDailyRewards = {}
	self.dailyDropPropCount = 0
	self.dailyDropPropCount2 = 0
end

function SeasonWeeklyRaceData:resetWeeklyData()

	if not PlatformConfig:isPlatform(PlatformNameEnum.kQQ) then
		self.levelMax 	= 0
	end

	self:resetDailyData()

	self.weeklyScore 	= 0
	self.receivedWeeklyRewards = {}
	self.dropPropCount = 0
	self.totalPlayed = 0

	self.lastWeekSurpass = 0
	self.lastWeekRank = 0
	self.lastWeekRankRewards = {}

	self.lastWeekTotalSurpass = 0
	self.lastWeekTotalRank = 0
	self.lastWeekTotalRankRewards = {}

	self.lastWeekRewards = {}

	self.activeFriends = {}
end

function SeasonWeeklyRaceData:incrLeftPlay(incrPlay)
	--if _G.isLocalDevelopMode then printx(0, 'RRR  SeasonWeeklyRaceData:incrLeftPlay ---------------------- ', incrPlay, self.leftPlay) end
	--printx( 1 , "   " , debug.traceback() )
	incrPlay = incrPlay or 1
	self.leftPlay = tonumber(self.leftPlay) + incrPlay
end

function SeasonWeeklyRaceData:addScore(newScore)
	if newScore > self.levelMax then
		self.oldLevelMax = self.levelMax
		self.levelMax = newScore
	end
	self.weeklyScore = self.weeklyScore + newScore
end

function SeasonWeeklyRaceData:addShareCount(addCount)
	addCount = addCount or 1
	self.dailyShare = self.dailyShare + addCount
end

function SeasonWeeklyRaceData:addDailyTimePropCount(addCount)
	addCount = addCount or 1
	self.dailyDropPropCount = self.dailyDropPropCount + addCount

	-- self.dailyDropPropCount = math.min(self.dailyDropPropCount,SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCount)
end

function SeasonWeeklyRaceData:addDailyTimePropCount2(addCount)
	addCount = addCount or 1
	self.dailyDropPropCount2 = self.dailyDropPropCount2 + addCount

	-- jingliping
	-- self.dailyDropPropCount2 = math.min(self.dailyDropPropCount2,SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCountJingLiPing)
end

function SeasonWeeklyRaceData:addDailyLevelPlayCount( addCount )
	addCount = addCount or 1
	self.dailyLevelPlay = self.dailyLevelPlay + addCount
end

function SeasonWeeklyRaceData:setLastPlayedTime()
	self.lastPlayedTime = Localhost:time()
end

function SeasonWeeklyRaceData:getLastPlayedTime()
	return self.lastPlayedTime
end

function SeasonWeeklyRaceData:fromLua(src)
	local data = SeasonWeeklyRaceData.new()
	if src then

		if not src.version then src.version = 0 end

		--self.version = SeasonWeeklyRaceHttpUtil.weekMatchVersion
		--[[
		local needTransData = false
		
		if not src.version and tostring(src.dailyShare) ~= "127" then
			needTransData = true
		elseif src.version and tonumber(src.version) < tonumber(SeasonWeeklyRaceHttpUtil.weekMatchVersion) then
			needTransData = true
		end
		]]

		data.leftPlay = src.leftPlay or 0

		if tonumber(data.version) > tonumber(src.version) and tostring(src.dailyShare) ~= "127" then
			--return
			if not src.dailyLevelPlay then src.dailyLevelPlay = 0 end

			local addPlayCount = 0

			if src.dailyLevelPlay == 1 then
				data.dailyLevelPlay = 1
			elseif  src.dailyLevelPlay == 2 then
				data.dailyLevelPlay = 2
				addPlayCount = 1
			elseif  src.dailyLevelPlay >= 3 then
				if src.dailyShare and tonumber(src.dailyShare) >= 1 then
					data.dailyLevelPlay = 6
					--addPlayCount = 1
				else
					data.dailyLevelPlay = 4
				end
			end

			data:incrLeftPlay(addPlayCount)
			data.dailyShare = 127
			--data.leftPlay = src.leftPlay + addPlayCount
		else
			data.dailyLevelPlay = src.dailyLevelPlay or 0
			data.dailyShare 	= src.dailyShare
		end

		data.levelMax 	= src.levelMax or 0
		data.weeklyScore 	= src.weeklyScore
		data.receivedDailyRewards = copyTable(src.receivedDailyRewards)
		data.receivedWeeklyRewards = copyTable(src.receivedWeeklyRewards)
		data.updateTime = src.updateTime
		data.lastPlayedTime = src.lastPlayedTime
		data.dropPropCount = src.dropPropCount or 0
		data.totalPlayed = src.totalPlayed or 0
		data.dailyDropPropCount = src.dailyDropPropCount or 0
		data.dailyDropPropCount2 = src.dailyDropPropCount2 or 0
		data.firstGuideRewarded = src.firstGuideRewarded
		data.firstGuideRewarded = src.firstGuideRewarded
		data.randomedIndices = src.randomedIndices or {}
		data.lastIndexFinished = src.lastIndexFinished or false
		data.medals = src.medals
		data.accumulateWeekShareRewardCount = src.accumulateWeekShareRewardCount or 0

		data.pieceNum = src.pieceNum or 0
		data.totalPieceNum = src.totalPieceNum or 0
		data.linkPieceNum = src.linkPieceNum or 0

		local skins = src.skins
		if type(skins) == 'string' then
			skins = table.deserialize(skins)
		end
		data.skins = table.clone(skins or {}, true)
		data.skins = self:checkSkins(data.skins)

		local curSkin = src.curSkin
		if type(curSkin) == 'string' then
			curSkin = table.deserialize(curSkin)
		end
		data.curSkin = table.clone(curSkin or {}, true)
		data.curSkin = self:checkCurSkin(data.curSkin)


		data.oldLevelMax = src.oldLevelMax

	end
	return data
end

function SeasonWeeklyRaceData:checkServerSkins( skins )
	local newSkins = {}

	for skinType, v in pairs(skins) do

		local newV = {}

		for groupIndex, positionGrp in pairs(v.groupDetail) do
			newV[tonumber(groupIndex)] = table.clone(positionGrp, true)
		end

		newSkins[tonumber(skinType)] = newV
	end

	return newSkins

end

function SeasonWeeklyRaceData:checkSkins( skins )

	local newSkins = {}

	for skinType, v in pairs(skins) do

		local newV = {}

		for groupIndex, positionGrp in pairs(v) do
			newV[tonumber(groupIndex)] = table.clone(positionGrp, true)
		end

		newSkins[tonumber(skinType)] = newV
	end

	return newSkins
end

function SeasonWeeklyRaceData:checkCurSkin( curSkin )

	local newCurSkin = {}

	for skinType, v in pairs(curSkin) do

		
		newCurSkin[tonumber(skinType)] = v
	end

	return newCurSkin
end

function SeasonWeeklyRaceData:fromRespData(src, localData)
	local data = SeasonWeeklyRaceData.new()
	if src then

		if not src.weekMatchVersion then src.weekMatchVersion = 0 end

		if tonumber(data.version) < tonumber(src.weekMatchVersion) then
			--return
		end

		data.levelMax 	= src.levelMax or 0
		data.weeklyScore 	= src.countThisWeek
		data.leftPlay 		= src.leftPlayTimes or 0
		data.dailyLevelPlay = src.mainLevelCount or 0
		data.dailyShare 	= src.shareCount or 0
		if not src.todayReward then src.todayReward = {} end
		data.receivedDailyRewards = copyTable(src.todayReward)
		data.receivedWeeklyRewards = copyTable(src.rewardsThisWeek)
		data.dropPropCount = src.droppedCount or 0
		data.totalPlayed = src.playSummerMatchTimes
		data.dailyDropPropCount = src.droppedCountDaily or 0
		data.dailyDropPropCount2 = src.energyDropCount or 0
		-- if _G.isLocalDevelopMode then printx(0, "get match data from resp : ",data.dailyDropPropCount,data.dailyDropPropCount2) end
		-- debug.debug()
		data.firstGuideRewarded = src.firstGuideRewarded

		data.activeFriends = src.friendIds
		data.lastWeekSurpass = src.lastPassFriendCount
		data.lastWeekTotalSurpass = src.lastTotalPassFriendCount

		data.lastWeekRank = src.lastPos
		data.lastWeekTotalRank = src.lastTotalPos

		data.medals = src.medals
		data.accumulateWeekShareRewardCount = src.accumulateWeekShareRewardCount or 0

		data.pieceNum = src.pieceNum or 0
		data.totalPieceNum = src.totalPieceNum or 0
		data.linkPieceNum = src.linkPieceNum or 0

		local skins = src.skins
		if type(skins) == 'string' then
			skins = table.deserialize(skins)
		end
		data.skins = table.clone(skins or {}, true)
		data.skins = self:checkServerSkins(data.skins)

		local curSkin = src.curSkin
		if type(curSkin) == 'string' then
			curSkin = table.deserialize(curSkin)
		end
		data.curSkin = table.clone(curSkin or {}, true)
		data.curSkin = self:checkCurSkin(data.curSkin)


		data.lastWeekRewards = copyTable(src.rewardsLastWeek)
		data.lastWeekRankRewards = copyTable(src.rankRewardsLastWeek)
		data.lastWeekTotalRankRewards = copyTable(src.totalRankRewardsLastWeek or {})

		data.oldLevelMax = data.levelMax

		if type(localData) == "table" and type(localData.lastPlayedTime) == "number" then
			data.lastPlayedTime = localData.lastPlayedTime
		end

		local timeStamp = Localhost:time()
		local num = tonumber(src.playCountReceived) or 0
		if num > 0 then
			CCUserDefault:sharedUserDefault():setFloatForKey("season.weekly.race.help.record", timeStamp)
			local now = Localhost:time()
			local createTime = UserManager:getInstance().mark.createTime or now
			local todayStart = math.floor((now - createTime) / 86400000) * 86400000 + createTime
			local timeStamp = CCUserDefault:sharedUserDefault():getFloatForKey("season.weekly.race.help.record")
			local hasNum = CCUserDefault:sharedUserDefault():getIntegerForKey("season.weekly.race.help.num")
			if type(timeStamp) == "number" and timeStamp > todayStart and timeStamp < todayStart + 86400000 and
				type(hasNum) == "number" and hasNum > 0 then
				CCUserDefault:sharedUserDefault():setIntegerForKey("season.weekly.race.help.num", num + hasNum)
			else
				CCUserDefault:sharedUserDefault():setIntegerForKey("season.weekly.race.help.num", num)
			end
			CCUserDefault:sharedUserDefault():flush()
		end
	end
	return data
end

function SeasonWeeklyRaceData:getLevelRandomDataFromLocal(data)
	self.randomedIndices = data.randomedIndices or {}
	self.lastIndexFinished = data.lastIndexFinished or false
end

function SeasonWeeklyRaceData:getIsShowHelpTip()
	local now = Localhost:time()
	local createTime = UserManager:getInstance().mark.createTime or now
	local todayStart = math.floor((now - createTime) / 86400000) * 86400000 + createTime
	local timeStamp = CCUserDefault:sharedUserDefault():getFloatForKey("season.weekly.race.help.record")
	local num = CCUserDefault:sharedUserDefault():getIntegerForKey("season.weekly.race.help.num")
	if type(timeStamp) == "number" and timeStamp > todayStart and timeStamp < todayStart + 86400000 and
		type(num) == "number" and num > 0 then
		return true
	end
	return false
end

function SeasonWeeklyRaceData:ShowedHelpTip()
	CCUserDefault:sharedUserDefault():setIntegerForKey("season.weekly.race.help.num", 0)
	CCUserDefault:sharedUserDefault():flush()
end

function SeasonWeeklyRaceData:getHelpNum()
	return tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey("season.weekly.race.help.num"))
end

function SeasonWeeklyRaceData:encode()
	local data = {}
	for k, v in pairs(self) do
		if k ~= "class" and v ~= nil and type(v) ~= "function" then data[k] = v end
	end
	return data
end