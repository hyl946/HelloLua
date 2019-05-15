SeasonWeeklyShowOffData = class()

function SeasonWeeklyShowOffData:ctor()
	self.date = nil
	self.dailyChampShared = 0
	self.dailySurpassShared = 0
	self.showPlayTip = true
	self.showTipsCounter = {}
end

function SeasonWeeklyShowOffData:create()
	local data = SeasonWeeklyShowOffData.new()
	data:init()
	return data
end

function SeasonWeeklyShowOffData:init()
	self.date = self:keyOfToday()
end

function SeasonWeeklyShowOffData:incrChampShared()
	self.dailyChampShared = self.dailyChampShared + 1
end

function SeasonWeeklyShowOffData:incrSurpassShared()
	self.dailySurpassShared = self.dailySurpassShared + 1
end

function SeasonWeeklyShowOffData:keyOfToday( ... )
	local day = os.date("*t", Localhost:timeInSec())
	return day.year.."_"..day.month.."_"..day.day
end

function SeasonWeeklyShowOffData:hasExpired()
	if self.date ~= self:keyOfToday() then
		return true
	end
	return false
end

function SeasonWeeklyShowOffData:getTipShowCount(tipType)
	if not tipType then return 0 end
	local key = tostring(tipType)
	return self.showTipsCounter[key] or 0
end

function SeasonWeeklyShowOffData:onShowTip(tipType)
	if not tipType then return end
	local key = tostring(tipType)
	local oldNum = self:getTipShowCount(key)
	self.showTipsCounter[key] = oldNum + 1
end

function SeasonWeeklyShowOffData:fromLua(src)
	if src then
		local data = SeasonWeeklyShowOffData.new()
		data.date = src.date
		data.dailyChampShared = src.dailyChampShared or 0
		data.dailySurpassShared = src.dailySurpassShared or 0
		data.showPlayTip = src.showPlayTip
		data.showTipsCounter = {}
		if src.showTipsCounter then
			for k, v in pairs(src.showTipsCounter) do
				data.showTipsCounter[k] = v
			end
		end
		return data
	end
	return nil
end
