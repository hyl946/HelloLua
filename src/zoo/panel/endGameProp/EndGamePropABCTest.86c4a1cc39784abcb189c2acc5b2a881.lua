--=====================================================
-- filename:  EndGamePropABCTest.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/10/10
-- descrip:   最终加五步面板IOS新版abc test 文档http://wiki.happyelements.net/pages/viewpage.action?pageId=21347883
-- descrip2:  ios测试结束~新版是android测试
--=====================================================
EndGamePropABCTest = class()
local instance = nil

EndGameUserGrop = table.const{
	kGroup1 = "kGroup1",
	kGroup2 = "kGroup2",
	kGroup3 = "kGroup3",
}

function EndGamePropABCTest.getInstance()
	if not instance then
		instance = EndGamePropABCTest.new()
		instance:init()
	end
	return instance
end

function EndGamePropABCTest:init()
	local uid = UserManager.getInstance().user.uid or "00"
	self.uidGroup = tonumber(string.sub(tostring(uid), -2)) or 0

	if __ANDROID then 
		if self.uidGroup >= 0 and self.uidGroup < 50 then
			self.userGroup = EndGameUserGrop.kGroup1 
		elseif self.uidGroup >= 50 and self.uidGroup < 100 then
			if UserManager:getInstance().userExtend.payUser then
				self.userGroup = EndGameUserGrop.kGroup2 
			else
				self.userGroup = EndGameUserGrop.kGroup3
			end 
		end	
	else
		self.userGroup = EndGameUserGrop.kGroup1 
	end
end

function EndGamePropABCTest:getFuuuShow(lastIsFuuu)
	if __ANDROID then 
		if self.uidGroup >= 0 and self.uidGroup < 12 or 
			self.uidGroup >= 50 and self.uidGroup < 62 then 
			if lastIsFuuu then 
				return true
			else
				return false
			end
		elseif self.uidGroup >= 12 and self.uidGroup < 24 or 
			self.uidGroup >= 62 and self.uidGroup < 74 then
			return false
		elseif self.uidGroup >= 24 and self.uidGroup < 37 or 
			self.uidGroup >= 74 and self.uidGroup < 87 then
			return true
		elseif self.uidGroup >= 37 and self.uidGroup < 50 or 
			self.uidGroup >= 87 and self.uidGroup < 100 then
			return false
		end
	else
		if self.uidGroup >= 50 then 
			return true
		else
			if lastIsFuuu then 
				return true
			else
				return false
			end
		end
	end
end

function EndGamePropABCTest:getUserGroup()
	return self.userGroup
end

function EndGamePropABCTest:setBecomePayUser(isPayUser)
	if isPayUser then 
		if self.userGroup == EndGameUserGrop.kGroup3 then 
			self.userGroup = EndGameUserGrop.kGroup2
		end
	end
end

function EndGamePropABCTest:dcLog(actType, levelId, source, propId, isFuuu)
	if not __ANDROID then return end

	if propId ~= ItemType.ADD_FIVE_STEP or propId ~= ItemType.ADD_BOMB_FIVE_STEP then return end
	-- if not MaintenanceManager:getInstance():isEnabled("IosFuuuAdd5Step") then return end
	
	local topLevel = UserManager.getInstance()
	local lastFuuuLogID = FUUUManager:getLastGameFuuuID()
	local target = nil

	if self:getFuuuShow(isFuuu) then 
		target = 1
	else
		target = 0
	end

	local userExtend = UserManager.getInstance().userExtend
	local payUser = 0
	if userExtend.payUser then 
		payUser = 1
	end

	local popType = AddFiveStepABCTestLogic.testType

	printx( 1 , "   EndGamePropABCTest:dcLog   actType = " .. tostring(actType) 
		.. "   levelId = " .. tostring(levelId) 
		.. "   topLevel = " .. tostring(topLevel)
		.. "   source = " .. tostring(source)
		.. "   payUser = " .. tostring(payUser) 
		.. "   lastFuuuLogID = " .. tostring(lastFuuuLogID)
		.. "   target = " .. tostring(target))

	DcUtil:logIosAddFiveStepsTest(actType, levelId, topLevel, source, payUser, lastFuuuLogID, target, popType)
end

