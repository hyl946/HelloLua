

---计算当前是第几周, 周一到周日算同一周
local function getWeekIndex( timeInSec )
	return math.floor((timeInSec - 4 * 24 * 3600 + 8 * 3600) / (7 *24 * 3600)) + 1
end

---梦瑶记周法: 计算当前是第几周, 这周六到下周五算同一周
local function getMengYaoWeekIndex( timeInSec )
	return getWeekIndex(timeInSec + 2 * 24 * 3600)
end


local function time2day(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
	return (dayStart + 8*3600)/24/3600
end



local FreeLotteryStrategy = class()

function FreeLotteryStrategy:ctor( tag )
	self.tag = tag
end

function FreeLotteryStrategy:shouldShowBBSPanel( lotteryLogic )
	return false
end

function FreeLotteryStrategy:getTag( ... )
	return self.tag
end

function FreeLotteryStrategy:getLeftFreeDrawCount( lotteryLogic )
	-- printx(61, 'NewFreeLotteryStrategy')

	return 0
end

function FreeLotteryStrategy:onLotteryFinish( lotteryLogic, ts )
	local json = self:getData()
	json.lastFreeTime = ts
	self:writeData(json)
end

function FreeLotteryStrategy:getData( ... )
	local json = table.deserialize(UserManager:getInstance().add5LotteryInfo or '{}') or {}
	if not json.lastFreeTime then
		json.lastFreeTime = 0
	end
	if not json.freeCount then
		json.freeCount = 0
	end
	return json
end

function FreeLotteryStrategy:writeData( json )
	local data = table.serialize(json) or '{}'
	UserManager:getInstance().add5LotteryInfo = data
	UserService:getInstance().add5LotteryInfo = data
end

function FreeLotteryStrategy:getLastLotteryTimeInSec( ... )
	return self:getData().lastFreeTime
end

function FreeLotteryStrategy:getThisMengYaoWeekLotteryCount( lotteryLogic )
	local freeCount = self:getData().freeCount

	local now = lotteryLogic:timeInSec()

	local lastFreeDrawTimeStampInSec = (tonumber(self:getLastLotteryTimeInSec() or 0) or 0)/1000

	local lastWeekIndex = getMengYaoWeekIndex(lastFreeDrawTimeStampInSec)
	local nowWeekIndex = getMengYaoWeekIndex(now)


	local thisWeekLotteryCount = freeCount
	
	if lastWeekIndex ~= nowWeekIndex then
		thisWeekLotteryCount = 0
	end

	return thisWeekLotteryCount
end



local StA = class(FreeLotteryStrategy)


function StA:getLeftFreeDrawCount( lotteryLogic )

	-- printx(61, 'StA')

	if not lotteryLogic:isFreeEnable() then
		return 0
	end
	
	local now = lotteryLogic:timeInSec()
	local date = os.date('*t', now)
	if date.wday ~= 1 and date.wday ~= 7 then --1是星期日 7是星期六
		return 0
	end

	local lastFreeDrawTimeStampInSec = (tonumber(self:getLastLotteryTimeInSec() or 0) or 0)/1000

	local lastWeekIndex = getWeekIndex(lastFreeDrawTimeStampInSec)
	local nowWeekIndex = getWeekIndex(now)
	if nowWeekIndex <= lastWeekIndex then
		return 0
	end

	return 1
end

function StA:shouldShowBBSPanel( lotteryLogic )
	return true
end


local StB = class(FreeLotteryStrategy)


function StB:getLeftFreeDrawCount( lotteryLogic )
	-- printx(61, 'StB')

	

	if not lotteryLogic:isFreeEnable() then
		return 0
	end
	
	local now = lotteryLogic:timeInSec()
	local date = os.date('*t', now)
	if date.wday ~= 1 and date.wday ~= 7 then --1是星期日 7是星期六
		return 0
	end

	local lastFreeDrawTimeStampInSec = (tonumber(self:getLastLotteryTimeInSec() or 0) or 0)/1000


	local lastDayIndex = time2day(lastFreeDrawTimeStampInSec)
	local nowDayIndex = time2day(now)

	if nowDayIndex <= lastDayIndex then
		return 0
	end

	return 1

end


local StC = class(FreeLotteryStrategy)

function StC:getLeftFreeDrawCount( lotteryLogic )
	
	-- printx(61, 'StC')

	if not lotteryLogic:isFreeEnable() then
		return 0
	end
	
	local now = lotteryLogic:timeInSec()

	local lastFreeDrawTimeStampInSec = (tonumber(self:getLastLotteryTimeInSec() or 0) or 0)/1000

	local lastDayIndex = time2day(lastFreeDrawTimeStampInSec)
	local nowDayIndex = time2day(now)

	local thisWeekLotteryCount = self:getThisMengYaoWeekLotteryCount(lotteryLogic)


	if thisWeekLotteryCount >= 2 then
		return 0
	end

	if lastDayIndex >= nowDayIndex then
		return 0
	end

	return 1

end


function StC:onLotteryFinish(lotteryLogic, ts )
	FreeLotteryStrategy.onLotteryFinish(self, lotteryLogic, ts)

	local thisWeekLotteryCount = self:getThisMengYaoWeekLotteryCount(lotteryLogic) + 1
	local json = self:getData()
	json.freeCount = thisWeekLotteryCount
	self:writeData(json)
end


local StD = class(FreeLotteryStrategy)

function StD:getLeftFreeDrawCount( lotteryLogic )

	-- printx(61, 'StD')

	if not lotteryLogic:isFreeEnable() then
		return 0
	end
	
	local now = lotteryLogic:timeInSec()

	local lastFreeDrawTimeStampInSec = (tonumber(self:getLastLotteryTimeInSec() or 0) or 0)/1000

	local lastDayIndex = time2day(lastFreeDrawTimeStampInSec)
	local nowDayIndex = time2day(now)

	if nowDayIndex <= lastDayIndex then
		return 0
	end

	return 1

end


function FreeLotteryStrategy:createStrategy( ... )

	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
		
	

	MaintenanceManager:getInstance():printGroupRange('NewFiveStepsLotteryFree')

	local is1 = MaintenanceManager:getInstance():isEnabledInGroup('NewFiveStepsLotteryFree', 'C1', uid)
	local is2 = MaintenanceManager:getInstance():isEnabledInGroup('NewFiveStepsLotteryFree', 'C2', uid)
	local is3 = MaintenanceManager:getInstance():isEnabledInGroup('NewFiveStepsLotteryFree', 'C3', uid)
	local is4 = MaintenanceManager:getInstance():isEnabledInGroup('NewFiveStepsLotteryFree', 'C4', uid)

	if __WIN32 then
		is4 = true
	end

	if is1 then
		return StA.new(1)
	end

	if is2 then
		return StB.new(2)
	end

	if is3 then
		return StC.new(3)
	end

	if is4 then
		return StD.new(4)
	end

	-- assert(false, '就这样坠入深渊...')

	return FreeLotteryStrategy.new()
end


return FreeLotteryStrategy