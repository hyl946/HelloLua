
CookieKey = {
	kUnlockHiddenArea = "unlockHiddenArea",
	kHiddenAreaIntroduction = "hiddenAreaIntro",
    kFishPromotionActivityStartTime = "fishPromotionActivityStartTime",
    kLocationProvince = "locationProvince",
    kHiddenAreaLastGuideTime = "hiddenAreaLastGuideTime",
    kHiddenAreaLastRewardGuideTime = "hiddenAreaLastRewardGuideTime",
    kHiddenAreaLastMaxBranchId = "hiddenAreaLastMaxBranchId",
    kHiddenAreaFirstMatchCondition = "hiddenAreaFirstMatchCondition",
    kHasPopoutNotificationGuide = "hasPopoutNotificationGuide",
    kIosNotificationGuide = "iosNotificationGuide",
    kMaxLevelNotificationGuide = "maxLevelNotificationGuide",
    kLastPopularityNum = "lastpopularityNum",
    kHasFruitLevel6ShowOff = "hasFruitLevel6ShowOff",
    kHasFruitUpgradeGuide = "hasFruitUpgradeGudie",
    kHasFriendRankingPanelDelQQFrdGuide = "hasFriendRankingPanelDelQQFrdGuide",
}

-----------------------------------------
-- Store local unnecessary data
-----------------------------------------
Cookie = class()

local instance = nil
local kLocalDataExt = ".ds"
local kStorageFileName = "local"

function Cookie:getInstance()
	if not instance then
		instance = Cookie.new()
		instance:init()
	end
	return instance
end

function Cookie:init()
	self.fields = {}

	local path = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. kLocalDataExt
	local file, err = io.open(path, "rb")

	if file and not err then
		local content = file:read("*a")
		io.close(file)

        local fields = nil
        local function decodeContent()
            fields = amf3.decode(content)
        end
        pcall(decodeContent)

		if fields then
			self.fields = fields
		end
	else
	    -- he_log_error("persistent file failure " .. kStorageFileName .. ", error: " .. err)
	end
end

function Cookie:read(key)
	return self.fields[key]
end

function Cookie:write(key, value)
	self.fields[key] = value

    local content = amf3.encode(self.fields)

	local filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. kLocalDataExt
    local file, err = io.open(filePath, "wb")

    if file and not err then
		local success = file:write(content)
	   
	    if success then
	        file:flush()
	        file:close()
	    else
	        file:close()
	        if _G.isLocalDevelopMode then printx(0, "write file failure " .. filePath) end
	    end        
	else
	    he_log_error("persistent file failure " .. kStorageFileName .. ", error: " .. err)
	end
end