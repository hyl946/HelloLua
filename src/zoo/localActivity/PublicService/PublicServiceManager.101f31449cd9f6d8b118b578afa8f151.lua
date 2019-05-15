_G.__PublicService = 1

PublicServiceManager = {}

local VERSION = "2_"	--本地缓存标识 每次换皮应更改 
local ACT_SOURCE = 'PublicService/Config.lua'
local ACT_MAIN_END_TIME = "public_service_main_end_time_"..VERSION
local ACT_ALL_END_TIME = "public_service_all_end_time_"..VERSION
local kStorageFileName = "public_service_"..VERSION
local kLocalDataExt = ".ds"
local actId = 1020

local function getUid()
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)
	return uid
end

local function getActInfo()
    local actInfo
    for k, v in pairs(UserManager:getInstance().actInfos or {}) do
        if v.actId == actId then
            actInfo = v
            break
        end
    end
    return actInfo    
end

function PublicServiceManager:init()
	if self.isInited then
		return
	end

	self.isInited = true
	self.data = {
		totalTargetCount = 0,
		mainEndTime = 0,
		actEndTime = 0,
		chapterTargetConfig = {6, 16, 32, 60, 90, 120},
		chapterIndex = 1,
	}

	self.uid = getUid()
	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt
	self:readFromLocal()

	local actInfo = getActInfo()
    if actInfo then
        local info = table.deserialize(actInfo.extra or "{}")
        self.data.totalTargetCount = info.totalTargetCount
        self.data.chapterIndex = info.chapterIndex
        self:writeToLocal()
    end

	Notify:register("PublicServiceActEvent", PublicServiceManager.updateByActivity, PublicServiceManager)
	Notify:register("PublicServiceActUpdateDataEvent", PublicServiceManager.updateData, PublicServiceManager)
	Notify:register("AchiEventStartLevel", self.onStartLevel, self)
end

function PublicServiceManager:onStartLevel(levelId, levelType)
	self.topLevelId = UserManager.getInstance().user:getTopLevelId()
end

function PublicServiceManager:readFromLocal()
	local file, err = io.open(self.filePath, "r")

	if file and not err then
		local content = file:read("*a")
		io.close(file)

        if content then
            local data = table.deserialize(content) or {}
            for k,v in pairs(data) do
            	self.data[k] = v
            end
        end
	end
end

function PublicServiceManager:writeToLocal()
	local file = io.open(self.filePath,"w")
    if file then 
        file:write(table.serialize(self.data or {}))
        file:close()
    end

    if _G.isLocalDevelopMode then
    	local file = io.open(self.filePath..".DEBUG","w")
	    if file then 
	        file:write(table.tostring(self.data or {}))
	        file:close()
	    end
    end
end

function PublicServiceManager:shouldShowActCollection(levelId)
	self:init()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local highestLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	if self.topLevelId == nil then
		return false
	end
	if highestLevelId > topLevelId then
		if self.topLevelId <= topLevelId and levelId < self.topLevelId then
			return false
		end
	elseif highestLevelId == topLevelId then
		local scoreRef = UserManager:getInstance():getUserScore(topLevelId)
		if (not scoreRef or scoreRef.star == 0 ) and levelId ~= topLevelId then
			return false
		end
	end

	return LevelType:isMainLevel( levelId ) and self:isActivitySupport()
end

function PublicServiceManager:isActivitySupport()
	if __WIN32 then 
		-- return true
	end

	local endTime = self.data.mainEndTime or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function PublicServiceManager:isActivitySupportAll()
	if __WIN32 then 
		-- return true
	end

	local endTime = self.data.actEndTime or 0
	if Localhost:timeInSec() > endTime then 
		return false
	end

	return true
end

function PublicServiceManager:updateByActivity(mainEndTime, actEndTime, chapterTargetConfig)
	local data = self.data
	data.mainEndTime = mainEndTime
	data.actEndTime = actEndTime

	self:writeToLocal()
end

function PublicServiceManager:getActivityIcon()
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
end

function PublicServiceManager:updateActIconRewardFlag()
	local ret = table.find(ActivityUtil:getActivitys() or {},function(v)
		return v.source == ACT_SOURCE
	end)
	if ret then 
		ActivityUtil:setRewardMark(ACT_SOURCE, true)
	end
end

function PublicServiceManager:loadSkeletonAssert()
	FrameLoader:loadArmature('tempFunctionRes/PublicService/skeleton/public_service', 'public_service', 'public_service')
end

function PublicServiceManager:unloadSkeletonAssert()
    ArmatureFactory:remove('public_service', 'public_service')
end

function PublicServiceManager:addTotalTargetCount( count )
	local config = self.data.chapterTargetConfig

	printx(10, count, self.data.totalTargetCount)
	printx(10, table.tostring(config))

	self.data.totalTargetCount = self.data.totalTargetCount + count

	local chapterIndex = self.data.chapterIndex

	if config[chapterIndex] and config[chapterIndex] <= self.data.totalTargetCount then
		self:updateActIconRewardFlag()
	end

	self:writeToLocal()
end

function PublicServiceManager:getProgressShowNum()
	local curNum = self.data.totalTargetCount
	local config = self.data.chapterTargetConfig
	local totalNum = config[#config]

	for index=#config,1,-1 do
		local tarNum = config[index]
		if curNum <= tarNum then
			totalNum = tarNum
		end
	end

	return curNum, totalNum
end

function PublicServiceManager:updateData(totalTargetCount, chapterIndex)
	self.data.totalTargetCount = totalTargetCount
	self.data.chapterIndex = chapterIndex
	self:writeToLocal()
end

Notify:register("PublicServiceInitEvent", PublicServiceManager.init, PublicServiceManager)