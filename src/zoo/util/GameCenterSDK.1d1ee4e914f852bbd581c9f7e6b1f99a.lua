require "zoo.util.GameCenterManagerDelegateSDK"

kGameCenterLeaderboards = {all_star_leaderboard = "all_star_leaderboard"}
local instance = nil
GameCenterSDK = {sdk=nil}
function GameCenterSDK:getInstance()
	if not instance then
		instance = GameCenterSDK
		if __IOS then			
			if GameCenterManager:isGameCenterAvailable() then
				local sdk = GameCenterManager:init()
				sdk:setDelegate(GameCenterManagerDelegateSDK:init())		
				instance.sdk = sdk
			end
		end
		
	end
	return instance
end

function GameCenterSDK:isGameCenterAvailable()
	if __IOS then return GameCenterManager:isGameCenterAvailable()
	else return false end
end

function GameCenterSDK:authenticateLocalUser(forceLogin)
	if __IOS and self.sdk then 
		local config = Localhost:getDefaultConfig()
		if _G.isLocalDevelopMode then printx(0, "GameCenterManagerDelegateSDK authenticateLocalUser", config.gc) end
		if config.gc == 1 or forceLogin then
			self.sdk:authenticateLocalUser() 
		end
	end
end

function GameCenterSDK:reportScore( score, category )
	if __IOS and self.sdk then self.sdk:reportScore_forCategory(score, category) end
end

function GameCenterSDK:submitAchievement( identifier, percentComplete )
	if __IOS and self.sdk then self.sdk:submitAchievement_percentComplete(identifier, percentComplete) end
end

function GameCenterSDK:resetAchievements()
	if __IOS and self.sdk then self.sdk:resetAchievements() end
end

function GameCenterSDK:getLocalUserName()
	local username = nil
	local deviceName = MetaInfo:getInstance():getDeviceName()
	local random = 1000000 + math.floor(math.random() * 1000000)
	if __IOS then 
		if self.sdk then username = self.sdk:getLocalUserName() end
		if not username then username = deviceName end
	else
		if not username then username = deviceName .. tostring(random) end
	end
	if _G.isLocalDevelopMode then printx(0, "getLocalUserName:", username, deviceName) end
	if username ~= nil then
		username = string.gsub(username, "iPhone", "")
		username = string.gsub(username, "iPad", "")
		username = string.gsub(username, "iPod", "")
		username = string.gsub(username, "'s", "")
	end
	return username
end