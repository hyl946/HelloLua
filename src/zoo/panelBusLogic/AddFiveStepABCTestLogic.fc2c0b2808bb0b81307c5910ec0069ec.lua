AddFiveStepABCTestLogic = {}

local platform = UserManager.getInstance().platform
local uid = UserManager.getInstance().uid
if not uid then
	uid = "12345"
end
local ABCTestFileKey = "ABCTestFileKey_" .. tostring(platform) .. "_u_".. tostring(uid) .. ".ds"

local TestType = {
	kNormal = "1",	
	kSlowcoach = "2",
	kCheater = "3",
}

local function conditionLimit()
	if __ANDROID then
		if PlatformConfig:isPlatform(PlatformNameEnum.kHE) or PlatformConfig:isPlatform(PlatformNameEnum.kTF) or
			PlatformConfig:isPlatform(PlatformNameEnum.kOppo) or PlatformConfig:isPlatform(PlatformNameEnum.kBBK) 
			or PlatformConfig:isPlatform(PlatformNameEnum.kHuaWei) then 
			return true
		end
	end
	return false
end

if conditionLimit() then 
	AddFiveStepABCTestLogic.testType = Localhost:readFromStorage(ABCTestFileKey)

	if not AddFiveStepABCTestLogic.testType then
		math.random(3) --注意，这一行是需要的，lua自带的随机方法的第一个参数返回是不准确的，取第二次返回才是正态分布
		AddFiveStepABCTestLogic.testType = tostring( math.random(3) )
		Localhost:writeToStorage( tostring(AddFiveStepABCTestLogic.testType) , ABCTestFileKey )
	end
end

AddFiveStepABCTestLogic.needBuy = false

function AddFiveStepABCTestLogic:dcLog(actType, levelId, source, propId)
	if conditionLimit() then
		local usermanager = UserManager.getInstance()
		local userExtend = usermanager.userExtend
		local lastFuuuLogID = FUUUManager:getLastGameFuuuID()
		printx( 1 , "   AddFiveStepABCTestLogic:dcLog   actType = " .. tostring(actType) 
			.. "   levelId = " .. tostring(levelId) 
			.. "   source = " .. tostring(source)
			.. "   testType = " .. tostring(self.testType)
			.. "   payUser = " .. tostring(userExtend.payUser) 
			.. "   lastFuuuLogID = " .. tostring(lastFuuuLogID))
		DcUtil:logAndroidAddFiveStepsTest(actType , levelId , source , self.testType , userExtend.payUser , propId , tostring(lastFuuuLogID))
	end
end

function AddFiveStepABCTestLogic:needShowCountdown()
	return false
end

function AddFiveStepABCTestLogic:needAutoClosePanel()
	if __ANDROID then 
		return false
		--[[
		if self.needBuy then
			if conditionLimit() then 
				printx( 1 , "   AddFiveStepABCTestLogic:needAutoClosePanel   testType = " .. tostring(self.testType) )
				if self.testType == TestType.kNormal then
					return true
				else
					return false
				end
			else
				return false
			end
		else
			return false 
		end
		]]
	else
		return false
	end
end

function AddFiveStepABCTestLogic:setPropNeedBuy(needBuy)
	self.needBuy = needBuy
end

function AddFiveStepABCTestLogic:setNeedShowCountdownByPrice(b)
	self.needShowCountdownByPrice = b
end