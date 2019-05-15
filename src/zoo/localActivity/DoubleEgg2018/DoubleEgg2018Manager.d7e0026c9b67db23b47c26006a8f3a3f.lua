
DoubleEgg2018Manager = class()

local instance = nil

local VERSION = "1_"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = 'Christmas2018/Config.lua'
local ACT_ID = 1029
local kStorageFileName = "Christmas2018"..VERSION
local kLocalDataExt = ".ds"

function DoubleEgg2018Manager.getInstance()
	if not instance then
		instance = DoubleEgg2018Manager.new()
		instance:init()
	end
	return instance
end

local function getUid()
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)
	return uid
end

function DoubleEgg2018Manager:init()
    self.UpdateActivityTime = 0
    self.MainEndTime = 0
    self.AllEndTime = 0
    self.Guide1Run = false
    self.Guide2Run = false

	self.uid = getUid()
	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt

	self:readFromLocal()
end


function DoubleEgg2018Manager:isActivitySupport()

--    if __WIN32 then
--        return true
--    end

    self:PassDayReset()

	local endTime = self.MainEndTime or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function DoubleEgg2018Manager:getDayStartTimeByTS(ts) --传入毫秒
	local utc8TimeOffset = 57600*1000 -- (24 - 8) * 3600
	local oneDaySeconds = 86400*1000 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

function DoubleEgg2018Manager:readFromLocal()
	local file, err = io.open(self.filePath, "rb")

	if file and not err then
		local content = file:read("*a")
		io.close(file)

        local data = nil
        local function decodeContent()
            data = amf3.decode(content)
        end
        pcall(decodeContent)

		if data and type(data) == "table" then
			self.MainEndTime = data.MainEndTime or 0
            self.AllEndTime = data.AllEndTime or 0
            self.UpdateActivityTime = data.UpdateActivityTime or 0
            self.Guide1Run = data.Guide1Run or false
            self.Guide2Run = data.Guide2Run or false
		end
	end

    self:PassDayReset()
end

function DoubleEgg2018Manager:PassDayReset()

    if self.UpdateActivityTime == 0 then
        return
    end
    
    --第二天刷新数据
    local SaveStartTime = self:getDayStartTimeByTS( self.UpdateActivityTime )
    local TodayStartTime = self:getDayStartTimeByTS( Localhost:time() )

    if SaveStartTime ~= TodayStartTime then
        self.UpdateActivityTime = Localhost:time()
        self:writeToLocal()
    end

end

function DoubleEgg2018Manager:writeToLocal()
	local data = {}
    data.MainEndTime = self.MainEndTime
    data.AllEndTime = self.AllEndTime
    data.UpdateActivityTime = self.UpdateActivityTime
    data.Guide1Run = self.Guide1Run
    data.Guide2Run = self.Guide2Run

	local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    -- assert(file, "DoubleEgg2018Manager persistent file failure " .. kStorageFileName)
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end

function DoubleEgg2018Manager:updateByActivity( mainEndTime, allEndTime )
    self.MainEndTime = mainEndTime or 0
    self.AllEndTime = allEndTime or 0
    self.UpdateActivityTime = Localhost:time()

    self:writeToLocal()
end

function DoubleEgg2018Manager:getActConfigSync(actId)
	local activitys = ActivityUtil:getAllActivitysSync()
	local activity = table.find(activitys,function( v )
        local c = require("activity/" .. v.source)
        return tostring(c.actId) == tostring(actId)
    end)
    
    if activity  then
    	return (require("activity/" .. activity.source))
    end
end

function DoubleEgg2018Manager:setGuideComplete(index)
    if index == 1 then
        self.Guide1Run = true
    elseif index == 2 then
        self.Guide2Run = true
    end

    self:writeToLocal()
end
