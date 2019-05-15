require "zoo.eggs.NationalDayAnimation"

local dataName = "nationalDay"
NationalDayManager = {}

function NationalDayManager:getDiceChance( ... )
	-- 获得骰子的概率30%
	return 30
end

function NationalDayManager:isSupport( ... )
	return false
	-- return table.find(ActivityUtil:getActivitys() or {},function( v )
	-- 	return v.source == "Guoqing2016/Config.lua"
	-- end)
end

function NationalDayManager:getData( ... )
	if not self.data then
		self.data = Localhost:readFromStorage(dataName) or {}
	end
	return self.data
end

function NationalDayManager:saveData( ... )
	self.data = { lastGetDiceTime = self.lastGetDiceTime,seqGetDiceTimes = self.seqGetDiceTimes }
	Localhost:writeToStorage(self.data,dataName)
end

function NationalDayManager:hasGetProp( ... )
	return self.getProp
end

function NationalDayManager:hasGetDice( ... )
	return self.getDice
end

function NationalDayManager:clear( ... )
	self.getProp = false
	self.getDice = false
end

-- 结束关卡
function NationalDayManager:completeLevel( levelType,levelId,star )
	self:clear()

	if not self:isSupport() then
		return
	end

	if not LevelType:isMainLevel(levelId)
		and not LevelType:isHideLevel(levelId)
		and not LevelType:isSummerMatchLevel(levelId) then
		
		return
	end


	-- if _G.isLocalDevelopMode then printx(0, "NationalDayManager:completeLevel",levelType,levelId,star) end
	-- debug.debug()

	local score = UserManager:getInstance():getUserScore(levelId)
	
	-- 若本次闯关为四星关或隐藏关，且成功过关
	if LevelType:isMainLevel(levelId) then
		if not score or score.star ~= 4 then
			if star == 4 then
				self.getProp = true
				return
			end
		end
	end

	if LevelType:isHideLevel(levelId) then
		if not score or score.star == 0 then
			if star > 0 then
				self.getProp = true
				return
			end
		end
	end

	if not self.lastGetDiceTime then
		self.lastGetDiceTime = self:getData().lastGetDiceTime or 0
	end
	if not self.seqGetDiceTimes then
		self.seqGetDiceTimes = self:getData().seqGetDiceTimes or 0
	end

	--不会出现连续5次闯关不获得骰子的情况
	if self.lastGetDiceTime >= 5 then
		self.getDice = true 

	--不会出现连续出3个的骰子的情况
	elseif self.seqGetDiceTimes >= 3 then 
		self.getDice = false

	-- 概率
	elseif math.random(0,100) <= self:getDiceChance() then
		self.getDice = true
	end

	if self.getDice then
		self.lastGetDiceTime = 1
		self.seqGetDiceTimes = self.seqGetDiceTimes + 1
	else
		self.lastGetDiceTime = self.lastGetDiceTime + 1
		self.seqGetDiceTimes = 1
	end

	self:saveData()
end